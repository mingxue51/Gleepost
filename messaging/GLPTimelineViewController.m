//
//  GLPTimelineViewController.m
//  Gleepost
//
//  Created by Lukas on 11/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.

#import "GLPTimelineViewController.h"
#import "ViewPostViewController.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "MBProgressHUD.h"
#import "AddCommentViewController.h"
#import "NewCommentView.h"
#import "Social/Social.h"
#import <Twitter/Twitter.h>
#import "PopUpMessage.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NewPostView.h"
#import <QuartzCore/QuartzCore.h>
#import "AppearanceHelper.h"
#import "GLPPostManager.h"
#import "GLPLoadingCell.h"
#import "SessionManager.h"
#import "ContactsManager.h"
#import "GLPProfileViewController.h"
#import "TSMessage.h"
#import "GLPNewElementsIndicatorView.h"
#import "UIViewController+GAI.h"
#import "UIViewController+Flurry.h"
#import "GLPPostNotificationHelper.h"
#import "GLPThemeManager.h"
#import "ImageFormatterHelper.h"
#import "GLPPrivateProfileViewController.h"
#import "GLPPostImageLoader.h"
#import "GLPMessagesLoader.h"
#import "GLPProfileLoader.h"
#import "GLPNewCategoriesViewController.h"
#import "TransitionDelegateViewCategories.h"
#import "UIImage+StackBlur.h"
#import "ConversationManager.h"
#import "AnimationDayController.h"
#import "GLPGroupManager.h"
#import "CampusWallGroupsPostsManager.h"
#import "GLPiOSSupportHelper.h"
#import "TableViewHelper.h"
#import "GLPFlurryVisibleCellProcessor.h"
#import "GLPVideoLoaderManager.h"
#import "GLPWalkthroughViewController.h"
#import "UINavigationBar+Format.h"
#import "UINavigationBar+Utils.h"
#import "UIRefreshControl+CustomLoader.h"
#import "IntroKindOfNewPostViewController.h"
#import "GLPVideoUploadManager.h"
#import "GLPVideoPostCWProgressManager.h"
#import "UploadingProgressView.h"
#import "NewPostViewController.h"
#import "GLPShowLocationViewController.h"
#import "CategoryManager.h"
#import "GLPAttendingPopUpViewController.h"
#import "TDPopUpAfterGoingView.h"
#import "GLPCalendarManager.h"
#import "GLPShowUsersViewController.h"
#import "GLPTableActivityIndicator.h"
#import "GLPApprovalManager.h"
#import "GLPPendingPostsManager.h"
#import "GLPPendingCell.h"
#import "GLPCategoryTitleCell.h"
#import "GLPTrackViewsCountProcessor.h"
#import "GLPCampusWallAsyncProcessor.h"
#import "GLPCategoryCell.h"
#import "GLPCampusWallStretchedView.h"
#import "CampusWallFakeNavigationBar.h"
#import "GLPCampusLiveViewController.h"
#import "GLPViewImageHelper.h"

@interface GLPTimelineViewController () <GLPAttendingPopUpViewControllerDelegate, GLPCategoriesViewControllerDelegate, GLPCampusWallStretchedViewDelegate, GLPCampusLiveViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray *posts;
@property (strong, nonatomic) GLPPost *selectedPost;
@property (strong, nonatomic) GLPUser *selectedUser;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSMutableArray *shownCells;
@property (strong, nonatomic) NewPostView *postView;
@property (strong, nonatomic) TransitionDelegateViewCategories *transitionCategoriesViewController;

@property (strong, nonatomic) TDPopUpAfterGoingView *transitionViewPopUpAttend;
@property (strong, nonatomic) UIImage *imageToBeView;

// cron controls
@property (assign, nonatomic) BOOL isReloadingCronRunning;
@property (assign, nonatomic) BOOL shouldReloadingCronRun;

//  table view controls
@property (assign, nonatomic) GLPLoadingCellStatus loadingCellStatus;
@property (assign, nonatomic) BOOL isLoading;
@property (assign, nonatomic) BOOL firstLoadSuccessful;
@property (assign, nonatomic) BOOL tableViewInScrolling;
@property (assign, nonatomic) NSInteger insertedNewRowsCount; // count of new rows inserted
@property (assign, nonatomic) NSInteger postIndexToReload;

// Not need because we use performselector which areis deprioritized during scrolling
@property (assign, nonatomic) BOOL shouldLoadNewPostsAfterScrolling;
@property (assign, nonatomic) int postsNewRowsCountToInsertAfterScrolling;

@property (strong, nonatomic) GLPNewElementsIndicatorView *elementsIndicatorView;

@property (assign, nonatomic) NSInteger selectedUserId;

//Used when there is new comment.
@property (assign, nonatomic) BOOL commentCreated;

//TODO: Remove after the integration of image posts.
@property NSInteger selectedIndex;

@property (strong, nonatomic) UITabBarItem *homeTabbarItem;


//Hidden navigation bar.
@property (assign, nonatomic) CGFloat startContentOffset;
@property (assign, nonatomic) CGFloat lastContentOffset;
@property (assign, nonatomic) BOOL hidden;

//Header.
@property (strong, nonatomic)  UploadingProgressView *pView;

//Groups.
@property (strong, nonatomic) CampusWallGroupsPostsManager *groupsPostsManager;

@property (assign, nonatomic, getter = isTableViewFirstTimeScrolled) BOOL tableViewFirstTimeScrolled;

//Extra view will present to hide the change of background during the viewing of new post.
//@property (strong, nonatomic) UIImageView *topImageView;

/** Captures the visibility of current cells. */
@property (strong, nonatomic) GLPFlurryVisibleCellProcessor *flurryVisibleProcessor;
@property (strong, nonatomic) GLPTrackViewsCountProcessor *trackViewsCountProcessor;
@property (strong, nonatomic) GLPCampusWallAsyncProcessor *campusWallAsyncProcessor;

//@property (strong, nonatomic) EmptyMessage *emptyCategoryPostsMessage;

@property (assign, nonatomic, getter = isWalkthroughFinished) BOOL walkthroughFinished;

@property (strong, nonatomic) GLPLocation *selectedLocation;

/** Used when user press the comment button on view from campus wall. */
@property (assign, nonatomic) BOOL showComment;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) GLPTableActivityIndicator *tableActivityIndicator;

@property (strong, nonatomic) GLPCampusWallStretchedView *strechedImageView;

@property (strong, nonatomic) CampusWallFakeNavigationBar *fakeNavigationBar;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) BOOL viewDisappeared;

@end


@implementation GLPTimelineViewController

//Constants.
const float TOP_OFFSET = -64.0;
const float OFFSET_START_ANIMATING_CW = 360.0;


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self configNotifications];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureTopImageView];

    [self configTableView];

    [self configHeader];

    [self configTabbarFormat];
    
    [self configNewElementsIndicatorView];
    
    [self initialiseObjects];
    
    [self addNavigationButtons];

    
     //Moved to GLPNetworkManager.
//    NSTimer *t = [NSTimer timerWithTimeInterval:0.5f target:self selector:@selector(startLoadingContents:) userInfo:nil repeats:NO];
//    [t fire];
    
    [self loadInitialPosts];
    
    [self startBackgroundOperations];
    
    [self configNavigationBar];

    
    //Find the sunset sunrise for preparation of the new chat.
    //TODO: That's will be used in GleepostSD app.
//    [AnimationDayController sharedInstance];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configAppearance];
    
    [self configureRefreshControl];
    
    [self configureNavigationBarBackground];
    
    [self showNetworkErrorViewIfNeeded];
    
    self.viewDisappeared = NO;
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self configureGoingButtonNotification];
    
    if(self.firstLoadSuccessful) {
        [self startReloadingCronImmediately:YES];
    }
    
//    [self showWalkthroughIfNeeded];

    //TODO: Delete that.
    if(self.postIndexToReload!=-1)
    {
        //Refresh post cell in the table view with index.
//        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.postIndexToReload inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        
    }
    
//    [self reloadVisibleCells];

    
    [self sendViewToGAI:NSStringFromClass([self class])];
    [self sendViewToFlurry:NSStringFromClass([self class])];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [self.homeTabbarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor blackColor], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
    
    [AppearanceHelper setUnselectedColourForTabbarItem:self.homeTabbarItem];
    
    //Hide temporary top image view.
//    [_topImageView setHidden:YES];
    
    // hide new element visual indicator if needed
    [self hideNewElementsIndicatorView];
    
    [[GLPVideoLoaderManager sharedInstance] enableViewJustViewed];
    
    //Show navigation bar.
//    [self contract];
    self.viewDisappeared = YES;

    [super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self stopReloadingCron];
    
    [self removeGoingButtonNotification];
    
    [_trackViewsCountProcessor resetSentPostsSet];
    
    [super viewDidDisappear:animated];
}

#pragma mark - Configuration 

