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
#import "AppearanceHelper.h"
#import "GLPPrivateProfileViewController.h"
#import "LoginRegisterViewController.h"
#import "ViewPostViewController.h"
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
#import "TransitionDelegateViewImage.h"
#import "GLPSettingsViewController.h"
#import "UIImage+StackBlur.h"
#import "GLPApplicationHelper.h"
#import "GLPiOSSupportHelper.h"
#import "GroupViewController.h"
#import "ContactsManager.h"
#import "EmptyMessage.h"
#import "TableViewHelper.h"
#import "GLPButton.h"
#import "UINavigationBar+Utils.h"
#import "UINavigationBar+Format.h"
#import "GLPBadgesViewController.h"
#import "UIRefreshControl+CustomLoader.h"
#import "GLPVideoLoaderManager.h"
#import "GLPShowLocationViewController.h"
#import "ViewPostImageViewController.h"
#import "ChangeImageProgressView.h"
#import "GLPViewImageViewController.h"
#import "TableViewHelper.h"
#import "NotificationsOrganiserHelper.h"
#import "GLPLiveGroupManager.h"
#import "GLPViewImageViewController.h"
#import "GLPCalendarManager.h"
#import "GLPAttendingPopUpViewController.h"
#import "TDPopUpAfterGoingView.h"
#import "GLPShowUsersViewController.h"
#import "GLPEmptyViewManager.h"
#import "GLPAttendingPostsViewController.h"

@interface GLPProfileViewController () <MFMessageComposeViewControllerDelegate, UIActionSheetDelegate, GLPAttendingPopUpViewControllerDelegate>

@property (strong, nonatomic) GLPUser *user;

@property (assign, nonatomic) int numberOfRows;

@property (strong, nonatomic) NSMutableArray *posts;

@property (assign, nonatomic) ButtonType selectedTab;

@property (assign, nonatomic) BOOL fromCampusWall;

@property (strong, nonatomic) UIImage *selectedImageToBeChanged;

@property (assign, nonatomic) NSInteger unreadNotificationsCount;

@property (strong, nonatomic) NSString *profileImageUrl;

@property (strong, nonatomic) UITabBarItem *profileTabbarItem;

@property (strong, nonatomic) MFMessageComposeViewController *messageComposeViewController;

@property (assign, nonatomic) BOOL commentCreated;

@property (strong, nonatomic) TransitionDelegateViewImage *transitionViewImageController;

@property (strong, nonatomic) NSDate *commentNotificationDate;

@property (assign, nonatomic) BOOL postUploaded;

@property (strong, nonatomic) NSMutableArray *notifications;

@property (assign, nonatomic) BOOL tabButtonEnabled;

@property (strong, nonatomic) GLPGroup *groupToNavigate;
@property (strong, nonatomic) GLPUser *userCreatedTheGroupPost;

@property (strong, nonatomic) EmptyMessage *emptyNotificationsMessage;

@property (assign, nonatomic) BOOL isPostFromNotifications;

@property (assign, nonatomic) NSInteger currentNumberOfPN;

@property (strong, nonatomic) GLPLocation *selectedLocation;

@property (strong, nonatomic) GLPPost *selectedPost;

@property (assign, nonatomic) NSInteger selectedUserId;

@property (strong, nonatomic) ChangeImageProgressView *progressView;

@property (strong, nonatomic) NotificationsOrganiserHelper *notificationsOrganiser;

@property (strong, nonatomic) TDPopUpAfterGoingView *transitionViewPopUpAttend;

@end


@implementation GLPProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerTableViewCells];
    
    [self initialiseObjects];
    
    [self addNavigationButtons];

    [self configTabbar];
    
    [self formatTableView];
    
    [self configureProgressView];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureNavigationBar];
    
    [self hideNetworkErrorViewIfNeeded];

    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if(![GLPiOSSupportHelper isIOS6])
    {
        //Change the colour of the tab bar.
        self.tabBarController.tabBar.tintColor = [AppearanceHelper redGleepostColour];
        [AppearanceHelper setSelectedColourForTabbarItem:self.profileTabbarItem withColour:[AppearanceHelper redGleepostColour]];
    }

    if(_fromPushNotification)
    {
        _selectedTab = kButtonRight;
    }

    [self setUpNotifications];
    
    [self loadInternalNotifications];
    
    if(_selectedTab == kButtonRight)
    {
        [self notificationsTabClick];
    }
    
    [self fetchUserData];
    [self fetchUsersPostsIfNeeded];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_NEW_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POST_IMAGE_LOADED object:nil];
    
    [self removeGoingButtonNotification];
    
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setTitle];
    
    [self configureRefreshControl];
    
    [self setUpGoingButtonNotification];

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

- (void)setUpGoingButtonNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goingButtonTouchedWithNotification:) name:GLPNOTIFICATION_GOING_BUTTON_TOUCHED object:nil];
}

- (void)removeGoingButtonNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_GOING_BUTTON_TOUCHED object:nil];
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
    
    if([GLPiOSSupportHelper isIOS6])
    {
        [GLPiOSSupportHelper setBackgroundImageToTableView:self.tableView];
        
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRealImage:) name:GLPNOTIFICATION_POST_IMAGE_LOADED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePost:) name:@"GLPPostUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLikedPost:) name:@"GLPLikedPostUdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postByUserInCampusWall:) name:@"GLPNewPostByUser" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePost:) name:GLPNOTIFICATION_POST_DELETED object:nil];
}

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

