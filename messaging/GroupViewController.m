//
//  GroupViewController.m
//  Gleepost
//
//  Created by Silouanos on 04/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GroupViewController.h"
#import "GLPPost.h"
#import "AppearanceHelper.h"
#import "GLPGroupManager.h"
#import "GLPPostManager.h"
#import "GLPPostImageLoader.h"
#import "GLPPostNotificationHelper.h"
#import "ViewPostViewController.h"
#import "TransitionDelegateViewImage.h"
#import "ContactUserCell.h"
#import "GLPPrivateProfileViewController.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "GLPNewElementsIndicatorView.h"
#import "GLPLoadingCell.h"
#import "MembersViewController.h"
#import "GroupOperationManager.h"
#import "SessionManager.h"
#import "GLPiOSSupportHelper.h"
#import "EmptyMessage.h"
#import "ShapeFormatterHelper.h"
#import "UINavigationBar+Utils.h"
#import "UINavigationBar+Format.h"
//#import "BOZPongRefreshControl.h"
//#import "GLPRefreshControl.h"
#import "ContactsManager.h"
#import "GLPProfileViewController.h"
#import "FakeNavigationBarView.h"
#import "IntroKindOfNewPostViewController.h"
#import "GLPShowLocationViewController.h"
#import "GLPLiveGroupManager.h"
#import "GLPLiveGroupPostManager.h"

@interface GroupViewController ()

@property (strong, nonatomic) NSMutableArray *posts;
@property (strong, nonatomic) NSArray *members;
@property (assign, nonatomic) BOOL commentCreated;
@property (strong, nonatomic) GLPPost *selectedPost;
@property (assign, nonatomic) int currentNumberOfRows;
@property (strong, nonatomic) TransitionDelegateViewImage *transitionViewImageController;
@property (assign, nonatomic) int selectedUserId;
//@property (assign, nonatomic) GLPSelectedTab selectedTabStatus;

//Properties for refresh loader.
@property (assign, nonatomic) BOOL isLoading;
@property (assign, nonatomic) int insertedNewRowsCount; // count of new rows inserted
@property (strong, nonatomic) GLPNewElementsIndicatorView *elementsIndicatorView;

@property (assign, nonatomic) GLPLoadingCellStatus loadingCellStatus;


//@property (assign, nonatomic) BOOL firstLoadSuccessful; //Not used here.

@property (assign, nonatomic) BOOL tableViewInScrolling;
@property (assign, nonatomic) int postIndexToReload;

@property (strong, nonatomic) UIImage *groupImage;
@property (strong, nonatomic) FDTakeController *fdTakeController;
@property (strong, nonatomic) EmptyMessage *emptyPostsMessage;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) GLPStretchedImageView *strechedImageView;

@property (strong, nonatomic) FakeNavigationBarView *fakeNavigationBar;

@property (assign, nonatomic, getter = isFakeNavigationBarVisible) BOOL fakeNavigationBarVisible;

//@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) GLPLocation *selectedLocation;

@property (assign, nonatomic) BOOL showComment;

@end

@implementation GroupViewController

const int NUMBER_OF_ROWS = 1;
const float OFFSET_START_ANIMATING = 300.0;
const float TOP_OFF_SET = -64.0;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self registerTableViewCells];
    
    [self initialiseObjects];
    
    if(!_fromPushNotification)
    {
        [self configureTopImageView];
        [self configureTableView];
        [self loadPosts];
    }
    

    
    
//    if(_fromPushNotification)
//    {
//        [self loadGroupData];
//    }
    
//    [self loadMembers];
    
    [self configureNotifications];
    
    
    [[GLPLiveGroupManager sharedInstance] postGroupReadWithRemoteKey:_group.remoteKey];
}

//- (void)viewDidLayoutSubviews
//{
//    self.pongRefreshControl = [BOZPongRefreshControl attachToTableView:self.tableView
//                                                     withRefreshTarget:self
//                                                      andRefreshAction:@selector(loadEarlierPostsFromPullToRefresh)];
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureNavigationItems];
    
    [self configureNavigationBar];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    if([self isFakeNavigationBarVisible])
//    {
//        [_fakeNavigationBar showNavigationBar];
//    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    
    [super viewWillDisappear:animated];
}

-(void)dealloc
{
    [self removeNotifications];
    [_tableView removeFromSuperview];
}


#pragma mark - Configuration methods