-(void)initialiseObjects
{
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    
    //Create the array and initialise.
    self.shownCells = [[NSMutableArray alloc] init];
        
    self.transitionCategoriesViewController = [[TransitionDelegateViewCategories alloc] init];
    
    self.transitionViewPopUpAttend = [[TDPopUpAfterGoingView alloc] init];
    
    //Initialise.
    self.readyToReloadPosts = YES;
    
    // loading related controls
    self.loadingCellStatus = kGLPLoadingCellStatusLoading;
    self.isLoading = NO;
    self.firstLoadSuccessful = NO;
    self.tableViewInScrolling = NO;
    self.insertedNewRowsCount = 0;
    self.shouldLoadNewPostsAfterScrolling = NO;
    self.postsNewRowsCountToInsertAfterScrolling = 0;
    
    self.isReloadingCronRunning = NO;
    self.shouldReloadingCronRun = NO;
    
    self.commentCreated = NO;
    
    self.postIndexToReload = -1;
    
    _flurryVisibleProcessor = [[GLPFlurryVisibleCellProcessor alloc] init];
    _trackViewsCountProcessor = [[GLPTrackViewsCountProcessor alloc] init];
    _campusWallAsyncProcessor = [[GLPCampusWallAsyncProcessor alloc] init];
    
    _walkthroughFinished = NO;
    
    _tableViewFirstTimeScrolled = NO;
    
    _showComment = NO;
    
    _tableActivityIndicator = [[GLPTableActivityIndicator alloc] initWithPosition:kActivityIndicatorBottom withView:self.tableView];
    
    self.viewDisappeared = NO;
}

- (void)startBackgroundOperations
{
    /** Check if there are pending video posts. */
    [[GLPVideoUploadManager sharedInstance] startCheckingForNonUploadedVideoPosts];
    
    [GLPApprovalManager sharedInstance];
    
    [[GLPPendingPostsManager sharedInstance] loadPendingPosts];
    
    [GLPVideoPostCWProgressManager sharedInstance];
}


-(void)removeDeallocNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPPostUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPPostUploaded" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POST_IMAGE_LOADED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPLikedPostUdated" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPShowEvent" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPProfileImageChanged" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POST_DELETED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_HOME_TAPPED_TWICE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_RELOAD_DATA_IN_CW object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_VIDEO_POST_READY object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_NEW_PENDING_POST object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POST_CELL_VIEWS_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_REMOVE_VC_NOTIFICATIONS object:nil];
}

- (void)showNetworkErrorViewIfNeeded
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_SHOW_ERROR_VIEW object:self userInfo:@{@"comingFromClass": [NSNumber numberWithBool:YES]}];
}

- (void)showWalkthroughIfNeeded
{
    if([[SessionManager sharedInstance] isFirstTimeLoggedIn] && ![self isWalkthroughFinished])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone_ipad" bundle:nil];
        GLPWalkthroughViewController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"GLPWalkthroughViewController"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:cvc];
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navigationController animated:YES completion:nil];
    }
    
    _walkthroughFinished = YES;
}


#pragma mark - Notifications

/**
 Updates the number of comments. Called only if number of comments changed in profile view controller or in view post view controller.
 
 @param noticiation the post notification coming from profile view controller.
 
 */
-(void)updatePostWithRemoteKey:(NSNotification*)notification
{
    int index = [GLPPostNotificationHelper parseNotification:notification withPostsArray:self.posts];
    
    if([GLPPostNotificationHelper parseNotification:notification withPostsArray:self.posts] != -1)
    {
        //Reload again only this post.
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)updatePostAfterUploading:(NSNotification*)notification
{
    NSInteger index = [GLPPostNotificationHelper parsePostWithImageUrlNotification:notification withPostsArray:self.posts];

    if(index == -1)
    {
        return;
    }
    
    GLPPost *uploadedPost = self.posts[index];
    
    if(uploadedPost.author.remoteKey == [SessionManager sharedInstance].user.remoteKey)
    {
        //If the post belongs to logged in user then inform his/her profile's posts.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GLPNewPostByUser" object:nil userInfo:nil];
    }
    
    [self refreshCellViewWithIndex: index];
}

/**
 This method should be called when the post is uploaded (GLPPostUploaderManager).
 
 In this case we just refresh the video post to remove the uploading indicator.
 
 @param notification contains videoUrl, thumbnailUrl, key and remoteKey.
 
 */
- (void)updateVideoPostAfterCreatingThePost:(NSNotification *)notification
{
    NSDictionary *data = [notification userInfo];
    
    GLPPost *inPost = data[@"final_post"];
    
    DDLogDebug(@"New video post received in campus wall: %@", inPost);
    
    //Check if the video post is already in the campus wall.
    
    if([self isPostVisible:inPost])
    {
        //Release isLoading variable.
        self.isLoading = NO;
        DDLogDebug(@"Is loading NO");

        return;
    }
    
    [self reloadNewVideoPost:inPost];
}


-(void)updateRealImage:(NSNotification*)notification
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSInteger index = -1;
        
        //        index = [GLPPostNotificationHelper parsePost:&currentPost imageNotification:notification withPostsArray:self.posts];
        index = [GLPPostNotificationHelper parseRefreshCellNotification:notification withPostsArray:self.posts];
        
        
        if(index != -1)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshCellViewWithIndex:index];
            });
        }
        
    });
}

/**
 This method is called when there is an update in views count.
 
 @param notification the notification contains post remote key and the updated
        number of views.
 */
- (void)updateViewsCounter:(NSNotification *)notification
{
    NSInteger postRemoteKey = [notification.userInfo[@"PostRemoteKey"] integerValue];
    NSInteger viewsCount = [notification.userInfo[@"UpdatedViewsCount"] integerValue];
    
    [_campusWallAsyncProcessor parseAndUpdatedViewsCountPostWithPostRemoteKey:postRemoteKey andPosts:_posts withCallbackBlock:^(NSInteger index) {
            
        if(index != -1)
        {
            GLPPost *post = [self.posts objectAtIndex:index];

            post.viewsCount = viewsCount;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(![post isVideoPost])
                {
                    [self refreshCellViewWithIndex:index];
                }
            });
        }
        
    }];
}

/**
 This method should be called from the NewPostViewController via an nsnotification in
 order to update the number of pending posts.
 */
- (void)refreshPendingPostCell
{
    //TODO: Fixed that later: Refresh only the pending post cell.
    
    [self.tableView reloadData];
}

-(void)updateLikedPost:(NSNotification*)notification
{
    [GLPPostNotificationHelper parseLikedPostNotification:notification withPostsArray:self.posts];
    [self.tableView reloadData];
}

-(void)refreshPostsWithNewProfileImage:(NSNotification *)notification
{
    NSArray *postsIndexes = [GLPPostNotificationHelper parseNotification:notification withPostsArrayForNewProfileImage:self.posts];
    
    //Update all the user's posts in campus wall.
    
    for(NSNumber *number in postsIndexes)
    {
        [self refreshCellViewWithIndex:number.integerValue];
    }
}

- (void)deletePost:(NSNotification *)notification
{
    NSInteger index = -1;
    
    index = [GLPPostNotificationHelper parseNotificationAndFindIndexWithNotification:notification withPostsArray:self.posts];
    
    if(index == -1)
    {
        return;
    }
    
    if([[GLPPendingPostsManager sharedInstance] arePendingPosts])
    {
        index+= 2;
    }
    else
    {
        ++index;
    }

    [self removeTableViewPostWithIndex:index];
}

#pragma mark - Init config

- (void)configAppearance
{
    UIColor *tabColour = [[GLPThemeManager sharedInstance] tabbarSelectedColour];

    [AppearanceHelper showTabBar:self];

    self.tabBarController.tabBar.tintColor = tabColour;
    
    [AppearanceHelper setSelectedColourForTabbarItem:self.homeTabbarItem withColour:tabColour];
    
    [self setCustomBackgroundToTableView];
    
    if([self.fakeNavigationBar isTransparentMode])
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
}

-(void)setCustomBackgroundToTableView
{
    if([GLPiOSSupportHelper isIOS6])
    {
        [GLPiOSSupportHelper setBackgroundImageToTableView:self.tableView];
        
        return;
    }
    
    [self.tableView setBackgroundColor:[AppearanceHelper lightGrayGleepostColour]];
    
    [self.view setBackgroundColor:[AppearanceHelper lightGrayGleepostColour]];
}

-(void)configTabbarFormat
{
    // set selected and unselected icons
    NSArray *items = self.tabBarController.tabBar.items;
    
    UITabBarItem *item = [items objectAtIndex:0];
    
    item.image = [[UIImage imageNamed:@"bird-house-7"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    item.selectedImage = [UIImage imageNamed:@"bird-house-7"];
    
    [AppearanceHelper setUnselectedColourForTabbarItem:item];
    
//    item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    self.homeTabbarItem = item;

    
    // this way, the icon gets rendered as it is (thus, it needs to be green in this example)
//    item0.image = [[UIImage imageNamed:@"contacts.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    
//    // this icon is used for selected tab and it will get tinted as defined in self.tabBar.tintColor
//    item0.selectedImage = [UIImage imageNamed:@"contacts.png"];
}

-(void)configNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePostWithRemoteKey:) name:@"GLPPostUpdated" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePostAfterUploading:) name:@"GLPPostUploaded" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRealImage:) name:GLPNOTIFICATION_POST_IMAGE_LOADED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLikedPost:) name:@"GLPLikedPostUdated" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showEventPost:) name:@"GLPShowEvent" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPostsWithNewProfileImage:) name:@"GLPProfileImageChanged" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePost:) name:GLPNOTIFICATION_POST_DELETED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToTheNavigationBarFromNotification:) name:GLPNOTIFICATION_HOME_TAPPED_TWICE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNewImagePostWithPost:) name:GLPNOTIFICATION_RELOAD_DATA_IN_CW object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVideoPostAfterCreatingThePost:) name:GLPNOTIFICATION_VIDEO_POST_READY object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPendingPostCell) name:GLPNOTIFICATION_NEW_PENDING_POST object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewsCounter:) name:GLPNOTIFICATION_POST_CELL_VIEWS_UPDATE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeDeallocNotifications) name:GLPNOTIFICATION_REMOVE_VC_NOTIFICATIONS object:nil];
}