- (void)configureRefreshControl
{
    // refresh control
    self.refreshControl = [[UIRefreshControl alloc] initWithCustomActivityIndicator];
    
    [self.refreshControl addTarget:self action:@selector(reloadContent) forControlEvents:UIControlEventValueChanged];
}

-(void)configTabbar
{
    NSArray *items = self.tabBarController.tabBar.items;
    
    self.profileTabbarItem = [items objectAtIndex:3];
}

-(void)addNavigationButtons
{
    [self.navigationController.navigationBar setButton:kRight withImageName:@"settings_btn" withButtonSize:CGSizeMake(30.0, 30.0) withSelector:@selector(showSettings:) andTarget:self];
}

-(void)configureNavigationBar
{

    //Change the format of the navigation bar.
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    
    //Change the format of the navigation bar.
    
    [self.navigationController.navigationBar setFontFormatWithColour:kBlack];
        
//    if(self.navigationController.viewControllers.count == 1)
//    {
        //Use the default method of formatting only if this VC is the first appeared.
        [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
//    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)setTitle
{
    //We are not using the default method for formatting the navigation bar because was causing issues
    //with the navigation to GroupVC.
    
    [self.navigationController.navigationBar setShadowImage:[ImageFormatterHelper generateOnePixelHeightImageWithColour:[AppearanceHelper mediumGrayGleepostColour]]];
    
    self.navigationController.navigationBar.topItem.title = @"MY PROFILE";
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
    
    _selectedTab = kButtonLeft;
    
    self.posts = [[NSMutableArray alloc] init];
    
    self.numberOfRows = 1;
    
    //Used for viewing post image.
    self.transitionViewImageController = [[TransitionDelegateViewImage alloc] init];
    
    _transitionViewPopUpAttend = [[TDPopUpAfterGoingView alloc] init];

    
    // internal notifications
    _notifications = [NSMutableArray array];
    _unreadNotificationsCount = 0;
    
    _postUploaded = NO;

    _emptyNotificationsMessage = [[EmptyMessage alloc] initWithText:@"You have no notifications" withPosition:EmptyMessagePositionBottom andTableView:self.tableView];
        
    _currentNumberOfPN = 0;
    
    _tabButtonEnabled = YES;
    
    _isPostFromNotifications = NO;
    
    _selectedLocation = nil;
    
    _notificationsOrganiser = [[NotificationsOrganiserHelper alloc] init];
    
}

- (void)configureProgressView
{
    _progressView = [[ChangeImageProgressView alloc] init];

    [self.navigationController.view addSubview:_progressView];
}

- (void)formatTableView
{
    [AppearanceHelper setCustomBackgroundToTableView:self.tableView];
}

-(void)registerTableViewCells
{
    //Register nib files in table view.
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileTopViewCell" bundle:nil] forCellReuseIdentifier:@"ProfileTopViewCell"];
    
    //Register posts.
    [self.tableView registerNib:[UINib nibWithNibName:@"PostImageCell" bundle:nil] forCellReuseIdentifier:@"ImageCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostVideoCell" bundle:nil] forCellReuseIdentifier:@"VideoCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTextCellView" bundle:nil] forCellReuseIdentifier:@"TextCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GLPNotificationCell" bundle:nil] forCellReuseIdentifier:@"GLPNotificationCell"];
}

- (void)hideNetworkErrorViewIfNeeded
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_HIDE_ERROR_VIEW object:self userInfo:nil];
}


#pragma mark - UI methods

-(void)updateRealImage:(NSNotification*)notification
{
    
//    int index = [GLPPostNotificationHelper parsePost:&currentPost imageNotification:notification withPostsArray:self.posts];
    NSInteger index = [GLPPostNotificationHelper parseRefreshCellNotification:notification withPostsArray:self.posts];


    if(index != -1)
    {
        //Find in which index the post exist and refresh it.
        if(_selectedTab == kButtonLeft)
        {
            [self refreshCellViewWithIndex:index + 1];
        }
    }
    
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
    DDLogDebug(@"Update post: %@", notification.userInfo);

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

- (void)startLoading
{
    [self.refreshControl beginRefreshing];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)stopLoading
{
    //Adding delay into the end refreshing helps the UI to acts smoothly.
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.refreshControl endRefreshing];
        
    });
//    [self.refreshControl endRefreshing];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


-(void)showSettings:(id)sender
{
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
//    SettingsViewController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    
    /**
     Takes screenshot from the current view controller to bring the sense of the transparency after the load
     of the NewPostViewController.
     */
//    UIGraphicsBeginImageContext(self.view.window.bounds.size);
//    [self.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    
//    cvc.view.backgroundColor = self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
//    cvc.modalPresentationStyle = UIModalPresentationCustom;
//    
//    [cvc.view setBackgroundColor:[UIColor colorWithPatternImage:[image stackBlur:10.0f]]];
//    
//    [self.view setBackgroundColor:[UIColor whiteColor]];
//    [self presentViewController:cvc animated:YES completion:nil];
    
    
    ///GLPSettingsViewController
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    GLPSettingsViewController *settingsVC = [storyboard instantiateViewControllerWithIdentifier:@"GLPSettingsViewController"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsVC];
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
            [WebClientHelper showInternetConnectionErrorWithTitle:@"Failed to invite friends."];
        }
    }];
}

