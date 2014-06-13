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
#import "ViewPostImageViewController.h"
#import "TransitionDelegateViewImage.h"
#import "ProfileTwoButtonsTableViewCell.h"
#import "ContactUserCell.h"
#import "GLPPrivateProfileViewController.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "GLPNewElementsIndicatorView.h"
#import "GLPLoadingCell.h"
#import "MembersViewController.h"
#import "GroupOperationManager.h"
#import "SessionManager.h"
#import "GLPiOS6Helper.h"
#import "EmptyMessage.h"
#import "ShapeFormatterHelper.h"
#import "UINavigationBar+Utils.h"

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

@end

@implementation GroupViewController

const int NUMBER_OF_ROWS = 2;

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self configureTableView];
    
    [self registerTableViewCells];
    
    [self initialiseObjects];
    
    [self loadPosts];
    
    if(_fromPushNotification)
    {
        [self loadGroupData];
    }
    
    
//    [self loadMembers];
    
    [self.tableView setTableFooterView:[[UIView alloc] init]];
    [self configureNotifications];

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureNavigationBar];
    
    [self configureNavigationItems];
    
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    
    [super viewDidDisappear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
}

-(void)dealloc
{
    [self removeNotifications];

}

#pragma mark - Configuration methods

-(void)registerTableViewCells
{
    //Register nib files in table view.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileViewTableViewCell" bundle:nil] forCellReuseIdentifier:@"ProfileCell"];

    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileViewTwoButtonsTableViewCell" bundle:nil] forCellReuseIdentifier:@"TwoButtonsCell"];
    
    //Register posts.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostImageCell" bundle:nil] forCellReuseIdentifier:@"ImageCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTextCellView" bundle:nil] forCellReuseIdentifier:@"TextCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostVideoCell" bundle:nil] forCellReuseIdentifier:@"VideoCell"];
    //Register contacts' cells.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
    
    
    
//    [self.tableView registerNib:[UINib nibWithNibName:@"GLPLoadingCell" bundle:nil] forCellReuseIdentifier:@"LoadingCell"];


}


-(void)configureTableView
{
    // refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadEarlierPostsFromPullToRefresh) forControlEvents:UIControlEventValueChanged];
    
    if([GLPiOS6Helper isIOS6])
    {
        [GLPiOS6Helper setBackgroundImageToTableView:self.tableView];
    }
    else
    {
        [AppearanceHelper setCustomBackgroundToTableView:self.tableView];
    }
    
}

-(void)initialiseObjects
{
    [self.view setBackgroundColor:[AppearanceHelper defaultGleepostColour]];
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
}

-(void)configureNavigationItems
{
    int buttonX = 10;
    
    if([GLPiOS6Helper isIOS6])
    {
        buttonX = 0;
    }
//    
//    [self.navigationController.navigationBar setButtonOnRightWithImageName:@"new_post_groups" withButtonSize:CGSizeMake(35, 35) withSelector:@selector(createNewPost:) andTarget:self];
    
    [self.navigationController.navigationBar setButton:kRight withImageOrTitle:@"new_post_groups" withButtonSize:CGSizeMake(35, 35) withSelector:@selector(createNewPost:) andTarget:self];
    
    
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
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;

    [self.navigationController setNavigationBarHidden:NO
                                             animated:YES];
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    
    //Change the format of the navigation bar.
//    [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:nil forBarMetrics:UIBarMetricsDefault];
    [AppearanceHelper setNavigationBarColour:self];

    
//    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [AppearanceHelper setNavigationBarFontFor:self];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    //Set title.
    self.title = _group.name;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

}

-(void)configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRealImage:) name:@"GLPPostImageUploaded" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePostRemoteKeyAndImage:) name:@"GLPPostUploaded" object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePost:) name:GLPNOTIFICATION_GROUP_POST_DELETED object:nil];
}

-(void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPPostImageUploaded" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPPostUploaded" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_GROUP_POST_DELETED object:nil];

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
    
    
    if(currentPost)
    {
        [self refreshCellViewWithIndex:index+2];
    }
}

-(void)updatePostRemoteKeyAndImage:(NSNotification*)notification
{
    NSDictionary *dict = [notification userInfo];
    
    int key = [(NSNumber*)[dict objectForKey:@"key"] integerValue];
    int remoteKey = [(NSNumber*)[dict objectForKey:@"remoteKey"] integerValue];
    NSString * urlImage = [dict objectForKey:@"imageUrl"];
    
    int index = 2;
    
    DDLogDebug(@"Post Uploaded: %@", urlImage);
    
    GLPPost *uploadedPost = nil;
    
    for(GLPPost* p in self.posts)
    {
        if(key == p.key)
        {
            p.imagesUrls = [[NSArray alloc] initWithObjects:urlImage, nil];
            p.remoteKey = remoteKey;
            uploadedPost = p;
            //            p.tempImage = nil;
            break;
        }
        ++index;
    }
    
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    //    [self.tableView reloadData];
    
    
}

