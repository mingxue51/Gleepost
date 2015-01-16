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
#import "GLPPostImageLoader.h"
#import "GLPPostNotificationHelper.h"
#import "GLPPostManager.h"
#import "GLPViewImageViewController.h"
#import "TransitionDelegateViewImage.h"
#import "TableViewHelper.h"
#import "AttendingPostsOrganiserHelper.h"
#import "SessionManager.h"
#import "GLPPrivateProfileViewController.h"
#import "GLPTableActivityIndicator.h"
#import "GLPNewElementsIndicatorView.h"
#import "GLPLoadingCell.h"
#import "GLPTrackViewsCountProcessor.h"

@interface GLPAttendingPostsViewController () <RemovePostCellDelegate, NewCommentDelegate, ViewImageDelegate, GLPPostCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *events;

@property (strong, nonatomic) GLPPost *selectedPost;

@property (strong, nonatomic) TransitionDelegateViewImage *transitionViewImageController;

@property (strong, nonatomic) AttendingPostsOrganiserHelper *attendingPostsOrganiserHelper;

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

@end

@implementation GLPAttendingPostsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureTableView];
    
    [self initialiseObjects];

    [self configureNotifications];

    [self loadUsersEvents];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self configureNotifications];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [self removeNotifications];
    
    [super viewWillDisappear:animated];
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
    self.transitionViewImageController = [[TransitionDelegateViewImage alloc] init];
    
    _attendingPostsOrganiserHelper = [[AttendingPostsOrganiserHelper alloc] init];
    
    _tableActivityIndicator = [[GLPTableActivityIndicator alloc] initWithPosition:kActivityIndicatorCenter withView:self.tableView];
    
    _showComment = NO;

    self.loadingCellStatus = kGLPLoadingCellStatusFinished;
    
    _trackViewsCountProcessor = [[GLPTrackViewsCountProcessor alloc] init];
}

- (void)configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRealImage:) name:GLPNOTIFICATION_POST_IMAGE_LOADED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewsCounter:) name:GLPNOTIFICATION_POST_CELL_VIEWS_UPDATE object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POST_IMAGE_LOADED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POST_CELL_VIEWS_UPDATE object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_attendingPostsOrganiserHelper numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == [_attendingPostsOrganiserHelper numberOfSections]-1)
    {
        return [_attendingPostsOrganiserHelper postsAtSectionIndex:section].count + 1;
    }
    
    return [_attendingPostsOrganiserHelper postsAtSectionIndex:section].count;

    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Try to load previous posts.
    if(indexPath.section == [_attendingPostsOrganiserHelper numberOfSections]-1 && indexPath.row == [_attendingPostsOrganiserHelper postsAtSectionIndex:indexPath.section].count)
    {
        return [self cellWithMessage:@"Loading..."];
    }
    
    static NSString *CellIdentifierWithImage = @"ImageCell";
    static NSString *CellIdentifierWithoutImage = @"TextCell";
    static NSString *CellIdentifierVideo = @"VideoCell";
    
    GLPPostCell *postViewCell;
    
    GLPPost *post = [_attendingPostsOrganiserHelper postWithIndex:indexPath.row andSectionIndex:indexPath.section];
    
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
    if(indexPath.section == [_attendingPostsOrganiserHelper numberOfSections]-1 && indexPath.row == [_attendingPostsOrganiserHelper postsAtSectionIndex:indexPath.section].count)
    {
        return;
    }
    
    self.selectedPost = [_attendingPostsOrganiserHelper postWithIndex:indexPath.row andSectionIndex:indexPath.section];

//    self.postIndexToReload = indexPath.row-1;
//    self.commentCreated = NO;
    [self performSegueWithIdentifier:@"view post" sender:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == [_attendingPostsOrganiserHelper numberOfSections]-1 && indexPath.row == [_attendingPostsOrganiserHelper postsAtSectionIndex:indexPath.section].count)
    {
        return (self.loadingCellStatus != kGLPLoadingCellStatusFinished) ? kGLPLoadingCellHeight : 0;
    }
    
    GLPPost *currentPost = [_attendingPostsOrganiserHelper postWithIndex:indexPath.row andSectionIndex:indexPath.section];
    
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
    return [TableViewHelper generateHeaderViewWithTitle:[_attendingPostsOrganiserHelper headerInSection:section] andBottomLine:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == [_attendingPostsOrganiserHelper numberOfSections]-1 && indexPath.row == [_attendingPostsOrganiserHelper postsAtSectionIndex:indexPath.section].count && self.loadingCellStatus == kGLPLoadingCellStatusInit)
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
    
    NSMutableArray *postsYValues = nil;
    
    NSArray *visiblePosts = [self getVisiblePostsInTableViewWithYValues:&postsYValues];
    
    [_trackViewsCountProcessor trackVisiblePosts:visiblePosts withPostsYValues:postsYValues];
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
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
        if(path.row == 0)
        {
            continue;
        }
        
        //Avoid any out of bounds access in array
        
//        if(path.row < self.posts.count)
//        {
            [visiblePosts addObject:[_attendingPostsOrganiserHelper postWithIndex:path.row andSectionIndex:path.section]];
            CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:path];
            CGRect rectInSuperview = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];
            [*postsYValues addObject:@(rectInSuperview.origin.y)];
//        }
    }
    
    return visiblePosts;
}


#pragma mark - Client

