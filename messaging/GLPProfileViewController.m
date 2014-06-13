//
//  GLPProfileViewController.m
//  Gleepost
//
//  Created by Silouanos on 10/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "UIViewController+GAI.h"
#import "UIViewController+Flurry.h"
#import <MessageUI/MessageUI.h>
#import "GLPProfileViewController.h"
#import "GLPUser.h"
#import "SessionManager.h"
#import "GLPPostManager.h"
#import "WebClientHelper.h"
#import "ProfileTwoButtonsTableViewCell.h"
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
#import "ViewPostImageViewController.h"
#import "TransitionDelegateViewImage.h"
#import "SettingsViewController.h"
#import "UIImage+StackBlur.h"
#import "NotificationCell.h"
#import "GLPApplicationHelper.h"
#import "GLPiOS6Helper.h"
#import "GroupViewController.h"
#import "ContactsManager.h"
#import "EmptyMessage.h"
#import "TableViewHelper.h"
#import "GLPButton.h"
#import "UINavigationBar+Utils.h"

@interface GLPProfileViewController () <ProfileSettingsTableViewCellDelegate, MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) GLPUser *user;

@property (strong, nonatomic) UIImage *userImage;

@property (assign, nonatomic) int numberOfRows;

@property (strong, nonatomic) NSMutableArray *posts;

@property (assign, nonatomic) GLPSelectedTab selectedTabStatus;

@property (assign, nonatomic) BOOL fromCampusWall;

@property (strong, nonatomic) TransitionDelegateViewNotifications *transitionViewNotificationsController;

@property (strong, nonatomic) FDTakeController *fdTakeController;

@property (strong, nonatomic) UIImage *uploadedImage;

@property (strong, nonatomic) NotificationsView *notificationView;

@property (assign, nonatomic) NSInteger unreadNotificationsCount;

@property (strong, nonatomic) NSString *profileImageUrl;

@property (strong, nonatomic) UITabBarItem *profileTabbarItem;

@property (strong, nonatomic) MFMessageComposeViewController *messageComposeViewController;

@property (assign, nonatomic) BOOL commentCreated;

@property (strong, nonatomic) TransitionDelegateViewImage *transitionViewImageController;

@property (strong, nonatomic) NSDate *commentNotificationDate;

@property (assign, nonatomic) BOOL postUploaded;

// new
@property (strong, nonatomic) NSMutableArray *notifications;
@property (assign, nonatomic) BOOL tabButtonEnabled;

@property (strong, nonatomic) GLPGroup *groupToNavigate;

@property (strong, nonatomic) EmptyMessage *emptyNotificationsMessage;
@property (strong, nonatomic) EmptyMessage *emptyMyPostsMessage;
@end


@implementation GLPProfileViewController

@synthesize notifications=_notifications;
@synthesize tabButtonEnabled=_tabButtonEnabled;
@synthesize unreadNotificationsCount=_unreadNotificationsCount;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.navigationController.viewControllers.count > 1) {
//        self.navigationItem.leftBarButtonItem = [AppDelegate customBackButtonWithTarget:self];
    }

//    [self setBottomView];

    _tabButtonEnabled = YES;
    
    [self registerTableViewCells];
    
    [self initialiseObjects];
    
//    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;

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

    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    
    if(![GLPiOS6Helper isIOS6])
    {
        //Change the colour of the tab bar.
        self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:75.0/255.0 green:208.0/255.0 blue:210.0/255.0 alpha:1.0];
        
        [AppearanceHelper setSelectedColourForTabbarItem:self.profileTabbarItem withColour:[UIColor colorWithRed:75.0/255.0 green:208.0/255.0 blue:210.0/255.0 alpha:1.0]];
    }

    if(_fromPushNotification)
    {
        self.selectedTabStatus = kGLPNotifications;
        
//        [self.tableView reloadData];
    }

    
    [self setUpNotifications];
    
    [self setCustomBackgroundToTableView];
    
    [self loadInternalNotifications];
    
    
    if(self.selectedTabStatus == kGLPNotifications)
    {
        [self notificationsTabClick];
    }
    
    if(self.posts.count == 0 || _postUploaded)
    {
        [self loadPosts];
    }