-(void)registerTableViewCells
{
    //Register nib files in table view.
    
//    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileViewTableViewCell" bundle:nil] forCellReuseIdentifier:@"ProfileCell"];
    
    

//    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileViewTwoButtonsTableViewCell" bundle:nil] forCellReuseIdentifier:@"TwoButtonsCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DescriptionSegmentGroupCell" bundle:nil] forCellReuseIdentifier:@"DescriptionSegmentGroupCell"];
    
    //Register posts.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostImageCell" bundle:nil] forCellReuseIdentifier:@"ImageCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTextCellView" bundle:nil] forCellReuseIdentifier:@"TextCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostVideoCell" bundle:nil] forCellReuseIdentifier:@"VideoCell"];
    //Register contacts' cells.
    
//    [self.tableView registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
    
    
    
//    [self.tableView registerNib:[UINib nibWithNibName:@"GLPLoadingCell" bundle:nil] forCellReuseIdentifier:@"LoadingCell"];


}

-(void)configureTableView
{
    // refresh control
//    _refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(50, 150, 320, 60)];
//    [_refreshControl addTarget:self action:@selector(loadEarlierPostsFromPullToRefresh) forControlEvents:UIControlEventValueChanged];

    

//    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 300, 320, 70)];
//    [self.refreshControl setTintColor:[UIColor blackColor]];
//    [self.refreshControl addTarget:self action:@selector(loadEarlierPostsFromPullToRefresh) forControlEvents:UIControlEventValueChanged];
//    [_tableView addSubview: self.refreshControl];
//    
//    [_tableView bringSubviewToFront:self.refreshControl];
    
    
//    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
//        self.tableView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, 0, 0); // This is the default and might not be necessary
    
//        self.headerContainerViewConstraint.constant = -self.topLayoutGuide.length;
    
//        self.tableView.tableHeaderView.frame = CGRectMake(self.tableView.tableHeaderView.frame.origin.x, self.tableView.tableHeaderView.frame.origin.y, self.tableView.tableHeaderView.frame.size.width, self.tableView.tableHeaderView.frame.size.height - self.topLayoutGuide.length);
 //   }
    
//    [_activityIndicator setFrame:CGRectMake(50, 100, 320, 70)];
    
    

    
    if([GLPiOSSupportHelper isIOS6])
    {
        [GLPiOSSupportHelper setBackgroundImageToTableView:self.tableView];
    }
    else
    {
        [AppearanceHelper setCustomBackgroundToTableView:self.tableView];
    }
    
    [self.tableView setTableFooterView:[[UIView alloc] init]];

    
    _tableView.contentInset = UIEdgeInsetsMake(185, 0, 0, 0);
    
    
    [_tableView addSubview:_strechedImageView];

}

- (void)configureTopImageView
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"GLPStretchedImageView" owner:self options:nil];
    
    //Set delegate.
    _strechedImageView = [array objectAtIndex:0];
    
//    CGRectSetY(_strechedImageView, -64.0);
    
    _strechedImageView.frame = CGRectMake(0, -kStretchedImageHeight, self.tableView.frame.size.width, kStretchedImageHeight);
    
    [_strechedImageView setImageUrl:_group.groupImageUrl withPlaceholderImage:@"default_thumbnail"];
    
    [_strechedImageView setTextInTitle:_group.name];
    
    [_strechedImageView setViewControllerDelegate:self];
    
    [_strechedImageView setGesture:YES];
}

-(void)initialiseObjects
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
//    self.selectedTabStatus = kGLPPosts;
    
    
    //Initialise.
//    self.readyToReloadPosts = YES;
    
    // loading related controls
//    self.loadingCellStatus = kGLPLoadingCellStatusLoading;
    self.isLoading = NO;
//    self.firstLoadSuccessful = NO;
    self.loadingCellStatus = kGLPLoadingCellStatusFinished;
    
    self.transitionViewImageController = [[TransitionDelegateViewImage alloc] init];
    
    self.fdTakeController = [[FDTakeController alloc] init];
    self.fdTakeController.viewControllerForPresentingImagePickerController = self;
    self.fdTakeController.delegate = self;
    
    _emptyPostsMessage = [[EmptyMessage alloc] initWithText:@"No more posts" withPosition:EmptyMessagePositionBottom andTableView:self.tableView];
    
    _fakeNavigationBar = [[FakeNavigationBarView alloc] initWithTitle:_group.name];
    
    [self.view addSubview:_fakeNavigationBar];
    
    [_fakeNavigationBar setHidden:YES];
    
    _fakeNavigationBarVisible = NO;
    
    _selectedLocation = nil;

    _showComment = NO;
    
//    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
//    _strechedImageView = [[GLPStretchedImageView alloc] init];
}