#pragma mark - Action Sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *selectedButtonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    [self clickedButtonToFirstActionSheetWithTitle:selectedButtonTitle];
    
}

- (void)clickedButtonToFirstActionSheetWithTitle:(NSString *)buttonTitle
{
    if([buttonTitle isEqualToString:@"View image"])
    {
        //Show image.
        [self showImage];
    }
    else if([buttonTitle isEqualToString:@"Change image"] || [buttonTitle isEqualToString:@"Add image"])
    {
        //Change image.
        [self performSegueWithIdentifier:@"show image selector" sender:self];
    }
}

-(void)showImage
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    GLPViewImageViewController *viewImage = [storyboard instantiateViewControllerWithIdentifier:@"GLPViewImageViewController"];
    viewImage.image = _user.profileImage;
    viewImage.view.backgroundColor = self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.89];
    viewImage.modalPresentationStyle = UIModalPresentationCustom;
    
    if(![GLPiOSSupportHelper isIOS6])
    {
        [viewImage setTransitioningDelegate:self.transitionViewImageController];
    }
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self presentViewController:viewImage animated:YES completion:nil];
}

#pragma mark - ImageSelectorViewControllerDelegate

- (void)takeImage:(UIImage *)image
{
    self.selectedImageToBeChanged = image;
    
    //Set directly the new user's profile image.
    _user.profileImage = image;
    
//    [self refreshFirstCell];
    
    //Communicate with server to change the image.
    [self uploadAndSetUsersImage];
    
}

#pragma mark - RemovePostCellDelegate

-(void)removePostWithPost:(GLPPost *)post
{
    [GLPPostNotificationHelper deletePostNotificationWithPostRemoteKey:post.remoteKey inCampusLive:NO];

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

-(void)uploadAndSetUsersImage
{
    _user.profileImage = self.selectedImageToBeChanged;
    
    [self refreshFirstCell];
    
    [[GLPProfileLoader sharedInstance] uploadAndSetNewUsersImage:self.selectedImageToBeChanged withCallbackBlock:^(BOOL success, NSString *url) {
       
        if(success)
        {
            [self notifyAppWithNewImage:url];
            
            [self fetchUserData];
            
            [self loadPosts];

        }
        
    }];
}

- (void)loadPosts
{
    [self startLoading];
    
    DDLogDebug(@"Load posts.");
    
    [GLPPostManager loadPostsWithRemoteKey:_user.remoteKey localCallback:^(NSArray *posts) {
        
        [self refreshNewPosts:posts];
        
    } remoteCallback:^(BOOL success, NSArray *posts) {
        
        [self stopLoading];
        
        if(success)
        {

            DDLogDebug(@"Remote");
            [self refreshNewPosts:posts];
            
        }
        
    }];
    
//    [GLPPostManager loadRemotePostsForUserRemoteKey:self.user.remoteKey callback:^(BOOL success, NSArray *posts) {
//        
//
//        
//        
//    }];
}

- (void)refreshNewPosts:(NSArray *)posts
{
//    DDLogDebug(@"Current posts %@ incoming posts %@", self.posts, posts);
    
    if(posts.count > 0 && self.posts.count > 0)
    {
        if(((GLPPost *)[posts objectAtIndex:0]).remoteKey == ((GLPPost *)[self.posts objectAtIndex:0]).remoteKey)
        {
            return;
        }
    }
    
    if(posts.count == 0)
    {
        return;
    }
    
    self.posts = [posts mutableCopy];
    
    [GLPPostManager setFakeKeysToPrivateProfilePosts:self.posts];
    
    [[GLPPostImageLoader sharedInstance] addPostsImages:self.posts];
    
    [self.tableView reloadData];
    
    _postUploaded = NO;
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
//                [WebClientHelper showStandardError];
            }
            
        }
        
    }];
}

#pragma mark - Internal notifications

