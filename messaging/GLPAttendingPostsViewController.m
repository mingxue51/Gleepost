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

@interface GLPAttendingPostsViewController () <RemovePostCellDelegate, NewCommentDelegate, ViewImageDelegate, GLPPostCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *events;

@property (strong, nonatomic) GLPPost *selectedPost;

@end

@implementation GLPAttendingPostsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureTableView];

    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self configureNotifications];
    
    [self loadUsersEvents];

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierWithImage = @"ImageCell";
    static NSString *CellIdentifierWithoutImage = @"TextCell";
    static NSString *CellIdentifierVideo = @"VideoCell";
    
    GLPPostCell *postViewCell;

    
    GLPPost *post = _events[indexPath.row];
    
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
    self.selectedPost = _events[indexPath.row];
//    self.postIndexToReload = indexPath.row-1;
//    self.commentCreated = NO;
    [self performSegueWithIdentifier:@"view post" sender:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLPPost *currentPost = [_events objectAtIndex:indexPath.row];
    
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


#pragma mark - Client

- (void)loadUsersEvents
{
    DDLogDebug(@"Selected user remote key %ld", (long)_selectedUser.remoteKey);
    
    [[WebClient sharedInstance] getAttendingEventsForUserWithRemoteKey:_selectedUser.remoteKey callback:^(BOOL success, NSArray *posts) {
       
        if(success)
        {
            _events = posts;
            
            [[GLPPostImageLoader sharedInstance] addPostsImages:_events];

            [_tableView reloadData];
        }
        
    }];
}

#pragma mark - RemovePostCellDelegate

-(void)removePostWithPost:(GLPPost *)post
{
    
}

#pragma mark - GLPPostCellDelegate

- (void)elementTouchedWithRemoteKey:(NSInteger)remoteKey
{
    
}

- (void)showLocationWithLocation:(GLPLocation *)location
{
    
}

#pragma mark - ViewImageDelegate

-(void)viewPostImage:(UIImage*)postImage
{
    
}

#pragma mark - Notifications

- (void)updateRealImage:(NSNotification *)notification
{
    GLPPost *currentPost = nil;
    
    int index = [GLPPostNotificationHelper parsePost:&currentPost imageNotification:notification withPostsArray:_events];
    
    if(currentPost)
    {
        [self refreshCellViewWithIndex:index];
    }
}

#pragma mark - Table view refresh methods

-(void)refreshCellViewWithIndex:(const NSUInteger)index
{
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
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
//    vc.showComment = _showComment;
    
//    _showComment = NO;

    
    vc.isFromCampusLive = NO;
    
    vc.post = self.selectedPost;
    
}


@end