//    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_NEW_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPPostImageUploaded" object:nil];
    
    if([GLPApplicationHelper isTheNextViewCampusWall:self.navigationController.viewControllers])
    {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self sendViewToGAI:NSStringFromClass([self class])];
    [self sendViewToFlurry:NSStringFromClass([self class])];
}



-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPPostUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPLikedPostUdated" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPNewPostByUser" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POST_DELETED object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 Sets custom background in order to have different colour on top and different colour in botton of the view.
 */

-(void)setCustomBackgroundToTableView
{
    
    if([GLPiOS6Helper isIOS6])
    {
        [GLPiOS6Helper setBackgroundImageToTableView:self.tableView];
        
        return;
    }
    
    UIImageView *backImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_background_main"]];
    
    [backImgView setFrame:CGRectMake(0.0f, 0.0f, backImgView.frame.size.width, backImgView.frame.size.height)];
    
    [self.tableView setBackgroundColor:[AppearanceHelper defaultGleepostColour]];
    [self.tableView setBackgroundView:backImgView];
}

-(void)setUpNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveInternalNotificationNotification:) name:GLPNOTIFICATION_NEW_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRealImage:) name:@"GLPPostImageUploaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePost:) name:@"GLPPostUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLikedPost:) name:@"GLPLikedPostUdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postByUserInCampusWall:) name:@"GLPNewPostByUser" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePost:) name:GLPNOTIFICATION_POST_DELETED object:nil];
}

//-(void)setUpNoMoreMessage
//{
//    _nomatchesView = [TableViewHelper generateNoMoreLabelWithText:@"No more notifications" withFrame:CGRectMake(0.0f, 320.0f, 320.0f, 50.0f) andTableView:self.tableView];
//    [self.tableView insertSubview:_nomatchesView belowSubview:self.tableView];
//}

#pragma mark - Notifications

-(void)deletePost:(NSNotification *)notification
{
    _postUploaded = YES;
    
//    [self.tableView reloadData];
    
//    int index = [GLPPostNotificationHelper parseNotificationAndFindIndexWithNotification:notification withPostsArray:self.posts];
//    
//    
//    [self removeTableViewPostWithIndex:index];
}

#pragma mark - Configuration


//-(void)setBottomView
//{
//    CGRect frame = self.tableView.bounds;
//    frame.origin.y = frame.size.height;
//    
//    CGRect viewFrame = self.view.bounds;
//    viewFrame.origin.y = viewFrame.size.height;
//    
//    UIImageView* grayView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 300.f, 320.0f, 250.0f)];
//    grayView.tag = 100;
//    grayView.backgroundColor = [UIColor whiteColor];
//    //    [self.tableView addSubview:grayView];
//    //    [grayView sendSubviewToBack:self.tableView];
//    
//    self.tableView.tableFooterView = grayView;
//    //    [self.view addSubview:grayView];
//}
//
//-(void)clearBottomView
//{
//    
//    self.tableView.tableFooterView = nil;
//}

-(void)configTabbar
{
    NSArray *items = self.tabBarController.tabBar.items;
    
    self.profileTabbarItem = [items objectAtIndex:4];
    
    [self.profileTabbarItem setTitle:@" "];
}

-(void)addNavigationButtons
{
//    UIImage *settingsIcon = [UIImage imageNamed:@"settings_btn"];
//    
//    GLPButton *btnBack=[[GLPButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25) andKind:kRightImage];
//    [btnBack addTarget:self action:@selector(showSettings:) forControlEvents:UIControlEventTouchUpInside];
//    [btnBack setBackgroundImage:settingsIcon forState:UIControlStateNormal];
//    
//    
//    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    
    
//    [self.navigationController.navigationBar setButtonOnRightWithImageName:@"settings_btn" withButtonSize:CGSizeMake(25, 25) withSelector:@selector(showSettings:) andTarget:self];
    
    [self.navigationController.navigationBar setButton:kRight withImageOrTitle:@"settings_btn" withButtonSize:CGSizeMake(25, 25) withSelector:@selector(showSettings:) andTarget:self];
    
    
//    self.navigationItem.rightBarButtonItem = settingsButton;
    
    

}

