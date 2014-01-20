//
//  GLPProfileViewController.m
//  Gleepost
//
//  Created by Silouanos on 10/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <MessageUI/MessageUI.h>
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
#import "GLPThemeManager.h"
#import "GLPLoginManager.h"
#import "WebClient.h"
#import "ImageFormatterHelper.h"
#import "GLPPostNotificationHelper.h"
#import "GLPPostImageLoader.h"
#import "GLPProfileLoader.h"
#import "GLPUserDao.h"
#import "GLPInvitationManager.h"

@interface GLPProfileViewController () <ProfileSettingsTableViewCellDelegate, MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) GLPUser *user;

@property (strong, nonatomic) UIImage *userImage;

@property (assign, nonatomic) int numberOfRows;

@property (strong, nonatomic) NSArray *posts;

@property (assign, nonatomic) GLPSelectedTab selectedTabStatus;

@property (assign, nonatomic) BOOL fromCampusWall;

@property (strong, nonatomic) TransitionDelegateViewNotifications *transitionViewNotificationsController;

@property (strong, nonatomic) FDTakeController *fdTakeController;

@property (strong, nonatomic) UIImage *uploadedImage;

@property (strong, nonatomic) NotificationsView *notificationView;

@property (assign, nonatomic) int unreadNotificationsCount;

@property (strong, nonatomic) NSString *profileImageUrl;

@property (strong, nonatomic) UITabBarItem *profileTabbarItem;

@property (strong, nonatomic) MFMessageComposeViewController *messageComposeViewController;

@property (assign, nonatomic) BOOL isBusy;

@end

@implementation GLPProfileViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if (self)
    {
        // Custom initialization
//        [self setNeedsStatusBarAppearanceUpdate];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerTableViewCells];
    
    [self initialiseObjects];
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;

//    [self configureNavigationBar];

    [self configTabbar];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureNavigationBar];

    //Change the colour of the tab bar.
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:75.0/255.0 green:208.0/255.0 blue:210.0/255.0 alpha:1.0];
    
    [AppearanceHelper setSelectedColourForTabbarItem:self.profileTabbarItem withColour:[UIColor colorWithRed:75.0/255.0 green:208.0/255.0 blue:210.0/255.0 alpha:1.0]];
    
    
    self.unreadNotificationsCount = [GLPNotificationManager getNotificationsCount];
    [self updateNotificationsBubble];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementNotificationsCount:) name:@"GLPNewNotifications" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRealImage:) name:@"GLPPostImageUploaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePost:) name:@"GLPPostUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLikedPost:) name:@"GLPLikedPostUdated" object:nil];

    
    [self.tableView reloadData];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPNewNotifications" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPPostImageUploaded" object:nil];
    
    [super viewWillDisappear:animated];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPPostUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPLikedPostUdated" object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Configuration

-(void)configTabbar
{
    NSArray *items = self.tabBarController.tabBar.items;
    
    self.profileTabbarItem = [items objectAtIndex:4];
}

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
    

    
    
//    NSLog(@"BACK button: %d", self.navigationController.viewControllers.count);
    
//    if(!self.fromCampusWall)
//    {
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.notificationView];
//        
//        self.navigationItem.rightBarButtonItem = settingsButton;
//    }
//    else
//    {
//        //Add both buttons on the right.
//        self.navigationItem.rightBarButtonItems = @[settingsButton, [[UIBarButtonItem alloc] initWithCustomView:self.notificationView]];
//    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.notificationView];
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
    
    self.title = @"Me";
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

    //Load busy status.
    [self getBusyStatus];
    
    //Load user's details from server.
    [self setUserDetails];
    
    
    
    //self.transitionViewImageController = [[TransitionDelegateViewImage alloc] init];
    
    self.selectedTabStatus = kGLPPosts;
    
    self.posts = [[NSArray alloc] init];
    
    self.numberOfRows = 2;
    
    self.fdTakeController = [[FDTakeController alloc] init];
    self.fdTakeController.viewControllerForPresentingImagePickerController = self;
    self.fdTakeController.delegate = self;

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
//    self.user = [[SessionManager sharedInstance]user];
    
    [self fetchUserData];
    
    //[self loadUserData];
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

-(void)updateRealImage:(NSNotification*)notification
{
    if([GLPPostNotificationHelper parsePostImageNotification:notification withPostsArray:self.posts])
    {
        //[self.tableView reloadData];
//        [self refreshFirstCell];
    }
    
}