- (void)loadInternalNotifications
{
    DDLogInfo(@"Load internal notifications");
    _unreadNotificationsCount = [GLPNotificationManager unreadNotificationsCount];
    
    DDLogDebug(@"Unread notifications: %ld", (unsigned long)_unreadNotificationsCount);
    
    //_notifications = [GLPNotificationManager notifications];

    [GLPNotificationManager loadNotificationsWithLocalCallback:^(BOOL success, NSArray *notifications) {
        
        _notifications = notifications.mutableCopy;
        
        [_notificationsOrganiser resetData];
        [_notificationsOrganiser organiseNotifications:_notifications];
        
        if(_selectedTab == kButtonRight) {
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

        
    } andRemoteCallback:^(BOOL success, NSArray *remoteNotifications) {
        
        _notifications = remoteNotifications.mutableCopy;
        
        [_notificationsOrganiser resetData];
        [_notificationsOrganiser organiseNotifications:_notifications];
        
        if(_selectedTab == kButtonRight) {
            //[self notificationsTabClick];
            [self.tableView reloadData];
        }
        else
        {
            if(_unreadNotificationsCount > 0)
            {
                [self.tableView reloadData];
            }
        }

        
    }];
    
    DDLogInfo(@"GLPProfileViewController - Unread: %d / Total: %d", _unreadNotificationsCount, _notifications.count);
}

- (void)refreshNotifications
{
    [self startLoading];
    
    [GLPNotificationManager loadNotificationsWithLocalCallback:^(BOOL success, NSArray *notifications) {
        
        [self stopLoading];
//        _notifications = notifications.mutableCopy;
        

        
    } andRemoteCallback:^(BOOL success, NSArray *remoteNotifications) {
        
        _notifications = remoteNotifications.mutableCopy;
        
        [_notificationsOrganiser resetData];
        [_notificationsOrganiser organiseNotifications:_notifications];
        
        [self.tableView reloadData];
        
        DDLogInfo(@"Notifications after remote refresh: %ld", (unsigned long)_notifications.count);

        
    }];
    
}

- (void)loadUnreadInternalNotifications
{
    DDLogInfo(@"Load new internal notifications");
//    _unreadNotificationsCount = [GLPNotificationManager unreadNotificationsCount];
    
    NSArray *notifications = [GLPNotificationManager unreadNotifications];
    _unreadNotificationsCount = notifications.count;
    if(notifications.count == 0 || _selectedTab != kButtonRight) {
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
    
    [_notificationsOrganiser resetData];
    [_notificationsOrganiser organiseNotifications:_notifications];
    
    [self.tableView reloadData];
    
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

- (void)imageTouchedWithImageView:(UIImageView *)imageView
{
    DDLogDebug(@"Image notification touched: %@", imageView);
}

//- (void)notificationCell:(NotificationCell *)cell acceptButtonClickForNotification:(GLPNotification *)notification
//{
//    
//    GLPContact *contact = [[GLPContact alloc] initWithUserName:notification.user.name profileImage:notification.user.profileImageUrl youConfirmed:YES andTheyConfirmed:YES];
//    contact.remoteKey = notification.user.remoteKey;
//    
//    //Accept contact in the local database and in server.
//    [[ContactsManager sharedInstance] acceptContact:contact.remoteKey callbackBlock:^(BOOL success) {
//        
//        if(!success)
//        {
//            [WebClientHelper showInternetConnectionErrorWithTitle:@"Failed to accept contact"];
//            
//            return;
//        }
//        
//        
//        [GLPNotificationManager acceptNotification:notification];
//        [cell updateWithNotification:notification];
//        
//        NSUInteger index = [_notifications indexOfObject:notification];
//        if(index == NSNotFound) {
//            DDLogError(@"Cannot find notification to remove in array");
//            return;
//        }
//                
//        //Save contact to database.
////        [[ContactsManager sharedInstance] saveNewContact:contact db:nil];
//        
//        
//        [self.tableView beginUpdates];
//        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index+2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//        [self.tableView endUpdates];
//        
//        
//    }];
//    
//
//}
//
//- (void)notificationCell:(NotificationCell *)cell ignoreButtonClickForNotification:(GLPNotification *)notification
//{
//    [GLPNotificationManager ignoreNotification:notification];
//    
//    NSUInteger index = [_notifications indexOfObject:notification];
//    if(index == NSNotFound) {
//        DDLogError(@"Cannot find notification to remove in array");
//        return;
//    }
//    
//    [self.tableView beginUpdates];
//    [_notifications removeObjectAtIndex:index];
//    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index+2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [self.tableView endUpdates];
//}


# pragma mark - Notifications

-(void)receiveInternalNotificationNotification:(NSNotification *)notification
{
    DDLogInfo(@"Receive internal notifications");
    
    if(_selectedTab == kButtonRight) {
        [self loadUnreadInternalNotifications];
        _unreadNotificationsCount = 0;
    } else {
        [self loadInternalNotifications];
        
        //TODO: See that later.
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}




/**
 Load user's details from server or from profile loader.
 */
- (void)fetchUserData
{
    [[GLPProfileLoader sharedInstance] loadUsersDataWithLocalCallback:^(GLPUser *user) {
        
        if(user)
        {
            _user = user;
            
            DDLogDebug(@"Data needs to be updated locally: %@", user);
            [self refreshCellViewWithIndex:0];
//            [self fetchUsersPostsIfNeeded];
        }
        
        
    } andRemoteCallback:^(BOOL success, BOOL updatedData, GLPUser *user) {
       
        if(success && updatedData)
        {
            DDLogDebug(@"Data needs to be updated remotely: %@", user);
            _user = user;
            [self refreshCellViewWithIndex:0];
//            [self fetchUsersPostsIfNeeded];
        }
    }];
}

- (void)fetchUsersPostsIfNeeded
{
    if(_posts.count == 0 || _postUploaded)
    {
        [self loadPosts];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(_selectedTab == kButtonRight)
    {
        //Notifications are selected.
        DDLogDebug(@"numberOfSectionsInTableView: %d", [_notificationsOrganiser numberOfSections]);
        
        return [_notificationsOrganiser numberOfSections] + 1;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_selectedTab == kButtonLeft)
    {
        [_emptyNotificationsMessage hideEmptyMessageView];
        
        [self hideOrShowPostsEmptyView];
        
        return self.numberOfRows + self.posts.count;
    }
    else
    {
        NSInteger extraRow = 0;
        
        [[GLPEmptyViewManager sharedInstance] hideViewWithKind:kProfilePostsEmptyView];
        
        if(_notifications.count == 0)
        {
            [_emptyNotificationsMessage showEmptyMessageView];
        }
        else
        {
            [_emptyNotificationsMessage hideEmptyMessageView];
            extraRow = 1;
        }
        
        DDLogDebug(@"Number of sections: %d, Current section: %d", [_notificationsOrganiser numberOfSections], section);

        
        if(section == 0)
        {
            return self.numberOfRows;
        }
        
        DDLogDebug(@"numberOfRowsInSection: %d", [_notificationsOrganiser notificationsAtSectionIndex:section - 1].count);
        
        
//        if([_notificationsOrganiser numberOfSections] == section)
//        {
//            
//            return self.numberOfRows + [_notificationsOrganiser notificationsAtSectionIndex:section - 1].count + extraRow;
//
//        }
//        else
//        {
            return [_notificationsOrganiser notificationsAtSectionIndex:section - 1].count;
//        }
        
        
//        return self.numberOfRows + _notifications.count + extraRow;
    }
}

#pragma mark - Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierWithImage = @"ImageCell";
    static NSString *CellIdentifierWithoutImage = @"TextCell";
    static NSString *CellIdentifierVideo = @"VideoCell";
    static NSString *CellIdentifierProfile = @"ProfileTopViewCell";
    
    static NSString *CellIdentifierNotification = @"GLPNotificationCell";
    
    
    GLPPostCell *postViewCell;

    ProfileTopViewCell *profileView;
    
    GLPNotificationCell *notificationCell;
    
    if(indexPath.row == 0 && indexPath.section == 0)
    {
        profileView = [tableView dequeueReusableCellWithIdentifier:CellIdentifierProfile forIndexPath:indexPath];
        
        [profileView setDelegate:self];
        [profileView comesFromPushNotification:_fromPushNotification];
        /** Set for test purposes */
        [profileView setNumberOfRsvps:_currentNumberOfPN];
        
        if(_fromPushNotification)
        {
            _fromPushNotification = NO;
        }
        
        [profileView setUserData:self.user];
        
        if(_unreadNotificationsCount > 0)
        {
            [profileView showNotificationBubbleWithNotificationCount:_unreadNotificationsCount];
        }
        else
        {
            [profileView hideNotificationBubble];
        }
        
        
        profileView.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        return profileView;
        
    }
    else if (indexPath.section > 0)
    {
        if(_selectedTab == kButtonRight)
        {
//            if(_notifications.count != 0 && (indexPath.row - 1) == _notifications.count)
//            {
//                DDLogDebug(@"Notifications count: %lu : %ld", (unsigned long)_notifications.count, (long)indexPath.row);
//                
//                return [TableViewHelper generateCellWithMessage:@"You have no more notifications"];
//            }
            
//            if([_notificationsOrganiser numberOfSections] == indexPath.section)
//            {
//                if([_notificationsOrganiser notificationsAtSectionIndex:indexPath.section - 1].count == indexPath.row)
//                {
//                    return [TableViewHelper generateCellWithMessage:@"You have no more notifications"];
//                }
//            }
            
            
            notificationCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierNotification forIndexPath:indexPath];
            notificationCell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            GLPNotification *notification = [_notificationsOrganiser notificationWithIndex:indexPath.row andSectionIndex:indexPath.section - 1];

            
            [notificationCell setNotification:notification];
            
            notificationCell.delegate = self;
            
            return notificationCell;
        }
    }
    else if (indexPath.row >= 1 && indexPath.section == 0)
    {
//        if(_selectedTab == kButtonRight)
//        {
//            if(_notifications.count != 0 && (indexPath.row - 1) == _notifications.count)
//            {
//                DDLogDebug(@"Notifications count: %lu : %ld", (unsigned long)_notifications.count, (long)indexPath.row);
//                
//                return [TableViewHelper generateCellWithMessage:@"You have no more notifications"];
//            }
//            
//            notificationCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierNotification forIndexPath:indexPath];
//            notificationCell.selectionStyle = UITableViewCellSelectionStyleGray;
//            
//            GLPNotification *notification = _notifications[indexPath.row - 1];
//            
//            DDLogDebug(@"cellForRowAtIndexPath: %@", [_notificationsOrganiser notificationWithIndex:indexPath.row - 1 andSectionIndex:indexPath.section - 1]);
////            [notificationCell updateWithNotification:notification];
//            
//            [notificationCell setNotification:notification];
//            
//            notificationCell.delegate = self;
//            
//            return notificationCell;
//        }
//        else if(_selectedTab == kButtonLeft)
//       {
            if(self.posts.count != 0)
            {
                GLPPost *post = self.posts[indexPath.row-1];
                
                if([post imagePost])
                {
                    postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithImage forIndexPath:indexPath];
                }
                else if ([post isVideoPost])
                {
                    if(indexPath.row != 0)
                    {
                        [[GLPVideoLoaderManager sharedInstance] disableTimelineJustFetched];
                    }
                    
                    postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierVideo forIndexPath:indexPath];
                }
                else
                {
                    postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithoutImage forIndexPath:indexPath];
                }
                
                //Set this class as delegate.
                postViewCell.delegate = self;
                
                [postViewCell setPost:post withPostIndex:indexPath.row];
//            }
            
            return postViewCell;
        }
        
    }
    
    //TODO: See this again.
    // => yep
    return nil;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(![[cell class] isSubclassOfClass:[GLPPostCell class]])
    {
        return;
        
    }
    
    if(_posts.count == 0)
    {
        
        DDLogError(@"Abord ending display with cell.");
        
        return;
    }
    
    
    GLPPost *post = _posts[indexPath.row - 1];
    
    GLPPostCell *postCell = (GLPPostCell *)cell;
    
    if([post isVideoPost])
    {
        [postCell deregisterNotificationsInVideoView];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 && indexPath.section == 0)
    {
        return;
    }
    
    // click on post cell
    if(_selectedTab == kLeft) {
        self.selectedPost = self.posts[indexPath.row-1];
        //    self.selectedIndex = indexPath.row;
        //    self.postIndexToReload = indexPath.row-2;
        self.commentCreated = NO;
        [self performSegueWithIdentifier:@"view post" sender:self];
        
        return;
        
    }
    
    if (indexPath.section > 0)
    {
        if(_selectedTab == kButtonRight)
        {
//            GLPNotification *notification = _notifications[indexPath.row - 1];
            
            GLPNotification *notification = [_notificationsOrganiser notificationWithIndex:indexPath.row andSectionIndex:indexPath.section - 1];
            
            // navigate to post.
            if(notification.notificationType == kGLPNotificationTypeLiked || notification.notificationType == kGLPNotificationTypeCommented)
            {
                self.selectedPost = [[GLPPost alloc] initWithRemoteKey:notification.postRemoteKey];
                
                
                self.selectedPost.content = @"Loading...";
                self.isPostFromNotifications = YES;
                
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
            //Navigate to group.
            else if (notification.notificationType == kGLPNotificationTypeAddedGroup)
            {
                [self loadGroupAndNavigateWithRemoteKey:[notification.customParams objectForKey:@"network"]];
            }
            else if (notification.notificationType == kGLPNotificationTypeCreatedPostGroup)
            {
                NSInteger groupRemoteKey = ((NSNumber *)[notification.customParams objectForKey:@"network"]).integerValue;
                
                _groupToNavigate = [[GLPLiveGroupManager sharedInstance] groupWithRemoteKey:groupRemoteKey];
                if(!_groupToNavigate)
                {
                    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

                    return;
                }
                
                _userCreatedTheGroupPost = notification.user;
                [self performSegueWithIdentifier:@"view group" sender:self];
            }
        }
    }
    // click on internal notification cell
//    else {
//        GLPNotification *notification = _notifications[indexPath.row - 1];
//        
//        
//        
//        // go to the contact detail ?
//        if(notification.notificationType == kGLPNotificationTypeAcceptedYou ||
//           notification.notificationType == kGLPNotificationTypeAddedYou) {
//            
//            self.selectedUserId = notification.user.remoteKey;
//            //Refresh contacts' data.
//            [[ContactsManager sharedInstance] refreshContacts];
//            
//            [self performSegueWithIdentifier:@"view private profile" sender:self];
//
//        }
//        // navigate to post.
//        else if(notification.notificationType == kGLPNotificationTypeLiked || notification.notificationType == kGLPNotificationTypeCommented) {
//            
//            
//            self.selectedPost = [[GLPPost alloc] initWithRemoteKey:notification.postRemoteKey];
//
//            
//            self.selectedPost.content = @"Loading...";
//            self.isPostFromNotifications = YES;
//            
//            if(notification.notificationType == kGLPNotificationTypeCommented)
//            {
//                //Add the date of the notification to the view post view controller.
//                self.commentNotificationDate = notification.date;
//            }
//            else
//            {
//                self.commentNotificationDate = nil;
//            }
//            
//            [self performSegueWithIdentifier:@"view post" sender:self];
//        }
//        //Navigate to group.
//        else if (notification.notificationType == kGLPNotificationTypeAddedGroup)
//        {
//            [self loadGroupAndNavigateWithRemoteKey:[notification.customParams objectForKey:@"network"]];
//        }

//    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 && indexPath.section == 0)
    {
        return PROFILE_TOP_VIEW_HEIGHT;
    }
    else if (indexPath.section > 0)
    {
        if(_selectedTab == kButtonRight)
        {
//            if(_notifications.count != 0 && (indexPath.row - 1) == _notifications.count)
//            {
//                return 50.0f;
//            }
            
            
//            if([_notificationsOrganiser numberOfSections] == indexPath.section)
//            {
//                DDLogDebug(@"Compare: %d : %d", [_notificationsOrganiser notificationsAtSectionIndex:indexPath.section - 1].count - 1, indexPath.row);
//                
//                if([_notificationsOrganiser notificationsAtSectionIndex:indexPath.section - 1].count == indexPath.row)
//                {
//                    DDLogDebug(@"Compare3");
//                    return 50.0f;
//                }
//            }
            
            

            
//            GLPNotification *notification = _notifications[indexPath.row - 1];
            
            GLPNotification *notification = [_notificationsOrganiser notificationWithIndex:indexPath.row andSectionIndex:indexPath.section - 1];
            return [GLPNotificationCell getCellHeightForNotification:notification];
        }
        else if (_selectedTab == kButtonLeft)
        {
//            GLPPost *currentPost = [self.posts objectAtIndex:indexPath.row-1];
//            
//            if([currentPost imagePost])
//            {
//                return [GLPPostCell getCellHeightWithContent:currentPost cellType:kImageCell isViewPost:NO];
//            }
//            else if ([currentPost isVideoPost])
//            {
//                return [GLPPostCell getCellHeightWithContent:currentPost cellType:kVideoCell isViewPost:NO];
//            }
//            else
//            {
//                return [GLPPostCell getCellHeightWithContent:currentPost cellType:kTextCell isViewPost:NO];
//            }
        }
    }
    else if (indexPath.row >= 1 && indexPath.section == 0)
    {
        GLPPost *currentPost = [self.posts objectAtIndex:indexPath.row-1];
        
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
    
    return 70.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return nil;
    }
    
    return [TableViewHelper generateHeaderViewWithTitle:[_notificationsOrganiser headerInSection:section - 1] andBottomLine:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 0.0;
    }
    
    return 30.0;
}

#pragma mark - View image delegate

-(void)viewPostImage:(UIImage*)postImage
{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
//    ViewPostImageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ViewPostImage"];
//    vc.image = postImage;
//    vc.view.backgroundColor = self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.67];
//    vc.modalPresentationStyle = UIModalPresentationCustom;
//    
//    [vc setTransitioningDelegate:self.transitionViewImageController];
//    
//    [self.view setBackgroundColor:[UIColor whiteColor]];
//    [self presentViewController:vc animated:YES completion:nil];
    
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    GLPViewImageViewController *viewImage = [storyboard instantiateViewControllerWithIdentifier:@"GLPViewImageViewController"];
    viewImage.image = postImage;
    viewImage.view.backgroundColor = self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.89];
    viewImage.modalPresentationStyle = UIModalPresentationCustom;
    
    if(![GLPiOSSupportHelper isIOS6])
    {
        [viewImage setTransitioningDelegate:self.transitionViewImageController];
    }
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self presentViewController:viewImage animated:YES completion:nil];
}

