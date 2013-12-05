//
//  PopUpNotificationsViewController.m
//  Gleepost
//
//  Created by Silouanos on 04/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "PopUpNotificationsViewController.h"
#import "NotificationCell.h"
#import "GLPNotificationManager.h"
#import "ContactsManager.h"
#import "ProfileViewController.h"
#import "ViewPostViewController.h"
#import "GLPPostManager.h"
#import "WebClientHelper.h"

@interface PopUpNotificationsViewController ()

@property (assign, nonatomic) BOOL inLoading;
@property (assign, nonatomic) BOOL shouldReload;
@property (strong, nonatomic) NSMutableArray *notifications;
@property (assign, nonatomic) int selectedUserId;
@property (weak, nonatomic) GLPPost *selectedPost;

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation PopUpNotificationsViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // controls for not having two loading in parallel, and programming a reload if needed
    self.inLoading = NO;
    self.shouldReload = NO;
    
    self.notifications = [NSMutableArray array];
    
    [self configTableView];

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNotifications:) name:@"GLPNewNotifications" object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //self.inLoading = YES;
    
    if(self.notifications.count == 0)
    {
        [self loadNotifications];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPNewNotifications" object:nil];
}

- (void)configTableView
{
    //Set border to table view.
    self.tableView.layer.borderWidth = 0.5;
    self.tableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [self.tableView registerNib:[UINib nibWithNibName:kGLPNotificationCell bundle:nil] forCellReuseIdentifier:kGLPNotificationCell];
}

#pragma mark - Notifications

- (void)loadNotifications
{
    if(self.inLoading) {
        self.shouldReload = YES;
        NSLog(@"Load notifications already in loading, programming new reload");
        return;
    }
    
    self.inLoading = YES;
    
    [GLPNotificationManager loadNotificationsWithCallback:^(BOOL success, NSArray *notifications) {
        if(success && notifications.count > 0) {
            // add notifications
            [self addNewNotifications:notifications];
            
            // and mark them read
            [self markNotificationsRead];
        }
        
        self.inLoading = NO;
        
        // reload if asked
        //        if(self.shouldReload) {
        //            self.shouldReload = NO;
        //            [self loadNotifications];
        //        }
    }];
}