-(void)updateViewWithNewImage:(NSString*)imageUrl
{
    [self loadUserData];
}

-(void)updatePost:(NSNotification*)notification
{

    int index = [GLPPostNotificationHelper parseNotification:notification withPostsArray:self.posts];
    
    if([GLPPostNotificationHelper parseNotification:notification withPostsArray:self.posts] != -1)
    {
        //Reload again only this post.
//        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(void)updateLikedPost:(NSNotification*)notification
{
    DDLogDebug(@"GLPProfileViewController : updateLikedPost %@", notification);

    int index = [GLPPostNotificationHelper parseLikedPostNotification:notification withPostsArray:self.posts];
    
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

#pragma mark - ProfileSettingsTableViewCellDelegate

-(void)logout:(id)sender
{
    //Pop up a bottom menu.
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Are you sure you want to logout?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Logout", nil];
    
    [actionSheet showInView:[self.view window]];
    
}

- (void)invite {
    [WebClientHelper showStandardLoaderWithTitle:@"Loading" forView:self.view];
    
    [[GLPInvitationManager sharedInstance] fetchInviteMessageWithCompletion:^(BOOL success, NSString *inviteMessage) {
        [WebClientHelper hideStandardLoaderForView:self.view];
        if (success) {
            [self showMessageViewControllerWithBody:inviteMessage];
        } else {
            [WebClientHelper showStandardError];
        }
    }];
}

#pragma mark - Action Sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [GLPLoginManager logout];
        [self.navigationController popViewControllerAnimated:YES];
        [self performSegueWithIdentifier:@"start" sender:self];
    }
    else
    {
        NSLog(@"Cancel");
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subview in actionSheet.subviews)
    {
        if ([subview isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton*)subview;
            
            if([btn.titleLabel.text isEqualToString:@"Cancel"])
            {
                //btn.titleLabel.textColor = [UIColor colorWithRed:75.0/255.0 green:204.0/255.0 blue:210.0/255.0 alpha:0.8];
                btn.titleLabel.textColor = [[GLPThemeManager sharedInstance]colorForTabBar];
            }
            else
            {
                btn.titleLabel.textColor = [UIColor lightGrayColor];
            }
        }
    }
}

#pragma mark - FDTakeController delegate

-(void)changeProfileImage:(id)sender
{
    [self.fdTakeController takePhotoOrChooseFromLibrary];
    
}

-(void)takeController:(FDTakeController *)controller didCancelAfterAttempting:(BOOL)madeAttempt
{
}

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)in
{
    self.uploadedImage = photo;
    
    //Set directly the new user's profile image.
    self.userImage = photo;
    
    
    //[self.profileView.profileImage setImage:photo];
    //[self.profileView updateImage:photo];
    
    //Communicate with server to change the image.
    [self uploadImageAndSetUserImageWithUserRemoteKey];
    
    [self loadPosts];
    
}

#pragma mark - Client

-(void)uploadImageAndSetUserImageWithUserRemoteKey
{
    UIImage* imageToUpload = [ImageFormatterHelper imageWithImage:self.uploadedImage scaledToHeight:320];
    
    NSData *imageData = UIImagePNGRepresentation(imageToUpload);
    
    NSLog(@"Image register image size: %d",imageData.length);
    
    
    //[WebClientHelper showStandardLoaderWithTitle:@"Uploading image" forView:self.view];
    
    
    [[WebClient sharedInstance] uploadImage:imageData ForUserRemoteKey:[[SessionManager sharedInstance]user].remoteKey callbackBlock:^(BOOL success, NSString* response) {
        
        //[WebClientHelper hideStandardLoaderForView:self.view];
        
        
        if(success)
        {
            NSLog(@"IMAGE UPLOADED. URL: %@",response);
            
            
            //Change profile image in Session Manager.
            //TODO: REFACTOR / FACTORIZE THIS
            GLPUser *user = [SessionManager sharedInstance].user;
            user.profileImageUrl = response;
            [GLPUserDao updateUserWithRemotKey:user.remoteKey andProfileImage:response];
            
            //Set image to user's profile.
            [self setImageToUserProfile:response];
            
            //            [[SessionManager sharedInstance]user].profileImageUrl = response;
            
            //TODO: This is wrong
            //[[SessionManager sharedInstance] updateUserWithUrl:response];
            
        }
        else
        {
            NSLog(@"ERROR");
            [WebClientHelper showStandardErrorWithTitle:@"Error uploading the image" andContent:@"Please check your connection and try again"];
            
        }
    }];
}