#pragma mark - GLPPostCellDelegate

-(void)elementTouchedWithRemoteKey:(NSInteger)remoteKey
{
    DDLogDebug(@"GLPProfileViewController : navigateToUsersProfileWithRemoteKey: %ld", (long)remoteKey);
}

- (void)showLocationWithLocation:(GLPLocation *)location
{
    _selectedLocation = location;
    
    [self performSegueWithIdentifier:@"show location" sender:self];
}

- (void)navigateToPostForCommentWithIndex:(NSInteger)postIndex
{
    _showComment = YES;
    self.selectedPost = _posts[postIndex - 1];
    
    self.commentCreated = NO;
    [self performSegueWithIdentifier:@"view post" sender:self];
}

- (void)goingButtonTouchedWithNotification:(NSNotification *)notification
{
    _selectedPost = notification.userInfo[@"post"];
    
    //Show the pop up view.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    GLPAttendingPopUpViewController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"GLPAttendingPopUpViewController"];
    
    [cvc setDelegate:self];
    [cvc setEventPost:_selectedPost];
    
    cvc.modalPresentationStyle = UIModalPresentationCustom;
    
    [cvc setTransitioningDelegate:self.transitionViewPopUpAttend];
    
    [self presentViewController:cvc animated:YES completion:nil];
}

