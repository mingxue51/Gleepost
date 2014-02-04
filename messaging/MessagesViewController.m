//
//  MessagesViewController.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "MessagesViewController.h"
#import "ViewTopicViewController.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "ConversationManager.h"
#import "GLPLiveConversationsManager.h"
#import "MessageTableViewCell.h"
#import "AppearanceHelper.h"
#import "UIViewController+GAI.h"
#import "GLPLoadingCell.h"
#import "UIViewController+Flurry.h"
#import "GLPThemeManager.h"
#import "ImageFormatterHelper.h"

#import "GLPMessagesLoader.h"

@interface MessagesViewController ()

@property (strong, nonatomic) GLPConversation *selectedConversation;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) NSMutableArray *sections;
@property (strong, nonatomic) NSMutableArray *regularConversations;
@property (strong, nonatomic) NSMutableArray *liveConversations;

// reload conversations when user comes back from chat view, in order to update last message and last update
@property (assign, nonatomic) BOOL needsReloadConversations;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (assign, nonatomic) GLPLoadingCellStatus loadingCellStatus;
@property (strong, nonatomic) UITabBarItem *messagesTabbarItem;

@end


@implementation MessagesViewController

@synthesize sections=_sections;
@synthesize regularConversations=_regularConversations;
@synthesize liveConversations=_liveConversations;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createNavigationBar];
    
    [self configTabbar];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    [self.tableView registerNib:[UINib nibWithNibName:kGLPLoadingCellNibName bundle:nil] forCellReuseIdentifier:kGLPLoadingCellIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone; // start with no separator for loading cell
    
    [AppearanceHelper setNavigationBarColour:self];
    [AppearanceHelper setNavigationBarFontFor:self];

    // various control init
    self.loadingCellStatus = kGLPLoadingCellStatusLoading;
    self.needsReloadConversations = NO;
    
    _liveConversations = [NSArray array];
    _regularConversations = [NSArray array];
    _sections = [[NSMutableArray alloc] initWithObjects:@"Live chats", @"Contact chats", nil];
    
    [self reloadConversations];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conversationSyncFromNotification:) name:GLPNOTIFICATION_ONE_CONVERSATION_SYNC object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conversationsSyncFromNotification:) name:GLPNOTIFICATION_CONVERSATIONS_SYNC object:nil];
    
    //Change the colour of the tab bar.
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:75.0/255.0 green:208.0/255.0 blue:210.0/255.0 alpha:1.0];
    
    [AppearanceHelper setSelectedColourForTabbarItem:self.messagesTabbarItem withColour:[UIColor colorWithRed:75.0/255.0 green:208.0/255.0 blue:210.0/255.0 alpha:1.0]];
    
    if(self.needsReloadConversations) {
        [self reloadConversations];
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self sendViewToGAI:NSStringFromClass([self class])];
    [self sendViewToFlurry:NSStringFromClass([self class])];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // reload the local conversations next time the VC appears
    self.needsReloadConversations = YES;
    
    [super viewDidDisappear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CONVERSATIONS_SYNC object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_ONE_CONVERSATION_SYNC object:nil];
    
    [AppearanceHelper setUnselectedColourForTabbarItem:self.messagesTabbarItem];
    
    [super viewWillDisappear:animated];
}


-(void)configTabbar
{
    NSArray *items = self.tabBarController.tabBar.items;
    
    self.messagesTabbarItem = [items objectAtIndex:1];

}

#pragma mark - Init

- (void)createNavigationBar
{
    //Change the format of the navigation bar.
//    [self.navigationController.navigationBar setTranslucent:YES];
//    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
//    
//    
//    
//    //[self setBackgroundToNavigationBar];
//    
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    
//    UIColor *tabColour = [[GLPThemeManager sharedInstance] colorForTabBar];

    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, nil]];
    
    [self.navigationController.navigationBar setShadowImage: [[UIImage alloc]init]];

    
//    [self.navigationController.navigationBar setShadowImage:[ImageFormatterHelper generateOnePixelHeightImageWithColour:tabColour]];

    
//    self.navigationController.navigationBar.tintColor = tabColour;


    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

// Create the refresh control
// Should be called only when the loading cell is hidden because it does not make sense to have both
// And obviously do not create refresh control twice
- (void)createRefreshIfNeed
{
    if(self.refreshControl) {
        return;
    }
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadConversations) forControlEvents:UIControlEventValueChanged];
}


-(void)setBackgroundToNavigationBar
{
    UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.f, -20.f, 320.f, 65.f)];
    
    [bar setBackgroundColor:[UIColor clearColor]];
    [bar setBackgroundImage:[UIImage imageNamed:@"navigationbar_4"] forBarMetrics:UIBarMetricsDefault];
    [bar setTranslucent:YES];
    
    
    //Change the format of the navigation bar.
    [self.navigationController.navigationBar setTranslucent:YES];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar_trans"] forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController.navigationBar insertSubview:bar atIndex:1];
}


