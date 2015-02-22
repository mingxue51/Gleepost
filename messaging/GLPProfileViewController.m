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
#import "GLPInvitationManager.h"
#import "TransitionDelegateViewImage.h"
#import "GLPSettingsViewController.h"
#import "GLPiOSSupportHelper.h"
#import "GroupViewController.h"
#import "EmptyMessage.h"
#import "TableViewHelper.h"
#import "UINavigationBar+Utils.h"
#import "UINavigationBar+Format.h"
#import "GLPBadgesViewController.h"
#import "UIRefreshControl+CustomLoader.h"
#import "GLPVideoLoaderManager.h"
#import "GLPShowLocationViewController.h"
#import "ChangeImageProgressView.h"
#import "GLPViewImageViewController.h"
#import "NotificationsOrganiserHelper.h"
#import "GLPLiveGroupManager.h"
#import "GLPCalendarManager.h"
#import "GLPAttendingPopUpViewController.h"
#import "TDPopUpAfterGoingView.h"
#import "GLPShowUsersViewController.h"
#import "GLPEmptyViewManager.h"
#import "GLPAttendingPostsViewController.h"
#import "GLPViewPendingPostViewController.h"
#import "GLPTrackViewsCountProcessor.h"
#import "GLPTableActivityIndicator.h"
#import "LoggedInUserProfileManager.h"
#import "GLPLoadingCell.h"

@interface GLPProfileViewController () <MFMessageComposeViewControllerDelegate, UIActionSheetDelegate, GLPAttendingPopUpViewControllerDelegate>

@property (strong, nonatomic) GLPUser *user;

@property (assign, nonatomic) int numberOfRows;

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
@property (assign, nonatomic) NSInteger groupPostCreatedRemoteKey;

@property (strong, nonatomic) EmptyMessage *emptyNotificationsMessage;

@property (assign, nonatomic) BOOL isPostFromNotifications;

@property (assign, nonatomic) NSInteger currentNumberOfPN;

@property (strong, nonatomic) GLPLocation *selectedLocation;

@property (strong, nonatomic) GLPPost *selectedPost;

@property (assign, nonatomic) NSInteger selectedUserId;

@property (strong, nonatomic) ChangeImageProgressView *progressView;

@property (strong, nonatomic) NotificationsOrganiserHelper *notificationsOrganiser;

@property (strong, nonatomic) TDPopUpAfterGoingView *transitionViewPopUpAttend;

/** Captures the visibility of current cells. */
@property (strong, nonatomic) GLPTrackViewsCountProcessor *trackViewsCountProcessor;

@property (strong, nonatomic) GLPTableActivityIndicator *tableActivityIndicator;


@property (assign, nonatomic) BOOL postsLoading;
@property (strong, nonatomic) LoggedInUserProfileManager *loggedInUserProfileManager;

/** Properties for loading previous posts. */
@property (assign, nonatomic) GLPLoadingCellStatus loadingCellStatus;

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
    
    [self configureViewDidLoadNSNotifications];
    
    [self loadPosts];
    
//    [self startLoading];
//    [[GLPEmptyViewManager sharedInstance] hideViewWithKind:kProfilePostsEmptyView];
//    _postsLoading = YES;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_trackViewsCountProcessor resetSentPostsSet];
    [super viewDidDisappear:animated];
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
        self.tabBarController.tabBar.tintColor = [[GLPThemeManager sharedInstance] tabbarSelectedColour];
        [AppearanceHelper setSelectedColourForTabbarItem:self.profileTabbarItem withColour:[AppearanceHelper redGleepostColour]];
    }

    if(_fromPushNotification)
    {
        DDLogDebug(@"GLPProfileViewController : fromPushNotifications");
        
        _selectedTab = kButtonRight;
    }

    [self configureViewWillAppearNSNotifications];
    
    [self loadInternalNotifications];
    
    if(_selectedTab == kButtonRight)
    {
        [self notificationsTabClick];
    }
    
    [self fetchUserData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self removeViewWillDisappearNSNotifications];
    [self removeGoingButtonNotification];
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setTitle];
    [self configureRefreshControl];
    [self setUpGoingButtonNotification];
    [self fetchUsersPostsIfNeeded];
    [self sendViewToGAI:NSStringFromClass([self class])];
    [self sendViewToFlurry:NSStringFromClass([self class])];
}

- (void)configureViewDidLoadNSNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewsCounter:) name:GLPNOTIFICATION_POST_CELL_VIEWS_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchUserData) name:GLPNOTIFICATION_REFRESH_PROFILE_CELL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeDeallocNotifications) name:GLPNOTIFICATION_REMOVE_VC_NOTIFICATIONS object:nil];
    [self configureManagerNotifications];
}

