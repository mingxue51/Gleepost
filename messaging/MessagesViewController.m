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

@property (strong, nonatomic) NSMutableArray *conversations;
@property (strong, nonatomic) GLPConversation *selectedConversation;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

//New approach.
@property (strong, nonatomic) NSMutableArray *sections;
@property (strong, nonatomic) NSMutableDictionary *categorisedConversations;

@property (strong, nonatomic) NSMutableArray *liveConversations;

// reload conversations when user comes back from chat view, in order to update last message and last update
@property (assign, nonatomic) BOOL needsReloadConversations;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (assign, nonatomic) GLPLoadingCellStatus loadingCellStatus;

@property (strong, nonatomic) UITabBarItem *messagesTabbarItem;

@end

@implementation MessagesViewController

NSString *const LIVE_CHATS_STR = @"Live chats";
NSString *const CONTACTS_CHATS_STR = @"Contacts chats";


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
    
    //NEW APPROACH.
    self.categorisedConversations = [[NSMutableDictionary alloc] init];
    
    //Initialise two sections: Random Chats and Messages from Contacts.
    self.sections = [[NSMutableArray alloc] init];
    [self addSectionWithName:LIVE_CHATS_STR];
    

    
}

- (void)viewWillAppear:(BOOL)animated
{
    //Change the colour of the tab bar.
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:75.0/255.0 green:208.0/255.0 blue:210.0/255.0 alpha:1.0];
    
    [AppearanceHelper setSelectedColourForTabbarItem:self.messagesTabbarItem withColour:[UIColor colorWithRed:75.0/255.0 green:208.0/255.0 blue:210.0/255.0 alpha:1.0]];
    
    if(self.needsReloadConversations) {
        [self reloadLocalConversations];
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar2"] forBarMetrics:UIBarMetricsDefault];
    
//    UIImage *image = [UIImage imageNamed:@"navigationbar2"];
//    if(SYSTEM_VERSION_EQUAL_TO(@"7")) {
//        [self.navigationController.navigationBar setBackgroundImage:image forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
//    } else {
//        [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
//    }
    [self loadLiveConversations];
    
    [self showReadyConversations:[[GLPMessagesLoader sharedInstance]getConversations]];
    
    //[self loadConversations];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConversationsFromNotification:) name:@"GLPNewMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLiveConversations:) name:@"GLPPostUpdated" object:nil];


    
    [self sendViewToGAI:NSStringFromClass([self class])];
    [self sendViewToFlurry:NSStringFromClass([self class])];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPNewMessage" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPPostUpdated" object:nil];

    // reload the local conversations next time the VC appears
    self.needsReloadConversations = YES;
    
    

    
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
            
            //ADDED NEW APPROACH.
            [self.categorisedConversations setObject:[conversations mutableCopy] forKey:[NSNumber numberWithInt:1]];

            
            [self showConversations:conversations];
        }
    } remoteCallback:^(BOOL success, NSArray *conversations) {
        if(success) {
            // hide loading cell and add refresh control
            self.loadingCellStatus = kGLPLoadingCellStatusFinished;
            [self createRefreshIfNeed];
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            
            //ADDED NEW APPROACH.
            [self.categorisedConversations setObject:[conversations mutableCopy] forKey:[NSNumber numberWithInt:1]];
            
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

-(void)showReadyConversations:(NSArray*)conversations
{
    // hide loading cell and add refresh control
    self.loadingCellStatus = kGLPLoadingCellStatusFinished;
    [self createRefreshIfNeed];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    //ADDED NEW APPROACH.
    [self.categorisedConversations setObject:[conversations mutableCopy] forKey:[NSNumber numberWithInt:1]];
    
    NSLog(@"Categorised Conversations: %@",self.categorisedConversations);
    
    [self showConversations:conversations];
}

- (void)showConversations:(NSArray *)conversations
{
    self.conversations = [conversations mutableCopy];
    
    if(self.conversations.count != 0)
    {
        //Add new section.
        [self addSectionWithName:CONTACTS_CHATS_STR];
    }

    
    [self.tableView reloadData];
}

- (void)reloadLocalConversations
{
    NSArray *localConversations = [ConversationManager getLocalNormalConversations];
    [self showConversations:localConversations];
}

-(void)loadLiveConversations
{
    
    [ConversationManager loadLiveConversationsWithCallback:^(BOOL success, NSArray *conversations) {
        
        if(!success) {
            [WebClientHelper showStandardErrorWithTitle:@"Refreshing live chat failed" andContent:@"Cannot connect to the live chat, check your network status and retry later."];
            return;
        }
        
        if(conversations.count != 0)
        {
            //Add live chats' section in the section array.
//            [self addSectionWithName:LIVE_CHATS_STR];
            
//            [GLPLiveConversationsManager sharedInstance].conversations = [conversations mutableCopy];
            [self.categorisedConversations setObject:[conversations mutableCopy] forKey:[NSNumber numberWithInt:0]];
            [self.tableView reloadData];
        }
        

    }];
    
}

-(void)addSectionWithName:(NSString*)section
{
    for(NSString* s in self.sections)
    {
        if([section isEqualToString:s])
        {
            return;
        }
    }
    
    if([section isEqualToString:LIVE_CHATS_STR])
    {
        [self.sections setObject:section atIndexedSubscript:0];
//        [self.sections insertObject:section atIndex:0];
    }
    else
    {
        [self.sections addObject:section];
        //[self.sections insertObject:section atIndex:1];
    }
    
    NSLog(@"SECTIONS: %@",self.sections);
}

#pragma mark - Notifications

- (void)updateConversationsFromNotification:(NSNotification *)notification
{
    [self reloadLocalConversations];
}

-(void)updateLiveConversations:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    
    NSArray *array = [dict objectForKey:@"Conversations"];
    
    NSLog(@"LIVE CHATS ARRAY RECEIVED: %@",array);
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
    //return 1;
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
    // loading cell or conversations
    //return (self.loadingCellStatus == kGLPLoadingCellStatusFinished) ? self.conversations.count : 1;
    
    if(self.loadingCellStatus == kGLPLoadingCellStatusFinished)
    {
        if(section == 0)
        {
            //Change to number of live chats.
            return [[GLPLiveConversationsManager sharedInstance] conversationsCount];
        }
        else
        {
            return self.conversations.count;
        }
    }
    
    
    return 1;

    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // loading cell in loading or error states
    if(self.loadingCellStatus != kGLPLoadingCellStatusFinished) {
        GLPLoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:kGLPLoadingCellIdentifier forIndexPath:indexPath];
        cell.delegate = self;
        [cell.loadMoreButton setTitle:@"Tap to load conversations" forState:UIControlStateNormal];
        [cell updateWithStatus:self.loadingCellStatus];
        return cell;
    }
    
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    //NEW APPROACH.
    //Take the array of appropriate section.
    NSArray *conversations = [self.categorisedConversations objectForKey:[NSNumber numberWithInt:indexPath.section]];
    
    GLPConversation *conversation = [conversations objectAtIndex:indexPath.row];

    
    
//    GLPConversation *conversation = self.conversations[indexPath.row];
    
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

//    self.selectedConversation = self.conversations[indexPath.row];
    
    //NEW APPROACH.
    NSArray *conversations = [self.categorisedConversations objectForKey:[NSNumber numberWithInt:indexPath.section]];
    
    GLPConversation *conversation = [conversations objectAtIndex:indexPath.row];
    
    self.selectedConversation = conversation;
    
    [self performSegueWithIdentifier:@"view topic" sender:self];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.loadingCellStatus != kGLPLoadingCellStatusFinished) {
        return kGLPLoadingCellHeight;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
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
