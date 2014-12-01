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

@interface GLPPendingPostsViewController () <UITableViewDataSource, UITableViewDelegate, GLPPostCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) PendingPostsOrganiserHelper *pendingPostOrganiser;
@property (strong, nonatomic) GLPPost *selectedPost;

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

- (void)configureObjects
{
    _pendingPostOrganiser = [[PendingPostsOrganiserHelper alloc] init];
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
    GLPPost *currentPost = nil;
    
    NSIndexPath *postIndexPath = [_pendingPostOrganiser indexPathWithPost:currentPost];
    
    if(currentPost)
    {
        [self refreshCellViewWithIndexPath:postIndexPath];
    }
}

- (void)updatePostRemoteKeyAndImage:(NSNotification *)notification
{
    //TODO: Refactor this code. (Add it in Notification Helper to parse the notification).
    
    NSDictionary *dict = [notification userInfo];
    
    NSInteger key = [(NSNumber*)[dict objectForKey:@"key"] integerValue];
    NSInteger remoteKey = [(NSNumber*)[dict objectForKey:@"remoteKey"] integerValue];
    NSString *urlImage = [dict objectForKey:@"imageUrl"];
    
    [self refreshCellViewWithIndexPath:[_pendingPostOrganiser addImageUrl:urlImage toPostWithRemoteKey:remoteKey]];
    
//    int index = 0;
//    
//    GLPPost *uploadedPost = nil;
//    
//    for(GLPPost* p in self.posts)
//    {
//        if(key == p.key)
//        {
//            if(urlImage && ![urlImage isEqualToString:@""])
//            {
//                p.imagesUrls = [[NSArray alloc] initWithObjects:urlImage, nil];
//            }
//            
//            p.remoteKey = remoteKey;
//            uploadedPost = p;
//            //            p.tempImage = nil;
//            break;
//        }
//        ++index;
//    }
    

    
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
    DDLogDebug(@"elementTouchedWithRemoteKey");
}

- (void)navigateToPostForCommentWithIndex:(NSInteger)postIndex
{
    //TODO: Pending implementation.
}

-(void)viewPostImage:(UIImage*)postImage
{
    
}

#pragma mark - RemovePostCellDelegate

-(void)removePostWithPost:(GLPPost *)post
{
    
}

#pragma mark - Client

- (void)loadCurrentPendingPosts
{
    //TODO: Add loading indicator.
    
    [[GLPPendingPostsManager sharedInstance] loadPendingPostsWithLocalCallback:^(NSArray *localPosts) {
       
        [self.pendingPostOrganiser organisePosts:localPosts];
        
        [[GLPPostImageLoader sharedInstance] addPostsImages: [[GLPPendingPostsManager sharedInstance] pendingPosts]];
        
        DDLogDebug(@"Local posts history");
        
        for (GLPPost *p in localPosts)
        {
            DDLogDebug(@"Post %@", p.reviewHistory);
        }
        
        [_tableView reloadData];
        
    } withRemoteCallback:^(BOOL success, NSArray *remotePosts) {
        
        if(success)
        {
            [self.pendingPostOrganiser resetData];
            
            [self.pendingPostOrganiser organisePosts:remotePosts];
            
            [[GLPPostImageLoader sharedInstance] addPostsImages: [[GLPPendingPostsManager sharedInstance] pendingPosts]];
            
            DDLogDebug(@"Local posts history");
            
            for (GLPPost *p in remotePosts)
            {
                DDLogDebug(@"Post %@", p.content);
            }
            
            [_tableView reloadData];
        }
        else
        {
            //TODO: Show error message.
        }

        
    }];
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
        GLPViewPendingPostViewController *viewPendingPostVC = segue.destinationViewController;
        viewPendingPostVC.pendingPost = self.selectedPost;
     }
}


@end