- (void)configureManagerNotifications
{
    NSString *notificationName = [_loggedInUserProfileManager postsNotificationName];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postsLoaded:) name:notificationName object:nil];
    
    notificationName = [_loggedInUserProfileManager previousPostsNotificationName];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(previousPostsLoaded:) name:notificationName object:nil];
}

-(void)removeDeallocNotifications
{
    [self removeViewDidLoadNSNotifications];
}

- (void)removeViewDidLoadNSNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPPostUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPLikedPostUdated" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPNewPostByUser" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POST_DELETED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POST_CELL_VIEWS_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_REFRESH_PROFILE_CELL object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_REMOVE_VC_NOTIFICATIONS object:nil];
    [self removeManagerNotifications];
}

- (void)removeManagerNotifications
{
    NSString *notificationName = [_loggedInUserProfileManager postsNotificationName];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];
    
    notificationName = [_loggedInUserProfileManager previousPostsNotificationName];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];
}

- (void)removeViewWillDisappearNSNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_NEW_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POST_IMAGE_LOADED object:nil];
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
    
    if(DEV)
    {
//        [WebClientHelper showLowMemoryWarningFromClass:@"GLPProfileViewController"];
    }
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

-(void)configureViewWillAppearNSNotifications
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
}

/**
 This method is called when there is an update in views count.
 
 @param notification the notification contains post remote key and the updated
 number of views.
 */
- (void)updateViewsCounter:(NSNotification *)notification
{
    [_loggedInUserProfileManager parseAndUpdatedViewsCountPostWithNotification:notification withCallbackBlock:^(NSInteger index) {
        
        if(index != -1 && _selectedTab == kButtonLeft)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshCellViewWithIndex:index+1];
            });
        }
    }];
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
    [self.navigationController.navigationBar setButton:kRight specialButton:kQuit withImageName:@"settings_btn" withButtonSize:CGSizeMake(30.0, 30.0) withSelector:@selector(showSettings:) andTarget:self];
}

-(void)configureNavigationBar
{
    //Change the format of the navigation bar.
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    
    //Change the format of the navigation bar.
    [self.navigationController.navigationBar setFontFormatWithColour:kBlack];

    //Use the default method of formatting only if this VC is the first appeared.
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
    
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
    
//    self.posts = [[NSMutableArray alloc] init];
    
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
    
    _trackViewsCountProcessor = [[GLPTrackViewsCountProcessor alloc] init];
    _user = nil;
    
    _tableActivityIndicator = [[GLPTableActivityIndicator alloc] initWithPosition:kActivityIndicatorBottom withView:self.tableView];
    
//    _postsLoading = NO;
    
    _loggedInUserProfileManager = [[LoggedInUserProfileManager alloc] init];
    
    self.loadingCellStatus = kGLPLoadingCellStatusFinished;
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
    NSInteger index = [_loggedInUserProfileManager parseRefreshCellNotification:notification];
    
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

- (void)updatePost:(NSNotification *)notification
{
    NSInteger index = [_loggedInUserProfileManager updateSocialDataPostWithNotification:notification];
    
    if(index != NSNotFound)
    {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)updateLikedPost:(NSNotification*)notification
{
    [_loggedInUserProfileManager updateLikedPostWithNotification:notification];
    [self.tableView reloadData];
}

- (void)postByUserInCampusWall:(NSNotification *)notification
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
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


-(void)showSettings:(id)sender
{
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
    
    //Communicate with server to change the image.
    [self uploadAndSetUsersImage];
}

#pragma mark - RemovePostCellDelegate

- (void)removePostWithPost:(GLPPost *)post
{
    NSInteger index = [_loggedInUserProfileManager removePostWithPost:post];
    if(index != NSNotFound)
    {
        [self removeTableViewPostWithIndex:index];
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
    [[GLPEmptyViewManager sharedInstance] hideViewWithKind:kProfilePostsEmptyView];
    _postsLoading = YES;
    [_tableActivityIndicator startActivityIndicator];
    [_loggedInUserProfileManager getPosts];
}

- (void)loadPreviousPosts
{
    if(_selectedTab == kButtonRight)
    {
        return;
    }
    
    if(self.postsLoading) {
        return;
    }
    
    if([_loggedInUserProfileManager postsCount] == 0) {
        self.loadingCellStatus = kGLPLoadingCellStatusFinished;
        return;
    }
    
    if(self.loadingCellStatus == kGLPLoadingCellStatusLoading) {
        return;
    }
    
    [self startLoading];
    self.loadingCellStatus = kGLPLoadingCellStatusLoading;
    [_loggedInUserProfileManager loadPreviousPosts];
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
                [WebClientHelper errorLoadingGroup];
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
        ++i;
    }
    
    [_notificationsOrganiser resetData];
    [_notificationsOrganiser organiseNotifications:_notifications];
    
    [self.tableView reloadData];
    
    _tabButtonEnabled = YES;
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

# pragma mark - Notifications

-(void)receiveInternalNotificationNotification:(NSNotification *)notification
{
    DDLogInfo(@"Receive internal notifications %@", notification.userInfo);
    
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
        }
        
    } andRemoteCallback:^(BOOL success, BOOL updatedData, GLPUser *user) {
       
        if(success && updatedData)
        {
            DDLogDebug(@"Data needs to be updated remotely: %@", user);
            _user = user;
            [self refreshCellViewWithIndex:0];
        }
    }];
}