-(void)configureNavigationBar
{

    [self addNavigationButtons];
    

    //Change the format of the navigation bar.
    
    [self.navigationController setNavigationBarHidden:NO
                                             animated:YES];
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    
    //Change the format of the navigation bar.
    [AppearanceHelper setNavigationBarColour:self];
    
    [AppearanceHelper setNavigationBarFontFor:self];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}



-(void)initialiseObjects
{
    
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
    
    self.posts = [[NSMutableArray alloc] init];
    
    self.numberOfRows = 2;
    
    self.fdTakeController = [[FDTakeController alloc] init];
    self.fdTakeController.viewControllerForPresentingImagePickerController = self;
    self.fdTakeController.delegate = self;
    
    //Used for viewing post image.
    self.transitionViewImageController = [[TransitionDelegateViewImage alloc] init];

    
    // internal notifications
    _notifications = [NSMutableArray array];
    _unreadNotificationsCount = 0;
    
    [self.tableView reloadData];
    
    _postUploaded = NO;

    _emptyNotificationsMessage = [[EmptyMessage alloc] initWithText:@"You have no notifications" withPosition:EmptyMessagePositionBottom andTableView:self.tableView];
    
    _emptyMyPostsMessage = [[EmptyMessage alloc] initWithText:@"No more posts" withPosition:EmptyMessagePositionBottom andTableView:self.tableView];
    
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
    [self.tableView registerNib:[UINib nibWithNibName:@"PostImageCell" bundle:nil] forCellReuseIdentifier:@"ImageCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostVideoCell" bundle:nil] forCellReuseIdentifier:@"VideoCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTextCellView" bundle:nil] forCellReuseIdentifier:@"TextCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileViewSettingsTableViewCell" bundle:nil] forCellReuseIdentifier:@"SettingsCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GLPNotCell" bundle:nil] forCellReuseIdentifier:@"GLPNotCell"];
}


-(void)setUserDetails
{
//    self.user = [[SessionManager sharedInstance]user];
    
    [self fetchUserData];
    
    //[self loadUserData];
}


#pragma mark - UI methods

//-(void)updateNotificationsBubble
//{
//    if(self.unreadNotificationsCount > 0)
//    {
//        [self.notificationView updateNotificationsWithNumber:self.unreadNotificationsCount];
//    }
//    else
//    {
//        [self.notificationView hideNotifications];
//    }
//}
//

-(void)updateRealImage:(NSNotification*)notification
{
    GLPPost *currentPost = nil;
    
    int index = [GLPPostNotificationHelper parsePost:&currentPost imageNotification:notification withPostsArray:self.posts];
    
    
    if(currentPost)
    {
        //Find in which index the post exist and refresh it.
        if(self.selectedTabStatus == kGLPPosts)
        {
            [self refreshCellViewWithIndex:index + 2];
        }
    }
    
}

-(void)updateViewWithNewImage:(NSString*)imageUrl
{
    [self loadUserData];
}

-(void)notifyAppWithNewImage:(NSString *)imageUrl
{
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:imageUrl , @"profile_image_url", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GLPProfileImageChanged" object:nil userInfo:data];

}

-(void)notifyCampusWallWithDeletedPost:(GLPPost *)post
{
//    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber num] , @"profile_image_url", nil];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"GLPProfileImageChanged" object:nil userInfo:data];
}