#pragma mark - GLPPopUpDialogViewControllerDelegate

- (void)showAttendees
{
    [self performSegueWithIdentifier:@"show attendees" sender:self];
}

- (void)addEventToCalendar
{
    [[GLPCalendarManager sharedInstance] addEventPostToCalendar:_selectedPost withCallback:^(CalendarEventStatus resultStatus) {
        
        switch (resultStatus) {
            case kSuccess:
                
                dispatch_async (dispatch_get_main_queue(), ^{
                    [WebClientHelper showEventSuccessfullyAddedToCalendar];
                });
                
                break;
                
            case kPermissionsError:
                
                dispatch_async (dispatch_get_main_queue(), ^{
                    [WebClientHelper showErrorPermissionsToCalendar];
                });
                break;
                
            case kOtherError:
                
                dispatch_async (dispatch_get_main_queue(), ^{
                    [WebClientHelper showErrorSavingEventToCalendar];
                });
                break;
                
            default:
                break;
        }
        
    }];
}

#pragma mark - New comment delegate

-(void)setPreviousViewToNavigationBar
{
}

-(void)setPreviousNavigationBarName
{
    [self.navigationItem setTitle:@"Me"];
}

-(void)hideNavigationBarAndButtonWithNewTitle:(NSString*)newTitle
{
    [self.navigationItem setTitle:newTitle];
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

-(void)removeTableViewPostWithIndex:(int)index
{
    NSMutableArray *rowsDeleteIndexPath = [[NSMutableArray alloc] init];
    
    [rowsDeleteIndexPath addObject:[NSIndexPath indexPathForRow:index+1 inSection:0]];
    
    [self.tableView deleteRowsAtIndexPaths:rowsDeleteIndexPath withRowAnimation:UITableViewRowAnimationRight];
}

#pragma mark - Scroll view

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(self.posts.count == 0)
    {
        return;
    }
    
    //Capture the current cells that are visible and add them to the GLPFlurryVisibleProcessor.
    
    NSArray *visiblePosts = [self snapshotVisibleCells];
    
//    DDLogDebug(@"scrollViewDidEndDecelerating1 posts: %@", visiblePosts);
    
    [[GLPVideoLoaderManager sharedInstance] visiblePosts:visiblePosts];
    
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(decelerate == 0)
    {
        NSArray *visiblePosts = [self snapshotVisibleCells];
        
//        DDLogDebug(@"scrollViewDidEndDragging2 posts: %@", visiblePosts);
        
        
        [[GLPVideoLoaderManager sharedInstance] visiblePosts:visiblePosts];
    }
}