-(void)configureNavigationItems
{
    int buttonX = 10;
    
    if([GLPiOSSupportHelper isIOS6])
    {
        buttonX = 0;
    }
    
    [self.navigationController.navigationBar setButton:kRight withImageName:@"new_post_groups" withButtonSize:CGSizeMake(30.0, 30.0) withSelector:@selector(createNewPost:) andTarget:self];
    
    [self.navigationController.navigationBar setButton:kRight withImageName:@"settings_btn" withButtonSize:CGSizeMake(30.0, 30.0) withSelector:@selector(showSettings:) andTarget:self];
    
    //=======
    //    [btnBack setFrame:CGRectMake(buttonX, 0, 35, 35)];
    //
    //    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, btnBack.frame.size.width, btnBack.frame.size.height)];
    //
    //
    //>>>>>>> ios6-support
    
}

-(void)configureNavigationBar
{
    
    //Change the format of the navigation bar.
//    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
    
//    [self.navigationController.navigationBar setFontFormatWithColour:kBlack];
    
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    if([self isFakeNavigationBarVisible])
    {
        //_fakeNavigationBarVisible = NO;
//        [self.navigationController.navigationBar makeVisibleWithTitle:_group.name];
//        [_fakeNavigationBar showNavigationBar];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    }
    else
    {
        //_fakeNavigationBarVisible = YES;
//        [self.navigationController.navigationBar invisible];
//        [_fakeNavigationBar hideNavigationBar];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    }
    
    [self.navigationController.navigationBar invisible];


    
    //Set title.
    self.navigationController.navigationBar.topItem.title = @"";
    

}

-(void)configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRealImage:) name:@"GLPPostImageUploaded" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePostRemoteKeyAndImage:) name:@"GLPPostUploaded" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNewMediaPostWithPost:) name:GLPNOTIFICATION_RELOAD_DATA_IN_GVC object:nil];
}

