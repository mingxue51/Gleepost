//
//  GLPPrivateProfileViewController.m
//  Gleepost
//
//  Created by Silouanos on 09/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "UIViewController+GAI.h"
#import "UIViewController+Flurry.h"
#import "GLPPrivateProfileViewController.h"
#import "TransitionDelegateViewImage.h"
#import "ContactsManager.h"
#import "ProfileAboutTableViewCell.h"
#import "ProfileMutualTableViewCell.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "GLPPostManager.h"
#import "AppearanceHelper.h"
#import "GLPPostNotificationHelper.h"
#import "GLPPostImageLoader.h"
#import "ViewPostViewController.h"
#import "GLPPostNotificationHelper.h"
#import "GLPConversationViewController.h"
#import "GLPApplicationHelper.h"
#import "GLPiOSSupportHelper.h"
#import "EmptyMessage.h"
#import "UINavigationBar+Format.h"
#import "GLPBadgesViewController.h"
#import "ImageFormatterHelper.h"
#import "GLPShowLocationViewController.h"
#import "GLPViewImageViewController.h"
#import "GLPCalendarManager.h"
#import "GLPAttendingPopUpViewController.h"
#import "TDPopUpAfterGoingView.h"
#import "GLPShowUsersViewController.h"
#import "GLPShowUsersGroupsViewController.h"
#import "GLPAttendingPostsViewController.h"
#import "GLPTrackViewsCountProcessor.h"
#import "UserProfileManager.h"
#import "TableViewHelper.h"

@interface GLPPrivateProfileViewController () <GLPAttendingPopUpViewControllerDelegate>


@property (strong, nonatomic) GLPUser *profileUser;
@property (strong, nonatomic) UIImage *profileImage;

@property (assign, nonatomic) NSInteger numberOfRows;
@property (assign, nonatomic) NSInteger currentNumberOfRows;


@property (strong, nonatomic) TransitionDelegateViewImage *transitionViewImageController;

@property (assign, nonatomic) GLPSelectedTab selectedTabStatus;

//Used when there is new comment.
@property (assign, nonatomic) BOOL commentCreated;

@property (strong, nonatomic) GLPPost *selectedPost;

@property (assign, nonatomic) int postIndexToReload;

@property (strong, nonatomic) GLPConversation *conversation;
@property (strong, nonatomic) GLPUser *emptyConversationUser;

@property (strong, nonatomic) EmptyMessage *emptyPostsMessage;

@property (strong, nonatomic) GLPLocation *selectedLocation;

@property (strong, nonatomic) TDPopUpAfterGoingView *transitionViewPopUpAttend;

/** Captures the visibility of current cells. */
@property (strong, nonatomic) GLPTrackViewsCountProcessor *trackViewsCountProcessor;

@property (strong, nonatomic) UserProfileManager *userProfileManager;

/** Properties for loading previous posts. */
@property (assign, nonatomic) BOOL isLoading;
@property (assign, nonatomic) GLPLoadingCellStatus loadingCellStatus;

@end

@implementation GLPPrivateProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureView];

    self.tableView.allowsSelectionDuringEditing=YES;
    
    [self registerTableViewCells];
    
    [self initialiseObjects];
    
    [self loadAndSetUserDetails];
    
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
    [self configureNotifications];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setTitle];
    [self sendViewToGAI:NSStringFromClass([self class])];
    [self sendViewToFlurry:NSStringFromClass([self class])];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_trackViewsCountProcessor resetSentPostsSet];
    [super viewDidDisappear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self removeNotifications];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Configuration

-(void)initialiseObjects
{
    //Initialise rows with 3 because About cell is presented first.
    self.numberOfRows = 1;
    self.profileImage = nil;
    self.isLoading = NO;
    self.transitionViewImageController = [[TransitionDelegateViewImage alloc] init];
    _emptyPostsMessage = [[EmptyMessage alloc] initWithText:@"No more posts" withPosition:EmptyMessagePositionBottom andTableView:self.tableView];
    _selectedLocation = nil;
    _transitionViewPopUpAttend = [[TDPopUpAfterGoingView alloc] init];
    _trackViewsCountProcessor = [[GLPTrackViewsCountProcessor alloc] init];
    _userProfileManager = [[UserProfileManager alloc] initWithUsersRemoteKey:self.selectedUserId];
    self.loadingCellStatus = kGLPLoadingCellStatusFinished;
}