/** This notification called when user presses the going button on post. */
- (void)configureGoingButtonNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goingButtonTouchedWithNotification:) name:GLPNOTIFICATION_GOING_BUTTON_TOUCHED object:nil];
}

- (void)removeGoingButtonNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_GOING_BUTTON_TOUCHED object:nil];
}

- (void)configureRefreshControl
{
    // refresh control
//    self.refreshControl = [[UIRefreshControl alloc] initWithCustomLoader];
//    [self.refreshControl addTarget:self action:@selector(loadEarlierPostsFromPullToRefresh) forControlEvents:UIControlEventValueChanged];
}

- (void)configureTopImageView
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"GLPCampusWallStretchedImageView" owner:self options:nil];
    
    _strechedImageView = [array objectAtIndex:0];
    
    _strechedImageView.frame = CGRectMake(0, -kCWStretchedImageHeight, [GLPiOSSupportHelper screenWidth], kCWStretchedImageHeight);
    
    [self.strechedImageView setImage:[UIImage imageNamed:@"campus_wall_header_back.jpg"]];
    
    self.strechedImageView.delegate = self;
    
//    [_strechedImageView setTextInTitle:_group.name];
    
//    [_strechedImageView setViewControllerDelegate:self];
    
    [_strechedImageView setGesture:YES];
}

- (void)configTableView
{
    //Register nib files in table view.
    [self.tableView registerNib:[UINib nibWithNibName:@"PostImageCell" bundle:nil] forCellReuseIdentifier:@"ImageCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTextCellView" bundle:nil] forCellReuseIdentifier:@"TextCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostVideoCell" bundle:nil] forCellReuseIdentifier:@"VideoCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GLPPendingCell" bundle:nil] forCellReuseIdentifier:@"GLPPendingCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GLPCategoryTitleCell" bundle:nil] forCellReuseIdentifier:@"GLPCategoryTitleCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostPollCell" bundle:nil] forCellReuseIdentifier:@"PollCell"];

    [self.tableView setTableFooterView:[[UIView alloc] init]];
    
    self.tableView.contentInset = UIEdgeInsetsMake(240, 0, 0, 0);

    [self.tableView addSubview:self.strechedImageView];
    
//    [self.tableView registerNib:[UINib nibWithNibName:@"CampusWallHeaderScrollView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"CampusWallHeaderSimple"];

    
 /**   UIImageView* animatedImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    animatedImageView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"loader5.gif"], nil];
    animatedImageView.animationDuration = 2.0f;
    animatedImageView.animationRepeatCount = 10;
    [animatedImageView startAnimating];
    */
}

-(void)configHeader
{
    //Load the header of the table view.
    
//    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"CampusWallHeaderScrollView" owner:self options:nil];
//    
//    //Set delegate.
//    self.campusWallHeader = [array objectAtIndex:0];
//    [self.campusWallHeader formatElements];
//    [self.campusWallHeader setDelegate:self];
//    
//    self.tableView.tableHeaderView = self.campusWallHeader;
//    
//    [self.campusWallHeader reloadData];
    
    
//    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"GLPCampusWallTopView" owner:self options:nil];
//    
//    //Set delegate.
//    
//    self.tableView.tableHeaderView = [array objectAtIndex:0];
    

    
    
    [self.navigationController.navigationBar addSubview:[[GLPVideoPostCWProgressManager sharedInstance] progressView]];
}

- (void)configNewElementsIndicatorView
{
    self.elementsIndicatorView = [[GLPNewElementsIndicatorView alloc] initWithDelegate:self];
    self.elementsIndicatorView.hidden = YES;
    self.elementsIndicatorView.center = self.navigationController.view.center;
    CGRectSetY(self.elementsIndicatorView, 80); //TODO: something better than arbitrary value
    [self.navigationController.view addSubview:self.elementsIndicatorView];
}


#pragma mark - Navigation bar

- (void)configureNavigationBarBackground
{
    [self.navigationController.navigationBar invisible];
}

-(void)configNavigationBar
{
//    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
//    [self.navigationController.navigationBar setCampusWallFontFormat];
    
//    [self.navigationController.navigationBar invisible];
    
    self.navigationController.navigationBar.topItem.title = @"";
    
//    self.title = [[GLPThemeManager sharedInstance] campusWallTitle];
    
//    self.navigationController.navigationBar.topItem.title = [[GLPThemeManager sharedInstance] campusWallTitle];
    self.fakeNavigationBar = [[CampusWallFakeNavigationBar alloc] initWithTitle:[[GLPThemeManager sharedInstance] campusWallTitle]];
    
    [self.view addSubview:self.fakeNavigationBar];
    
}

- (void)addNavigationButtons
{
    [self.navigationController.navigationBar setButton:kLeft withImageName:@"navigationbar_trans" withButtonSize:CGSizeMake(29.0, 24.0) withSelector:@selector(showCategoriesViewController) andTarget:self];
//    
    [self.navigationController.navigationBar setButton:kRight withImageName:@"navigationbar_trans" withButtonSize:CGSizeMake(23.0, 23.0) withSelector:@selector(newPostButtonClick) andTarget:self];
}

//- (void)showProgressView
//{
//    [_pView resetView];
//    [_pView setHidden:NO];
//}

/*
 
 Not used.
 This method can be used in order to customise the title of the navigation bar.
 
 */