-(void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPPostImageUploaded" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPPostUploaded" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_RELOAD_DATA_IN_GVC object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notifications methods

-(void)updateRealImage:(NSNotification *)notification
{
    GLPPost *currentPost = nil;
    
    int index = [GLPPostNotificationHelper parsePost:&currentPost imageNotification:notification withPostsArray:self.posts];
    
    
    DDLogWarn(@"GroupViewController : updateRealImage notification: %@ and index: %d", notification, index);

    
#warning bug here.
    if(currentPost)
    {
        DDLogWarn(@"Refresh cell with index: %d", index);
        
        [self refreshCellViewWithIndex:index+1];
    }
}

-(void)updatePostRemoteKeyAndImage:(NSNotification*)notification
{
    NSDictionary *dict = [notification userInfo];
    
    int key = [(NSNumber*)[dict objectForKey:@"key"] integerValue];
    int remoteKey = [(NSNumber*)[dict objectForKey:@"remoteKey"] integerValue];
    NSString * urlImage = [dict objectForKey:@"imageUrl"];
    

    int index = 1;
    
    GLPPost *uploadedPost = nil;
    
    for(GLPPost* p in self.posts)
    {
        if(key == p.key)
        {
            
            //If the post is text or video post don't add any url image.
            if(![urlImage isEqualToString:@""])
            {
                p.imagesUrls = [[NSArray alloc] initWithObjects:urlImage, nil];
            }
            
            p.remoteKey = remoteKey;
            uploadedPost = p;
            break;
        }
        ++index;
    }
    
    [[GLPLiveGroupPostManager sharedInstance] removePost:uploadedPost fromGroupWithRemoteKey:_group.remoteKey];

    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
}


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

#pragma mark - Table view refresh methods

-(void)refreshCellViewWithIndex:(const NSUInteger)index
{
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)updateTableViewWithNewPostsAndScrollToTop:(int)count
{
    NSMutableArray *rowsInsertIndexPath = [[NSMutableArray alloc] init];
    for(int i = 1; i < count+1; i++) {
        [rowsInsertIndexPath addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    //The condition is added to prevent error when there are no posts in the table view.
    
    if(self.posts.count == 1 || !self.posts)
    {
        [self.tableView reloadData];
    }
    else
    {
        [self.tableView insertRowsAtIndexPaths:rowsInsertIndexPath withRowAnimation:UITableViewRowAnimationFade];
    }
    
    
    
    //    [self scrollToTheTop];
    
}

- (void)updateTableViewWithNewPosts:(int)count
{
    CGPoint tableViewOffset = [self.tableView contentOffset];
    [UIView setAnimationsEnabled:NO];
    
    int heightForNewRows = 0;
    
    NSMutableArray *rowsInsertIndexPath = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < count; i++) {
        
        NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [rowsInsertIndexPath addObject:tempIndexPath];
        
        heightForNewRows = heightForNewRows + [self tableView:self.tableView heightForRowAtIndexPath:tempIndexPath];
    }
    
    tableViewOffset.y += heightForNewRows;
    
    [self.tableView setContentOffset:tableViewOffset animated:NO];
    [self.tableView insertRowsAtIndexPaths:rowsInsertIndexPath withRowAnimation:UITableViewRowAnimationFade];
    
    [UIView setAnimationsEnabled:YES];
    
    // display the new elements indicator if we are not on top
    NSIndexPath *firstVisibleIndexPath = [[self.tableView indexPathsForVisibleRows] objectAtIndex:0];
    if(firstVisibleIndexPath.row != 0) {
        [self showNewElementsIndicatorView];
    }
}

-(void)removeTableViewPostWithIndex:(int)index
{
    NSMutableArray *rowsDeleteIndexPath = [[NSMutableArray alloc] init];
    
    [rowsDeleteIndexPath addObject:[NSIndexPath indexPathForRow:index+1 inSection:0]];
    
    [self.tableView deleteRowsAtIndexPaths:rowsDeleteIndexPath withRowAnimation:UITableViewRowAnimationRight];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if(self.selectedTabStatus == kGLPPosts)
//    {
//        int i = (self.posts.count == 0) ? 0 : 1;
    
    if(self.posts.count == 0)
    {
        [_emptyPostsMessage showEmptyMessageView];
    }
    else
    {
        [_emptyPostsMessage hideEmptyMessageView];
    }
    
    self.currentNumberOfRows = NUMBER_OF_ROWS + self.posts.count + 1 /*+ i*/;
//    }
//    else
//    {
//        self.currentNumberOfRows = NUMBER_OF_ROWS + self.members.count;
//    }
        
    
    
    return self.currentNumberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Try to load previous posts.
    if(indexPath.row-1 == self.posts.count) {
        
//        DDLogDebug(@"Rows: %d, Count: %d", indexPath.row, self.posts.count);
        
//        GLPLoadingCell *loadingCell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell" forIndexPath:indexPath];
//        [loadingCell updateWithStatus:self.loadingCellStatus];
//        return loadingCell;
        
        return [self cellWithMessage:@"Loading..."];
        
        
    }
    
    static NSString *CellIdentifierWithImage = @"ImageCell";
    static NSString *CellIdentifierWithoutImage = @"TextCell";
    static NSString *CellVideoIdentifier = @"VideoCell";
    static NSString *CellDescriptionGroupIdentifier = @"DescriptionSegmentGroupCell";
    
    GLPPostCell *postViewCell;
    DescriptionSegmentGroupCell *groupDescrViewCell;
    
    if(indexPath.row == 0)
    {
        groupDescrViewCell = [tableView dequeueReusableCellWithIdentifier:CellDescriptionGroupIdentifier forIndexPath:indexPath];
        
//        [profileView setPrivateProfileDelegate:self];
        
//        if(self.profileImage && self.profileUser)
//        {
//            [profileView initialiseElementsWithUserDetails:self.profileUser withImage:self.profileImage];
//        }
//        else if(self.profileImage && !self.profileUser)
//        {
//            [profileView initialiseProfileImage:self.profileImage];
//        }
//        else
//        {
//            [profileView initialiseElementsWithUserDetails:self.profileUser];
//        }
        
        [groupDescrViewCell setDelegate:self];

        [self loadPendingImageIfExist];
        
        groupDescrViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [groupDescrViewCell setGroupData:_group];
        
        return groupDescrViewCell;
    }
    else if (indexPath.row >= 1)
    {
        if(self.posts.count != 0)
        {
            GLPPost *post = self.posts[indexPath.row-1];
            
            if([post imagePost])
            {
                postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithImage forIndexPath:indexPath];
            }
            else if ([post isVideoPost])
            {
                postViewCell = [tableView dequeueReusableCellWithIdentifier:CellVideoIdentifier forIndexPath:indexPath];
            }
            else
            {
                postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithoutImage forIndexPath:indexPath];
            }
            
            //Set this class as delegate.
            postViewCell.delegate = self;
            
            [postViewCell setPost:post withPostIndex:indexPath.row];
        }


        return postViewCell;
    }
    
    return nil;
}


