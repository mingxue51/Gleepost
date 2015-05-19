//
//  GLPAttendingPostsViewController.m
//  Gleepost
//
//  Created by Silouanos on 24/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPAttendingPostsViewController.h"
#import "ViewPostViewController.h"
#import "WebClient.h"
#import "GLPPostCell.h"
#import "GLPPost.h"
#import "AppearanceHelper.h"
#import "GLPPostManager.h"
#import "TableViewHelper.h"
#import "SessionManager.h"
#import "GLPPrivateProfileViewController.h"
#import "GLPTableActivityIndicator.h"
#import "GLPNewElementsIndicatorView.h"
#import "GLPLoadingCell.h"
#import "GLPTrackViewsCountProcessor.h"
#import "GLPAttendingPostsManager.h"
#import "GLPShowLocationViewController.h"
#import "GLPViewImageHelper.h"

@interface GLPAttendingPostsViewController () <RemovePostCellDelegate, NewCommentDelegate, ViewImageDelegate, GLPPostCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) GLPPost *selectedPost;

@property (assign, nonatomic) NSInteger selectedUserId;

@property (assign, nonatomic) BOOL showComment;

@property (strong, nonatomic) GLPTableActivityIndicator *tableActivityIndicator;

/** Captures the visibility of current cells. */
@property (strong, nonatomic) GLPTrackViewsCountProcessor *trackViewsCountProcessor;

//Properties for refresh loader.
@property (assign, nonatomic) BOOL isLoading;
@property (assign, nonatomic) int insertedNewRowsCount; // count of new rows inserted
@property (strong, nonatomic) GLPNewElementsIndicatorView *elementsIndicatorView;
@property (assign, nonatomic) GLPLoadingCellStatus loadingCellStatus;

@property (strong, nonatomic) GLPAttendingPostsManager *attendingPostsManager;

@property (strong, nonatomic) GLPLocation *selectedLocation;

@end

@implementation GLPAttendingPostsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNotifications];

    [self configureTableView];
    
    [self initialiseObjects];

    [self loadUsersEvents];
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [self removeNotifications];
}

#pragma mark - Configuration

- (void)configureTableView
{
    //Remove empty cells.
    [self.tableView setTableFooterView:[[UIView alloc] init]];
    
    [self.tableView setBackgroundColor:[AppearanceHelper lightGrayGleepostColour]];
    
    [self registerTableViewCells];
}

- (void)registerTableViewCells
{
    //Register posts.
    [self.tableView registerNib:[UINib nibWithNibName:@"PostImageCell" bundle:nil] forCellReuseIdentifier:@"ImageCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostVideoCell" bundle:nil] forCellReuseIdentifier:@"VideoCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTextCellView" bundle:nil] forCellReuseIdentifier:@"TextCell"];
}

- (void)initialiseObjects
{    
    _tableActivityIndicator = [[GLPTableActivityIndicator alloc] initWithPosition:kActivityIndicatorCenter withView:self.tableView];
    
    _showComment = NO;

    self.loadingCellStatus = kGLPLoadingCellStatusFinished;
    
    _trackViewsCountProcessor = [[GLPTrackViewsCountProcessor alloc] init];
    
    _attendingPostsManager = [[GLPAttendingPostsManager alloc] initWithUserRemoteKey:_selectedUser.remoteKey];
}

- (void)configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRealImage:) name:GLPNOTIFICATION_POST_IMAGE_LOADED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewsCounter:) name:GLPNOTIFICATION_POST_CELL_VIEWS_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventsFetched:) name:GLPNOTIFICATION_ATTENDING_POSTS_FETCHED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(previousEventsFetched:) name:GLPNOTIFICATION_ATTENDING_PREVIOUS_POSTS_FETCHED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goingButtonUnpressed:) name:GLPNOTIFICATION_GOING_BUTTON_UNTOUCHED object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POST_IMAGE_LOADED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POST_CELL_VIEWS_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_ATTENDING_POSTS_FETCHED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_ATTENDING_PREVIOUS_POSTS_FETCHED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_GOING_BUTTON_UNTOUCHED object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_attendingPostsManager numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == [_attendingPostsManager numberOfSections] - 1)
    {
        return [_attendingPostsManager numberOfPostsAtSectionIndex:section] + 1;
    }
    
    return [_attendingPostsManager numberOfPostsAtSectionIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Try to load previous posts.
    if(indexPath.section == [_attendingPostsManager numberOfSections]-1 && indexPath.row == [_attendingPostsManager numberOfPostsAtSectionIndex:indexPath.section])
    {
        return [self cellWithMessage:@"Loading..."];
    }
    
    static NSString *CellIdentifierWithImage = @"ImageCell";
    static NSString *CellIdentifierWithoutImage = @"TextCell";
    static NSString *CellIdentifierVideo = @"VideoCell";
    
    GLPPostCell *postViewCell;
    
    GLPPost *post = [_attendingPostsManager postWithSection:indexPath.section andIndex:indexPath.row];

    
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
    
    return postViewCell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == [_attendingPostsManager numberOfSections]-1 && indexPath.row == [_attendingPostsManager numberOfPostsAtSectionIndex:indexPath.section])
    {
        return;
    }
    
    self.selectedPost = [_attendingPostsManager postWithSection:indexPath.section andIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"view post" sender:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == [_attendingPostsManager numberOfSections]-1 && indexPath.row == [_attendingPostsManager numberOfPostsAtSectionIndex:indexPath.section])
    {
        return (self.loadingCellStatus != kGLPLoadingCellStatusFinished) ? kGLPLoadingCellHeight : 0;
    }
    