/**
 This method is used to take a snapshot of the current visible posts cells.
 
 @return The visible posts.
 
 */
-(NSArray *)snapshotVisibleCells
{
    NSMutableArray *visiblePosts = [[NSMutableArray alloc] init];
    
    NSArray *paths = [self.tableView indexPathsForVisibleRows];
    
    for (NSIndexPath *path in paths)
    {
        //Avoid any out of bounds access in array
        
        if(path.row < self.posts.count)
        {
            [visiblePosts addObject:[self.posts objectAtIndex:path.row]];
        }
        
    }
    
    return visiblePosts;
}

#pragma mark - ProfileTopViewCellDelegate

- (void)segmentSwitchedWithButtonType:(ButtonType)buttonType
{
    if(!_tabButtonEnabled) {
        return;
    }
    
    _selectedTab = buttonType;
    
    if(_selectedTab == kButtonRight) {
        [self notificationsTabClick];
    }
    
    [self.tableView reloadData];
}


- (void)changeProfileImage:(id)sender
{
    UIActionSheet *actionSheet = nil;

    if(_user.profileImage)
    {
        actionSheet = [[UIActionSheet alloc]initWithTitle:@"Image Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View image", @"Change image", nil];
    }
    else
    {
        actionSheet = [[UIActionSheet alloc]initWithTitle:@"Image Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View image", @"Add image", nil];
    }
    
    actionSheet.tag = 1;

    [actionSheet showInView:[self.view window]];
}