-(void) setTheNavigationTextWhiteWithText:(NSString*)title
{
    //Set white colour to the title of the navigation bar.
    CGRect frame = CGRectMake(0, 0, 200, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Helvetica" size:18.0];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = NSLocalizedString(title, @"Example");
    
    self.navigationItem.titleView = label;
    
    self.navigationItem.titleView = label;
}

#pragma mark - Table view refresh methods

-(void)refreshCellViewWithIndex:(NSUInteger)index
{
//    index = ([[GLPPendingPostsManager sharedInstance] arePendingPosts]) ? (index+=2) : (index+=1);
    
    if([[GLPPendingPostsManager sharedInstance] arePendingPosts])
    {
        index+=2;
    }
    else
    {
        index+=1;
    }
    
    if([self cellNeedsReloadWithIndex:index])
    {

        //For now we are reloading all the data (for now) because there was a problem reloading each cell as individual.
        [self.tableView reloadData];
        
        
        //            [self.tableView beginUpdates];
        //            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        //            [self.tableView endUpdates];

    }
}

- (BOOL)cellNeedsReloadWithIndex:(NSInteger)index
{
    NSArray *paths = [self.tableView indexPathsForVisibleRows];
    
    for(NSIndexPath *indexPath in paths)
    {
        if(indexPath.row == index)
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Posts

- (void)loadInitialPosts
{
    if(self.isLoading) {
        return;
    }
    
    [self startLoading];
    [self showLoadingIndicator];
//    [self clearTableViewAndShowLoader];
    [self clearTableView];
    [_tableActivityIndicator startActivityIndicator];
    
    [GLPPostManager loadInitialPostsWithLocalCallback:^(NSArray *localPosts) {
        // show temp local results
        self.posts = [localPosts mutableCopy];

        
        [[GLPPostImageLoader sharedInstance] addPostsImages:self.posts];
        

        if(self.posts.count != 0)
        {
//            [self hideLoader];
            [_tableActivityIndicator stopActivityIndicator];
            [self.tableView reloadData];
            DDLogDebug(@"Data reloaded for local posts.");
        }
        else
        {
//            [self clearTableViewAndShowLoader];
            [self clearTableView];
            [_tableActivityIndicator startActivityIndicator];
            
        }
        
    } remoteCallback:^(BOOL success, BOOL remain, NSArray *remotePosts) {
        
//        [self hideLoader];
        [_tableActivityIndicator stopActivityIndicator];

        if(success) {
            
//            self.posts = [self preserveRealImagesWithPosts:remotePosts.mutableCopy];
            
            self.posts = [remotePosts mutableCopy];

            [[GLPPostImageLoader sharedInstance] addPostsImages:self.posts];
            [[GLPVideoLoaderManager sharedInstance] addVideoPosts:self.posts];

            
            self.loadingCellStatus = (remain) ? kGLPLoadingCellStatusInit : kGLPLoadingCellStatusFinished;
            
            [self.tableView reloadData];
            
            self.firstLoadSuccessful = YES;
            [self startReloadingCronImmediately:NO];
            
//            [self showEmptyViewIfNeeded];
            
            
            
        } else {
            self.loadingCellStatus = kGLPLoadingCellStatusError;
            [self.tableView reloadData];
        }
        
        
        [self stopLoading];
//        [self hideLoadingIndicator];
        [_tableActivityIndicator stopActivityIndicator];
    }];
}

/**
 Helps to preserve the actual images have been saved before to the post data structure.
 
 DEPRECATED: we are not using the finalImage attribute anymore.
 
 @param posts the new posts.
 
 @return the updated new posts with images.
 
 */
- (NSMutableArray *)preserveRealImagesWithPosts:(NSMutableArray *)posts
{
    
    for(GLPPost *post in self.posts)
    {
        for(GLPPost *newPost in posts)
        {
            if(post.remoteKey == newPost.remoteKey)
            {
                newPost.finalImage = post.finalImage;
            }
        }
    }
    
    return posts;
}

- (void)clearTableView
{
    _posts = [[NSMutableArray alloc] init];
    
    [self.tableView reloadData];
}

-(void)setBottomView
{
    //Clear bottom view.
    //    [self clearBottomView];
    
    CGRect frame = self.tableView.bounds;
    frame.origin.y = frame.size.height;
    
    CGRect viewFrame = self.view.bounds;
    viewFrame.origin.y = viewFrame.size.height;
    
    UIImageView* grayView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 300.f, 320.0f, 250.0f)];
    grayView.tag = 100;
    grayView.backgroundColor = [UIColor whiteColor];
    //    [self.tableView addSubview:grayView];
    //    [grayView sendSubviewToBack:self.tableView];
    
    self.tableView.tableFooterView = grayView;
    //    [self.view addSubview:grayView];
}

-(void)clearBottomView
{
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
}

- (void)loadEarlierPostsFromPullToRefresh
{
    [self loadEarlierPostsAndSaveScrollingState:NO];
    
    
//    //Load campus live events posts.
//    [_campusWallHeader reloadData];

}

- (void)loadEarlierPostsFromCron
{
    [self loadEarlierPostsAndSaveScrollingState:YES];
}

- (void)loadEarlierPostsAndSaveScrollingState:(BOOL)saveScrollingState
{
    if(self.isLoading) {
        return;
    }
    
    // take the last remote post
    GLPPost *remotePost = nil;
    
    NSMutableArray *notUploadedPosts = [[NSMutableArray alloc] init];
    
    if(self.posts.count > 0) {
        // first is the most recent
        for(GLPPost *p in self.posts) {
            
            if(p.remoteKey == 0)
            {
                [notUploadedPosts addObject:p];
            }
            
            if(p.remoteKey != 0) {
                remotePost = p;
                break;
            }
        }
    }
    
    [self startLoading];
    
    [GLPPostManager loadRemotePostsBefore:remotePost withNotUploadedPosts:notUploadedPosts andCurrentPosts:self.posts callback:^(BOOL success, BOOL remain, NSArray *posts, NSArray *deletedPosts) {
        [self stopLoading];
        
        if(deletedPosts.count > 0)
        {
            DDLogInfo(@"GLPTimelineViewController : deleted posts %@", deletedPosts);
            [self.posts removeObjectsInArray:deletedPosts];
            [self.tableView reloadData];
        }
        
        if(posts.count > 0) {
            
            [self.posts insertObjects:posts atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, posts.count)]];
            
            //New methodology of loading images.
            [[GLPPostImageLoader sharedInstance] addPostsImages:posts];

            
            // update table view and keep the scrolling state
            if(saveScrollingState) {
                // delay the update if user is in scrolling state
                // Not need because we use performselector which areis deprioritized during scrolling
//                if(self.tableViewInScrolling) {
//                    self.shouldLoadNewPostsAfterScrolling = YES;
//                    self.postsNewRowsCountToInsertAfterScrolling += posts.count; // add new posts count to possibly non 0 count, if scrolling is still enabled after two reloads for instance
//                } else {
//                    [self updateTableViewWithNewPosts:posts.count];
//                }
                
                // do not care about the user is in scrolling state, see commented code below
                [self updateTableViewWithNewPosts:posts.count];
                
                // save the new rows count in order to know when (at what scroll position) to hide the new elements indicator
                self.insertedNewRowsCount += posts.count;
            }
            
            // or scroll to the top
            else {
                [self updateTableViewWithNewPostsAndScrollToTop:posts.count];
            }
            
            [self addFooterIfNeeded];
        }
        

    }];
}

- (void)loadPreviousPosts
{
    if(self.isLoading) {
        return;
    }
    
    if(self.posts.count == 0) {
        self.loadingCellStatus = kGLPLoadingCellStatusFinished;
        return;
    }
    
    if(self.loadingCellStatus == kGLPLoadingCellStatusLoading) {
        return;
    }
    
    [self startLoading];
    self.loadingCellStatus = kGLPLoadingCellStatusLoading;
    
    [GLPPostManager loadPreviousPostsAfter:[self.posts lastObject] callback:^(BOOL success, BOOL remain, NSArray *posts) {
        [self stopLoading];
        
        if(!success) {
            self.loadingCellStatus = kGLPLoadingCellStatusError;
            [self reloadLoadingCell];

            return;
        }
        
        self.loadingCellStatus = remain ? kGLPLoadingCellStatusInit : kGLPLoadingCellStatusFinished;
        
        if(posts.count > 0) {
            
            int firstInsertRow = ([[GLPPendingPostsManager sharedInstance] arePendingPosts]) ? self.posts.count + 1 : self.posts.count;
            
            [[GLPPostImageLoader sharedInstance] addPostsImages:posts];

            [self.posts insertObjects:posts atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.posts.count, posts.count)]];
            
            int finalRowsCount = ([[GLPPendingPostsManager sharedInstance] arePendingPosts]) ? self.posts.count + 1 : self.posts.count;
            
            NSMutableArray *rowsInsertIndexPath = [[NSMutableArray alloc] init];
            for(int i = firstInsertRow; i < finalRowsCount; i++) {
                [rowsInsertIndexPath addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            
            // update table view with showing new rows and updating the loading row
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:firstInsertRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView insertRowsAtIndexPaths:rowsInsertIndexPath withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView endUpdates];
            
        } else {
            [self reloadLoadingCell];
        }
        
    }];
}

- (void)reloadNewLocalPosts
{
    if(self.isLoading) {
        return;
    }
    
    self.isLoading = YES;
    
    // get the last post if exists
    GLPPost *post = (self.posts.count > 0) ? self.posts[0] : nil;
    
    [GLPPostManager loadLocalPostsBefore:post callback:^(NSArray *posts) {
        if(!posts || posts.count == 0) {
            return;
        }
        
        [self.posts insertObjects:posts atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, posts.count)]];
        
        [self updateTableViewWithNewPostsAndScrollToTop:posts.count];
        
        self.isLoading = NO;
    }];
    
}


#pragma mark - Groups' Posts

- (void)loadInitialGroupsPosts
{
    if(self.isLoading) {
        return;
    }
    
    [self showLoadingIndicator];
    
//    if(![[CampusWallGroupsPostsManager sharedInstance] arePostsEmpty])
//    {
//        DDLogDebug(@"Post are not empty.");
//        
//        [self.tableView reloadData];
//    }
    
    [self.tableView reloadData];

    
    
    [GLPGroupManager loadGroupsFeedWithCallback:^(BOOL success, NSArray *posts) {
       
        
        if(!success)
        {
            [WebClientHelper showInternetConnectionErrorWithTitle:@"Failed to load groups feed posts"];
            [self stopLoading];
            return;
        }
        
        [[CampusWallGroupsPostsManager sharedInstance] setPosts:posts.mutableCopy];
        
//        self.posts = posts.mutableCopy;
        
        [[GLPPostImageLoader sharedInstance] addPostsImages:[[CampusWallGroupsPostsManager sharedInstance] allPosts]];
        
        [self addFooterIfNeeded];
        
        [self.tableView reloadData];
        
        self.firstLoadSuccessful = YES;
//        [self startReloadingCronImmediately:NO];

        
        [self hideLoadingIndicator];
        
    }];
    
    
//    [GLPGroupManager loadInitialPostsWithGroupId:[SessionManager sharedInstance].user.networkId remoteCallback:^(BOOL success, BOOL remain, NSArray *remotePosts) {
//       
//        if(success)
//        {
//            [[CampusWallGroupsPostsManager sharedInstance] setPosts:remotePosts.mutableCopy];
//            
//            self.posts = remotePosts.mutableCopy;
//            
//            [[GLPPostImageLoader sharedInstance] addPostsImages:self.posts];
//
//            [self.tableView reloadData];
//            
//            self.firstLoadSuccessful = YES;
//            [self startReloadingCronImmediately:NO];
//        }
//        
//        [self stopLoading];
//    }];
}

