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
#import "RemoteConversation+Additions.h"
#import "ConversationManager.h"
#import "MessageTableViewCell.h"

@interface MessagesViewController ()

@property (strong, nonatomic) NSMutableArray *conversations;
@property (strong, nonatomic) RemoteConversation *selectedConversation;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

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
    
    [self loadConversations];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) viewDidAppear:(BOOL)animated
{
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar2"] forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar2"] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];

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
    
//    [[WebClient sharedInstance] getConversationsWithCallbackBlock:^(BOOL success, NSArray *conversations) {
//        [hud hide:YES];
//        
//        if(success) {
//            self.conversations = [conversations mutableCopy];
//            [self.tableView reloadData];
//        } else {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading failed"
//                                                            message:@"Check your internet connection, dude."
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//            [alert show];
//        }
//    }];
}

- (void)showConversations:(NSArray *)conversations
{
    self.conversations = [conversations mutableCopy];
    [self.tableView reloadData];
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
    
    Conversation *conversation = self.conversations[indexPath.row];
    
    
    cell.userName.text = [NSString stringWithFormat:@"%@", [conversation getParticipantsNames]];
    cell.content.text = [NSString stringWithFormat:@"%@", conversation.mostRecentMessage.content];
    cell.userImage.image = [UIImage imageNamed:@"avatar_big"];
    cell.time.text = [NSString stringWithFormat:@"%@", conversation.mostRecentMessage.date.description];
    
   //cell.textLabel.text = [NSString stringWithFormat:@"Conversation with %@", [conversation getParticipantsNames]];
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"Last message: %@", conversation.lastMessage.content];
    
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
        vc.conversation = self.selectedConversation;
        self.selectedConversation = nil;

    }
    
}

@end