- (UITableViewCell *)cellWithMessage:(NSString *)message {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = message;
    cell.textLabel.font = [UIFont fontWithName:GLP_APP_FONT size:12.0f];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [UIColor grayColor];
    cell.userInteractionEnabled = NO;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if(indexPath.row < 1)
    {
        return;
    }
    
    if(indexPath.row-1 == self.posts.count) {
        return;
    }
    
    self.selectedPost = self.posts[indexPath.row - 1];
    //    self.postIndexToReload = indexPath.row-2;
    self.commentCreated = NO;
    [self performSegueWithIdentifier:@"view post" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row - 1 == self.posts.count) {
        
        
        
        return (self.loadingCellStatus != kGLPLoadingCellStatusFinished) ? kGLPLoadingCellHeight : 0;
    }
    
    if(indexPath.row == 0)
    {
        return [DescriptionSegmentGroupCell getCellHeightWithGroup:_group];
    }
    else if(indexPath.row >= 1)
    {
        if(self.posts.count != 0 && self.posts)
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
    }
    
    return 70.0f;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // hide the new elements indicator if needed when we are on top
    if(!self.elementsIndicatorView.hidden && (indexPath.row == 0 || indexPath.row < self.insertedNewRowsCount)) {
        NSLog(@"HIDE %d - %d", indexPath.row, self.insertedNewRowsCount);
        
        self.insertedNewRowsCount = 0; // reset the count
        [self hideNewElementsIndicatorView];
    }
    
    //    if(indexPath.row == self.posts.count && self.loadingCellStatus == kGLPLoadingCellStatusFinished) {

    
    if(indexPath.row - 1 == self.posts.count && self.loadingCellStatus == kGLPLoadingCellStatusInit) {
        DDLogInfo(@"Load previous posts cell activated");
        [self loadPreviousPosts];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat yOffset  = scrollView.contentOffset.y;
    
    [self configureStrechedImageViewWithOffset:yOffset];
        
    [self makeVisibleOrInvisibleActivityIndicatorWithOffset:yOffset];
    
    [self makeVisibleOrInvisibleNavigationBarWithOffset:yOffset];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat yOffset  = scrollView.contentOffset.y;

//    [self stopLoading];
    
    if(yOffset < (-OFFSET_START_ANIMATING) && !self.isLoading)
    {
        [self loadEarlierPostsFromPullToRefresh];
    }
}

- (void)configureStrechedImageViewWithOffset:(float)offset
{
    if (offset < -kStretchedImageHeight)
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
    if(offset < (-OFFSET_START_ANIMATING))
    {
        [_activityIndicator setHidden:NO];
    }
    else if(!self.isLoading)
    {
        [_activityIndicator setHidden:YES];
    }
}

- (void)makeVisibleOrInvisibleNavigationBarWithOffset:(float)offset
{
//    DDLogDebug(@"Offset: %f, top off set: %f", offset, TOP_OFF_SET);
    
    if(offset >= TOP_OFF_SET)
    {
        if([self isFakeNavigationBarVisible])
        {
            return;
        }
        
        [_fakeNavigationBar showNavigationBar];

        _fakeNavigationBarVisible = YES;
        
    }
    else
    {
        if(![self isFakeNavigationBarVisible])
        {
            return;
        }
        
        [_fakeNavigationBar hideNavigationBar];

        _fakeNavigationBarVisible = NO;
    }
}

-(void)loadPendingImageIfExist
{
    UIImage *img = [[GroupOperationManager sharedInstance] pendingGroupImageWithRemoteKey:_group.remoteKey];
    
    if(!img)
    {
        return;
    }
    
    _groupImage = img;
}

#pragma mark - Client

-(void)loadPosts
{
    [GLPGroupManager loadInitialPostsWithGroupId:_group.remoteKey localCallback:^(NSArray *localPosts) {
        
        DDLogDebug(@"Local group posts: %@", localPosts);
        
        [self setNewLocalPosts:localPosts];
        
    } remoteCallback:^(BOOL success, BOOL remain, NSArray *remotePosts) {
        
        [self setNewRemotePosts:remotePosts withRemain:remain];
        
    }];
    
//    [GLPGroupManager loadInitialPostsWithGroupId:_group.remoteKey remoteCallback:^(BOOL success, BOOL remain, NSArray *remotePosts) {
//       
//        if(success)
//        {
////            DDLogDebug(@"Posts from network: %@ - %@", _group.name, remotePosts);
//            
//            _posts = remotePosts.mutableCopy;
//            
//            [GLPPostManager setFakeKeysToPrivateProfilePosts:self.posts];
//            
//            [[GLPPostImageLoader sharedInstance] addPostsImages:self.posts];
//            
//            [self.tableView reloadData];
//            
//            self.loadingCellStatus = remain ? kGLPLoadingCellStatusInit : kGLPLoadingCellStatusFinished;
//            
//            //If the view comes from notifications, focus on the user's latest post.
//            [self focusOnTheLatestUsersPostIfNeeded];
//            
//            [self removeAnyAlreadyUploadedImagePosts];
//            
//            [self insertPendingImagePostsIfNeeded];
//               
//        }
//        else
//        {
//            self.loadingCellStatus = kGLPLoadingCellStatusError;
//        }
//        
//    }];
}

- (void)setNewRemotePosts:(NSArray *)remotePosts withRemain:(BOOL)remain
{
    _posts = remotePosts.mutableCopy;
    
    [GLPPostManager setFakeKeysToPrivateProfilePosts:self.posts];
    
    [[GLPPostImageLoader sharedInstance] addPostsImages:self.posts];
    
    [self.tableView reloadData];
    
    self.loadingCellStatus = remain ? kGLPLoadingCellStatusInit : kGLPLoadingCellStatusFinished;
    
    //If the view comes from notifications, focus on the user's latest post.
    [self focusOnTheLatestUsersPostIfNeeded];
    
    [self removeAnyAlreadyUploadedImagePosts];
    
    [self insertPendingImagePostsIfNeeded];
}


- (void)setNewLocalPosts:(NSArray *)posts
{
    _posts = posts.mutableCopy;
    
    [GLPPostManager setFakeKeysToPrivateProfilePosts:self.posts];
    
    [[GLPPostImageLoader sharedInstance] addPostsImages:self.posts];
    
    [self.tableView reloadData];
    
    //If the view comes from notifications, focus on the user's latest post.
    [self focusOnTheLatestUsersPostIfNeeded];
    
    [self removeAnyAlreadyUploadedImagePosts];
    
    [self insertPendingImagePostsIfNeeded];
}

- (void)focusOnTheLatestUsersPostIfNeeded
{
    if(_userCreatedPost)
    {
        GLPPost *usersPost = nil;
        int index = 0;
        
        for(GLPPost *p in _posts)
        {
            if(p.author.remoteKey == _userCreatedPost.remoteKey)
            {
                usersPost = p;
                break;
            }
            ++index;
        }
        
        if(usersPost)
        {
            
            if(index == _posts.count)
            {
                DDLogError(@"Index to scroll should be less than the number of posts. Abort scrolling");
                
                return;
            }
            
            DDLogDebug(@"Post index: %d", index);
            //Scroll to index.
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index + 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
}

/**
 This method removes any pending post in GLPLiveGroupPostManager in case
 that posts is already uploaded.
 */
- (void)removeAnyAlreadyUploadedImagePosts
{
    [[GLPLiveGroupPostManager sharedInstance] removeAnyUploadedImagePostWithPosts:_posts inGroupRemoteKey:_group.remoteKey];
}

/**
 Inserts any pending image post exist to the table view.
 */
- (void)insertPendingImagePostsIfNeeded
{
    NSArray *pendingImagePosts = [[GLPLiveGroupPostManager sharedInstance] pendingImagePostsWithGroupRemoteKey:_group.remoteKey];
    
    [self.posts insertObjects:pendingImagePosts atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, pendingImagePosts.count)]];

    [self.tableView reloadData];
    
}

-(void)loadGroupData
{
    [[WebClient sharedInstance] getGroupDescriptionWithId:_group.remoteKey withCallbackBlock:^(BOOL success, GLPGroup *group, NSString *errormMessage) {
        
        if(success)
        {
            DDLogDebug(@"Group comes from PN");
            _group = group;
            self.title = @"";
            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                // do work here
//
//            });
            
            [self configureTopImageView];
            
            [self configureTableView];

            [self loadPosts];
            
            _fakeNavigationBar = [[FakeNavigationBarView alloc] initWithTitle:_group.name];
            
            [self.view addSubview:_fakeNavigationBar];
            
            [_fakeNavigationBar setHidden:YES];

            
            //TODO: That should refresh the first cell plus the strecthed image view.
            
            [self refreshCellViewWithIndex:0];
        }
        else
        {
//            [WebClientHelper showStandardError];
        }
        
    }];
    

}

#pragma mark - Previous posts

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
    
    
    
    [GLPGroupManager loadPreviousPostsAfter:[self.posts lastObject] withGroupRemoteKey:_group.remoteKey callback:^(BOOL success, BOOL remain, NSArray *posts) {
        
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
        
        
    }];
    
    
}