#pragma mark - Conversations

- (void)reloadConversations
{
    [[GLPLiveConversationsManager sharedInstance] conversationsList:^(NSArray *liveConversations, NSArray *regularConversations) {
        _liveConversations = [NSMutableArray arrayWithArray:liveConversations];
        _regularConversations = [NSMutableArray arrayWithArray:regularConversations];
        
        [self.tableView reloadData];
    }];
}

- (void)reloadLiveConversations
{
    [[GLPLiveConversationsManager sharedInstance] conversationsList:^(NSArray *liveConversations, NSArray *regularConversations) {
        _liveConversations = [NSMutableArray arrayWithArray:liveConversations];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

- (void)reloadRegularConversations
{
    [[GLPLiveConversationsManager sharedInstance] conversationsList:^(NSArray *liveConversations, NSArray *regularConversations) {
        _regularConversations = [NSMutableArray arrayWithArray:regularConversations];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}


//- (void)loadConversations
//{
//    [self startLoading];
//    
//    [ConversationManager loadConversationsWithLocalCallback:^(NSArray *conversations) {
//        if(conversations.count > 0) {
//            // hide loading cell and add refresh control
//            self.loadingCellStatus = kGLPLoadingCellStatusFinished;
//            [self createRefreshIfNeed];
//            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//            
//            [self showConversations:conversations];
//        }
//    } remoteCallback:^(BOOL success, NSArray *conversations) {
//        if(success) {
//            // hide loading cell and add refresh control
//            self.loadingCellStatus = kGLPLoadingCellStatusFinished;
//            [self createRefreshIfNeed];
//            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//            
//            [self showConversations: conversations];
//        } else {
//            // no local conversations
//            // show loading cell error and do not add refresh control
//            // because loading cell already provides a refresh button
//            if(self.conversations.count == 0) {
//                self.loadingCellStatus = kGLPLoadingCellStatusError;
//                [self.tableView reloadData];
//            }
//        }
//        
//        [self stopLoading];
//    }];
//}
//
//- (void)showConversations:(NSArray *)conversations
//{
//    self.conversations = [conversations mutableCopy];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
//}


#pragma mark - Notifications

- (void)newMessageFromNotification:(NSNotification *)notification
{
    GLPMessage *message = [notification userInfo][@"message"];
    
    if(message.conversation.isLive) {
        [self reloadLiveConversations];
    } else {
        [self reloadRegularConversations];
    }
}

// One conversation sync
- (void)conversationSyncFromNotification:(NSNotification *)notification
{
    NSInteger conversationRemoteKey = [[notification userInfo][@"remoteKey"] integerValue];
    DDLogInfo(@"Conversation sync notification for conversation with remote key: %d", conversationRemoteKey);
    
    GLPConversation *conversation = [[GLPLiveConversationsManager sharedInstance] findByRemoteKey:conversationRemoteKey];
    
    NSMutableArray *array = conversation.isLive ? _liveConversations : _regularConversations;
    NSUInteger index = [array indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if(((GLPConversation *)obj).remoteKey == conversation.remoteKey) {
            return YES;
        }
        
        return NO;
    }];
    
    if(index == NSNotFound) {
        DDLogError(@"Cannot find conversation in the local list, abort");
        return;
    }
    
    array[index] = conversation;
    
    if(conversation.isLive) {
        [self reloadLiveConversations];
    } else {
        [self reloadRegularConversations];
    }
    
    DDLogInfo(@"Conversation with remote key %d reloaded successfuly", conversation.remoteKey);
}

// Conversations list sync
- (void)conversationsSyncFromNotification:(NSNotification *)notification
{
    [self reloadConversations];
}


#pragma mark - Refresh

- (void)startLoading
{
    [self.refreshControl beginRefreshing];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)stopLoading
{
    [self.refreshControl endRefreshing];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index
{
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _sections[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? _liveConversations.count : _regularConversations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLPConversation *conversation = indexPath.section == 0 ? _liveConversations[indexPath.row] : _regularConversations[indexPath.row];
    
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.userName.text = conversation.title;
    cell.content.text = [conversation getLastMessageOrDefault];
    cell.time.text = [conversation getLastUpdateOrDefault];
    cell.unreadImageView.hidden = !conversation.hasUnreadMessages;
    
    // add profile image
    [cell.userImage configureWithConversation:conversation];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    self.selectedConversation = (indexPath.section == 0) ? _liveConversations[indexPath.row] : _regularConversations[indexPath.row];
    
    [self performSegueWithIdentifier:@"view topic" sender:self];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.loadingCellStatus != kGLPLoadingCellStatusFinished) {
        return kGLPLoadingCellHeight;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"view topic"]) {
        ViewTopicViewController *vc = segue.destinationViewController;
        vc.conversation = self.selectedConversation;
        vc.hidesBottomBarWhenPushed = YES;
    }
}

@end