- (void)postsLoaded:(NSNotification *)notification
{
    BOOL success = [notification.userInfo[@"success"] boolValue];
    BOOL remote = [notification.userInfo[@"remote"] boolValue];
    
    if(remote)
    {
        _postsLoading = NO;
        _postUploaded = NO;
        
        [_tableActivityIndicator stopActivityIndicator];
        
        [self stopLoading];
        
        if(success)
        {
            BOOL remains = [_loggedInUserProfileManager postsCount] == kGLPNumberOfPosts ? YES : NO;
            self.loadingCellStatus = remains ? kGLPLoadingCellStatusInit : kGLPLoadingCellStatusFinished;
            [self.tableView reloadData];
        }
        
        if([_loggedInUserProfileManager postsCount] == 0)
        {
            [[GLPEmptyViewManager sharedInstance] addEmptyViewWithKindOfView:kProfilePostsEmptyView withView:self.tableView];
        }
        else
        {
            [[GLPEmptyViewManager sharedInstance] hideViewWithKind:kProfilePostsEmptyView];
        }
        
    }
    else
    {
        if([_loggedInUserProfileManager postsCount] == 0)
        {
            [_tableActivityIndicator startActivityIndicator];
        }
        else
        {
            _postsLoading = NO;
            [_tableActivityIndicator stopActivityIndicator];
            [[GLPEmptyViewManager sharedInstance] hideViewWithKind:kProfilePostsEmptyView];
            [self.tableView reloadData];
        }
    }
}

- (void)previousPostsLoaded:(NSNotification *)notification
{
    NSArray *previousPosts = notification.userInfo[@"posts"];
    BOOL success = [notification.userInfo[@"success"] boolValue];
    NSInteger remain = [notification.userInfo[@"remain"] integerValue];
    
    [self stopLoading];
    
    if(!success) {
        self.loadingCellStatus = kGLPLoadingCellStatusError;
        [self reloadLoadingCell];
        return;
    }
    
    self.loadingCellStatus = remain ? kGLPLoadingCellStatusInit : kGLPLoadingCellStatusFinished;
    
    if(previousPosts.count > 0) {
        
        [self.tableView reloadData];
        
    } else {
        [self reloadLoadingCell];
    }
}