- (void)reloadLoadingCell
{
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.posts.count inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Pull to refresh methods

- (void)loadEarlierPostsFromPullToRefresh
{
    //Added to support groups' feed.
    [self loadEarlierPostsAndSaveScrollingState:NO];
    
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
    
    
    [GLPGroupManager loadRemotePostsBefore:remotePost withGroupRemoteKey:_group.remoteKey callback:^(BOOL success, BOOL remain, NSArray *posts) {
        [self stopLoading];
        DDLogDebug(@"Stop loading activity indicator");
        
//        [_pongRefreshControl finishedLoading];


        if(!success) {
            //                [self showLoadingError:@"Failed to load new posts"];
            DDLogInfo(@"Failed to load new posts");
            
            return;
        }
        
        if(posts.count > 0)
        {
            
            [self.posts insertObjects:posts atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, posts.count)]];
            
            //New methodology of loading images.
            [[GLPPostImageLoader sharedInstance] addPostsImages:posts];
            
            
            // update table view and keep the scrolling state
            if(saveScrollingState)
            {
                // do not care about the user is in scrolling state, see commented code below
                [self updateTableViewWithNewPosts:posts.count];
                
                // save the new rows count in order to know when (at what scroll position) to hide the new elements indicator
                self.insertedNewRowsCount += posts.count;
            }
        }
        
        // or scroll to the top
        else
        {
            //This method causes problems.
//           [self updateTableViewWithNewPostsAndScrollToTop:posts.count];
        }
        
    }];
    


}