- (void)configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRealImage:) name:GLPNOTIFICATION_POST_IMAGE_LOADED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goingButtonTouchedWithNotification:) name:GLPNOTIFICATION_GOING_BUTTON_TOUCHED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewsCounter:) name:GLPNOTIFICATION_POST_CELL_VIEWS_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(usersDataFetched:) name:GLPNOTIFICATION_USERS_DATA_FETCHED object:nil];
    [self configureManagerNotifications];
 }

- (void)configureManagerNotifications
{
    NSString *notificationName = [ProfileManager postsNotificationNameWithUserRemoteKey:self.selectedUserId];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postsLoaded:) name:notificationName object:nil];
    
    notificationName = [ProfileManager previousPostsNotificationNameWithUserRemoteKey:self.selectedUserId];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(previousPostsLoaded:) name:notificationName object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POST_IMAGE_LOADED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_GOING_BUTTON_TOUCHED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POST_CELL_VIEWS_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_USERS_DATA_FETCHED object:nil];
    [self removeManagerNotifications];
}

- (void)removeManagerNotifications
{
    NSString *notificationName = [ProfileManager postsNotificationNameWithUserRemoteKey:self.selectedUserId];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];
    
    notificationName = [ProfileManager previousPostsNotificationNameWithUserRemoteKey:self.selectedUserId];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];

}


-(void)registerTableViewCells
{
    //Register nib files in table view.
    [self.tableView registerNib:[UINib nibWithNibName:@"PrivateProfileTopViewCell" bundle:nil] forCellReuseIdentifier:@"PrivateProfileTopViewCell"];

    //Register posts.
    [self.tableView registerNib:[UINib nibWithNibName:@"PostImageCell" bundle:nil] forCellReuseIdentifier:@"ImageCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostVideoCell" bundle:nil] forCellReuseIdentifier:@"VideoCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTextCellView" bundle:nil] forCellReuseIdentifier:@"TextCell"];
}

-(void)configureView
{
    
    if([GLPiOSSupportHelper isIOS6])
    {
        [GLPiOSSupportHelper setBackgroundImageToTableView:self.tableView];
        
        return;
    }
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [AppearanceHelper setCustomBackgroundToTableView:self.tableView];

}

- (void)setTitle
{
    if(_profileUser)
    {
        self.navigationController.navigationBar.topItem.title = [_profileUser.name uppercaseString];
    }
    
}

-(void)setBottomView
{
    CGRect frame = self.tableView.bounds;
    frame.origin.y = frame.size.height;
    CGRect viewFrame = self.view.bounds;
    viewFrame.origin.y = viewFrame.size.height;
    UIImageView* grayView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 300.f, 320.0f, 250.0f)];
    grayView.tag = 100;
    grayView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = grayView;
}

-(void)clearBottomView
{
    self.tableView.tableFooterView = nil;
}

-(void)configureNavigationBar
{
    //Change the format of the navigation bar.
    [self.navigationController.navigationBar setFontFormatWithColour:kBlack];
    
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
    
    //We are not using the default method for formatting the navigation bar because was causing issues
    //with the navigation to GroupVC.
    
    [self.navigationController.navigationBar setShadowImage:[ImageFormatterHelper generateOnePixelHeightImageWithColour:[AppearanceHelper mediumGrayGleepostColour]]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)hideNetworkErrorViewIfNeeded
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_HIDE_ERROR_VIEW object:self userInfo:nil];
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Client methods


/**
 Loads first user from local database and then from server.
 */

-(void)loadAndSetUserDetails
{
    [_userProfileManager getUserData];
    [_userProfileManager getPosts];
}

- (void)loadPreviousPosts
{
    if(self.isLoading) {
        return;
    }
    
    if([_userProfileManager postsCount] == 0) {
        self.loadingCellStatus = kGLPLoadingCellStatusFinished;
        return;
    }
    
    if(self.loadingCellStatus == kGLPLoadingCellStatusLoading) {
        return;
    }
    
    [self startLoading];
    self.loadingCellStatus = kGLPLoadingCellStatusLoading;
    [_userProfileManager loadPreviousPosts];
    
//TODO: After previous posts' loaded.
    
    /**
     [self stopLoading];
     
     if(!success) {
     self.loadingCellStatus = kGLPLoadingCellStatusError;
     [self reloadLoadingCell];
     return;
     }
     
     self.loadingCellStatus = remain ? kGLPLoadingCellStatusInit : kGLPLoadingCellStatusFinished;
     
     
     if(posts.count > 0) {
     int firstInsertRow = self.posts.count+1;
     
     [[GLPPostImageLoader sharedInstance] addPostsImages:posts];
     
     [self.posts insertObjects:posts atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.posts.count, posts.count)]];
     
     
     NSMutableArray *rowsInsertIndexPath = [[NSMutableArray alloc] init];
     for(int i = firstInsertRow; i < self.posts.count+1; i++) {
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
     */

}