//TODO: NOT USED.
-(void)deletePost:(NSNotification *)notification
{
    int index = [GLPPostNotificationHelper parseNotificationAndFindIndexWithNotification:notification withPostsArray:self.posts];
    
    DDLogDebug(@"Delete POST! %@", notification);
    
    [self removeTableViewPostWithIndex:index];
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
    for(int i = 2; i < count+2; i++) {
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
    
    [rowsDeleteIndexPath addObject:[NSIndexPath indexPathForRow:index+2 inSection:0]];
    
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
    
    self.currentNumberOfRows = NUMBER_OF_ROWS + self.posts.count +1 /*+ i*/;
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
    if(indexPath.row-2 == self.posts.count) {
        
//        DDLogDebug(@"Rows: %d, Count: %d", indexPath.row, self.posts.count);
        
//        GLPLoadingCell *loadingCell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell" forIndexPath:indexPath];
//        [loadingCell updateWithStatus:self.loadingCellStatus];
//        return loadingCell;
        
        return [self cellWithMessage:@"Loading..."];
        
        
    }
    
    static NSString *CellIdentifierWithImage = @"ImageCell";
    static NSString *CellIdentifierWithoutImage = @"TextCell";
    static NSString *CellVideoIdentifier = @"VideoCell";
    static NSString *CellIdentifierProfile = @"ProfileCell";
    static NSString *CellIdentifierTwoButtons = @"TwoButtonsCell";
    
    GLPPostCell *postViewCell;
    ProfileTableViewCell *profileView;
    ProfileTwoButtonsTableViewCell *buttonsView;
    
    if(indexPath.row == 0)
    {
        profileView = [tableView dequeueReusableCellWithIdentifier:CellIdentifierProfile forIndexPath:indexPath];
        
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
        
        [profileView setDelegate:self];

        [self loadPendingImageIfExist];
        
        [profileView initialiseElementsWithGroupInformation:self.group withGroupImage:_groupImage];
        
        profileView.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return profileView;
        
    }
    else if(indexPath.row == 1)
    {
        buttonsView = [tableView dequeueReusableCellWithIdentifier:CellIdentifierTwoButtons forIndexPath:indexPath];
        buttonsView.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [buttonsView setDelegate:self fromPushNotification:NO];
        
        return buttonsView;
        
    }
    else if (indexPath.row >= 2)
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
                postViewCell = [tableView dequeueReusableCellWithIdentifier:CellVideoIdentifier forIndexPath:indexPath];
            }
            else
            {
                postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithoutImage forIndexPath:indexPath];
            }
            
            //Set this class as delegate.
            postViewCell.delegate = self;
            
            [postViewCell setPost:post withPostIndex:indexPath.row];
            
            if(indexPath.row - 2  != self.posts.count)
            {
                //Add separator line to posts' cells.
                UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, postViewCell.frame.size.height-0.5f, 320, 0.5)];
                line.backgroundColor = [UIColor colorWithRed:217.0f/255.0f green:228.0f/255.0f blue:234.0f/255.0f alpha:1.0f];
                [postViewCell addSubview:line];
            }
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

    if(indexPath.row < 2)
    {
        return;
    }
    
//    if(self.selectedTabStatus == kGLPPosts)
//    {
        if(indexPath.row-2 == self.posts.count) {
            return;
        }
        
        self.selectedPost = self.posts[indexPath.row-2];
        //    self.postIndexToReload = indexPath.row-2;
        self.commentCreated = NO;
        [self performSegueWithIdentifier:@"view post" sender:self];
//    }
//    else
//    {
//        GLPUser *member = self.members[indexPath.row - 2];
//        
//        self.selectedUserId = member.remoteKey;
//        
//        [self performSegueWithIdentifier:@"view private profile" sender:self];
//
//    }
    

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row - 2 == self.posts.count) {
        
        
        
        return (self.loadingCellStatus != kGLPLoadingCellStatusFinished) ? kGLPLoadingCellHeight : 0;
    }
    
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
        
//        if(self.selectedTabStatus == kGLPPosts)
//        {
            if(self.posts.count != 0 && self.posts)
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
//        }
//        else
//        {
//            return CONTACT_CELL_HEIGHT;
//        }
        

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

    
    if(indexPath.row - 2 == self.posts.count && self.loadingCellStatus == kGLPLoadingCellStatusInit) {
        NSLog(@"Load previous posts cell activated");
        [self loadPreviousPosts];
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
    [GLPGroupManager loadInitialPostsWithGroupId:_group.remoteKey remoteCallback:^(BOOL success, BOOL remain, NSArray *remotePosts) {
       
        if(success)
        {
//            DDLogDebug(@"Posts from network: %@ - %@", _group.name, remotePosts);
            
            _posts = remotePosts.mutableCopy;
            
            [GLPPostManager setFakeKeysToPrivateProfilePosts:self.posts];
            
            [[GLPPostImageLoader sharedInstance] addPostsImages:self.posts];
            
            [self.tableView reloadData];
            
            self.loadingCellStatus = remain ? kGLPLoadingCellStatusInit : kGLPLoadingCellStatusFinished;
        }
        else
        {
            self.loadingCellStatus = kGLPLoadingCellStatusError;
        }
        
    }];
}