#pragma mark - Request management

- (void)startLoading
{
    self.isLoading = YES;
    
    [_activityIndicator startAnimating];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)stopLoading
{
    self.isLoading = NO;
    
    [_activityIndicator stopAnimating];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


#pragma mark - New Post Delegate

-(void)reloadNewMediaPostWithPost:(NSNotification *)notification
{
    //TODO: REMOVED! IT'S IMPORTANT!
    
    //    if(self.isLoading) {
    //        return;
    //    }
    
    //Get post from notification.
    NSDictionary *notDictionary = notification.userInfo;
    
    GLPPost *inPost = [notDictionary objectForKey:@"new_post"];
    
    if(!inPost.group)
    {
        return;
    }
    
    DDLogInfo(@"Reload post in GroupViewController: %@", inPost);
    
    self.isLoading = YES;
    
    //    GLPPost *post = (self.posts.count > 0) ? self.posts[0] : nil;
        
    NSArray *posts = [[NSArray alloc] initWithObjects:inPost, nil];
    
    [self.posts insertObjects:posts atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, posts.count)]];
    
    [self updateTableViewWithNewPostsAndScrollToTop:posts.count];
    
    
    //Add the pending new image post to the GLPLiveGroupPostManager.
    [[GLPLiveGroupPostManager sharedInstance] addImagePost:inPost withGroupRemoteKey:_group.remoteKey];
    
//    self.isLoading = NO;
    
    //Bring the fake navigation bar to from because is hidden by new cell.
    //    [self.tableView bringSubviewToFront:self.reNavBar];
    
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

            break;
        }
    }
    
    [self.posts removeObjectAtIndex:index];
    
    [self removeTableViewPostWithIndex:index];
    
}

#pragma mark - FDTakeController delegate

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)dictionary
{
    _groupImage = photo;
    
    //Set directly the new user's profile image.
//    self.userImage = photo;
//    
    [self refreshCellViewWithIndex:0];
    
    
    //Communicate with server to change the image.
//    GroupUploaderManager *uploader = [[GroupUploaderManager alloc] init];
//    
//    [uploader changeGroupImageWithImage:_groupImage withGroup:_group];
    
    [[GroupOperationManager sharedInstance] changeGroupImageWithImage:_groupImage withGroup:_group];
    
}

#pragma mark - Action Sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSString *selectedButtonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if([selectedButtonTitle isEqualToString:@"View image"])
    {
        //Show image.
        [self showImage];
    }
    else if([selectedButtonTitle isEqualToString:@"Change image"] || [selectedButtonTitle isEqualToString:@"Add image"])
    {
        //Change image.
        
        [self.fdTakeController takePhotoOrChooseFromLibrary];
    }
}

//-(void)viewPostImage:(UIImage*)postImage
//{
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
//}


#pragma mark - New comment delegate

-(void)setPreviousViewToNavigationBar
{
    self.navigationItem.hidesBackButton = NO;
    
}

-(void)setPreviousNavigationBarName
{
    [self.navigationItem setTitle:@""];
}

-(void)hideNavigationBarAndButtonWithNewTitle:(NSString*)newTitle
{
    [self.navigationItem setTitle:newTitle];
    self.navigationItem.hidesBackButton = YES;
}

-(void)navigateToViewPostFromCommentWithIndex:(int)postIndex
{
    self.selectedPost = self.posts[postIndex-1];
    
    //    self.postIndexToReload = postIndex;
    
    ++self.selectedPost.commentsCount;
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:postIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    self.commentCreated = YES;
    
    //Notify GLPProfileViewController about changes.
    [GLPPostNotificationHelper updatePostWithNotifiationName:@"GLPPostUpdated" withObject:self remoteKey:self.selectedPost.remoteKey numberOfLikes:self.selectedPost.likes andNumberOfComments:self.selectedPost.commentsCount];
    
    [self performSegueWithIdentifier:@"view post" sender:self];
}

#pragma  mark - DescriptionSegmentGroupCellDelegate