- (void)reloadLoadingCell
{
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[_loggedInUserProfileManager postsCount] inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)fetchUsersPostsIfNeeded
{
    if([_loggedInUserProfileManager postsCount] == 0 || _postUploaded)
    {
        [_loggedInUserProfileManager reloadPosts];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(_selectedTab == kButtonRight)
    {
        //Notifications are selected.
        return [_notificationsOrganiser numberOfSections] + 1;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_selectedTab == kButtonLeft)
    {
        [_emptyNotificationsMessage hideEmptyMessageView];
        return self.numberOfRows + [_loggedInUserProfileManager postsCount] + 1;
    }
    else
    {
        NSInteger extraRow = 0;
        
        if(_notifications.count == 0)
        {
            [_emptyNotificationsMessage showEmptyMessageView];
        }
        else
        {
            [_emptyNotificationsMessage hideEmptyMessageView];
            extraRow = 1;
        }
        
        if(section == 0)
        {
            return self.numberOfRows;
        }
        
        return [_notificationsOrganiser notificationsAtSectionIndex:section - 1].count;
    }
}

#pragma mark - Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Try to load previous posts.
    if(indexPath.row-1 == [_loggedInUserProfileManager postsCount] && _selectedTab == kButtonLeft)
    {
        return [TableViewHelper generateLoadingCell];
    }
    
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
        if([_loggedInUserProfileManager postsCount] != 0)
        {
            GLPPost *post = [_loggedInUserProfileManager postWithIndex:indexPath.row - 1];
            
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
            
            [postViewCell setPost:post withPostIndexPath:indexPath];
            
            return postViewCell;
        }
    }
    
    //TODO: See this again.
    // => yep
    return nil;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row-1 == [_loggedInUserProfileManager postsCount] && _selectedTab == kButtonLeft)
    {
        return;
    }
    
    if(![[cell class] isSubclassOfClass:[GLPPostCell class]])
    {
        return;
        
    }
    
    if([_loggedInUserProfileManager postsCount] == 0)
    {
        DDLogError(@"Abord ending display with cell.");
        return;
    }
    
    GLPPost *post = [_loggedInUserProfileManager postWithIndex:indexPath.row - 1];
    
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
    if(_selectedTab == kLeft)
    {
        if(indexPath.row-1 == [_loggedInUserProfileManager postsCount])
        {
            return;
        }
        
        self.selectedPost = [_loggedInUserProfileManager postWithIndex:indexPath.row - 1];
        self.commentCreated = NO;
        [self performSegueWithIdentifier:@"view post" sender:self];
        
        return;
    }
    
    if (indexPath.section > 0)
    {
        if(_selectedTab == kButtonRight)
        {
            GLPNotification *notification = [_notificationsOrganiser notificationWithIndex:indexPath.row andSectionIndex:indexPath.section - 1];
            
            // navigate to post.
            if(notification.notificationType == kGLPNotificationTypeLiked || notification.notificationType == kGLPNotificationTypeCommented)
            {
                self.selectedPost = [[GLPPost alloc] initWithRemoteKey:notification.postRemoteKey];
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
                _groupPostCreatedRemoteKey = notification.postRemoteKey;
                [self performSegueWithIdentifier:@"view group" sender:self];
            }
            else if(notification.notificationType == kGLPNotificationTypePostApproved)
            {
                self.selectedPost = [[GLPPost alloc] initWithRemoteKey:notification.postRemoteKey];
                self.isPostFromNotifications = YES;
                self.commentNotificationDate = nil;
                [self performSegueWithIdentifier:@"view post" sender:self];
            }
            else if(notification.notificationType == kGLPNotificationTypePostRejected)
            {
                self.selectedPost = [[GLPPost alloc] initWithRemoteKey:notification.postRemoteKey];
                self.commentNotificationDate = nil;
                self.isPostFromNotifications = YES;
                [self performSegueWithIdentifier:@"view pending post" sender:self];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row - 1 == [_loggedInUserProfileManager postsCount] && _selectedTab == kButtonLeft) {
        return (self.loadingCellStatus != kGLPLoadingCellStatusFinished) ? kGLPLoadingCellHeight : 0;
    }
    
    if(indexPath.row == 0 && indexPath.section == 0)
    {
        return PROFILE_TOP_VIEW_HEIGHT;
    }
    else if (indexPath.section > 0)
    {
        if(_selectedTab == kButtonRight)
        {
            GLPNotification *notification = [_notificationsOrganiser notificationWithIndex:indexPath.row andSectionIndex:indexPath.section - 1];
            return [GLPNotificationCell getCellHeightForNotification:notification];
        }
    }
    else if (indexPath.row >= 1 && indexPath.section == 0)
    {
        GLPPost *currentPost = [_loggedInUserProfileManager postWithIndex:indexPath.row - 1];
        
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row - 1 == [_loggedInUserProfileManager postsCount] && self.loadingCellStatus == kGLPLoadingCellStatusInit && _selectedTab == kButtonLeft) {
        DDLogInfo(@"Load previous posts cell activated");
        [self loadPreviousPosts];
    }
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

- (void)navigateToPostForCommentWithIndexPath:(NSIndexPath *)postIndexPath
{
    _showComment = YES;
    self.selectedPost = [_loggedInUserProfileManager postWithIndex:postIndexPath.row - 1];
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

-(void)removeTableViewPostWithIndex:(NSInteger)index
{
    NSMutableArray *rowsDeleteIndexPath = [[NSMutableArray alloc] init];
    
    [rowsDeleteIndexPath addObject:[NSIndexPath indexPathForRow:index+1 inSection:0]];
    
    [self.tableView deleteRowsAtIndexPaths:rowsDeleteIndexPath withRowAnimation:UITableViewRowAnimationRight];
}

#pragma mark - Scroll view

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(_selectedTab == kButtonRight)
    {
        return;
    }
    
    [_trackViewsCountProcessor resetVisibleCells];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    if(_selectedTab == kButtonRight)
    {
        return;
    }
    
    if([_loggedInUserProfileManager postsCount] == 0)
    {
        return;
    }
    
    //Capture the current cells that are visible and add them to the GLPFlurryVisibleProcessor.
    
    NSMutableArray *postsYValues = nil;
    
    NSArray *visiblePosts = [self getVisiblePostsInTableViewWithYValues:&postsYValues];
    
    [_trackViewsCountProcessor trackVisiblePosts:visiblePosts withPostsYValues:postsYValues];

    [[GLPVideoLoaderManager sharedInstance] visiblePosts:visiblePosts];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(_selectedTab == kButtonRight)
    {
        return;
    }
    
    if(decelerate == 0)
    {
        NSMutableArray *postsYValues = nil;
        
        NSArray *visiblePosts = [self getVisiblePostsInTableViewWithYValues:&postsYValues];
        
        [_trackViewsCountProcessor trackVisiblePosts:visiblePosts withPostsYValues:postsYValues];

        [[GLPVideoLoaderManager sharedInstance] visiblePosts:visiblePosts];
    }
}

/**
 This method is used to take a snapshot of the current visible posts cells.
 
 @param postsYValues this parameter is passed in order to be returned with the current
 Y values of each respect visible post.
 
 @return The visible posts.
 
 */
-(NSArray *)getVisiblePostsInTableViewWithYValues:(NSMutableArray **)postsYValues
{
    NSMutableArray *visiblePosts = [[NSMutableArray alloc] init];
    
    *postsYValues = [[NSMutableArray alloc] init];

    NSArray *paths = [self.tableView indexPathsForVisibleRows];
    
    for (NSIndexPath *path in paths)
    {
        if(path.row == 0)
        {
            continue;
        }
        
        //Avoid any out of bounds access in array
        
        if(path.row < [_loggedInUserProfileManager postsCount])
        {
            [visiblePosts addObject:[_loggedInUserProfileManager postWithIndex:path.row - 1]];
            CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:path];
            CGRect rectInSuperview = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];
            [*postsYValues addObject:@(rectInTableView.size.height/2.0 + rectInSuperview.origin.y)];
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
    
    if(_selectedTab == kButtonRight)
    {
        [_tableActivityIndicator stopActivityIndicator];
        [[GLPEmptyViewManager sharedInstance] hideViewWithKind:kProfilePostsEmptyView];

        [self notificationsTabClick];
    }
    else
    {
        if([_loggedInUserProfileManager postsCount] == 0 && !_postsLoading)
        {
            [[GLPEmptyViewManager sharedInstance] addEmptyViewWithKindOfView:kProfilePostsEmptyView withView:self.tableView];
            [_tableActivityIndicator stopActivityIndicator];
        }
        else if([_loggedInUserProfileManager postsCount] != 0 && !_postsLoading)
        {
            [[GLPEmptyViewManager sharedInstance] hideViewWithKind:kProfilePostsEmptyView];
            [_tableActivityIndicator stopActivityIndicator];
        }
        else if(_postsLoading)
        {
            [[GLPEmptyViewManager sharedInstance] hideViewWithKind:kProfilePostsEmptyView];
            [_tableActivityIndicator startActivityIndicator];
        }
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
    if([_loggedInUserProfileManager postsCount] == 0)
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
        vc.isViewPostFromNotifications = self.isPostFromNotifications;
        self.selectedPost = nil;
        _showComment = NO;
    }
    else if([segue.identifier isEqualToString:@"view pending post"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        GLPViewPendingPostViewController *vc = segue.destinationViewController;
        vc.pendingPost = self.selectedPost;
        vc.isViewPostFromNotifications = self.isPostFromNotifications;
        self.selectedPost = nil;
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
        groupVC.postCreatedRemoteKey = _groupPostCreatedRemoteKey;
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
        [self loadPosts];
    }
    else
    {
        [self refreshNotifications];
    }
}

#pragma mark - Actions

- (void)showMessageViewControllerWithBody:(NSString *)messageBody {
    if (![MFMessageComposeViewController canSendText]) {
//        [WebClientHelper showStandardErrorWithTitle:@"Error" andContent:@"Your device doesn't support SMS."];
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
//            [WebClientHelper showStandardErrorWithTitle:@"Error" andContent:@"An error occurred while sending the SMS"];
            break;
        }
        case MessageComposeResultSent: {
//            [WebClientHelper showStandardErrorWithTitle:@"Sent" andContent:@"SMS sent successfully"];
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