-(void)updatePost:(NSNotification*)notification
{

    [GLPPostNotificationHelper parseNotification:notification withPostsArray:self.posts];
    
    if([GLPPostNotificationHelper parseNotification:notification withPostsArray:self.posts] != -1)
    {
        //Reload again only this post.
//        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(void)updateLikedPost:(NSNotification*)notification
{
    [GLPPostNotificationHelper parseLikedPostNotification:notification withPostsArray:self.posts];
    [self.tableView reloadData];

}



-(void)postByUserInCampusWall:(NSNotification *)notification
{
    //Set a boolean value YES in order to reload posts when user navigates back to profile.
    _postUploaded = YES;
    
}

#pragma mark - ProfileSettingsTableViewCellDelegate

-(void)logout:(id)sender
{
    //Pop up a bottom menu.
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Are you sure you want to logout?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Logout", nil];
    
    [actionSheet showInView:[self.view window]];
    
}

-(void)showSettings:(id)sender
{
    //TODO: Implement here settings.
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
//    PopUpNotificationsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"PopUpNotifications"];
//    vc.view.backgroundColor =  self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
//    vc.delegate = self;
//    vc.campusWallView = self.fromCampusWall;
////    [vc setTransitioningDelegate:self.transitionViewNotificationsController];
//    vc.modalPresentationStyle= UIModalPresentationCurrentContext;
//    [self.view setBackgroundColor:[UIColor whiteColor]];
//    [self presentViewController:vc animated:YES completion:nil];
    
    
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
//    SettingsViewController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    
    /**
     Takes screenshot from the current view controller to bring the sense of the transparency after the load
     of the NewPostViewController.
     */
    UIGraphicsBeginImageContext(self.view.window.bounds.size);
    [self.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
//    cvc.view.backgroundColor = self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
//    cvc.modalPresentationStyle = UIModalPresentationCustom;
//    
//    [cvc.view setBackgroundColor:[UIColor colorWithPatternImage:[image stackBlur:10.0f]]];
//    
//    [self.view setBackgroundColor:[UIColor whiteColor]];
//    [self presentViewController:cvc animated:YES completion:nil];
    
    
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    SettingsViewController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [cvc.view setBackgroundColor:[UIColor colorWithPatternImage:[image stackBlur:10.0f]]];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:cvc];
    [navigationController setNavigationBarHidden:YES];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
    
    
    
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

-(void)takeController:(FDTakeController *)controller didCancelAfterAttempting:(BOOL)madeAttempt
{
}

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)in
{
    self.uploadedImage = photo;
    
    //Set directly the new user's profile image.
    self.userImage = photo;
    
    [self refreshFirstCell];
    
    
//    [self.profileView.profileImage setImage:photo];
//    [self.profileView updateImage:photo];
    
    //Communicate with server to change the image.
    [self uploadImageAndSetUserImageWithUserRemoteKey];
    
    [self loadPosts];
    
}


#pragma mark - RemovePostCellDelegate

-(void)removePostWithPost:(GLPPost *)post
{
    [GLPPostNotificationHelper deletePostNotificationWithPostRemoteKey:post.remoteKey];

    int index;
    
    for(index = 0; index < self.posts.count; ++index)
    {
        GLPPost *p = [self.posts objectAtIndex:index];
        
        if(p.remoteKey == post.remoteKey)
        {
            [self.posts removeObject:p];
            
            [self removeTableViewPostWithIndex:index];
            
            return;
        }
    }
    
}


#pragma mark - Client

-(void)uploadImageAndSetUserImageWithUserRemoteKey
{
    UIImage* imageToUpload = [ImageFormatterHelper imageWithImage:self.uploadedImage scaledToHeight:320];
    
    NSData *imageData = UIImagePNGRepresentation(imageToUpload);
    
    
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
            
            [GLPPostManager setFakeKeysToPrivateProfilePosts:self.posts];

            [[GLPPostImageLoader sharedInstance] addPostsImages:self.posts];
            
            [self.tableView reloadData];
            
            _postUploaded = NO;
        }
        else
        {
            [WebClientHelper showStandardError];
        }
        
        
    }];
}

-(void)loadGroupAndNavigateWithRemoteKey:(NSString *)remoteKey
{
    [[WebClient sharedInstance] getGroupDescriptionWithId:[remoteKey integerValue] withCallbackBlock:^(BOOL success, GLPGroup *group, NSString *errorMessage) {
       
        if(success)
        {
            //Navigate to group with group.
            _groupToNavigate = group;
            [self performSegueWithIdentifier:@"view group" sender:self];
        }
        else
        {
            
            if([errorMessage isEqualToString:@"No access"])
            {
                [WebClientHelper showStandardErrorWithTitle:@"Error loading group" andContent:@"It seems that you are not belonging to this group anymore"];
            }
            else
            {
                [WebClientHelper showStandardError];
            }
            
        }
        
    }];
}