- (void)segmentSwitchedWithButtonType:(ButtonType)buttonType
{
    if(buttonType == kButtonRight)
    {
        //Navigate to members view controller.
        [self performSegueWithIdentifier:@"view members" sender:self];
        
    }
    else if(buttonType == kButtonLeft)
    {
        [self.tableView reloadData];
    }
    else if (buttonType == kButtonMiddle)
    {
        DDLogDebug(@"Messages selected!");
    }
}

#pragma  mark - GLPImageViewDelegate

- (void)imageTouchedWithImageView:(UIImageView *)imageView
{
    UIActionSheet *actionSheet = nil;
    
    BOOL hasImage = [self addGroupImage:imageView.image];
    
    if(_group.author.remoteKey == [SessionManager sharedInstance].user.remoteKey)
    {
        if(hasImage)
        {
            actionSheet = [[UIActionSheet alloc]initWithTitle:@"More" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View image", @"Change image", nil];
        }
        else
        {
            actionSheet = [[UIActionSheet alloc]initWithTitle:@"More" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Add image", nil];
        }
    }
    else
    {
        actionSheet = [[UIActionSheet alloc]initWithTitle:@"More" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View image", nil];
    }
    
    [actionSheet showInView:[self.view window]];
}

#pragma mark - GLPPostCellDelegate

-(void)elementTouchedWithRemoteKey:(NSInteger)remoteKey
{
    //Decide where to navigate. Private or current profile.
    
    
    if([[ContactsManager sharedInstance] userRelationshipWithId:remoteKey] == kCurrentUser)
    {
        self.selectedUserId = -1;
        
        [self performSegueWithIdentifier:@"view profile" sender:self];
    }
    else
    {
        self.selectedUserId = remoteKey;

        [self performSegueWithIdentifier:@"view private profile" sender:self];
    }
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

-(void)viewPostImage:(UIImage*)postImage
{
#warning implementation pending.
}

#pragma  mark - Helpers

/**
 Takes the image and add it to groupImage.
 
 @param sender
 
 @return returns NO if there group does not contain any image, otherwise returns YES.
 
 */
-(BOOL)addGroupImage:(UIImage *)image
{
//    UITapGestureRecognizer *incomingImage = (UITapGestureRecognizer*) sender;
//    
//    UIImageView *clickedImageView = (UIImageView*)incomingImage.view;
    
    _groupImage = image;
    
    return (_groupImage) ? YES : NO;
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

-(void)showImage
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    ViewPostImageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ViewPostImage"];
    vc.image = _groupImage;
    vc.view.backgroundColor =  self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.67];
    
    if(![GLPiOSSupportHelper isIOS6])
    {
        [vc setTransitioningDelegate:self.transitionViewImageController];
    }
    vc.modalPresentationStyle= UIModalPresentationCustom;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self presentViewController:vc animated:YES completion:nil];
}


- (void)createNewPost:(id)sender
{
    if(_group.remoteKey == 0)
    {
        [WebClientHelper showInternetConnectionErrorWithTitle:@"It seems that the group is not uploaded yet!"];
        
        return;
    }

//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
//    IntroKindOfNewPostViewController *newPostVC = [storyboard instantiateViewControllerWithIdentifier:@"NewPostViewController"];
//    newPostVC.group = _group;
//    [newPostVC setDelegate:self];
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newPostVC];
//    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
//    [self presentViewController:navigationController animated:YES completion:nil];
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    IntroKindOfNewPostViewController *newPostVC = [storyboard instantiateViewControllerWithIdentifier:@"IntroKindOfNewPostViewController"];
    newPostVC.groupPost = YES;
    newPostVC.group = _group;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newPostVC];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)showSettings:(id)sender
{
    DDLogDebug(@"Show Settings");
}



// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"view post"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];

        ViewPostViewController *vpvc = segue.destinationViewController;
        
        vpvc.post = self.selectedPost;
        
        vpvc.groupController = self;
        
        vpvc.commentJustCreated = self.commentCreated;
        
        vpvc.showComment = _showComment;
        
        _showComment = NO;
    }
    else if([segue.identifier isEqualToString:@"view private profile"])
    {
        GLPPrivateProfileViewController *profileViewController = segue.destinationViewController;
        
        profileViewController.selectedUserId = self.selectedUserId;
    }
    else if ([segue.identifier isEqualToString:@"view profile"])
    {
//        GLPProfileViewController *profileViewController = segue.destinationViewController;
        
//        profileViewController.selectedUserId = self.selectedUserId;
    }
    else if ([segue.identifier isEqualToString:@"view members"])
    {
        MembersViewController *mvc = segue.destinationViewController;
        
        mvc.group = _group;
    }
    else if ([segue.identifier isEqualToString:@"show location"])
    {
        GLPShowLocationViewController *showLocationVC = segue.destinationViewController;
        
        showLocationVC.location = _selectedLocation;
    }
}

@end