//    GLPPost *currentPost = [_attendingPostsOrganiserHelper postWithIndex:indexPath.row andSectionIndex:indexPath.section];
    
    GLPPost *currentPost = [_attendingPostsManager postWithSection:indexPath.section andIndex:indexPath.row];
    
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [TableViewHelper generateHeaderViewWithTitle:[_attendingPostsManager headerInSection:section] andBottomLine:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == [_attendingPostsManager numberOfSections]-1 && indexPath.row == [_attendingPostsManager numberOfPostsAtSectionIndex:indexPath.section] && self.loadingCellStatus == kGLPLoadingCellStatusInit)
    {
        DDLogInfo(@"GLPAttendingPostsViewController : Load previous posts cell activated");
        [self loadPreviousUserEvents];
    }
}

- (UITableViewCell *)cellWithMessage:(NSString *)message {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = message;
    cell.textLabel.font = [UIFont fontWithName:GLP_APP_FONT size:12.0f];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [UIColor grayColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.userInteractionEnabled = NO;
    return cell;
}

#pragma mark - Scroll view

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_trackViewsCountProcessor resetVisibleCells];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //Capture the current cells that are visible and add them to the GLPFlurryVisibleProcessor.
    
    if(self.loadingCellStatus == kGLPLoadingCellStatusLoading)
    {
        return;
    }
    
    NSMutableArray *postsYValues = nil;
    
    NSArray *visiblePosts = [self getVisiblePostsInTableViewWithYValues:&postsYValues];
    
    [_trackViewsCountProcessor trackVisiblePosts:visiblePosts withPostsYValues:postsYValues];
    
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
        
        [_trackViewsCountProcessor trackVisiblePosts:visiblePosts withPostsYValues:postsYValues];
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
        GLPPost *post = [_attendingPostsManager postWithSection:path.section andIndex:path.row];
        
        if(!post)
        {
            continue;
        }
        
        [visiblePosts addObject:post];
        CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:path];
        CGRect rectInSuperview = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];
        [*postsYValues addObject:@(rectInTableView.size.height/2.0 + rectInSuperview.origin.y)];
    }
    
    return visiblePosts;
}

- (void)eventsFetched:(NSNotification *)notification
{
    NSDictionary *notificationDict = notification.userInfo;
    
    self.isLoading = NO;
    [_tableActivityIndicator stopActivityIndicator];
    
    BOOL success = [notificationDict[@"success"] boolValue];
    
    if(success)
    {
        BOOL remains = [_attendingPostsManager eventsCount] == kGLPNumberOfPosts ? YES : NO;
        self.loadingCellStatus = remains ? kGLPLoadingCellStatusInit : kGLPLoadingCellStatusFinished;
        [_tableView reloadData];
    }
}

- (void)previousEventsFetched:(NSNotification *)notification
{
    NSDictionary *notificationDict = notification.userInfo;
    BOOL success = [notificationDict[@"success"] boolValue];
    NSInteger remain = [notificationDict[@"remain"] integerValue];
    NSArray *previousPosts = notificationDict[@"posts"];
    
    [self stopLoading];

    if(!success) {
        self.loadingCellStatus = kGLPLoadingCellStatusError;
        [self reloadLoadingCell];
        return;
    }
    
    self.loadingCellStatus = remain ? kGLPLoadingCellStatusInit : kGLPLoadingCellStatusFinished;
    
    if(previousPosts.count > 0) {
        
        [_tableView reloadData];
        
    } else {
        [self reloadLoadingCell];
    }
}

#pragma mark - Client

- (void)loadPreviousUserEvents
{
    if(self.isLoading) {
        return;
    }
    
    if([_attendingPostsManager numberOfSections] == 0) {
        self.loadingCellStatus = kGLPLoadingCellStatusFinished;
        return;
    }
    
    if(self.loadingCellStatus == kGLPLoadingCellStatusLoading) {
        return;
    }
    
    [self startLoading];
    self.loadingCellStatus = kGLPLoadingCellStatusLoading;
    [_attendingPostsManager loadPreviousPosts];
}

