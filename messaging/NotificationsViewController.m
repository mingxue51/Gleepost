//
//  NotificationsViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 15/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "NotificationsViewController.h"
#import "NotificationCell.h"
#import "GLPNotificationManager.h"

@interface NotificationsViewController ()

@property (assign, nonatomic) BOOL inLoading;
@property (assign, nonatomic) BOOL shouldReload;
@property (strong, nonatomic) NSMutableArray *notifications;

@end

@implementation NotificationsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Notifications";
    
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
    [self loadNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPNewNotifications" object:nil];
}

- (void)configTableView
{
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
    [cell updateWithNotification:notification];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"view post" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLPNotification *notification = self.notifications[indexPath.row];
    
    
    if(notification.notificationType == kGLPNotificationTypeAddedYou)
    {
        return 91;
    }
    else
    {
        return 80;
    }
    
//    return [NotificationCell getCellHeightForNotification:notification];
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
