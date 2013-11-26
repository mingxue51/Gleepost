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
#import "NSDate+TimeAgo.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppearanceHelper.h"
#import "ShapeFormatterHelper.h"
#import "UIViewController+GAI.h"
#import "GLPLoadingCell.h"

@interface MessagesViewController ()

@property (strong, nonatomic) NSMutableArray *conversations;
@property (strong, nonatomic) GLPConversation *selectedConversation;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

// reload conversations when user comes back from chat view, in order to update last message and last update
@property (assign, nonatomic) BOOL needsReloadConversations;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (assign, nonatomic) GLPLoadingCellStatus loadingCellStatus;

@end

@implementation MessagesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createNavigationBar];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    [self.tableView registerNib:[UINib nibWithNibName:kGLPLoadingCellNibName bundle:nil] forCellReuseIdentifier:kGLPLoadingCellIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone; // start with no separator for loading cell
    
    [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar2" forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTranslucent:YES];

    // various control init
    self.loadingCellStatus = kGLPLoadingCellStatusLoading;
    self.needsReloadConversations = NO;
    
    [self loadConversations];
}

- (void)viewWillAppear:(BOOL)animated
{
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
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConversationsFromNotification:) name:@"GLPNewMessage" object:nil];
    
    [self sendViewToGAI:NSStringFromClass([self class])];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPNewMessage" object:nil];
    
    // reload the local conversations next time the VC appears
    self.needsReloadConversations = YES;
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
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];


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

- (void)showConversations:(NSArray *)conversations
{
    self.conversations = [conversations mutableCopy];
    [self.tableView reloadData];
}

- (void)reloadLocalConversations
{
    NSArray *localConversations = [ConversationManager getLocalConversations];
    [self showConversations:localConversations];
}


#pragma mark - Notifications

- (void)updateConversationsFromNotification:(NSNotification *)notification
{
    [self reloadLocalConversations];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // loading cell or conversations
    return (self.loadingCellStatus == kGLPLoadingCellStatusFinished) ? self.conversations.count : 1;
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
    
    GLPConversation *conversation = self.conversations[indexPath.row];
    
    cell.userName.text = conversation.title;
    cell.content.text = [conversation getLastMessageOrDefault];
    cell.time.text = [conversation getLastUpdateOrDefault];
    cell.unreadImageView.hidden = !conversation.hasUnreadMessages;
    
    // add profile image
    if(conversation.isGroup) {
        cell.userImage.image = [UIImage imageNamed:@"default_group_image"];
    } else {
        GLPUser *user = [conversation getUniqueParticipant];
        UIImage *defaultProfilePicture = [UIImage imageNamed:@"default_user_image"];
                            
        if([user hasProfilePicture]) {
            [cell.userImage setImageWithURL:[NSURL URLWithString:user.profileImageUrl] placeholderImage:defaultProfilePicture];
        } else {
            cell.userImage.image = defaultProfilePicture;
        }
        
        [ShapeFormatterHelper setRoundedView:cell.userImage toDiameter:cell.userImage.frame.size.height];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    self.selectedConversation = self.conversations[indexPath.row];
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
        vc.randomChat = NO;
        vc.conversation = self.selectedConversation;
    }
}

@end