-(void)loadAndSetContactDetails
{
    //Try to load image.
    self.profileImage = [[ContactsManager sharedInstance] contactImageWithRemoteKey:self.selectedUserId];
    
    //If image is nil then load directly from the server.
    if(self.profileImage == nil)
    {
        [self loadAndSetUserDetails];
    }
    else
    {
        GLPUser *notCompletedUser = [[ContactsManager sharedInstance] contactWithRemoteKey:self.selectedUserId].user;
        
        self.navigationItem.title = [notCompletedUser.name uppercaseString];
        
        [self refreshFirstCell];
        
        [self loadAndSetUserDetails];
    }
}


#pragma mark - UI methods

-(void)updateRealImage:(NSNotification*)notification
{
    NSInteger index = [_userProfileManager parseRefreshCellNotification:notification];
    
    if(index != -1)
    {
        [self refreshCellViewWithIndex:index+1];
    }
}

#pragma mark - Request management

- (void)startLoading
{
    self.isLoading = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)stopLoading
{
    self.isLoading = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - PrivateProfileTopViewCellDelegate

- (void)viewProfileImage:(UIImage *)image
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    GLPViewImageViewController *viewImage = [storyboard instantiateViewControllerWithIdentifier:@"GLPViewImageViewController"];
    viewImage.image = image;
    viewImage.view.backgroundColor = self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.89];
    viewImage.modalPresentationStyle = UIModalPresentationCustom;
    
    if(![GLPiOSSupportHelper isIOS6])
    {
        [viewImage setTransitioningDelegate:self.transitionViewImageController];
    }
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self presentViewController:viewImage animated:YES completion:nil];
}

- (void)badgeTouched
{
    [self performSegueWithIdentifier:@"view badges" sender:self];
}

- (void)numberOfGroupsTouched
{
    [self performSegueWithIdentifier:@"show users groups" sender:self];
}