-(void)setImageToUserProfile:(NSString*)url
{
    [[WebClient sharedInstance] uploadImageToProfileUser:url callbackBlock:^(BOOL success) {
        
        if(success)
        {
            NSLog(@"NEW PROFILE IMAGE UPLOADED");
            
            [self updateViewWithNewImage:url];
            
            [self notifyAppWithNewImage:url];

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


# pragma mark - Internal notifications

- (void)loadInternalNotifications
{
    DDLogInfo(@"Load internal notifications");
    _unreadNotificationsCount = [GLPNotificationManager unreadNotificationsCount];
    _notifications = [GLPNotificationManager notifications];
    
 

    
    DDLogInfo(@"GLPProfileViewController - Unread: %d / Total: %d", _unreadNotificationsCount, _notifications.count);
    
    if(self.selectedTabStatus == kGLPNotifications) {
        [self notificationsTabClick];
        [self.tableView reloadData];
    }
    else
    {
        if(_unreadNotificationsCount > 0)
        {
            [self.tableView reloadData];
        }
    }
}

- (void)loadUnreadInternalNotifications
{
    DDLogInfo(@"Load new internal notifications");
//    _unreadNotificationsCount = [GLPNotificationManager unreadNotificationsCount];
    
    //Check if is the first notification that arrives.
    BOOL isNotification = (_notifications.count != 0);
    
    NSArray *notifications = [GLPNotificationManager unreadNotifications];
    _unreadNotificationsCount = notifications.count;
    if(notifications.count == 0 || self.selectedTabStatus != kGLPNotifications) {
        return;
    }
    
    _tabButtonEnabled = NO;
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:notifications.count];
    int i = 0;
    for(id not in notifications) {
        [_notifications insertObject:not atIndex:i];
        [indexPaths addObject:[NSIndexPath indexPathForRow:i + 2 inSection:0]];
        
        //ADDED.
        ++i;
        
    }
    
    if(isNotification)
    {
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    }
    else
    {
        [self.tableView reloadData];
    }
    
    

    
//    [self.tableView reloadData];
    
    _tabButtonEnabled = YES;
    
    //ADDED.
    [GLPNotificationManager markAllNotificationsRead];
    
}

- (void)notificationsTabClick
{
    [GLPNotificationManager markAllNotificationsRead];
    _unreadNotificationsCount = 0;
}



# pragma mark - GLPNotificationCellDelegate

- (void)notificationCell:(NotificationCell *)cell acceptButtonClickForNotification:(GLPNotification *)notification
{
    
    GLPContact *contact = [[GLPContact alloc] initWithUserName:notification.user.name profileImage:notification.user.profileImageUrl youConfirmed:YES andTheyConfirmed:YES];
    contact.remoteKey = notification.user.remoteKey;
    
    //Accept contact in the local database and in server.
    [[ContactsManager sharedInstance] acceptContact:contact.remoteKey callbackBlock:^(BOOL success) {
        
        if(!success)
        {
            [WebClientHelper showInternetConnectionErrorWithTitle:@"Failed to accept contact"];
            
            return;
        }
        
        
        [GLPNotificationManager acceptNotification:notification];
        [cell updateWithNotification:notification];
        
        NSUInteger index = [_notifications indexOfObject:notification];
        if(index == NSNotFound) {
            DDLogError(@"Cannot find notification to remove in array");
            return;
        }
                
        //Save contact to database.
//        [[ContactsManager sharedInstance] saveNewContact:contact db:nil];
        
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index+2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
        
    }];
    

}

- (void)notificationCell:(NotificationCell *)cell ignoreButtonClickForNotification:(GLPNotification *)notification
{
    [GLPNotificationManager ignoreNotification:notification];
    
    NSUInteger index = [_notifications indexOfObject:notification];
    if(index == NSNotFound) {
        DDLogError(@"Cannot find notification to remove in array");
        return;
    }
    
    [self.tableView beginUpdates];
    [_notifications removeObjectAtIndex:index];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index+2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}


# pragma mark - Notifications

-(void)receiveInternalNotificationNotification:(NSNotification *)notification
{
    DDLogInfo(@"Receive internal notifications");
    
    if(self.selectedTabStatus == kGLPNotifications) {
        [self loadUnreadInternalNotifications];
        _unreadNotificationsCount = 0;
    } else {
        [self loadInternalNotifications];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
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
        [_emptyNotificationsMessage hideEmptyMessageView];
        
        if(self.posts.count == 0)
        {
            [_emptyMyPostsMessage showEmptyMessageView];
        }
        else
        {
            [_emptyMyPostsMessage hideEmptyMessageView];
        }
        
        return self.numberOfRows + self.posts.count;
    }
    else
    {
        NSInteger extraRow = 0;
        
        [_emptyMyPostsMessage hideEmptyMessageView];
        
        if(_notifications.count == 0)
        {
            [_emptyNotificationsMessage showEmptyMessageView];
        }
        else
        {
            [_emptyNotificationsMessage hideEmptyMessageView];
            extraRow = 1;
        }
        
        return self.numberOfRows + _notifications.count + extraRow;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierWithImage = @"ImageCell";
    static NSString *CellIdentifierWithoutImage = @"TextCell";
    static NSString *CellIdentifierVideo = @"VideoCell";
    static NSString *CellIdentifierProfile = @"ProfileCell";
    static NSString *CellIdentifierTwoButtons = @"TwoButtonsCell";
    static NSString *CellIdentifierNotification = @"GLPNotCell";
    
    
    GLPPostCell *postViewCell;
    
    ProfileTwoButtonsTableViewCell *buttonsView;
    ProfileTableViewCell *profileView;
//    ProfileSettingsTableViewCell *profileSettingsView;
    NotificationCell *notificationCell;
    
    if(indexPath.row == 0)
    {
        profileView = [tableView dequeueReusableCellWithIdentifier:CellIdentifierProfile forIndexPath:indexPath];
        
        [profileView setDelegate:self];

//        [profileView updateImageWithUrl:self.profileImageUrl];
//        if(_userImage)
//        {
//            [profileView initialiseElementsWithUserDetails:self.user withImage:self.userImage];
//        }
//        else
//        {
            [profileView initialiseElementsWithUserDetails:self.user];
//        }
        
        
        profileView.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        return profileView;
        
    }
    else if (indexPath.row == 1)
    {
        buttonsView = [tableView dequeueReusableCellWithIdentifier:CellIdentifierTwoButtons forIndexPath:indexPath];
        buttonsView.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        if(_unreadNotificationsCount > 0) {
//            buttonsView.notificationsBubbleImageView.hidden = NO;
            [buttonsView showNotificationBubbleWithNotificationCount:_unreadNotificationsCount];
        } else {
            [buttonsView hideNotificationBubble];
//            buttonsView.notificationsBubbleImageView.hidden = YES;
        }
        
        [buttonsView setDelegate:self fromPushNotification:_fromPushNotification];
        
        if(_fromPushNotification)
        {
//            [buttonsView viewSettingsButton];
            _fromPushNotification = NO;
        }
        
        
        if(self.selectedTabStatus == kGLPNotifications)
        {
//            if(_notifications.count < 5)
//            {
//                [self setBottomView];
//            }
        }
        
        return buttonsView;
    }
    else if (indexPath.row >= 2)
    {
        if(self.selectedTabStatus == kGLPNotifications)
        {
            if(_notifications.count != 0 && (indexPath.row - 2) == _notifications.count)
            {
                DDLogDebug(@"Notifications count: %lu : %ld", (unsigned long)_notifications.count, (long)indexPath.row);
                
                return [TableViewHelper generateCellWithMessage:@"You have no more notifications"];
            }
            
            notificationCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierNotification forIndexPath:indexPath];
            notificationCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            GLPNotification *notification = _notifications[indexPath.row - 2];
            [notificationCell updateWithNotification:notification];
            notificationCell.delegate = self;
            
            return notificationCell;
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
                else if ([post isVideoPost])
                {
                    postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierVideo forIndexPath:indexPath];
                }
                else
                {
                    postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithoutImage forIndexPath:indexPath];
                }
                
                //Set this class as delegate.
                postViewCell.delegate = self;
                
                [postViewCell setPost:post withPostIndex:indexPath.row];
                
                //Add separator line to posts' cells.
//                UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, postViewCell.frame.size.height-0.5f, 320, 0.5)];
//                line.backgroundColor = [UIColor colorWithRed:217.0f/255.0f green:228.0f/255.0f blue:234.0f/255.0f alpha:1.0f];
//                [postViewCell addSubview:line];
                
            }
            
            return postViewCell;
        }
        
    }
    
    //TODO: See this again.
    // => yep
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < 2) {
        return;
    }
    
    // click on post cell
    if(self.selectedTabStatus == kGLPPosts) {
        self.selectedPost = self.posts[indexPath.row-2];
        //    self.selectedIndex = indexPath.row;
        //    self.postIndexToReload = indexPath.row-2;
        self.commentCreated = NO;
        [self performSegueWithIdentifier:@"view post" sender:self];
        
    }
    // click on internal notification cell
    else {
        GLPNotification *notification = _notifications[indexPath.row - 2];
        
        // go to the contact detail ?
        if(notification.notificationType == kGLPNotificationTypeAcceptedYou ||
           notification.notificationType == kGLPNotificationTypeAddedYou) {
            
            self.selectedUserId = notification.user.remoteKey;
            //Refresh contacts' data.
            [[ContactsManager sharedInstance] refreshContacts];
            
            [self performSegueWithIdentifier:@"view private profile" sender:self];

        }
        // navigate to post.
        else if(notification.notificationType == kGLPNotificationTypeLiked || notification.notificationType == kGLPNotificationTypeCommented) {
            
            DDLogInfo(@"Go to the post details.");
            
            [WebClientHelper showStandardLoaderWithTitle:@"Loading post" forView:self.view];
            
            [GLPPostManager loadPostWithRemoteKey:notification.postRemoteKey callback:^(BOOL success, GLPPost *post) {
                
                [WebClientHelper hideStandardLoaderForView:self.view];
                
                if(success)
                {
                    self.selectedPost = post;
                    
                    if(notification.notificationType == kGLPNotificationTypeCommented)
                    {
                        //Add the date of the notification to the view post view controller.
                        self.commentNotificationDate = notification.date;
                    }
                    else
                    {
                        self.commentNotificationDate = nil;
                    }
                    
                    [self performSegueWithIdentifier:@"view post" sender:self];
                }
                else
                {
                    [WebClientHelper showStandardErrorWithTitle:@"Failed to load post" andContent:@"Check your internet connection and try again"];
                }
            }];
        }
        //Navigate to group.
        else if (notification.notificationType == kGLPNotificationTypeAddedGroup)
        {
            [self loadGroupAndNavigateWithRemoteKey:[notification.customParams objectForKey:@"network"]];
        }

    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        return PROFILE_CELL_HEIGHT;
    }
    else if(indexPath.row == 1)
    {
        return TWO_BUTTONS_CELL_HEIGHT;
    }
    else if(indexPath.row >= 2)
    {
        if(self.selectedTabStatus == kGLPNotifications)
        {
            if(_notifications.count != 0 && (indexPath.row - 2) == _notifications.count)
            {
                return 50.0f;
            }
            
            GLPNotification *notification = _notifications[indexPath.row - 2];
            return [NotificationCell getCellHeightForNotification:notification];
        }
        else if (self.selectedTabStatus == kGLPPosts)
        {
            GLPPost *currentPost = [self.posts objectAtIndex:indexPath.row-2];
            
            if([currentPost imagePost])
            {
                return [GLPPostCell getCellHeightWithContent:currentPost cellType:kImageCell isViewPost:NO];
            }
            else if ([currentPost isVideoPost])
            {
                return [GLPPostCell getCellHeightWithContent:currentPost cellType:kVideoCell isViewPost:NO];
            }
            else
            {
                return [GLPPostCell getCellHeightWithContent:currentPost cellType:kTextCell isViewPost:NO];
            }
        }
    }
    
    return 70.0f;
}