-(void)loadEarlierGroupsPostsAndSaveScrollingState:(BOOL)scrollingState
{
    if(self.isLoading) {
        return;
    }
    
//    // take the last remote post
//    GLPPost *remotePost = nil;
//    
//    NSMutableArray *notUploadedPosts = [[NSMutableArray alloc] init];
//    
//    if(self.posts.count > 0) {
//        // first is the most recent
//        for(GLPPost *p in self.posts) {
//            
//            if(p.remoteKey == 0)
//            {
//                [notUploadedPosts addObject:p];
//            }
//            
//            if(p.remoteKey != 0) {
//                remotePost = p;
//                break;
//            }
//        }
//    }
    
    [self startLoading];
    
    
    
    [GLPGroupManager loadGroupsFeedWithCallback:^(BOOL success, NSArray *posts) {
        
        if(!success)
        {
            [WebClientHelper showInternetConnectionErrorWithTitle:@"Failed to load groups feed posts"];
            [self stopLoading];
            return;
        }
        
        NSArray *recentPosts = [[CampusWallGroupsPostsManager sharedInstance] addNewPosts:posts.mutableCopy];
        
        //        self.posts = posts.mutableCopy;
        


        [[GLPPostImageLoader sharedInstance] addPostsImages:recentPosts];

        if(recentPosts.count > 0)
        {
            [self updateTableViewWithNewPosts:recentPosts.count];
        }
        
        
        [self addFooterIfNeeded];
        
        self.firstLoadSuccessful = YES;
        //        [self startReloadingCronImmediately:NO];
        
        
        [self stopLoading];
        
//        [self updateTableViewWithNewPostsAndScrollToTop:[[CampusWallGroupsPostsManager sharedInstance] numberOfPosts]];

        
        
    }];
    
//    [GLPPostManager loadRemotePostsBefore:remotePost withNotUploadedPosts:notUploadedPosts andCurrentPosts:self.posts callback:^(BOOL success, BOOL remain, NSArray *posts) {
//        [self stopLoading];
//        
//        if(!success) {
//            [self showLoadingError:@"Failed to load new posts"];
//            return;
//        }
//        
//        if(posts.count > 0) {
//            [self.posts insertObjects:posts atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, posts.count)]];
//            
//            //New methodology of loading images.
//            [[GLPPostImageLoader sharedInstance] addPostsImages:posts];
//            
//            
//            // update table view and keep the scrolling state
//            if(scrollingState) {
//                // delay the update if user is in scrolling state
//                // Not need because we use performselector which areis deprioritized during scrolling
//                //                if(self.tableViewInScrolling) {
//                //                    self.shouldLoadNewPostsAfterScrolling = YES;
//                //                    self.postsNewRowsCountToInsertAfterScrolling += posts.count; // add new posts count to possibly non 0 count, if scrolling is still enabled after two reloads for instance
//                //                } else {
//                //                    [self updateTableViewWithNewPosts:posts.count];
//                //                }
//                
//                // do not care about the user is in scrolling state, see commented code below
//                [self updateTableViewWithNewPosts:posts.count];
//                
//                // save the new rows count in order to know when (at what scroll position) to hide the new elements indicator
//                self.insertedNewRowsCount += posts.count;
//            }
//            
//            // or scroll to the top
//            else {
//                [self updateTableViewWithNewPostsAndScrollToTop:posts.count];
//            }
//        }
//    }];
}

//- (void)showEmptyViewIfNeeded
//{
//    if(_posts.count == 0)
//    {
//        NSString *noPostYetMessage = [NSString stringWithFormat:@"No post yet for %@ category", [[CategoryManager sharedInstance] selectedCategory].name];
//        
//        [_emptyCategoryPostsMessage setTitle: noPostYetMessage];
//        [_emptyCategoryPostsMessage showEmptyMessageView];
//    }
//    else
//    {
//        [_emptyCategoryPostsMessage hideEmptyMessageView];
//    }
//    
//
//}

/** NOT USED. */
-(void)addFooterIfNeeded
{
    int numberOfPosts = 0;
    

     numberOfPosts = self.posts.count;
    
    
    
    if(numberOfPosts == 0 || (numberOfPosts == 1 && [[CampusWallGroupsPostsManager sharedInstance] isTextPostExist]))
    {
        [self addTableViewFooterWithSize:2];
    }
    else if (numberOfPosts == 1 && ![[CampusWallGroupsPostsManager sharedInstance] isTextPostExist])
    {
        [self addTableViewFooterWithSize:1];
    }
    else if (numberOfPosts == 2 && [[CampusWallGroupsPostsManager sharedInstance] isTextPostExist])
    {
        [self addTableViewFooterWithSize:0.4];
    }
    else
    {
        [self removeTableViewFooter];
    }
}

/**
 Notification method. 
 This method is called to reload the non-uploaded post in order to be visible
 to user while uploading.
 
 @param notification contains the post's data.
 
 */
-(void)reloadNewImagePostWithPost:(NSNotification *)notification
{
    //TODO: REMOVED! IT'S IMPORTANT!
    
//    if(self.isLoading) {
//        return;
//    }
    
    //Get post from notification.
    NSDictionary *notDictionary = notification.userInfo;
    
    GLPPost *inPost = [notDictionary objectForKey:@"new_post"];
    
    if(inPost.video != nil)
    {
        //Set isLoading variable YES in order to prevent duplicated video posts (from cron).
        //The variable is setting as NO after the updateVideoPostAfterCreatingThePost is called
        //from NSNotification. (that means the video post is uploaded)
        self.isLoading = YES;
        
        return;
    }
    
    if(inPost.group)
    {
        return;
    }
    
    DDLogInfo(@"Reload post in GLPTimelineViewController: %@", inPost);

    
    self.isLoading = YES;
    
//    GLPPost *post = (self.posts.count > 0) ? self.posts[0] : nil;
    
    NSArray *posts = [[NSArray alloc] initWithObjects:inPost, nil];
    
    [self.posts insertObjects:posts atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, posts.count)]];
    
    [self updateTableViewWithNewPostsAndScrollToTop:posts.count];
    
    
    self.isLoading = NO;
    //Bring the fake navigation bar to from because is hidden by new cell.
//    [self.tableView bringSubviewToFront:self.reNavBar];

}

- (void)reloadNewVideoPost:(GLPPost *)post
{
    DDLogInfo(@"Reload new video post in GLPTimelineViewController: %@", post);
    
    self.isLoading = YES;
    
    //    GLPPost *post = (self.posts.count > 0) ? self.posts[0] : nil;
    
    NSArray *posts = [[NSArray alloc] initWithObjects:post, nil];
    
    [self.posts insertObjects:posts atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, posts.count)]];
    
    [self updateTableViewWithNewPostsAndScrollToTop:posts.count];
    
    
    self.isLoading = NO;
    DDLogDebug(@"Is loading NO");
}

#pragma mark - Request management

- (void)startReloadingCronImmediately:(BOOL)immediately
{
    if(self.isReloadingCronRunning) {
        NSLog(@"Reloading cron already running");
        return;
    }
    
    NSLog(@"Start reloading cron, immediately: %d", immediately);
    
    self.isReloadingCronRunning = YES;
    self.shouldReloadingCronRun = YES;
    
    [self executeReloadingCron:[NSNumber numberWithBool:immediately]];
}

- (void)stopReloadingCron
{
//    // try to stop it if it runs
//    self.shouldReloadingCronRun = NO;
    
    // or cancel performSelector:afterDelay: call
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(executeReloadingCron:) object:[NSNumber numberWithBool:YES]];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(executeReloadingCron:) object:[NSNumber numberWithBool:NO]];
    
    self.isReloadingCronRunning = NO;
    
    NSLog(@"Stop reloading cron");
}

- (void)executeReloadingCron:(id)immediatelyObject
{
    NSLog(@"Execute reloading cron, immediately: %@", immediatelyObject);
    
    BOOL immediately = [immediatelyObject boolValue];
    
    // sometimes we may want to pass one time interval because reloading
    // when we start the reloading cron after a successful initial loading for instance
    if(immediately) {
        [self loadEarlierPostsAndSaveScrollingState:YES];
    }
    
    [self performSelector:@selector(executeReloadingCron:) withObject:[NSNumber numberWithBool:YES] afterDelay:RELOAD_POSTS_INTERVAL_S];
}