- (void)numberOfRsvpsTouched
{
    [self performSegueWithIdentifier:@"show attending events" sender:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([_userProfileManager postsCount] == 0)
    {
        [_emptyPostsMessage showEmptyMessageView];
    }
    else
    {
        [_emptyPostsMessage hideEmptyMessageView];
    }
    
    self.currentNumberOfRows = self.numberOfRows + [_userProfileManager postsCount] + 1;
    return self.currentNumberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //Try to load previous posts.
    if(indexPath.row-1 == [_userProfileManager postsCount])
    {
        return [TableViewHelper generateLoadingCell];
    }
    
    static NSString *CellIdentifierWithImage = @"ImageCell";
    static NSString *CellIdentifierWithoutImage = @"TextCell";
    static NSString *CellIdentifierVideo = @"VideoCell";

    
    static NSString *CellIdentifierProfile = @"PrivateProfileTopViewCell";
    
//    static NSString *CellIdentifierProfile = @"ProfileCell";
//    static NSString *CellIdentifierButtons = @"ButtonsCell";
    
//    static NSString *CellIdentifierAbout = @"AboutCell";
//    static NSString *CellIdentifierMutual = @"MutualCell";
    
    
    GLPPostCell *postViewCell;
    
//    ProfileButtonsTableViewCell *buttonsView;
    PrivateProfileTopViewCell *profileView;
//    ProfileTableViewCell *profileView;
//    ProfileAboutTableViewCell *profileAboutView;
//    ProfileMutualTableViewCell *profileMutualView;
    

    if(indexPath.row == 0)
    {
        profileView = [tableView dequeueReusableCellWithIdentifier:CellIdentifierProfile forIndexPath:indexPath];
        
        
        return  [self configureProfileViewCell:profileView];
        
    }
    else if (indexPath.row >= 1)
    {
        if([_userProfileManager postsCount] != 0)
        {
            GLPPost *post = [_userProfileManager postWithIndex:indexPath.row - 1];
            
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
            
            [postViewCell setPost:post withPostIndexPath:indexPath];
            
            if(indexPath.row > 5)
            {
                [self clearBottomView];
            }
        }
        
        return postViewCell;
        
    }
    
    //TODO: See if this is right.
    return nil;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //TODO: implement manual reloading
    if(indexPath.row-1 == [_userProfileManager postsCount]) {
        return;
    }
    else if(indexPath.row < 1)
    {
        return;
    }
    
    self.selectedPost = [_userProfileManager postWithIndex:indexPath.row - 1];
//    self.selectedIndex = indexPath.row;
    self.postIndexToReload = indexPath.row-1;
    self.commentCreated = NO;
    [self performSegueWithIdentifier:@"view post" sender:self];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row - 1 == [_userProfileManager postsCount]) {
        return (self.loadingCellStatus != kGLPLoadingCellStatusFinished) ? kGLPLoadingCellHeight : 0;
    }
    
    if(indexPath.row == 0)
    {
        return PRIVATE_PROFILE_TOP_VIEW_HEIGHT;
    }
    else if(indexPath.row >= 1)
    {
//        if(self.posts.count != 0 && self.posts)
        if([_userProfileManager postsCount] != 0)
        {
            GLPPost *currentPost = [_userProfileManager postWithIndex:indexPath.row - 1];
                        
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row - 1 == [_userProfileManager postsCount] && self.loadingCellStatus == kGLPLoadingCellStatusInit) {
        DDLogInfo(@"Load previous posts cell activated");
        [self loadPreviousPosts];
    }
}

- (PrivateProfileTopViewCell *)configureProfileViewCell:(PrivateProfileTopViewCell *)cell
{
    [cell setDelegate:self];
    [cell setUserData:_profileUser];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table view refresh methods

-(void)refreshCellViewWithIndex:(const NSUInteger)index
{
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

-(void)refreshFirstCell
{
    [self.tableView reloadData];
//    [self.tableView beginUpdates];
//    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//    [self.tableView endUpdates];
}

#pragma  mark - Buttons view methods

-(void)viewSectionWithId:(GLPSelectedTab) selectedTab
{
    self.selectedTabStatus = selectedTab;
    [self.tableView reloadData];
}

#pragma mark - Scroll view

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_trackViewsCountProcessor resetVisibleCells];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if([_userProfileManager postsCount] == 0)
    {
        return;
    }
    
    if(self.loadingCellStatus == kGLPLoadingCellStatusLoading)
    {
        return;
    }
    
    //Capture the current cells that are visible and add them to the GLPFlurryVisibleProcessor.
    
    NSMutableArray *postsYValues = nil;
    
    NSArray *visiblePosts = [self getVisiblePostsInTableViewWithYValues:&postsYValues];
    
    DDLogDebug(@"Profile scrollViewDidEndDecelerating1 posts: %@", visiblePosts);
    
    [_trackViewsCountProcessor trackVisiblePosts:visiblePosts withPostsYValues:postsYValues];
    
//    [[GLPVideoLoaderManager sharedInstance] visiblePosts:visiblePosts];
    
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(self.loadingCellStatus == kGLPLoadingCellStatusLoading)
    {
        return;
    }
    
    if(decelerate == 0)
    {
        NSMutableArray *postsYValues = nil;
        
        NSArray *visiblePosts = [self getVisiblePostsInTableViewWithYValues:&postsYValues];
        
        DDLogDebug(@"Profile scrollViewDidEndDragging2 posts: %@", visiblePosts);
        
        [_trackViewsCountProcessor trackVisiblePosts:visiblePosts withPostsYValues:postsYValues];
        
//        [[GLPVideoLoaderManager sharedInstance] visiblePosts:visiblePosts];
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
        if(path.row < [_userProfileManager postsCount])
        {
            [visiblePosts addObject:[_userProfileManager postWithIndex:path.row - 1]];
            CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:path];
            CGRect rectInSuperview = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];
            [*postsYValues addObject:@(rectInTableView.size.height/2.0 + rectInSuperview.origin.y)];
        }
    }
    return visiblePosts;
}

#pragma mark - Notification methods

/**
 Method is called once the posts data fetched via UserProfileManager
 
 @param notification NSNotification containing if posts fetched properly or not.
 
 */
- (void)postsLoaded:(NSNotification *)notification
{
    BOOL success = [notification.userInfo[@"success"] boolValue];
    
    if(success)
    {
        BOOL remains = [_userProfileManager postsCount] == kGLPNumberOfPosts ? YES : NO;
        self.loadingCellStatus = remains ? kGLPLoadingCellStatusInit : kGLPLoadingCellStatusFinished;
        [self.tableView reloadData];
    }
}

- (void)previousPostsLoaded:(NSNotification *)notification
{
    NSArray *previousPosts = notification.userInfo[@"posts"];
    BOOL success = [notification.userInfo[@"success"] boolValue];
    NSInteger remain = [notification.userInfo[@"remain"] integerValue];
    
    DDLogDebug(@"Previous posts %@", previousPosts);
    
    
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

- (void)usersDataFetched:(NSNotification *)notification
{
    GLPUser *userData = notification.userInfo[@"user_data"];
    self.profileUser = userData;
    self.navigationItem.title = [self.profileUser.name uppercaseString];;
    [self.tableView reloadData];
}


/**
 This method is called when there is an update in views count.
 
 @param notification the notification contains post remote key and the updated
 number of views.
 */
- (void)updateViewsCounter:(NSNotification *)notification
{
    [_userProfileManager parseAndUpdatedViewsCountPostWithNotification:notification withCallbackBlock:^(NSInteger index) {
        
        if(index != -1)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshCellViewWithIndex:index+1];
            });
        }
    }];
}