- (void)loadUsersEvents
{
    DDLogDebug(@"Selected user remote key %ld", (long)_selectedUser.remoteKey);
    [_tableActivityIndicator startActivityIndicator];
    self.isLoading = YES;
    [_attendingPostsManager getPosts];
}


- (void)reloadLoadingCell
{
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[_attendingPostsManager eventsCount] inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark - RemovePostCellDelegate

-(void)removePostWithPost:(GLPPost *)post
{
    NSDictionary *postIndexPathDeletedSection = [_attendingPostsManager removePostWithPost:post];
    [self removeTableViewPostWithIndexPath:postIndexPathDeletedSection[@"index_path"] andDeletedSections:[postIndexPathDeletedSection[@"delete_section"] boolValue]];
}

#pragma mark - GLPPostCellDelegate

- (void)elementTouchedWithRemoteKey:(NSInteger)remoteKey
{
    if(remoteKey == [SessionManager sharedInstance].user.remoteKey)
    {
        return;
    }
    
    self.selectedUserId = remoteKey;
    
    [self performSegueWithIdentifier:@"view private profile" sender:self];
}

- (void)showLocationWithLocation:(GLPLocation *)location
{
    _selectedLocation = location;
    
    [self performSegueWithIdentifier:@"show location" sender:self];
}

- (void)navigateToPostForCommentWithIndexPath:(NSIndexPath *)postIndexPath
{
    _showComment = YES;
    self.selectedPost = [_attendingPostsManager postWithSection:postIndexPath.section andIndex:postIndexPath.row];

    
//    self.selectedIndex = postIndex;
//    self.postIndexToReload = postIndex;
//    self.commentCreated = NO;
    [self performSegueWithIdentifier:@"view post" sender:self];
}

#pragma mark - ViewImageDelegate

-(void)viewPostImageView:(UIImageView *)postImageView
{
    [GLPViewImageHelper showImageInViewController:self withImageView:postImageView];
}

#pragma mark - Notifications

- (void)updateRealImage:(NSNotification *)notification
{
    GLPPost *currentPost = nil;
    
    NSIndexPath *postIndexPath = [_attendingPostsManager indexPathWithPost:&currentPost];
    
    if(currentPost)
    {
        [self refreshCellViewWithIndexPath:postIndexPath];
    }
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
    
    NSIndexPath *postIndexPath = [_attendingPostsManager updatePostWithRemoteKey:postRemoteKey andViewsCount:viewsCount];
    
    DDLogDebug(@"updateViewsCounter %ld %ld", (long)postIndexPath.row, (long)postIndexPath.section);
    
    if(!postIndexPath)
    {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshCellViewWithIndexPath:postIndexPath];
    });
}

- (void)goingButtonUnpressed:(NSNotification *)notification
{
    DDLogDebug(@"goingButtonUnpressed %@", notification.userInfo[@"post"]);
    
    if([self.selectedUser isLoggedInUser])
    {
        [self removePostWithPost:notification.userInfo[@"post"]];
    }
    
}

#pragma mark - Table view refresh methods

-(void)refreshCellViewWithIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

-(void)removeTableViewPostWithIndexPath:(NSIndexPath *)indexPath andDeletedSections:(BOOL)deletedSections
{
    NSMutableArray *rowsDeleteIndexPath = [[NSMutableArray alloc] init];
    
    [rowsDeleteIndexPath addObject:indexPath];
    
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:indexPath.section];
    
    DDLogDebug(@"removeTableViewPostWithIndexPath %d : %d", indexPath.row, indexPath.section);
    
    if(deletedSections)
    {
        [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationRight];
    }
    else
    {
        [self.tableView deleteRowsAtIndexPaths:rowsDeleteIndexPath withRowAnimation:UITableViewRowAnimationRight];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"view post"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        ViewPostViewController *vc = segue.destinationViewController;
        /**
         Forward data of the post the to the view. Or in future just forward the post id
         in order to fetch it from the server.
         */
        
        //    vc.commentJustCreated = self.commentCreated;
        //
        vc.showComment = _showComment;
        
        _showComment = NO;
        
        
        vc.isFromCampusLive = NO;
        
        vc.post = self.selectedPost;
    }
    else if ([segue.identifier isEqualToString:@"view private profile"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
        GLPPrivateProfileViewController *privateProfileViewController = segue.destinationViewController;
        
        privateProfileViewController.selectedUserId = self.selectedUserId;
    }
    else if ([segue.identifier isEqualToString:@"show location"])
    {
        GLPShowLocationViewController *showLocationVC = segue.destinationViewController;
        
        showLocationVC.location = _selectedLocation;
    }
}

@end
