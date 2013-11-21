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
#import "UIViewController+Flurry.h"

@interface MessagesViewController ()

@property (strong, nonatomic) NSMutableArray *conversations;
@property (strong, nonatomic) GLPConversation *selectedConversation;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (assign, nonatomic) BOOL needsReloadConversations;

@property (strong, nonatomic) UIView *loadingView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (assign, nonatomic) BOOL isFullScreenLoading;

@end

@implementation MessagesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    [self createNavigationBar];
    [self createRefresh];
    [self createFullScreenLoading];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    self.needsReloadConversations = NO;
    [self loadConversations];
    
    //[AppearanceHelper setNavigationBarBlurBackgroundFor:self WithImage:@"navigationbar2"];
    [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar2" forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTranslucent:YES];


}

- (void)viewWillAppear:(BOOL)animated
{
    if(self.needsReloadConversations)
    {
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
    [self sendViewToFlurry:NSStringFromClass([self class])];
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


    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)createRefresh
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadConversations) forControlEvents:UIControlEventValueChanged];
}

- (void)createFullScreenLoading
{
    self.loadingView = [[UIView alloc] initWithFrame:self.tableView.frame];
    self.loadingView.backgroundColor = [UIColor whiteColor];
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    self.activityIndicatorView.center = self.loadingView.center;
    [self.loadingView addSubview:self.activityIndicatorView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.loadingView.center.y + self.activityIndicatorView.frame.size.height - 10, self.loadingView.frame.size.width, 40)];
    label.text = @"Loading conversations";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor grayColor];
    [self.loadingView addSubview:label];
    
    self.isFullScreenLoading = NO;
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
            
            [self showConversations:conversations];
            
        }
    } remoteCallback:^(BOOL success, NSArray *conversations) {
        [self stopLoading];
    
        //Find paricipants.
        for(GLPConversation* conv in conversations)
        {
            NSArray* part = [GLPConversationParticipantsDao participants:conv.key];
            conv.participants = part;
        }
        
        if(success) {
            [self showConversations: conversations];
        } else {
            [WebClientHelper showStandardError];
        }
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
    return self.conversations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    self.selectedConversation = self.conversations[indexPath.row];
    [self performSegueWithIdentifier:@"view topic" sender:self];
}


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