- (void)reloadLoadingCell
{
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[_userProfileManager postsCount] inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - View image delegate

-(void)viewPostImage:(UIImage*)postImage
{
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

#pragma mark - New comment delegate

-(void)setPreviousViewToNavigationBar
{
    self.navigationItem.hidesBackButton = NO;
}

-(void)setPreviousNavigationBarName
{
    [self.navigationItem setTitle:self.profileUser.name];
}

-(void)hideNavigationBarAndButtonWithNewTitle:(NSString*)newTitle
{
    [self.navigationItem setTitle:newTitle];
    self.navigationItem.hidesBackButton = YES;
}

-(void)navigateToViewPostFromCommentWithIndex:(int)postIndex
{
    self.selectedPost = [_userProfileManager postWithIndex:postIndex-1];
    
//    self.postIndexToReload = postIndex;
    
    ++self.selectedPost.commentsCount;
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:postIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    self.commentCreated = YES;
    
    //Notify GLPProfileViewController about changes.
    [GLPPostNotificationHelper updatePostWithNotifiationName:@"GLPPostUpdated" withObject:self remoteKey:self.selectedPost.remoteKey numberOfLikes:self.selectedPost.likes andNumberOfComments:self.selectedPost.commentsCount];
    
    [self performSegueWithIdentifier:@"view post" sender:self];
}


#pragma mark - GLPPostCellDelegate

-(void)elementTouchedWithRemoteKey:(NSInteger)remoteKey
{
    //Decide where to navigate. Private or current profile.
    
    
//    if([[ContactsManager sharedInstance] userRelationshipWithId:remoteKey] == kCurrentUser)
//    {
//        self.selectedUserId = -1;
//        
//        [self performSegueWithIdentifier:@"view profile" sender:self];
//    }
//    else
//    {
//        self.selectedUserId = remoteKey;
//        
//        [self performSegueWithIdentifier:@"view private profile" sender:self];
//    }
}

- (void)showLocationWithLocation:(GLPLocation *)location
{
    _selectedLocation = location;
    
    [self performSegueWithIdentifier:@"show location" sender:self];
}

- (void)navigateToPostForCommentWithIndexPath:(NSIndexPath *)postIndexPath
{
    _showComment = YES;
    self.selectedPost = [_userProfileManager postWithIndex:postIndexPath.row - 1];
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

#pragma mark - Navigation methods

-(void)viewConversation:(GLPConversation*)conversation
{
    _conversation = conversation;
    
    [self performSegueWithIdentifier:@"view topic" sender:self];
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
        
        vc.showComment = _showComment;
        
        vc.isFromCampusLive = NO;
        
        vc.post = self.selectedPost;
        
        _showComment = NO;
        
    }
    else if ([segue.identifier isEqualToString:@"view topic"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
        GLPConversationViewController *vt = segue.destinationViewController;
        vt.conversation = _conversation;
    }
    else if ([segue.identifier isEqualToString:@"view badges"])
    {
        GLPBadgesViewController *bVC = segue.destinationViewController;
        bVC.customTitle = [NSString stringWithFormat:@"%@'s", _profileUser.name];
    }
    else if ([segue.identifier isEqualToString:@"show location"])
    {
        GLPShowLocationViewController *showLocationVC = segue.destinationViewController;
        
        showLocationVC.location = _selectedLocation;
    }
    else if ([segue.identifier isEqualToString:@"show attendees"])
    {
        GLPShowUsersViewController *showUsersVC = segue.destinationViewController;
        
        showUsersVC.postRemoteKey = _selectedPost.remoteKey;
        
        showUsersVC.selectedTitle = @"GUEST LIST";
    }
    else if ([segue.identifier isEqualToString:@"show users groups"])
    {
        GLPShowUsersGroupsViewController *showUsersGroups = segue.destinationViewController;
        
        showUsersGroups.user = _profileUser;
    }
    else if([segue.identifier isEqualToString:@"show attending events"])
    {
        GLPAttendingPostsViewController *attendingPostsViewController = segue.destinationViewController;
        
        attendingPostsViewController.selectedUser = _profileUser;
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