- (void)addNewNotifications:(NSArray *)notifications
{
    // just reload in case of empty table
    if(self.notifications.count == 0) {
        self.notifications = [notifications mutableCopy];
        [self.tableView reloadData];
        return;
    }
    
    // otherwise add at the top
    [self.notifications insertObjects:notifications atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, notifications.count)]];
    
    NSMutableArray *rowsInsertIndexPath = [[NSMutableArray alloc] init];
    for(int i = 0; i < notifications.count; i++) {
        [rowsInsertIndexPath addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    [self.tableView insertRowsAtIndexPaths:rowsInsertIndexPath withRowAnimation:UITableViewRowAnimationFade];
}

- (void)markNotificationsRead
{
    [GLPNotificationManager markNotificationsRead:self.notifications callback:^(BOOL success, NSArray *notifications) {
        
        NSLog(@"Notifications mark as read success: %d - new notifications: %d", success, notifications.count);
        
        if(success && notifications.count > 0) {
            // add new notifications
            [self addNewNotifications:notifications];
            
            // and restart the function to mark new notifications read as well
            //[self markNotificationsRead];
        }
    }];
}


- (void)reloadNotifications:(NSNotification *)notification
{
    NSLog(@"Reload notification received from background processor");
    [self loadNotifications];
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.notifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:kGLPNotificationCell forIndexPath:indexPath];
    
    
    GLPNotification *notification = self.notifications[indexPath.row];
    
    NSLog(@"Current notification: %@ Seen: %d",notification.notificationTypeDescription, notification.seen);
    
    
    [cell updateWithNotification:notification withViewController:self];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Depending on kind of notification navigate to the appropriate view.
    
    GLPNotification *currentNotification = self.notifications[indexPath.row];
    
    
    switch (currentNotification.notificationType)
    {
        case kGLPNotificationTypeAddedYou:
            
            break;
            
        case kGLPNotificationTypeAcceptedYou:
            self.selectedUserId = currentNotification.user.remoteKey;
            //Refresh contacts' data.
            [[ContactsManager sharedInstance] refreshContacts];
            [self navigateToViewWithName:@"view profile"];
            //[self performSegueWithIdentifier:@"view profile" sender:self];
            break;
            
        case kGLPNotificationTypeCommented:
            NSLog(@"Commented.");
            //View post (navigate to comment).
            
            break;
            
        case kGLPNotificationTypeLiked:
            NSLog(@"Liked.");
            //View post.
            
            break;
            
        default:
            break;
    }
    
    if(currentNotification.notificationType == kGLPNotificationTypeCommented || currentNotification.notificationType == kGLPNotificationTypeLiked)
    {
        [GLPPostManager loadPostWithRemoteKey:currentNotification.postRemoteKey callback:^(BOOL sucess, GLPPost *post) {
            
            
            if(sucess)
            {
                self.selectedPost = post;
                [self navigateToViewWithName:@"view post"];
                //[self performSegueWithIdentifier:@"view post" sender:self];
            }
            else
            {
                [WebClientHelper showStandardErrorWithTitle:@"Failed to load post" andContent:@"Check your internet connection and try again"];
            }
        }];
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLPNotification *notification = self.notifications[indexPath.row];
    
    //[notification alreadyContacts];
    
    if(notification.notificationType == kGLPNotificationTypeAddedYou)
    {
        return 91;
    }
    else
    {
        return 70;
    }
    
    //    return [NotificationCell getCellHeightForNotification:notification];
}
- (void)acceptContact:(id)sender
{
    UIButton *acceptButton = (UIButton*)sender;
    
    //Accept contact in the local database and in server.
    [[ContactsManager sharedInstance] acceptContact:acceptButton.tag callbackBlock:^(BOOL success) {
        
        if(success)
        {
            //Navigate to unlocked profile.
            
            NSLog(@"User with remote key %d accepted.", acceptButton.tag);
            self.selectedUserId = acceptButton.tag;
            
            //For now no need to refresh contacts.
            //            [[ContactsManager sharedInstance] refreshContacts];
            
            //Reload data to show the new cell.
            [self.tableView reloadData];
            
            [self navigateToViewWithName:@"view profile"];
            //[self performSegueWithIdentifier:@"view profile" sender:self];
            
        }
    }];
}

- (void)ignoreContact:(id)sender
{
    UIButton *ignoreButton = (UIButton*)sender;
    
    //TODO: Implement that when is implemented by the server side.
    NSLog(@"User with remote key %d ignored.", ignoreButton.tag);
    
}

-(void)changeTheCellToAlreadyContactsWithRemoteKey:(int)remoteKey
{
    
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

#pragma mark - Navigation

-(void)navigateToViewWithName:(NSString*)viewController
{
    if([viewController isEqualToString:@"view post"])
    {
        /**
         Forward data of the post the to the view. Or in future just forward the post id
         in order to fetch it from the server.
         */
        
        self.delegate.selectedPost = self.selectedPost;

    }
    else
    {
        self.delegate.selectedUserId = self.selectedUserId;
    }

    [self dismissViewControllerAnimated:NO completion:^{
    
        
        [self.delegate performSegueWithIdentifier:viewController sender:self.delegate];
        
        
    }];
}


- (IBAction)hideViewController:(id)sender
{
    [UIView animateWithDuration:0.25 animations:^{
        
        self.view.alpha = 0;
        
    } completion:^(BOOL b){
        
        //        self.view.alpha = 1;
        [self dismissViewControllerAnimated:NO completion:^{
        }];
    }];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