- (void)badgeTouched
{
    [self performSegueWithIdentifier:@"view badges" sender:self];
}

- (void)numberOfPostTouched
{
    if(_posts.count == 0)
    {
        return;
    }
    
    if(_selectedTab == kButtonLeft)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
}

- (void)numberOfGroupsTouched
{
    DDLogDebug(@"numberOfGroupsTouched");

}

- (void)numberOfRsvpsTouched
{
    [self performSegueWithIdentifier:@"show attending events" sender:self];

}

#pragma mark - Selectors

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    
    
    if([segue.identifier isEqualToString:@"view post"])
    {
        //Hide tabbar.
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
        ViewPostViewController *vc = segue.destinationViewController;
        vc.commentJustCreated = self.commentCreated;
        vc.commentNotificationDate = self.commentNotificationDate;
        
        vc.post = self.selectedPost;
        vc.showComment = _showComment;
        vc.isFromCampusLive = NO;
        vc.isViewPostNotifications = YES;
        vc.isViewPostFromNotifications = self.isPostFromNotifications;
        self.selectedPost = nil;
        _showComment = NO;
        
    }
    else if([segue.identifier isEqualToString:@"view private profile"])
    {
        GLPPrivateProfileViewController *profileViewController = segue.destinationViewController;
        
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
        groupVC.userCreatedPost = _userCreatedTheGroupPost;
    }
    else if ([segue.identifier isEqualToString:@"view badges"])
    {
        GLPBadgesViewController *bVC = segue.destinationViewController;
        bVC.customTitle = @"My";
    }
    else if ([segue.identifier isEqualToString:@"show location"])
    {
        GLPShowLocationViewController *showLocationVC = segue.destinationViewController;
        
        showLocationVC.location = _selectedLocation;
    }
    else if([segue.identifier isEqualToString:@"show image selector"])
    {
        ImageSelectorViewController *imgSelectorVC = segue.destinationViewController;
        
        [imgSelectorVC setDelegate:self];
    }
    else if ([segue.identifier isEqualToString:@"show attendees"])
    {
        GLPShowUsersViewController *showUsersVC = segue.destinationViewController;
        
        showUsersVC.postRemoteKey = _selectedPost.remoteKey;
        
        showUsersVC.selectedTitle = @"GUEST LIST";
    }
    else if([segue.identifier isEqualToString:@"show attending events"])
    {
        GLPAttendingPostsViewController *attendingPostsViewController = segue.destinationViewController;
        
        attendingPostsViewController.selectedUser = _user;
    }
}

- (void)reloadContent
{
    if(_selectedTab == kButtonLeft)
    {
        DDLogDebug(@"Reload posts");
        [self loadPosts];
    }
    else
    {
        DDLogDebug(@"Reload notifications");
        [self refreshNotifications];
    }
}

#pragma mark - UI

- (void)hideOrShowPostsEmptyView
{
    if(_posts.count == 0)
    {
        [[GLPEmptyViewManager sharedInstance] addEmptyViewWithKindOfView:kProfilePostsEmptyView withView:self.tableView];
    }
    else
    {
        [[GLPEmptyViewManager sharedInstance] hideViewWithKind:kProfilePostsEmptyView];
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




@end
