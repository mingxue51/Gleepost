//
//  MessagesViewController.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "MessagesViewController.h"
#import "GLPConversationViewController.h"
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
#import "GLPLoadMoreCell.h"
#import "GLPMessagesLoader.h"

// debug
#include <stdlib.h>
#include "RemoteParser.h"
#import "GLPNotification.h"
#import "GLPNotificationManager.h"


#define CELL_THEME_COLOR [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1.0]

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

// debug
@property (assign, nonatomic) NSInteger debugNotificationCount;


@end


@implementation MessagesViewController

@synthesize sections=_sections;
@synthesize regularConversations=_regularConversations;
@synthesize liveConversations=_liveConversations;

// debug
@synthesize debugNotificationCount=_debugNotificationCount;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self createNavigationBar];
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
    
    _liveConversations = [NSMutableArray array];
    _regularConversations = [NSMutableArray array];
    _sections = [[NSMutableArray alloc] initWithObjects:@"Random Chats", @"Messages", nil];
    
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
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    
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
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, nil]];
    
    [self.navigationController.navigationBar setShadowImage: [[UIImage alloc]init]];
    
    if(ENV_DEBUG) {
//        _debugNotificationCount = 0;
//        UIBarButtonItem *debug = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"Notif %d", _debugNotificationCount] style:UIBarButtonItemStyleBordered target:self action:@selector(debugNotification)];
//        self.navigationItem.rightBarButtonItem = debug;
        
        UIBarButtonItem *debug = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStyleBordered target:self action:@selector(debugSearch)];
        self.navigationItem.rightBarButtonItem = debug;
    }

    
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

- (NSArray *)sortedByDateOnArray:(NSArray *)array{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastUpdate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    return [array sortedArrayUsingDescriptors:sortDescriptors];
 }

- (void)reloadConversations
{
    
    [[GLPLiveConversationsManager sharedInstance] conversationsList:^(NSArray *liveConversations, NSArray *regularConversations) {
        self.loadingCellStatus = kGLPLoadingCellStatusFinished;
        _liveConversations = [NSMutableArray arrayWithArray:[self sortedByDateOnArray:liveConversations]];
        _regularConversations = [NSMutableArray arrayWithArray:[self sortedByDateOnArray:regularConversations]];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self.tableView reloadData];
    }];
}

- (void)reloadLiveConversations
{
    [[GLPLiveConversationsManager sharedInstance] conversationsList:^(NSArray *liveConversations, NSArray *regularConversations) {
        self.loadingCellStatus = kGLPLoadingCellStatusFinished;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _liveConversations = [NSMutableArray arrayWithArray:[self sortedByDateOnArray:liveConversations]];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

- (void)reloadRegularConversations
{
    [[GLPLiveConversationsManager sharedInstance] conversationsList:^(NSArray *liveConversations, NSArray *regularConversations) {
        self.loadingCellStatus = kGLPLoadingCellStatusFinished;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _regularConversations = [NSMutableArray arrayWithArray:[self sortedByDateOnArray:regularConversations]];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}


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
        self.loadingCellStatus = kGLPLoadingCellStatusLoading;
        [self reloadLiveConversations];
    } else {
                self.loadingCellStatus = kGLPLoadingCellStatusLoading;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.loadingCellStatus == kGLPLoadingCellStatusLoading) {
        return 1;
    }
    
    NSInteger count = section == 0 ? _liveConversations.count : _regularConversations.count;
    return count != 0 ? count : 1; // if no rows, then add 1 for the "no more" row
}

- (UITableViewCell *)cellWithMessage:(NSString *)message {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = message;
    cell.textLabel.font = [UIFont fontWithName:GLP_APP_FONT size:12.0f];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [UIColor grayColor];
    cell.userInteractionEnabled = NO;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.loadingCellStatus == kGLPLoadingCellStatusLoading) {
        return [GLPLoadMoreCell cell];
    }
    
    if (indexPath.section == 0 && indexPath.row == 0 && _liveConversations.count == 0) {
        
        return [self cellWithMessage:@"You have no more chats."];
        
    }else if (indexPath.section == 1 && indexPath.row == 0 && _regularConversations.count == 0){
        
        return [self cellWithMessage:@"You have no more messages."];
        
    }else {
        
        GLPConversation *conversation = indexPath.section == 0 ? _liveConversations[indexPath.row] : _regularConversations[indexPath.row];
        
        MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        //cell.conversation = conversation;
        cell.userName.text = conversation.title;
        cell.userName.font = [UIFont fontWithName:GLP_TITLE_FONT size:14.0f];
        
        cell.content.text = [conversation getLastMessageOrDefault];
        cell.content.textColor = [UIColor grayColor];
        cell.content.font = [UIFont fontWithName:GLP_MESSAGE_FONT size:12.0f];
        cell.content.numberOfLines = 2;
        
        
        cell.time.text = [conversation getLastUpdateOrDefault];
        cell.time.textColor = [UIColor grayColor];
        cell.time.font = [UIFont fontWithName:GLP_APP_FONT size:12.0f];
        
        cell.unreadImageView.hidden = !conversation.hasUnreadMessages;
        
        // add profile image
        [cell.userImage configureWithConversation:conversation];
        return cell;


    }
    
    return nil;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    self.selectedConversation = (indexPath.section == 0) ? _liveConversations[indexPath.row] : _regularConversations[indexPath.row];
    
    [self performSegueWithIdentifier:@"view topic" sender:self];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.loadingCellStatus == kGLPLoadingCellStatusLoading) {
        return [GLPLoadMoreCell height];
    }else
    
    //return 60.0f;
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    [headerView setBackgroundColor:CELL_THEME_COLOR];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width - 10, 20)];
    label.text = _sections[section];
    label.font = [UIFont fontWithName:GLP_TITLE_FONT size:16.0f];
    label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label];
    return headerView;
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"view topic"]) {
        GLPConversationViewController *vc = segue.destinationViewController;
        vc.conversation = self.selectedConversation;
        vc.hidesBottomBarWhenPushed = YES;
    }
}


# pragma mark - Debug

- (void)debugSearch
{
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"GLPSearchUsersViewController"] animated:YES];
}

- (void)debugNotification
{
    if(_debugNotificationCount == 0) {
        [GLPNotificationManager clearAllNotifications];
        
        _debugNotificationCount++;
        [self.navigationItem.rightBarButtonItem setTitle:[NSString stringWithFormat:@"Notif %d", _debugNotificationCount]];
        return;
    }
    
    NSString *file = [NSString stringWithFormat:@"notification%d", _debugNotificationCount];
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"json"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    GLPNotification *not = [RemoteParser parseNotificationFromJson:[NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil]];
    
    NSLog(@"Send debug notification with remote key %d", not.remoteKey);
    
    BOOL delay = _debugNotificationCount == 4 ? YES : NO;
    
    [self performSelectorInBackground:@selector(debugPostNotification:) withObject:[NSArray arrayWithObjects:not, [NSNumber numberWithBool:delay ], nil]];
    
    _debugNotificationCount++;
    if(_debugNotificationCount > 5) {
        _debugNotificationCount = 0;
    }
    
    [self.navigationItem.rightBarButtonItem setTitle:[NSString stringWithFormat:@"Notif %d", _debugNotificationCount]];
}

- (void)debugPostNotification:(NSArray *)args
{
    GLPNotification *not = args[0];
    BOOL delay = [args[1] boolValue];
    
    if(delay) {
        [NSThread sleepForTimeInterval:5.0];
    }
    
    NSLog(@"Debug post notification");
    [GLPNotificationManager saveNotification:not];
}

@end