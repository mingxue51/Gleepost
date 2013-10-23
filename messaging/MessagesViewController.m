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

@interface MessagesViewController ()

@property (strong, nonatomic) NSMutableArray *conversations;
@property (strong, nonatomic) GLPConversation *selectedConversation;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (assign, nonatomic) BOOL needsReloadConversations;

@end

@implementation MessagesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"MessagesViewController");
    //Change the format of the navigation bar.
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    //[self setBackgroundToNavigationBar];
    
    //Change navigations items' (back arrow, edit etc.) colour.
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    self.needsReloadConversations = NO;
    [self loadConversations];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) viewDidAppear:(BOOL)animated
{
    if(self.needsReloadConversations) {
        [self reloadLocalConversations];
    }
    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar2"] forBarMetrics:UIBarMetricsDefault];
    
    UIImage *image = [UIImage imageNamed:@"navigationbar2"];
    if(SYSTEM_VERSION_EQUAL_TO(@"7")) {
        [self.navigationController.navigationBar setBackgroundImage:image forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    } else {
        [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConversationsFromNotification:) name:@"GLPNewMessage" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPNewMessage" object:nil];
    
    // reload the local conversations next time the VC appears
    self.needsReloadConversations = YES;
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
    [WebClientHelper showStandardLoaderWithTitle:@"Loading new conversations" forView:self.view];
    [ConversationManager loadConversationsWithLocalCallback:^(NSArray *conversations) {
        [self showConversations:conversations];
    } remoteCallback:^(BOOL success, NSArray *conversations) {
        [WebClientHelper hideStandardLoaderForView:self.view];
        if(success) {
            [self showConversations:conversations];
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
    [self showConversations:localConversations];
}


#pragma mark - Notifications

- (void)updateConversationsFromNotification:(NSNotification *)notification
{
    
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
    
    if(conversation.participants.count > 2)
    {
        cell.userImage.image = [UIImage imageNamed:@"default_group_image"];
    }
    else
    {
        //TODO: Add the opponent's image.
        //Find the logged in user and add the opponents image.
        NSLog(@"Conversation Participants: %@",[conversation.participants objectAtIndex:0]);
        
        cell.userImage.image = [UIImage imageNamed:@"avatar_big"];
        NSLog(@"Conversation Author: %@", conversation.author.profileImageUrl);
    }
    
    cell.userName.text = conversation.title;
    cell.content.text = (conversation.lastMessage) ? conversation.lastMessage : @"";
//    cell.userImage.image = [UIImage imageNamed:@"avatar_big"];
    
    //    [self.postImage setImageWithURL:url placeholderImage:[UIImage imageNamed:nil]];

   // cell.userImage.image = conve
    cell.time.text = (conversation.lastUpdate) ? conversation.lastUpdate.description : @"";
    
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
        self.selectedConversation = nil;

    }
    
}

@end
