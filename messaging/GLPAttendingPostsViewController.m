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

@interface GLPAttendingPostsViewController () <RemovePostCellDelegate, NewCommentDelegate, ViewImageDelegate, GLPPostCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *events;

@property (strong, nonatomic) GLPPost *selectedPost;

@property (strong, nonatomic) TransitionDelegateViewImage *transitionViewImageController;

@property (strong, nonatomic) AttendingPostsOrganiserHelper *attendingPostsOrganiserHelper;

@property (assign, nonatomic) NSInteger selectedUserId;

@property (assign, nonatomic) BOOL showComment;

@property (strong, nonatomic) GLPTableActivityIndicator *tableActivityIndicator;

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

}

- (void)configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRealImage:) name:GLPNOTIFICATION_POST_IMAGE_LOADED object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POST_IMAGE_LOADED object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_attendingPostsOrganiserHelper numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_attendingPostsOrganiserHelper postsAtSectionIndex:section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    [postViewCell setPost:post withPostIndex:indexPath.row];
    
    return postViewCell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedPost = [_attendingPostsOrganiserHelper postWithIndex:indexPath.row andSectionIndex:indexPath.section];

//    self.postIndexToReload = indexPath.row-1;
//    self.commentCreated = NO;
    [self performSegueWithIdentifier:@"view post" sender:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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


#pragma mark - Client

- (void)loadUsersEvents
{
    DDLogDebug(@"Selected user remote key %ld", (long)_selectedUser.remoteKey);
    
    [_tableActivityIndicator startActivityIndicator];
    
    [GLPPostManager getAttendingEventsWithUsersRemoteKey:_selectedUser.remoteKey callback:^(BOOL success, NSArray *posts) {
       
        [_tableActivityIndicator stopActivityIndicator];
        
        if(success)
        {
//            [_attendingPostsOrganiserHelper resetData];
            [_attendingPostsOrganiserHelper organisePosts:posts];
            
            _events = posts.mutableCopy;
            
            [[GLPPostImageLoader sharedInstance] addPostsImages:_events];
            
            [_tableView reloadData];
        }
    }];
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

- (void)navigateToPostForCommentWithIndex:(NSInteger)postIndex
{
    _showComment = YES;
    self.selectedPost = [_events objectAtIndex:postIndex];
    
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
    
    int index = [GLPPostNotificationHelper parsePost:&currentPost imageNotification:notification withPostsArray:_events];
    
    NSIndexPath *postIndexPath = [_attendingPostsOrganiserHelper indexPathWithPost:currentPost];
        
    if(currentPost)
    {
        [self refreshCellViewWithIndexPath:postIndexPath];
    }
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
