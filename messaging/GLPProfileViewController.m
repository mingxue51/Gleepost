//
//  GLPProfileViewController.m
//  Gleepost
//
//  Created by Silouanos on 10/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPProfileViewController.h"
#import "GLPUser.h"
#import "SessionManager.h"
#import "GLPPostManager.h"
#import "WebClientHelper.h"
#import "PostCell.h"
#import "ProfileTwoButtonsTableViewCell.h"
#import "ProfileTableViewCell.h"
#import "ProfileSettingsTableViewCell.h"
#import "AppearanceHelper.h"
#import "PopUpNotificationsViewController.h"
#import "TransitionDelegateViewNotifications.h"
#import "GLPPrivateProfileViewController.h"
#import "LoginRegisterViewController.h"
#import "ViewPostViewController.h"
#import "NotificationsView.h"
#import "GLPNotificationManager.h"

@interface GLPProfileViewController ()

@property (strong, nonatomic) GLPUser *user;

@property (assign, nonatomic) int numberOfRows;

@property (strong, nonatomic) NSArray *posts;

@property (assign, nonatomic) GLPSelectedTab selectedTabStatus;

@property (assign, nonatomic) BOOL fromCampusWall;

@property (strong, nonatomic) TransitionDelegateViewNotifications *transitionViewNotificationsController;

@property (strong, nonatomic) NotificationsView *notificationView;

@property (assign, nonatomic) int unreadNotificationsCount;

@end

@implementation GLPProfileViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerTableViewCells];
    
    [self initialiseObjects];
    
    [self configureNavigationBar];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.unreadNotificationsCount = [GLPNotificationManager getNotificationsCount];
    [self updateNotificationsBubble];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementNotificationsCount:) name:@"GLPNewNotifications" object:nil];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPNewNotifications" object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Configuration

-(void)addNavigationButtons
{
    UIImage *settingsIcon = [UIImage imageNamed:@"settings_icon"];
    
    UIButton *btnBack=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
    [btnBack setBackgroundImage:settingsIcon forState:UIControlStateNormal];
    [btnBack setFrame:CGRectMake(0, 0, 30, 30)];
    
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    
//    UIButton *notView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//    [notView setBackgroundImage: [UIImage imageNamed:@"bell"]forState:UIControlStateNormal];
//    [notView addTarget:self action:@selector(popUpNotifications:) forControlEvents:UIControlEventTouchUpInside];
    
    
//    UIBarButtonItem *bellButton = [[UIBarButtonItem alloc] initWithCustomView:notView];
    
    
    //Create the custom bell icon with notification dot.
    
    UIButton *bellBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [bellBtn addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
    [bellBtn setBackgroundImage:[UIImage imageNamed:@"bell"] forState:UIControlStateNormal];
    [bellBtn setFrame:CGRectMake(0, 0, 30, 30)];
    

    
    
    NSLog(@"BACK button: %d", self.navigationController.viewControllers.count);
    
    if(!self.fromCampusWall)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.notificationView];
        
        self.navigationItem.rightBarButtonItem = settingsButton;
    }
    else
    {
        //Add both buttons on the right.
        self.navigationItem.rightBarButtonItems = @[settingsButton, [[UIBarButtonItem alloc] initWithCustomView:self.notificationView]];
    }
    
}

-(void)configureNavigationBar
{
    
    [self addNavigationButtons];
    
    //Change the format of the navigation bar.
    [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:nil forBarMetrics:UIBarMetricsDefault];
    [AppearanceHelper setNavigationBarColour:self];
    
//    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, nil]];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [AppearanceHelper setNavigationBarFontFor:self];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    self.title = @"Profile";
}
-(void)initialiseObjects
{
    self.unreadNotificationsCount = 0;
    
    //Find out from which view controller this comes.
    if(self.navigationController.viewControllers.count == 1)
    {
        self.fromCampusWall = NO;
    }
    else
    {
        self.fromCampusWall = YES;
    }
    
    self.transitionViewNotificationsController = [[TransitionDelegateViewNotifications alloc] init];

    
    //Load user's details from server.
    [self setUserDetails];
    
    //self.transitionViewImageController = [[TransitionDelegateViewImage alloc] init];
    
    self.selectedTabStatus = kGLPPosts;
    
    self.posts = [[NSArray alloc] init];
    
    self.numberOfRows = 2;
}

-(void)registerTableViewCells
{
    //Register notifications' nib file.
    
    self.notificationView = [[[NSBundle mainBundle] loadNibNamed:@"NotificationsUIView" owner:self options:nil] objectAtIndex:0];
    
    [self.notificationView setDelegate:self];
    
    //Register nib files in table view.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileViewTableViewCell" bundle:nil] forCellReuseIdentifier:@"ProfileCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileViewTwoButtonsTableViewCell" bundle:nil] forCellReuseIdentifier:@"TwoButtonsCell"];
    
    //Register posts.
    [self.tableView registerNib:[UINib nibWithNibName:@"PostImageCellView" bundle:nil] forCellReuseIdentifier:@"ImageCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTextCellView" bundle:nil] forCellReuseIdentifier:@"TextCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileViewSettingsTableViewCell" bundle:nil] forCellReuseIdentifier:@"SettingsCell"];
}


-(void)setUserDetails
{
    self.user = [[SessionManager sharedInstance]user];
    
    [self loadPosts];
}


