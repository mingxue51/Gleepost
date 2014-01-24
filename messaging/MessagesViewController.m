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
#import "MessageTableViewCell.h"
#import "AppearanceHelper.h"
#import "UIViewController+GAI.h"
#import "GLPLoadingCell.h"
#import "UIViewController+Flurry.h"
#import "GLPThemeManager.h"
#import "ImageFormatterHelper.h"
#import "GLPLiveConversationsManager.h"
#import "GLPMessagesLoader.h"

@interface MessagesViewController ()

@property (strong, nonatomic) GLPConversation *selectedConversation;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) NSMutableArray *sections;
@property (strong, nonatomic) NSMutableArray *conversations;
@property (strong, nonatomic) NSArray *liveConversations;

// reload conversations when user comes back from chat view, in order to update last message and last update
@property (assign, nonatomic) BOOL needsReloadConversations;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (assign, nonatomic) GLPLoadingCellStatus loadingCellStatus;
@property (strong, nonatomic) UITabBarItem *messagesTabbarItem;

@end


@implementation MessagesViewController

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
    
    //[AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar2" forBarMetrics:UIBarMetricsDefault];
    
    //[AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar8" forBarMetrics:UIBarMetricsDefault];
    
    [AppearanceHelper setNavigationBarColour:self];
    [AppearanceHelper setNavigationBarFontFor:self];

    
    //[AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"chat_background_default" forBarMetrics:UIBarMetricsDefault];
    //[self.navigationController.navigationBar setTranslucent:YES];

    // various control init
    self.loadingCellStatus = kGLPLoadingCellStatusLoading;
    self.needsReloadConversations = NO;
    
    self.sections = [[NSMutableArray alloc] initWithObjects:@"Live chats", @"Contact chats", nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Change the colour of the tab bar.
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:75.0/255.0 green:208.0/255.0 blue:210.0/255.0 alpha:1.0];
    
    [AppearanceHelper setSelectedColourForTabbarItem:self.messagesTabbarItem withColour:[UIColor colorWithRed:75.0/255.0 green:208.0/255.0 blue:210.0/255.0 alpha:1.0]];
    
    if(self.needsReloadConversations) {
        [self reloadLocalConversations];
    }
    
    [self loadLiveConversations];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConversationsFromNotification:) name:GLPNOTIFICATION_NEW_MESSAGE object:nil];
    
    [self sendViewToGAI:NSStringFromClass([self class])];
    [self sendViewToFlurry:NSStringFromClass([self class])];
    
    
    [self loadConversations];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_NEW_MESSAGE object:nil];

    // reload the local conversations next time the VC appears
    self.needsReloadConversations = YES;
    
    [super viewDidDisappear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
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
    
    UIColor *tabColour = [[GLPThemeManager sharedInstance] colorForTabBar];

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


-(void) setBackgroundToNavigationBar
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

- (void)loadConversations
{
    [self startLoading];
    
    [ConversationManager loadConversationsWithLocalCallback:^(NSArray *conversations) {
        if(conversations.count > 0) {
            // hide loading cell and add refresh control
            self.loadingCellStatus = kGLPLoadingCellStatusFinished;
            [self createRefreshIfNeed];
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            
            [self showConversations:conversations];
        }
    } remoteCallback:^(BOOL success, NSArray *conversations) {
        if(success) {
            // hide loading cell and add refresh control
            self.loadingCellStatus = kGLPLoadingCellStatusFinished;
            [self createRefreshIfNeed];
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            
            [self showConversations: conversations];
        } else {
            // no local conversations
            // show loading cell error and do not add refresh control
            // because loading cell already provides a refresh button
            if(self.conversations.count == 0) {
                self.loadingCellStatus = kGLPLoadingCellStatusError;
                [self.tableView reloadData];
            }
        }
        
        [self stopLoading];
    }];
}

- (void)loadLiveConversations
{
    _liveConversations = [[GLPLiveConversationsManager sharedInstance] conversations];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

//-(void)showReadyConversations:(NSArray*)conversations
//{
//    // hide loading cell and add refresh control
//    self.loadingCellStatus = kGLPLoadingCellStatusFinished;
//    [self createRefreshIfNeed];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//    
//    //ADDED NEW APPROACH.
//    [self.categorisedConversations setObject:[conversations mutableCopy] forKey:[NSNumber numberWithInt:1]];
//    
//    NSLog(@"Categorised Conversations: %@",self.categorisedConversations);
//    
//    [self showConversations:conversations];
//}

- (void)showConversations:(NSArray *)conversations
{
    self.conversations = [conversations mutableCopy];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)reloadLocalConversations
{
    NSArray *localConversations = [ConversationManager getLocalNormalConversations];
    [self showConversations:localConversations];
}


#pragma mark - Notifications

- (void)updateConversationsFromNotification:(NSNotification *)notification
{
    GLPMessage *message = [notification userInfo][@"message"];
    if(message.conversation.isLive) {
        [self loadLiveConversations];
    } else {
        [self reloadLocalConversations];
    }
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
    return  self.sections.count;
}

/**
 NEW APPROACH ADDED METHODS.
 */
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index
{
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sections objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) {
        return [[GLPLiveConversationsManager sharedInstance] conversationsCount];
    }
    
    // loading cell or conversations
    return (self.loadingCellStatus == kGLPLoadingCellStatusFinished) ? self.conversations.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLPConversation *conversation;
    
    if(indexPath.section == 0) {
        conversation = _liveConversations[indexPath.row];
        DDLogInfo(@"live conv with user %@", conversation.title);
    } else {
        // loading cell in loading or error states
        if(self.loadingCellStatus != kGLPLoadingCellStatusFinished) {
            GLPLoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:kGLPLoadingCellIdentifier forIndexPath:indexPath];
            cell.delegate = self;
            [cell.loadMoreButton setTitle:@"Tap to load conversations" forState:UIControlStateNormal];
            [cell updateWithStatus:self.loadingCellStatus];
            return cell;
        }
        
        conversation = self.conversations[indexPath.row];
    }
    
    
    
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

    self.selectedConversation = (indexPath.section == 0) ? _liveConversations[indexPath.row] : self.conversations[indexPath.row];
    
    [self performSegueWithIdentifier:@"view topic" sender:self];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.loadingCellStatus != kGLPLoadingCellStatusFinished) {
        return kGLPLoadingCellHeight;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES - we will be able to delete all rows
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Perform the real delete action here. Note: you may need to check editing style
    //   if you do not perform delete only.
    NSLog(@"Deleted row.");
}


#pragma mark - Loading cell

- (void)loadingCellDidReload
{
    self.loadingCellStatus = kGLPLoadingCellStatusLoading;
    [self.tableView reloadData];
    [self loadConversations];
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"view topic"]) {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        ViewTopicViewController *vc = segue.destinationViewController;
        vc.conversation = self.selectedConversation;
    }
}

@end