- (void)loadPosts
{
    [GLPPostManager loadRemotePostsForUserRemoteKey:self.user.remoteKey callback:^(BOOL success, NSArray *posts) {
        
        if(success)
        {
            self.posts = [posts mutableCopy];
            
            [[GLPPostImageLoader sharedInstance] addPostsImages:self.posts];
            
            [self.tableView reloadData];
        }
        else
        {
            [WebClientHelper showStandardErrorWithTitle:@"Error loading posts" andContent:@"Please ensure that you are connected to the internet"];
        }
        
        
    }];
}

-(void)setImageToUserProfile:(NSString*)url
{
    NSLog(@"READY TO ADD IMAGE TO USER WITH URL: %@",url);
    
    [[WebClient sharedInstance] uploadImageToProfileUser:url callbackBlock:^(BOOL success) {
        
        if(success)
        {
            NSLog(@"NEW PROFILE IMAGE UPLOADED");
            
            [self updateViewWithNewImage:url];

        }
        else
        {
            NSLog(@"ERROR: Not able to register image for profile.");
        }
    }];
}

-(void)loadUserData
{
    [[WebClient sharedInstance] getUserWithKey:[SessionManager sharedInstance].user.remoteKey callbackBlock:^(BOOL success, GLPUser *user) {
        
        if(success)
        {
            self.user = user;
            
            [self refreshFirstCell];
            
            [self loadPosts];
            
            //[self.tableView reloadData];
        }
        else
        {
            [WebClientHelper showStandardError];
        }
    }];
}

-(void)getBusyStatus
{
    [[WebClient sharedInstance] getBusyStatus:^(BOOL success, BOOL status) {
        
        if(success)
        {
            self.isBusy = status;
        }
    }];
}

/**
 Fetch user data from loader.
 */
-(void)fetchUserData
{
    NSArray *usersData = [[GLPProfileLoader sharedInstance] userData];
    
    if(!usersData)
    {
        [self loadUserData];
    }
    else
    {
        self.user = [usersData objectAtIndex:0];
        self.userImage = [usersData objectAtIndex:1];
//        [self.tableView reloadData];
        [self refreshFirstCell];
        
        [self loadPosts];
    }
    
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
        
        [profileView setDelegate:self];

        profileView.isBusy = self.isBusy;

//        [profileView updateImageWithUrl:self.profileImageUrl];
        if(_userImage)
        {
            [profileView initialiseElementsWithUserDetails:self.user withImage:self.userImage];
        }
        else
        {
            [profileView initialiseElementsWithUserDetails:self.user];
        }
        
        
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
            
            profileSettingsView.selectionStyle = UITableViewCellSelectionStyleNone;

            profileSettingsView.delegate = self;
            
            
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
                return IMAGE_CELL_HEIGHT;
            }
            else
            {
                return TEXT_CELL_HEIGHT;
            }
        }
    }
    
    return 70.0f;
}

#pragma mark - Table view refresh methods

-(void)refreshCellViewWithIndex:(const NSUInteger)index
{
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

-(void)refreshFirstCell
{
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

#pragma  mark - Buttons view methods

-(void)viewSectionWithId:(GLPSelectedTab) selectedTab
{
    self.selectedTabStatus = selectedTab;
    
    [self.tableView reloadData];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    
    
    if([segue.identifier isEqualToString:@"view post"])
    {
        //Hide tabbar.
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
        ViewPostViewController *vc = segue.destinationViewController;
        vc.post = self.selectedPost;
        vc.isViewPostNotifications = YES;
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

#pragma mark - Actions

- (void)showMessageViewControllerWithBody:(NSString *)messageBody {
    if (![MFMessageComposeViewController canSendText]) {
        [WebClientHelper showStandardErrorWithTitle:@"Error" andContent:@"Your device doesn't support SMS."];
        return;
    }
    
    self.messageComposeViewController = [[MFMessageComposeViewController alloc] init];
    self.messageComposeViewController.messageComposeDelegate = self;
    [self.messageComposeViewController setBody:messageBody];
    
    [self presentViewController:self.messageComposeViewController animated:YES completion:nil];
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultFailed: {
            [WebClientHelper showStandardErrorWithTitle:@"Error" andContent:@"An error occurred while sending the SMS."];
            break;
        }
        case MessageComposeResultSent: {
            [WebClientHelper showStandardErrorWithTitle:@"Sent" andContent:@"SMS sent successfully."];
            break;
        }
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
