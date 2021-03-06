//
//  GLPPendingPostsViewController.m
//  Gleepost
//
//  Created by Silouanos on 26/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPPendingPostsViewController.h"
#import "PendingPostsOrganiserHelper.h"
#import "TableViewHelper.h"
#import "GLPPostCell.h"
#import "GLPPendingPostsManager.h"
#import "GLPPostImageLoader.h"
#import "AppearanceHelper.h"
#import "UINavigationBar+Format.h"
#import "UINavigationBar+Utils.h"
#import "GLPViewPendingPostViewController.h"
#import "GLPReviewHistory.h"
#import "GLPPostNotificationHelper.h"
#import "GLPVideoLoaderManager.h"
#import "GLPViewImageHelper.h"

@interface GLPPendingPostsViewController () <UITableViewDataSource, UITableViewDelegate, GLPPostCellDelegate, NewCommentDelegate, RemovePostCellDelegate, ViewImageDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) PendingPostsOrganiserHelper *pendingPostOrganiser;
@property (strong, nonatomic) GLPPost *selectedPost;
@property (strong, nonatomic) NSIndexPath *postToBeRefreshed;

@end

@implementation GLPPendingPostsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureObjects];
    [self configureTableView];
    [self configureObjects];
    [self loadCurrentPendingPosts];
    [self configureNavigationBar];
    [self configureNotificationsAfterViewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self configureNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self removeNotifications];
    
    [[GLPVideoLoaderManager sharedInstance] enableViewJustViewed];

    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [self removeNotificationsJustBeforeDealloc];
}

#pragma mark - Configuration

- (void)configureObjects
{
    _pendingPostOrganiser = [[PendingPostsOrganiserHelper alloc] init];
    _postToBeRefreshed = nil;
}

- (void)configureTableView
{
    //Remove empty cells.
    [self.tableView setTableFooterView:[[UIView alloc] init]];
    
    [self.tableView setBackgroundColor:[AppearanceHelper lightGrayGleepostColour]];
    
    [self registerTableViewCells];
}

-(void)configureNavigationBar
{    
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES andView:self.view];
    
    [self.navigationController.navigationBar setFontFormatWithColour:kBlack];
    
    
//    [self.navigationController.navigationBar setButton:kRight withImageName:@"pad_icon" withButtonSize:CGSizeMake(25.0, 25.0) withSelector:@selector(showAttendees) andTarget:self];
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)registerTableViewCells
{
    //Register posts.
    [self.tableView registerNib:[UINib nibWithNibName:@"PostImageCell" bundle:nil] forCellReuseIdentifier:@"ImageCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostVideoCell" bundle:nil] forCellReuseIdentifier:@"VideoCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTextCellView" bundle:nil] forCellReuseIdentifier:@"TextCell"];
}

- (void)configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRealImage:) name:GLPNOTIFICATION_POST_IMAGE_LOADED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePostRemoteKeyAndImage:) name:@"GLPPostUploaded" object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POST_IMAGE_LOADED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPPostUploaded" object:nil];
}

- (void)configureNotificationsAfterViewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postEditedFinished:) name:GLPNOTIFICATION_POST_EDITED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postEditedStartedUploading:) name:GLPNOTIFICATION_POST_STARTED_EDITING object:nil];
}

- (void)removeNotificationsJustBeforeDealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POST_EDITED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POST_STARTED_EDITING object:nil];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_pendingPostOrganiser numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_pendingPostOrganiser postsAtSectionIndex:section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierWithImage = @"ImageCell";
    static NSString *CellIdentifierWithoutImage = @"TextCell";
    static NSString *CellIdentifierVideo = @"VideoCell";
    
    GLPPostCell *postViewCell;
    
    GLPPost *post = [_pendingPostOrganiser postWithIndex:indexPath.row andSectionIndex:indexPath.section];
    
    if([post imagePost])
    {
        postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithImage forIndexPath:indexPath];
    }
    else if ([post isVideoPost])
    {
        if(indexPath.row != 0)
        {
            [[GLPVideoLoaderManager sharedInstance] disableViewJustViewed];
        }
        
        postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierVideo forIndexPath:indexPath];
    }
    else
    {
        postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithoutImage forIndexPath:indexPath];
    }
    
    //Set this class as delegate.
    postViewCell.delegate = self;
    
    
    if([_postToBeRefreshed compare:indexPath] == NSOrderedSame)
    {
        DDLogDebug(@"Post to be refreshed YES %@ post content %@", _postToBeRefreshed, post.content);
        
        [postViewCell reloadMedia:YES];
        _postToBeRefreshed = nil;
    }
    else
    {
        DDLogDebug(@"Post to be refreshed NO");
        [postViewCell reloadMedia:NO];
    }
    
    [postViewCell setPost:post withPostIndexPath:indexPath];
    
    return postViewCell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedPost = [_pendingPostOrganiser postWithIndex:indexPath.row andSectionIndex:indexPath.section];
    
    [self performSegueWithIdentifier:@"view post" sender:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLPPost *currentPost = [_pendingPostOrganiser postWithIndex:indexPath.row andSectionIndex:indexPath.section];
    
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
    return [TableViewHelper generateHeaderViewWithTitle:[_pendingPostOrganiser headerInSection:section] andBottomLine:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

#pragma mark - Notifications

- (void)updateRealImage:(NSNotification *)notification
{
    NSInteger currentPostRemoteKey = [notification.userInfo[@"RemoteKey"] integerValue];
    
    NSIndexPath *postIndexPath = [_pendingPostOrganiser indexPathWithPostRemoteKey:currentPostRemoteKey];
    
    if(postIndexPath)
    {
        [self refreshCellViewWithIndexPath:postIndexPath];
    }
}

- (void)updatePostRemoteKeyAndImage:(NSNotification *)notification
{
    //TODO: Refactor this code. (Add it in Notification Helper to parse the notification).
    
    NSDictionary *dict = [notification userInfo];
    
    NSInteger remoteKey = [(NSNumber*)[dict objectForKey:@"remoteKey"] integerValue];
    NSString *urlImage = [dict objectForKey:@"imageUrl"];
    
    [self refreshCellViewWithIndexPath:[_pendingPostOrganiser addImageUrl:urlImage toPostWithRemoteKey:remoteKey]];
}

/**
 This method is called once a post is finished editing.
 
 @param nsnotification
 
 */
- (void)postEditedFinished:(NSNotification *)notification
{
    NSDictionary *notificationDict = [notification userInfo];
    
    DDLogDebug(@"GLPPendingPostsViewController : postEditedFinished %@", notificationDict);

    [self reloadPendingPostsAfterEditingPost:notificationDict[@"post_edited"]];
}

- (void)postEditedStartedUploading:(NSNotification *)notification
{
    NSDictionary *notificationDict = [notification userInfo];
    
    DDLogDebug(@"GLPPendingPostsViewController : postEditedStartedUploading %@", notificationDict);
    
    [self reloadPendingPostsBeforeEditingFinished:notificationDict[@"posts_started_editing"]];

}

- (void)reloadPendingPostsAfterEditingPost:(GLPPost *)postEdited
{
    NSIndexPath *postIndexPath = [_pendingPostOrganiser indexPathWithPostRemoteKey:postEdited.remoteKey];
    
    DDLogDebug(@"reloadPendingPostsAfterEditingPost updated post content %@", postEdited.content);
    
    [_pendingPostOrganiser updatePostAfterSent:postEdited];

    if(postIndexPath)
    {
        _postToBeRefreshed = postIndexPath;
        [self refreshCellViewWithIndexPath:postIndexPath];
    }
}

- (void)reloadPendingPostsBeforeEditingFinished:(GLPPost *)postUploading
{
    [_pendingPostOrganiser markPostAsEdited:postUploading];
    
    [self.tableView reloadData];
}

#pragma mark - Table view refresh methods

-(void)refreshCellViewWithIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

-(void)removeTableViewPostWithIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *rowsDeleteIndexPath = [[NSMutableArray alloc] init];
    
    [rowsDeleteIndexPath addObject:indexPath];
    
    [self.tableView deleteRowsAtIndexPaths:rowsDeleteIndexPath withRowAnimation:UITableViewRowAnimationRight];
}

#pragma mark - GLPPostCellDelegate

//TODO: Implement the following methods.

- (void)showLocationWithLocation:(GLPLocation *)location
{
    DDLogDebug(@"showLocationWithLocation");
}

- (void)elementTouchedWithRemoteKey:(NSInteger)remoteKey
{
    [self performSegueWithIdentifier:@"view profile" sender:self];
}

- (void)navigateToPostForCommentWithIndex:(NSInteger)postIndex
{
    //TODO: Pending implementation.
}

-(void)viewPostImageView:(UIImageView *)postImageView
{
    [GLPViewImageHelper showImageInViewController:self withImageView:postImageView];
}

- (void)navigateToPostForCommentWithIndexPath:(NSIndexPath *)postIndexPath
{
    //TODO: Pending implementation.
}

#pragma mark - RemovePostCellDelegate

-(void)removePostWithPost:(GLPPost *)post
{
    NSIndexPath *postIndexPath = [_pendingPostOrganiser indexPathWithPost:post];
    
    [_pendingPostOrganiser removePost:post];
    
    [[GLPPendingPostsManager sharedInstance] removePendingPost:post];
    
    [self popViewControllerIfNeeded];
    
    [self removeTableViewPostWithIndexPath:postIndexPath];
}

#pragma mark - Client

- (void)loadCurrentPendingPosts
{
    //TODO: Add loading indicator.
    
    [[GLPPendingPostsManager sharedInstance] loadPendingPostsWithLocalCallback:^(NSArray *localPosts) {
       
        [self.pendingPostOrganiser organisePosts:localPosts];
        
        [[GLPPostImageLoader sharedInstance] addPostsImages: [[GLPPendingPostsManager sharedInstance] pendingPosts]];
        
        [_tableView reloadData];
        
    } withRemoteCallback:^(BOOL success, NSArray *remotePosts) {
        
        if(success)
        {
            [self.pendingPostOrganiser resetData];
            
            [self.pendingPostOrganiser organisePosts:remotePosts];
            
            [[GLPPostImageLoader sharedInstance] addPostsImages: [[GLPPendingPostsManager sharedInstance] pendingPosts]];
            
            [_tableView reloadData];
        }
        else
        {
            //TODO: Show error message.
        }

        
    }];
}

#pragma mark - Scroll view

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(self.pendingPostOrganiser.numberOfSections == 0)
    {
        return;
    }
    
    //Capture the current cells that are visible and add them to the GLPFlurryVisibleProcessor.
    
    NSArray *visiblePosts = [self snapshotVisibleCells];
    
    [[GLPVideoLoaderManager sharedInstance] visiblePosts:visiblePosts];
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(decelerate == 0)
    {
        NSArray *visiblePosts = [self snapshotVisibleCells];
        
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
        [visiblePosts addObject:[_pendingPostOrganiser postWithIndex:path.row andSectionIndex:path.section]];
        
        DDLogDebug(@"Visible cell with row %ld and section %ld", (long)path.row, (long)path.section);
        
    }
    
    return visiblePosts;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    FLog(@"GLPPendingPostsViewController : didReceiveMemoryWarning");
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"view post"])
    {
        GLPViewPendingPostViewController *viewPendingPostVC = segue.destinationViewController;
        viewPendingPostVC.pendingPost = self.selectedPost;
     }
}

- (void)popViewControllerIfNeeded
{
    if([_pendingPostOrganiser isEmpty])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