- (void)startLoading
{
    self.isLoading = YES;
    [self.fakeNavigationBar startLoading];
    //[self.refreshControl beginRefreshing];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)stopLoading
{
    self.isLoading = NO;
    [self.fakeNavigationBar stopLoading];
    //[self.refreshControl endRefreshing];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)showLoadingIndicator
{
    self.isLoading = YES;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)hideLoadingIndicator
{
    self.isLoading = NO;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)showLoadingError:(NSString *)message
{
    [TSMessage showNotificationInViewController:self title:@"Loading failed" subtitle:message type:TSMessageNotificationTypeWarning];
}


#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.startContentOffset = self.lastContentOffset = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{    
    //[self makeVisibleOrInvisibleActivityIndicatorWithOffset:scrollView.contentOffset.y];
    
    [_flurryVisibleProcessor resetVisibleCells];
    [_trackViewsCountProcessor resetVisibleCells];
    
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat differenceFromStart = self.startContentOffset - currentOffset;
    CGFloat differenceFromLast =  self.lastContentOffset - currentOffset;
    self.lastContentOffset = currentOffset;
    
    
    CGFloat yOffset  = scrollView.contentOffset.y;
    
    [self configureStrechedImageViewWithOffset:yOffset];
    
    
    if(self.viewDisappeared)
    {
        return;
    }
    
    if(yOffset > -64)
    {
        //Set coloured mode.
        [self.fakeNavigationBar colourMode];
    }
    else
    {
        //Set transparent mode.
        [self.fakeNavigationBar transparentMode];
    }
    
    
//    [self.reNavBar setFrame:CGRectMake(0.0f, scrollView.contentOffset.y, 320.0f, 50.0f)];
    
    
//    [self.campusWallHeader setPositionToNavBar:CGPointMake(0.0f, scrollView.contentOffset.y)];
    
    //TODO: Remove unnecessary code.
    
//    if(scrollView.contentOffset.y >= TOP_OFFSET)
//    {
//        //[self contract];
//    
//        [UIView animateWithDuration:0.1f animations:^{
//            
//            [self.reNavBar setAlpha:1.0f];
//            
//            //Bring reNavBar to front to avoid problems of hiding the view.
//            [self.tableView bringSubviewToFront:self.reNavBar];
//
//            
//        } completion:^(BOOL finished) {
//            
//            [self.reNavBar setHidden:NO];
//
//        }];
//        
//        //[self.campusWallHeader showFakeNavigationBar];
//            
//    }
//    else
//    {
//        //[self expand];
//        
//        [UIView animateWithDuration:0.1f animations:^{
//            
//            [self.reNavBar setAlpha:0.0f];
//            
//        } completion:^(BOOL finished) {
//            
//            [self.reNavBar setHidden:YES];
//
//        }];
//        
//        
//       // [self.campusWallHeader hideFakeNavigationBar];
//
//    }

    
    if(scrollView.contentOffset.y >= 180.0f)
    {
        if ([scrollView.panGestureRecognizer translationInView:scrollView].y > 0)
        {
//            DDLogDebug(@"down");

            
        } else
        {
//            DDLogDebug(@"up");
        }
    }
    
    if((differenceFromStart) < 0)
    {
        // scroll up
        if(scrollView.isTracking && (fabs(differenceFromLast)>1))
        {
            
        }
            //[self expand];
    }
    else {
        if(scrollView.isTracking && (fabs(differenceFromLast)>1))
        {
            
        }
            //[self contract];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(self.posts.count == 0)
    {
        return;
    }

    if(self.isLoading )
    {
        return;
    }
    
    //Capture the current cells that are visible and add them to the GLPFlurryVisibleProcessor.
    
    NSMutableArray *postsYValues = nil;
    
    NSArray *visiblePosts = [self getVisiblePostsInTableViewWithYValues:&postsYValues];
    
    [_flurryVisibleProcessor addVisiblePosts:visiblePosts];
    
    [_trackViewsCountProcessor trackVisiblePosts:visiblePosts withPostsYValues:postsYValues];
    
    [[GLPVideoLoaderManager sharedInstance] visiblePosts:visiblePosts];
    
    _tableViewFirstTimeScrolled = YES;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(decelerate == 0)
    {
        if(self.isLoading )
        {
            return;
        }
        
        NSMutableArray *postsYValues = nil;
        
        NSArray *visiblePosts = [self getVisiblePostsInTableViewWithYValues:&postsYValues];
        
        [_flurryVisibleProcessor addVisiblePosts:visiblePosts];
        
        [_trackViewsCountProcessor trackVisiblePosts:visiblePosts withPostsYValues:postsYValues];
        
        DDLogDebug(@"scrollViewDidEndDragging2 posts %lu", (unsigned long)visiblePosts.count);
        
        [[GLPVideoLoaderManager sharedInstance] visiblePosts:visiblePosts];
        
        _tableViewFirstTimeScrolled = YES;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat yOffset  = scrollView.contentOffset.y;

    if(yOffset < (-OFFSET_START_ANIMATING_CW) && !self.isLoading)
    {
        [self loadEarlierPostsFromPullToRefresh];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    //[self contract];
    return YES;
}

- (void)configureStrechedImageViewWithOffset:(CGFloat)offset
{
    if (offset < -kCWStretchedImageHeight)
    {
        CGRect f = _strechedImageView.frame;
        f.origin.y = offset;
        f.size.height =  -offset;
        _strechedImageView.frame = f;
        
        [_strechedImageView setHeightOfTransImage:-offset];
        
        //        CGRectSetY(_lbl, -yOffset/2);
    }
}

- (void)makeVisibleOrInvisibleActivityIndicatorWithOffset:(float)offset
{
    if(offset < (-OFFSET_START_ANIMATING_CW))
    {
        [self.fakeNavigationBar setHiddenLoader:NO];
    }
    else if(!self.isLoading)
    {
        [self.fakeNavigationBar setHiddenLoader:YES];
    }
}

#pragma mark - Hidden navigation bar

//-(void)expand
//{
//    if(self.hidden)
//    {
//        return;
//    }
//    
//    self.hidden = YES;
//
//    
//    [self.navigationController setNavigationBarHidden:YES
//                                             animated:NO];
//}
//
//-(void)contract
//{
//    if(!self.hidden)
//    {
//        return;
//    }
//    
//    self.hidden = NO;
//    
////    [self.tabBarController setTabBarHidden:NO
////                                  animated:YES];
//    
//    
//    [self.navigationController setNavigationBarHidden:NO
//                                             animated:NO];
//}
//
//
//
//-(void)hideNavigationbarElements
//{
//    [self.navigationController.navigationBar setBackgroundColor: [UIColor clearColor]];
//}
//
//-(void)showNavigationbarElements
//{
//    [self configAppearance];
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([[GLPPendingPostsManager sharedInstance] arePendingPosts])
    {
        return self.posts.count + 2;
    }
    else
    {
        return self.posts.count + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierWithImage = @"ImageCell";
    static NSString *CellIdentifierWithoutImage = @"TextCell";
    static NSString *CellIdentifierVideo = @"VideoCell";
    static NSString *CellIdentifierPoll = @"PollCell";
    static NSString *CellIdentifierPendingCell = @"GLPPendingCell";
    static NSString *CellIdentifierCategoryTitle = @"GLPCategoryTitleCell";
    
    if([[GLPPendingPostsManager sharedInstance] arePendingPosts])
    {
        if(indexPath.row == 0)
        {
            GLPPendingCell *pendingCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierPendingCell forIndexPath:indexPath];
            
            [pendingCell updateLabelWithNumberOfPendingPosts];
            
            return pendingCell;
        }
        else if(indexPath.row == 1)
        {
            UITableViewCell *categoryTitle = [tableView dequeueReusableCellWithIdentifier:CellIdentifierCategoryTitle forIndexPath:indexPath];
            
            return categoryTitle;
        }
    }
    else
    {
        if(indexPath.row == 0)
        {
            UITableViewCell *categoryTitle = [tableView dequeueReusableCellWithIdentifier:CellIdentifierCategoryTitle forIndexPath:indexPath];
            
            return categoryTitle;
        }
    }
    
    

    
    NSInteger countOfCells = [self convertArrayIndexToTableViewIndex:self.posts.count];

    if(indexPath.row - 1 == countOfCells) {
        
        GLPLoadingCell *loadingCell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell" forIndexPath:indexPath];
        [loadingCell setBackgroundColor:[AppearanceHelper lightGrayGleepostColour]];
        [loadingCell updateWithStatus:self.loadingCellStatus];
        return loadingCell;
    }
    
    
    GLPPostCell *postCell;
    
    GLPPost *post = [self currentPostWithIndexPath:indexPath];
    
    if([post imagePost] && ![post isPollPost])
    {
        postCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithImage forIndexPath:indexPath];
        
//        postCell.imageAvailable = YES;
        
    }
    else if ([post isVideoPost])
    {
//        [[GLPVideoLoaderManager sharedInstance] setVideoPost:post];
        
        if(indexPath.row != 0)
        {
            [[GLPVideoLoaderManager sharedInstance] disableViewJustViewed];
        }
                
        postCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierVideo forIndexPath:indexPath];
    }
    else if([post isPollPost])
    {
        postCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierPoll forIndexPath:indexPath];
    }
    else
    {
        postCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithoutImage forIndexPath:indexPath];
    }
    
    postCell.delegate = self;
    
    
    NSIndexPath *postIndexPath = [NSIndexPath indexPathForRow:[self postCurrentIndexWithIndexPath:indexPath] inSection:0];
    
    
    [postCell setPost:post withPostIndexPath:postIndexPath];
    
//    [self.tableView bringSubviewToFront:self.reNavBar];
    
    return postCell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if(self.isLoading)
//    {
//        DDLogDebug(@"didEndDisplayingCell index path: %d. Posts count: %d", indexPath.row, _posts.count);
//
//        return;
//    }
    
    NSUInteger currentRow = [self postCurrentIndexWithIndexPath:indexPath];
    
    if(currentRow >= _posts.count)
    {
        //TODO: If this contition is YES then the app is going to crash.
        //That's why we have a temporary return.
        
        DDLogDebug(@"Avoid crash didEndDisplayingCell index path: %ld. Posts count: %lu", (long)indexPath.row, (unsigned long)_posts.count);

        return;
    }
    
    GLPPost *post = _posts[currentRow];
    
    if(![[cell class] isSubclassOfClass:[GLPPostCell class]])
    {
        DDLogDebug(@"%@ not subclass", [cell class]);
        
        return;
    }
    
    
//    if(![self isTableViewFirstTimeScrolled])
//    {
//        return;
//    }
    
    GLPPostCell *postCell = (GLPPostCell *)cell;
    
    if([post isVideoPost])
    {
        [postCell deregisterNotificationsInVideoView];
    }
    
    