#pragma mark - View image delegate


-(void)viewPostImage:(UIImage*)postImage
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    ViewPostImageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ViewPostImage"];
    vc.image = postImage;
    vc.view.backgroundColor = self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.67];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    
    [vc setTransitioningDelegate:self.transitionViewImageController];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)navigateToUsersProfileWithRemoteKey:(NSInteger)remoteKey
{
    DDLogDebug(@"GLPProfileViewController : navigateToUsersProfileWithRemoteKey: %ld", (long)remoteKey);
}

#pragma mark - New comment delegate

-(void)setPreviousViewToNavigationBar
{
    [self.notificationView setHidden:NO];
}

-(void)setPreviousNavigationBarName
{
    [self.navigationItem setTitle:@"Me"];
}

-(void)hideNavigationBarAndButtonWithNewTitle:(NSString*)newTitle
{
    [self.navigationItem setTitle:newTitle];
    [self.notificationView setHidden:YES];
}

-(void)navigateToViewPostFromCommentWithIndex:(int)postIndex
{
    self.selectedPost = self.posts[postIndex-2];
    
    //    self.postIndexToReload = postIndex;
    
    ++self.selectedPost.commentsCount;
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:postIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    self.commentCreated = YES;
    
    //Notify GLPProfileViewController about changes.
    [GLPPostNotificationHelper updatePostWithNotifiationName:@"GLPPostUpdated" withObject:self remoteKey:self.selectedPost.remoteKey numberOfLikes:self.selectedPost.likes andNumberOfComments:self.selectedPost.commentsCount];
    
    [self performSegueWithIdentifier:@"view post" sender:self];
}