- (void)loadUsersEvents
{
    DDLogDebug(@"Selected user remote key %ld", (long)_selectedUser.remoteKey);
    
    [_tableActivityIndicator startActivityIndicator];
    self.isLoading = YES;
    [GLPPostManager getAttendingEventsWithUsersRemoteKey:_selectedUser.remoteKey callback:^(BOOL success, NSArray *posts) {
        self.isLoading = NO;
        [_tableActivityIndicator stopActivityIndicator];
        
        if(success)
        {
//            [_attendingPostsOrganiserHelper resetData];
            [_attendingPostsOrganiserHelper organisePosts:posts];
            
            _events = posts.mutableCopy;
            
            BOOL remains = _events.count == kGLPNumberOfPosts ? YES : NO;
            self.loadingCellStatus = remains ? kGLPLoadingCellStatusInit : kGLPLoadingCellStatusFinished;

            
            [[GLPPostImageLoader sharedInstance] addPostsImages:_events];
            
            [_tableView reloadData];
            
//            [self loadPreviousUserEvents];
        }
    }];
}

- (void)loadPreviousUserEvents
{
    if(self.isLoading) {
        return;
    }
    
    if([_attendingPostsOrganiserHelper numberOfSections] == 0) {
        self.loadingCellStatus = kGLPLoadingCellStatusFinished;
        return;
    }
    
    if(self.loadingCellStatus == kGLPLoadingCellStatusLoading) {
        return;
    }
    
    [self startLoading];
    self.loadingCellStatus = kGLPLoadingCellStatusLoading;
    
    [GLPPostManager getAttendingEventsAfter:[_attendingPostsOrganiserHelper lastPost] withUserRemoteKey:_selectedUser.remoteKey callback:^(BOOL success, BOOL remain, NSArray *posts) {
        
        [self stopLoading];
        
        if(!success) {
            self.loadingCellStatus = kGLPLoadingCellStatusError;
            [self reloadLoadingCell];
            return;
        }
        
        self.loadingCellStatus = remain ? kGLPLoadingCellStatusInit : kGLPLoadingCellStatusFinished;
        
        if(posts.count > 0) {
            
            [_attendingPostsOrganiserHelper organisePosts:posts];
            
            _events = posts.mutableCopy;
            
            [_events insertObjects:posts atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(_events.count, posts.count)]];

            [[GLPPostImageLoader sharedInstance] addPostsImages:_events];
            
            [_tableView reloadData];
            
        } else {
            [self reloadLoadingCell];
        }
    }];
}

- (void)reloadLoadingCell
{
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_events.count inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
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
    [GLPPostNotificationHelper deletePostNotificationWithPostRemoteKey:post.remoteKey inCampusLive:NO];
    
    NSIndexPath *postIndexPath = [_attendingPostsOrganiserHelper indexPathWithPost:post];
    
    [_attendingPostsOrganiserHelper removePost:post];

    [self removeTableViewPostWithIndexPath:postIndexPath];

    for(int index = 0; index < _events.count; ++index)
    {
        GLPPost *p = [_events objectAtIndex:index];
        
        if(p.remoteKey == post.remoteKey)
        {
            [_events removeObject:p];
            
            return;
        }
    }
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
    DDLogDebug(@"showLocationWithLocation");
}

- (void)navigateToPostForCommentWithIndexPath:(NSIndexPath *)postIndexPath
{
    _showComment = YES;
    self.selectedPost = [_attendingPostsOrganiserHelper postWithIndex:postIndexPath.row andSectionIndex:postIndexPath.section];
//    self.selectedIndex = postIndex;
//    self.postIndexToReload = postIndex;
//    self.commentCreated = NO;
    [self performSegueWithIdentifier:@"view post" sender:self];
}

#pragma mark - ViewImageDelegate

-(void)viewPostImage:(UIImage*)postImage
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    GLPViewImageViewController *viewImage = [storyboard instantiateViewControllerWithIdentifier:@"GLPViewImageViewController"];
    viewImage.image = postImage;
    viewImage.view.backgroundColor = self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.89];
    viewImage.modalPresentationStyle = UIModalPresentationCustom;
    
    [viewImage setTransitioningDelegate:self.transitionViewImageController];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self presentViewController:viewImage animated:YES completion:nil];

}

#pragma mark - Notifications

- (void)updateRealImage:(NSNotification *)notification
{
    GLPPost *currentPost = nil;
        
    NSIndexPath *postIndexPath = [_attendingPostsOrganiserHelper indexPathWithPost:currentPost];
        
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
    
    NSIndexPath *postIndexPath = [_attendingPostsOrganiserHelper updatePostWithRemoteKey:postRemoteKey andViewsCount:viewsCount];
    
    DDLogDebug(@"updateViewsCounter %d %d", postIndexPath.row, postIndexPath.section);
    
    if(!postIndexPath)
    {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{

        [self refreshCellViewWithIndexPath:postIndexPath];
    });
    
//    [_campusWallAsyncProcessor parseAndUpdatedViewsCountPostWithPostRemoteKey:postRemoteKey andPosts:_posts withCallbackBlock:^(NSInteger index) {
//        
//        DDLogDebug(@"updateViewsCounter index %ld", (long)index);
//        
//        if(index != -1 && _selectedTab == kLeft)
//        {
//            GLPPost *post = [self.posts objectAtIndex:index];
//            
//            post.viewsCount = viewsCount;
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self refreshCellViewWithIndex:index+1];
//            });
//        }
//        
//    }];
}

#pragma mark - Table view refresh methods

-(void)refreshCellViewWithIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

-(void)removeTableViewPostWithIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *rowsDeleteIndexPath = [[NSMutableArray alloc] init];
    
    [rowsDeleteIndexPath addObject:indexPath];
    
    [self.tableView deleteRowsAtIndexPaths:rowsDeleteIndexPath withRowAnimation:UITableViewRowAnimationRight];
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
}


@end