//    [[GLPVideoLoaderManager sharedInstance] removeVideoPost:post];


}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //TODO: implement manual reloading
    if(indexPath.row - 1 == self.posts.count) {
        return;
    }
    
    if([[GLPPendingPostsManager sharedInstance] arePendingPosts])
    {
        if(indexPath.row == 0 || indexPath.row == 1)
        {
            //Navigate to pending posts view.
            [self performSegueWithIdentifier:@"view pending posts" sender:self];
            
            return;
        }
    }
    else
    {
        if(indexPath.row == 0)
        {
            //The title cell selected.
            return;
        }
    }
    
    
    self.selectedPost = [self currentPostWithIndexPath:indexPath];
    
    self.selectedIndex = indexPath.row;
    self.postIndexToReload = indexPath.row;
    self.commentCreated = NO;
    _showComment = NO;
        
    [self performSegueWithIdentifier:@"view post" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[GLPPendingPostsManager sharedInstance] arePendingPosts])
    {
        if(indexPath.row == 0)
        {
            return [GLPPendingCell cellHeight];
        }
        else if (indexPath.row == 1)
        {
            return CATEGORY_TITLE_HEIGHT;
        }
    }
    else
    {
        if(indexPath.row == 0)
        {
            return CATEGORY_TITLE_HEIGHT;
        }
    }
    
    NSInteger countOfCells = [self convertArrayIndexToTableViewIndex:self.posts.count];
    
    if(indexPath.row - 1 == countOfCells) {
        return (self.loadingCellStatus != kGLPLoadingCellStatusFinished) ? kGLPLoadingCellHeight : 0;
    }
    
    GLPPost *currentPost = [self currentPostWithIndexPath:indexPath];
    
    if([currentPost imagePost] && ![currentPost isPollPost])
    {
        return [GLPPostCell getCellHeightWithContent:currentPost cellType:kImageCell isViewPost:NO];
    }
    else if ([currentPost isVideoPost])
    {
        return [GLPPostCell getCellHeightWithContent:currentPost cellType:kVideoCell isViewPost:NO];
    }
    else if ([currentPost isPollPost])
    {
        return [GLPPostCell getCellHeightWithContent:currentPost cellType:kPollCell isViewPost:NO];
    }
    else
    {
        return [GLPPostCell getCellHeightWithContent:currentPost cellType:kTextCell isViewPost:NO];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // hide the new elements indicator if needed when we are on top
    if(!self.elementsIndicatorView.hidden && (indexPath.row == 0 || indexPath.row < self.insertedNewRowsCount)) {
        NSLog(@"HIDE %ld - %ld", (long)indexPath.row, (long)self.insertedNewRowsCount);
        
        self.insertedNewRowsCount = 0; // reset the count
        [self hideNewElementsIndicatorView];
    }
    
    if(indexPath.row == self.posts.count && self.loadingCellStatus == kGLPLoadingCellStatusInit) {
        NSLog(@"Load previous posts cell activated");
        [self loadPreviousPosts];
    }
}


#pragma mark - Table view manager methods

/**
 
 Gives the current post depending on the mode.
 
 @param indexPath.
 
 @return the current post.
 
 */
-(GLPPost *)currentPostWithIndexPath:(NSIndexPath *)indexPath
{
    return [self.posts objectAtIndex:[self postCurrentIndexWithIndexPath:indexPath]];
}

- (NSInteger)postCurrentIndexWithIndexPath:(NSIndexPath *)indexPath
{
    return ([[GLPPendingPostsManager sharedInstance] arePendingPosts] ? indexPath.row - 2 : indexPath.row - 1);
}

- (NSInteger)convertArrayIndexToTableViewIndex:(NSInteger)arrayIndex
{
    return ([[GLPPendingPostsManager sharedInstance] arePendingPosts] ? arrayIndex + 2 : arrayIndex + 1);
}

-(void) updateTableWithNewRowCount:(int)rowCount
{
    CGPoint tableViewOffset = [self.tableView contentOffset];
    
    [UIView setAnimationsEnabled:NO];
    
    NSMutableArray *rowsInsertIndexPath = [[NSMutableArray alloc] init];
    
    int heightForNewRows = 0;
    
    for (NSInteger i = 0; i < rowCount; i++) {
        NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [rowsInsertIndexPath addObject:tempIndexPath];
        
        heightForNewRows = heightForNewRows + [self tableView:self.tableView heightForRowAtIndexPath:tempIndexPath];
    }
    
    tableViewOffset.y += heightForNewRows;
    
    [self.tableView reloadData];
    [self.tableView setContentOffset:tableViewOffset animated:NO];
    
    [UIView setAnimationsEnabled:YES];
}

- (void)reloadLoadingCell
{
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.posts.count inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)scrollToTheTop
{
    // we never know, that would be a stupid crash
    if(self.posts.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

-(void)scrollToTheNavigationBar
{
    [UIView animateWithDuration:0.5f animations:^{
        
        [self.tableView setContentOffset:CGPointMake(0, TOP_OFFSET)];
        
    } completion:^(BOOL finished) {
        
    }];
}

/**
 This method is called from the GLPTabBarController class
 When the home tab button pressed twice.
 
 @param notification
 
 */
-(void)scrollToTheNavigationBarFromNotification:(id)notification
{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}


- (void)updateTableViewWithNewPostsAndScrollToTop:(NSInteger)count
{
    NSMutableArray *rowsInsertIndexPath = [[NSMutableArray alloc] init];
    
    NSUInteger startIndex = 0;
    
    if([[GLPPendingPostsManager sharedInstance] arePendingPosts])
    {
        startIndex = 2;
//        ++count;
        count += 2;
    }
    else
    {
        startIndex = 1;
        count += 1;
    }
    
    for(NSInteger i = startIndex; i < count; i++) {
        [rowsInsertIndexPath addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    FLog(@"GLPTimelineViewController : updateTableViewWithNewPostsAndScrollToTop count %d start index %d", count, startIndex);
    
    //The condition is added to prevent error when there are no posts in the table view.
    if(self.posts.count == 1 || !self.posts)
    {
        [self.tableView reloadData];
    }
    else
    {
//        [self.tableView reloadData];

        [self.tableView insertRowsAtIndexPaths:rowsInsertIndexPath withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self scrollToTheNavigationBar];
    
    //Bring the fake navigation bar to from because is hidden by new cell.
    //    [self.tableView bringSubviewToFront:self.reNavBar];
}

- (void)updateTableViewWithNewPosts:(int)count
{
    CGPoint tableViewOffset = [self.tableView contentOffset];
    [UIView setAnimationsEnabled:NO];
    
    int heightForNewRows = 0;
    NSMutableArray *rowsInsertIndexPath = [[NSMutableArray alloc] init];
    
    NSUInteger startIndex = 1;

    if([[GLPPendingPostsManager sharedInstance] arePendingPosts])
    {
        startIndex = 2;
        count+=2;
    }
    
    for (NSInteger i = startIndex; i < count; i++) {
        NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [rowsInsertIndexPath addObject:tempIndexPath];
        
        heightForNewRows = heightForNewRows + [self tableView:self.tableView heightForRowAtIndexPath:tempIndexPath];
    }
    
    tableViewOffset.y += heightForNewRows;
    
    [self.tableView setContentOffset:tableViewOffset animated:NO];
    [self.tableView reloadData];
//    [self.tableView insertRowsAtIndexPaths:rowsInsertIndexPath withRowAnimation:UITableViewRowAnimationFade];
    
    [UIView setAnimationsEnabled:YES];
    
    // display the new elements indicator if we are not on top
    NSIndexPath *firstVisibleIndexPath = [[self.tableView indexPathsForVisibleRows] objectAtIndex:0];
    if(firstVisibleIndexPath.row != 0) {
        [self showNewElementsIndicatorView];
    }
}


- (void)removeTableViewPostWithIndex:(NSInteger)index
{
    NSMutableArray *rowsDeleteIndexPath = [[NSMutableArray alloc] init];
    
    [rowsDeleteIndexPath addObject:[NSIndexPath indexPathForRow:index inSection:0]];

    [self.tableView deleteRowsAtIndexPaths:rowsDeleteIndexPath withRowAnimation:UITableViewRowAnimationRight];
}

#pragma mark - RemovePostCellDelegate

-(void)removePostWithPost:(GLPPost *)post
{
    self.isLoading = YES;
    
    [GLPPostNotificationHelper deletePostNotificationWithPostRemoteKey:post.remoteKey inCampusLive:NO];
    
    self.isLoading = NO;
}

#pragma mark - GLPCampusWallStretchedViewDelegate

- (void)takeALookTouched
{
    [self removeGoingButtonNotification];
    [[GLPVideoLoaderManager sharedInstance] enableViewJustViewed];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone_ipad" bundle:nil];
    GLPCampusLiveViewController *campusLiveVC = [storyboard instantiateViewControllerWithIdentifier:@"GLPCampusLiveViewController"];
    campusLiveVC.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:campusLiveVC];
    navigationController.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - GLPCampusLiveViewControllerDelegate

/** This delegate helps us to identify when the campus live is visible.
 we need that because there is unexcected behaviour when campus live
 is visible. That happens because viewDidDisappear is not called.*/
- (void)campusLiveDisappeared
{
    [[GLPVideoLoaderManager sharedInstance] disableViewJustViewed];

    [self configureGoingButtonNotification];
}

#pragma mark - GLPCategoriesViewControllerDelegate

-(void)refreshPostsWithNewCategory
{
     [self loadInitialPosts];
}

#pragma mark - UI methods

-(void)addTableViewFooterWithSize:(float)sizeFactor
{
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 240*sizeFactor)];
    
    [imgView setBackgroundColor:[AppearanceHelper lightGrayGleepostColour]];
    
    self.tableView.tableFooterView = imgView;
}

-(void)removeTableViewFooter
{
    self.tableView.tableFooterView = nil;
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
        //Avoid any out of bounds access in array
        
        NSUInteger row = [self postCurrentIndexWithIndexPath:path];
        
        if(row < self.posts.count)
        {
            GLPPost *post = [self.posts objectAtIndex:row];
            [visiblePosts addObject:post];
            
            CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:path];
            CGRect rectInSuperview = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];
            
            [*postsYValues addObject:@(rectInTableView.size.height/2.0 + rectInSuperview.origin.y)];
            
//            DDLogDebug(@"-> Post: %@, Y: %f %f result %f", post, rectInSuperview.origin.y, rectInTableView.size.height, rectInTableView.size.height/2.0 + rectInSuperview.origin.y);
        }
    }
    
    return visiblePosts;
}


