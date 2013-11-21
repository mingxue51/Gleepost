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
#import "GLPConversationParticipantsDao.h"
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
            //Find paricipants.
            for(GLPConversation* conv in conversations)
            {
                NSArray* part = [GLPConversationParticipantsDao participants:conv.key];
                conv.participants = part;
            }
            
            // hide loading cell and add refresh control
            self.loadingCellStatus = kGLPLoadingCellStatusFinished;
            [self createRefreshIfNeed];
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            
            [self showConversations:conversations];
        }
    } remoteCallback:^(BOOL success, NSArray *conversations) {
        if(success) {
            //Find paricipants.
            for(GLPConversation* conv in conversations)
            {
                NSArray* part = [GLPConversationParticipantsDao participants:conv.key];
                conv.participants = part;
            }
            
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
    
    for(GLPConversation* conv in localConversations)
    {
        NSArray* part = [GLPConversationParticipantsDao participants:conv.key];
        conv.participants = part;
    }
    
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
    
    static NSString *CellIdentifier = @"Cell";
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    GLPConversation *conversation = self.conversations[indexPath.row];
    
    if(conversation.isGroup)
    {
        cell.userImage.image = [UIImage imageNamed:@"default_group_image"];
        cell.userName.text = @"Group Chat";
    }
    else
    {
        //todo: dont do this
        GLPUser *opponentUser = [conversation.participants objectAtIndex:0];
        
        if(opponentUser.profileImageUrl == nil || [opponentUser.profileImageUrl isEqualToString:@""])
        {
            cell.userImage.image = [UIImage imageNamed:@"default_user_image"];
        }
        else
        {
            [cell.userImage setImageWithURL:[NSURL URLWithString:opponentUser.profileImageUrl] placeholderImage:nil];
        }
        
        [ShapeFormatterHelper setRoundedView:cell.userImage toDiameter:cell.userImage.frame.size.height];
        
        cell.userName.text = conversation.title;

        
        //TODO: Add the opponent's image.
        //Find the logged in user and add the opponents image.
    }
    
    cell.content.text = (conversation.lastMessage) ? conversation.lastMessage : @"";
//    cell.userImage.image = [UIImage imageNamed:@"avatar_big"];
    
    //    [self.postImage setImageWithURL:url placeholderImage:[UIImage imageNamed:nil]];

   // cell.userImage.image = conve
    
    NSDate *currentDate = conversation.lastUpdate;
    
//    NSLog(@"CONVERSATION USER DETAILS: %@", [ConversationManager userWithConversationId:conversation.key]);
//    
//    NSLog(@"User: %@ Last Message: %@",conversation.title, conversation.lastMessage);
    
    cell.time.text = [currentDate timeAgo];
    
    if(conversation.hasUnreadMessages) {
        cell.unreadImageView.hidden = NO;
    } else {
        cell.unreadImageView.hidden = YES;
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
    if([segue.identifier isEqualToString:@"view topic"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        ViewTopicViewController *vc = segue.destinationViewController;
        vc.randomChat = NO;
        vc.conversation = self.selectedConversation;
        
        //Fetch the participants.
        [ConversationManager usersWithConversationId:self.selectedConversation.key callback:^(BOOL success, NSArray *participants) {
           
            NSLog(@"Participants id: %@", participants);
            vc.participants = participants;
            
        }];
        
        //vc.patricipants = [[NSArray alloc] initWithObjects:<#(id), ...#>, nil];
        
        //self.selectedConversation = nil;

    }
    
}

@end