#pragma mark - UI methods

-(void)updateNotificationsBubble
{
    if(self.unreadNotificationsCount > 0)
    {
        [self.notificationView updateNotificationsWithNumber:self.unreadNotificationsCount];
    }
    else
    {
        [self.notificationView hideNotifications];
    }
}

#pragma mark - Selectors

-(void)popUpNotifications:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    PopUpNotificationsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"PopUpNotifications"];
    vc.view.backgroundColor =  self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    vc.delegate = self;
    vc.campusWallView = self.fromCampusWall;
    [vc setTransitioningDelegate:self.transitionViewNotificationsController];
    vc.modalPresentationStyle= UIModalPresentationCustom;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self presentViewController:vc animated:YES completion:nil];
}


-(void)incrementNotificationsCount:(NSNotification *)notification
{
    self.unreadNotificationsCount += [notification.userInfo[@"count"] intValue];
    [self updateNotificationsBubble];
}


-(void)logout:(id)sender
{
    
}



#pragma mark - Client

- (void)loadPosts
{
    [GLPPostManager loadRemotePostsForUserRemoteKey:self.user.remoteKey callback:^(BOOL success, NSArray *posts) {
        
        if(success)
        {
            self.posts = [posts mutableCopy];
            
            [self.tableView reloadData];
        }
        else
        {
            [WebClientHelper showStandardErrorWithTitle:@"Error loading posts" andContent:@"Please ensure that you are connected to the internet"];
        }
        
        
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if(self.selectedTabStatus == kGLPPosts)
    {
        return self.numberOfRows + self.posts.count;
    }
    else
    {
        return self.numberOfRows + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierWithImage = @"ImageCell";
    static NSString *CellIdentifierWithoutImage = @"TextCell";
    static NSString *CellIdentifierProfile = @"ProfileCell";
    static NSString *CellIdentifierTwoButtons = @"TwoButtonsCell";
    static NSString *CellIdentifierSettings = @"SettingsCell";
    
    
    PostCell *postViewCell;
    
    ProfileTwoButtonsTableViewCell *buttonsView;
    ProfileTableViewCell *profileView;
    ProfileSettingsTableViewCell *profileSettingsView;
    
    if(indexPath.row == 0)
    {
        profileView = [tableView dequeueReusableCellWithIdentifier:CellIdentifierProfile forIndexPath:indexPath];
        
        [profileView initialiseElementsWithUserDetails:self.user];
        profileView.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return profileView;
        
    }
    else if (indexPath.row == 1)
    {
        buttonsView = [tableView dequeueReusableCellWithIdentifier:CellIdentifierTwoButtons forIndexPath:indexPath];
        buttonsView.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [buttonsView setDelegate:self];
        
        return buttonsView;
    }
    else if (indexPath.row >= 2)
    {
        if(self.selectedTabStatus == kGLPSettings)
        {
            profileSettingsView = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSettings forIndexPath:indexPath];
            
            return profileSettingsView;
        }
        else if(self.selectedTabStatus == kGLPPosts)
        {
            if(self.posts.count != 0)
            {
                GLPPost *post = self.posts[indexPath.row-2];
                
                if([post imagePost])
                {
                    postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithImage forIndexPath:indexPath];
                }
                else
                {
                    postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithoutImage forIndexPath:indexPath];
                }
                
                //Set this class as delegate.
                //TODO: Fix that.
                //postViewCell.delegate = self;
                
                [postViewCell updateWithPostData:post withPostIndex:indexPath.row];
                
            }
            
            return postViewCell;
        }
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        return 245.0f;
    }
    else if(indexPath.row == 1)
    {
        return 50.0f;
    }
    else if(indexPath.row >= 2)
    {
        if(self.selectedTabStatus == kGLPSettings)
        {
            return 150.0f;
        }
        else if (self.selectedTabStatus == kGLPPosts)
        {
            GLPPost *currentPost = [self.posts objectAtIndex:indexPath.row-2];
            
            if([currentPost imagePost])
            {
                return 415.0f;
            }
            else
            {
                return 156.0f;
            }
        }
    }
    
    return 70.0f;
}

#pragma  mark - Buttons view methods

-(void)viewSectionWithId:(GLPSelectedTab) selectedTab
{
    self.selectedTabStatus = selectedTab;
    
    [self.tableView reloadData];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Modal View Controller");
    
    
    if([segue.identifier isEqualToString:@"view post"])
    {
        //Hide tabbar.
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
        ViewPostViewController *vc = segue.destinationViewController;
        vc.post = self.selectedPost;
        self.selectedPost = nil;
        
    }
    else if([segue.identifier isEqualToString:@"view private profile"])
    {
        //        NotificationsViewController *nv = segue.destinationViewController;
        //ProfileViewController *profileViewController = segue.destinationViewController;
        
        GLPPrivateProfileViewController *profileViewController = segue.destinationViewController;
        
//        GLPUser *incomingUser = [[GLPUser alloc] init];
//        
//        incomingUser.remoteKey = self.selectedUserId;
//        
//        if(self.selectedUserId == -1)
//        {
//            incomingUser = nil;
//        }
        
        profileViewController.selectedUserId = self.selectedUserId;
    }
    else if([segue.identifier isEqualToString:@"start"])
    {
        //Hide tabbar.
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
        LoginRegisterViewController *loginRegisterViewController = segue.destinationViewController;
        
        
    }
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