/**
 This method reloads visible cells.
 */

- (void)reloadVisibleCells
{
    NSArray *paths = [self.tableView indexPathsForVisibleRows];
    
    [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - View image delegate


-(void)viewPostImageView:(UIImageView *)postImageView
{
    [GLPViewImageHelper showImageInViewController:self withImageView:postImageView];
}


#pragma mark - New comment delegate

-(void)setPreviousViewToNavigationBar
{
    [self configAppearance];
}

-(void)setPreviousNavigationBarName
{
    [self.navigationItem setTitle:@"STANFORD WALL"];
}

-(void)hideNavigationBarAndButtonWithNewTitle:(NSString*)newTitle
{
    [self.navigationItem setTitle:newTitle];
}

-(void)navigateToViewPostFromCommentWithIndex:(int)postIndex
{

    self.selectedPost = self.posts[postIndex];
    self.postIndexToReload = postIndex;
   
    ++self.selectedPost.commentsCount;

    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:postIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    self.commentCreated = YES;
    
    //Notify GLPProfileViewController about changes.
    [GLPPostNotificationHelper updatePostWithNotifiationName:@"GLPPostUpdated" withObject:self remoteKey:self.selectedPost.remoteKey numberOfLikes:self.selectedPost.likes andNumberOfComments:self.selectedPost.commentsCount];
    
    [self performSegueWithIdentifier:@"view post" sender:self];
}


// Not need because we use performselector which areis deprioritized during scrolling

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    self.tableViewInScrolling = YES;
//}
//
//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
//{
//    self.tableViewInScrolling = NO;
//    
//    // rows waiting to be inserted
//    if(self.shouldLoadNewPostsAfterScrolling) {
//        [self updateTableViewWithNewPosts:self.postsNewRowsCountToInsertAfterScrolling];
//        
//        // reset the control values
//        self.shouldLoadNewPostsAfterScrolling = NO;
//        self.postsNewRowsCountToInsertAfterScrolling = 0;
//    }
//}


#pragma mark - GLPNewElementsIndicatorView

- (void)showNewElementsIndicatorView
{
    if(!self.elementsIndicatorView.hidden) {
        return;
    }
    
    self.elementsIndicatorView.alpha = 0;
    self.elementsIndicatorView.hidden = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.elementsIndicatorView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideNewElementsIndicatorView
{
    if(self.elementsIndicatorView.hidden) {
        return;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.elementsIndicatorView.alpha = 0;
    } completion:^(BOOL finished) {
        self.elementsIndicatorView.hidden = YES;
    }];
}

// from GLPNewElementsIndicatorViewDelegate
- (void)newElementsIndicatorViewPushed
{
    [self hideNewElementsIndicatorView];
    
    [self scrollToTheTop];
}

#pragma mark - GLPPostCellDelegate

-(void)elementTouchedWithRemoteKey:(NSInteger)remoteKey
{
    //Decide where to navigate. Private or current profile.
    
    self.selectedUserId = remoteKey;
    
    if([[ContactsManager sharedInstance] userRelationshipWithId:remoteKey] == kCurrentUser)
    {
        self.selectedUserId = -1;
        
        [self performSegueWithIdentifier:@"view profile" sender:self];
    }
    else
    {
        self.selectedUserId = remoteKey;
        
        [self performSegueWithIdentifier:@"view new private profile" sender:self];
    }
}

- (void)showLocationWithLocation:(GLPLocation *)location
{
    _selectedLocation = location;
    
    [self performSegueWithIdentifier:@"show location" sender:self];
}

- (void)navigateToPostForCommentWithIndexPath:(NSIndexPath *)postIndexPath
{
    _showComment = YES;
    self.selectedPost = [self.posts objectAtIndex:postIndexPath.row];
    self.selectedIndex = postIndexPath.row;
    self.postIndexToReload = postIndexPath.row;
    self.commentCreated = NO;
    [self performSegueWithIdentifier:@"view post" sender:self];
}

- (void)goingButtonTouchedWithNotification:(NSNotification *)notification
{
    
    _selectedPost = notification.userInfo[@"post"];
    UIImage *image = notification.userInfo[@"post_image"];

    if([image isEqual:[NSNull null]])
    {
        image = nil;
    }
    
    //Show the pop up view.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone_ipad" bundle:nil];
    GLPAttendingPopUpViewController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"GLPAttendingPopUpViewController"];
    
    [cvc setDelegate:self];
    [cvc setEventPost:_selectedPost withImage:image];
    
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

- (void)newPostButtonClick
{
    if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"new_post" bundle:nil];
        IntroKindOfNewPostViewController *newPostVC = [storyboard instantiateViewControllerWithIdentifier:@"IntroKindOfNewPostViewController"];
        newPostVC.groupPost = NO;
        newPostVC.navBarTransparentMode = [self.fakeNavigationBar isTransparentMode];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newPostVC];
        navigationController.modalPresentationStyle = UIModalPresentationCustom;
        [navigationController setTransitioningDelegate:self.transitionCategoriesViewController];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
    else
    {
        
        //If iOS6
        
        /**
         Takes screenshot from the current view controller to bring the sense of the transparency after the load
         of the NewPostViewController.
         */
        UIGraphicsBeginImageContext(self.view.window.bounds.size);
        [self.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"new_post" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"IntroKindOfNewPostViewController"];
        
        // vc.view.backgroundColor = [UIColor clearColor];
        vc.view.backgroundColor = [UIColor colorWithPatternImage:image];
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

-(void)loadGroupsFeed
{
    //Initialise categories to all.
//    [[SessionManager sharedInstance] setCurrentCategory:nil];
    
    [self.tableView reloadData];
    [self loadInitialGroupsPosts];
}

-(void)loadRegularPosts
{
    //Initialise categories to all.
    [[CategoryManager sharedInstance] setSelectedCategory:nil];
    [self loadInitialPosts];
}

- (void)showCategoriesViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone_ipad" bundle:nil];
    GLPNewCategoriesViewController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"GLPNewCategoriesViewController"];
    
    /**
     Takes screenshot from the current view controller to bring the sense of the transparency after the load
     of the NewPostViewController.
     */
    UIGraphicsBeginImageContext(self.view.window.bounds.size);
    [self.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cvc.modalPresentationStyle = UIModalPresentationCustom;
    cvc.delegate = self;
    
    [cvc setCampusWallScreenshot:image];
    [cvc setTransitioningDelegate:self.transitionCategoriesViewController];
    [self presentViewController:cvc animated:YES completion:nil];
}

/**
 This method is called by the notification that is called by campus live cell.
 
 @param notification
 */
-(void)showEventPost:(NSNotification*)notification
{
    NSDictionary *dict = [notification userInfo];
    GLPPost *post = [dict objectForKey:@"Post"];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone_ipad" bundle:nil];
    ViewPostViewController *vpvc = [storyboard instantiateViewControllerWithIdentifier:@"ViewPostViewController"];
    vpvc.post = post;
    vpvc.isFromCampusLive = YES;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vpvc];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Helpers

- (BOOL)isPostVisible:(GLPPost *)post
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"remoteKey == %d", post.remoteKey];
    
    NSArray *filteredArray = [_posts filteredArrayUsingPredicate:predicate];
    
    if(filteredArray.count > 0)
    {
        return YES;
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    FLog(@"GLPTimelineViewController : didReceiveMemoryWarning");
    [[GLPVideoLoaderManager sharedInstance] clearCache];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.identifier isEqualToString:@"view post"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];

        ViewPostViewController *vc = segue.destinationViewController;
        /**
         Forward data of the post the to the view. Or in future just forward the post id
         in order to fetch it from the server.
         */
        
        
        vc.commentJustCreated = self.commentCreated;
        vc.isFromCampusLive = NO;
        vc.post = self.selectedPost;
        vc.showComment = _showComment;
        _showComment = NO;
        
    }
    else if([segue.identifier isEqualToString:@"new comment"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
        AddCommentViewController *addComment = segue.destinationViewController;
        
        addComment.delegate = self;
        
    }
    else if([segue.identifier isEqualToString:@"view new private profile"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
        GLPPrivateProfileViewController *privateProfileViewController = segue.destinationViewController;
        
        privateProfileViewController.selectedUserId = self.selectedUserId;

    }
    else if([segue.identifier isEqualToString:@"view profile"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    }
    else if([segue.identifier isEqualToString:@"show location"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];

        GLPShowLocationViewController *showLocationVC = segue.destinationViewController;
        
        showLocationVC.location = _selectedLocation;
    }
    else if ([segue.identifier isEqualToString:@"show attendees"])
    {
        GLPShowUsersViewController *showUsersVC = segue.destinationViewController;
        
        showUsersVC.postRemoteKey = _selectedPost.remoteKey;
        
        showUsersVC.selectedTitle = @"GUEST LIST";
    }
    else if ([segue.identifier isEqualToString:@"show campus live"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    }
}

@end