#pragma mark - ProfileTableViewCellDelegate

-(void)changeProfileImage:(id)sender
{
    [self.fdTakeController takePhotoOrChooseFromLibrary];
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
    [self.tableView reloadData];
    
//    [self.tableView beginUpdates];
//    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//    [self.tableView endUpdates];
}

-(void)removeTableViewPostWithIndex:(int)index
{
    NSMutableArray *rowsDeleteIndexPath = [[NSMutableArray alloc] init];
    
    [rowsDeleteIndexPath addObject:[NSIndexPath indexPathForRow:index+2 inSection:0]];
    
    [self.tableView deleteRowsAtIndexPaths:rowsDeleteIndexPath withRowAnimation:UITableViewRowAnimationRight];
}


#pragma  mark - Button Navigation Delegate

-(void)viewSectionWithId:(GLPSelectedTab) selectedTab
{
    
    if(!_tabButtonEnabled) {
        return;
    }
    
    self.selectedTabStatus = selectedTab;
    
    if(selectedTab == kGLPNotifications) {
        [self notificationsTabClick];
    }
    
    [self.tableView reloadData];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    
    
    if([segue.identifier isEqualToString:@"view post"])
    {
        //Hide tabbar.
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
        ViewPostViewController *vc = segue.destinationViewController;
        vc.commentJustCreated = self.commentCreated;
        vc.commentNotificationDate = self.commentNotificationDate;
        
        [vc reloadImage:([self.selectedPost imagePost] || [self.selectedPost isVideoPost]) ? YES : NO];
        
        vc.post = self.selectedPost;
        vc.isFromCampusLive = NO;
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
        
    }
    else if([segue.identifier isEqualToString:@"view group"])
    {
        GroupViewController *groupVC = segue.destinationViewController;
        
        groupVC.group = _groupToNavigate;
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
            [WebClientHelper showStandardErrorWithTitle:@"Error" andContent:@"An error occurred while sending the SMS"];
            break;
        }
        case MessageComposeResultSent: {
            [WebClientHelper showStandardErrorWithTitle:@"Sent" andContent:@"SMS sent successfully"];
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