-(void)loadGroupData
{
    [[WebClient sharedInstance] getGroupDescriptionWithId:_group.remoteKey withCallbackBlock:^(BOOL success, GLPGroup *group, NSString *errormMessage) {
        
        if(success)
        {
            _group = group;
            self.title = _group.name;
            
            [self refreshCellViewWithIndex:0];
        }
        else
        {
            [WebClientHelper showStandardError];
        }
        
    }];
}

//-(void)loadMembers
//{
//    [[WebClient sharedInstance] getMembersWithGroupRemoteKey:self.group.remoteKey withCallbackBlock:^(BOOL success, NSArray *members) {
//       
//        if(success)
//        {
//            self.members = members;
//            
//            if(self.selectedTabStatus == kGLPSettings)
//            {
//                [self.tableView reloadData];
//            }
//        }
//        
//    }];
//    
//    
//}

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
           [self updateTableViewWithNewPostsAndScrollToTop:posts.count];
        }
        
    }];
    


}


#pragma mark - Request management

- (void)startLoading
{
    self.isLoading = YES;
    
    [self.refreshControl beginRefreshing];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)stopLoading
{
    self.isLoading = NO;
    
    [self.refreshControl endRefreshing];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - New Post Delegate

-(void)reloadNewImagePostWithPost:(GLPPost *)post
{

//    DDLogDebug(@"Is loading: %d", self.isLoading);
    
    //TODO: REMOVED! IT'S IMPORTANT!
    
    //    if(self.isLoading) {
    //        return;
    //    }
    
//    self.isLoading = YES;
    
    //    GLPPost *post = (self.posts.count > 0) ? self.posts[0] : nil;
    
    NSArray *posts = [[NSArray alloc] initWithObjects:post, nil];
    
    [self.posts insertObjects:posts atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, posts.count)]];
    
    [self updateTableViewWithNewPostsAndScrollToTop:posts.count];
    
    
//    self.isLoading = NO;
    
    //Bring the fake navigation bar to from because is hidden by new cell.
    //    [self.tableView bringSubviewToFront:self.reNavBar];
    
}

#pragma mark - Selectors

-(void)viewGroupImageOptions:(id)sender
{
    
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

#pragma mark - ProfileTableViewCellDelegate

-(void)showInformationMenu:(id)sender
{
    UIActionSheet *actionSheet = nil;
    
    BOOL hasImage = [self addGroupImage:sender];
    
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

#pragma mark - New comment delegate

-(void)setPreviousViewToNavigationBar
{
    self.navigationItem.hidesBackButton = NO;
    
}

-(void)setPreviousNavigationBarName
{
    [self.navigationItem setTitle:self.group.name];
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

#pragma  mark - Button Navigation Delegate

-(void)viewSectionWithId:(GLPSelectedTab) selectedTab
{
    
//    self.selectedTabStatus = selectedTab;
    
    if(selectedTab == kGLPMembers)
    {
        //Navigate to members view controller.
        [self performSegueWithIdentifier:@"view members" sender:self];
        
    }
    else
    {
        [self.tableView reloadData];
    }
    
}

#pragma  mark - Helpers

/**
 Takes the image and add it to groupImage.
 
 @param sender
 
 @return returns NO if there group does not contain any image, otherwise returns YES.
 
 */
-(BOOL)addGroupImage:(id)sender
{
    UITapGestureRecognizer *incomingImage = (UITapGestureRecognizer*) sender;
    
    UIImageView *clickedImageView = (UIImageView*)incomingImage.view;
    
    _groupImage = clickedImageView.image;
    
    return (clickedImageView.tag == 0) ? NO : YES;
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
    
    if(![GLPiOS6Helper isIOS6])
    {
        [vc setTransitioningDelegate:self.transitionViewImageController];
    }
    vc.modalPresentationStyle= UIModalPresentationCustom;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self presentViewController:vc animated:YES completion:nil];
}


- (IBAction)createNewPost:(id)sender
{
    if(_group.remoteKey == 0)
    {
        [WebClientHelper showInternetConnectionErrorWithTitle:@"It seems that the group is not uploaded yet!"];
        
        return;
    }

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    NewPostViewController *newPostVC = [storyboard instantiateViewControllerWithIdentifier:@"NewPostViewController"];
    newPostVC.group = _group;
    [newPostVC setDelegate:self];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newPostVC];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
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
    }
    else if([segue.identifier isEqualToString:@"view private profile"])
    {
        GLPPrivateProfileViewController *profileViewController = segue.destinationViewController;
        
        profileViewController.selectedUserId = self.selectedUserId;
    }
    else if ([segue.identifier isEqualToString:@"view members"])
    {
        MembersViewController *mvc = segue.destinationViewController;
        
        mvc.group = _group;
    }
}

@end
