//
//  GLPCampusLiveViewController.m
//  Gleepost
//
//  Created by Silouanos on 04/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPCampusLiveViewController.h"
#import "UINavigationBar+Format.h"
#import "CampusLiveFakeNavigationBarView.h"
#import "SwipeView.h"
#import "CLPostTableView.h"
#import "CampusLiveManager.h"
#import "CampusLiveTableViewTopView.h"
#import "GLPiOSSupportHelper.h"
#import "TableViewHelper.h"
#import "URBMediaFocusViewController.h"
#import "GLPPost.h"
#import "CLCommentsManager.h"
#import "GLPLikesCell.h"
#import "CommentCell.h"
#import "ViewPostTitleCell.h"
#import "GLPTableActivityIndicator.h"
#import "GLPShowUsersViewController.h"

/**
 CommentCell *cell;
 ViewPostTitleCell *titleCell;
 GLPLikesCell *likesCell;
 */

@interface GLPCampusLiveViewController () <UITableViewDataSource, UITableViewDelegate, GLPLikesCellDelegate, GLPImageViewDelegate, GLPLabelDelegate>

@property (strong, nonatomic) CampusLiveFakeNavigationBarView *fakeNavigationBar;
//@property (nonatomic, strong) IBOutlet SwipeView *swipeView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet CampusLiveTableViewTopView *topView;

@property (strong, nonatomic) URBMediaFocusViewController *mediaFocusViewController;

@property (strong, nonatomic) CLCommentsManager *commentsManager;

@property (strong, nonatomic) GLPPost *selectedPost;

@property (strong, nonatomic) GLPTableActivityIndicator *tableActivityIndicator;

@property (assign, nonatomic) BOOL showUsersLikedThePost;

@property (assign, nonatomic) BOOL postChanged;

@end

@implementation GLPCampusLiveViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureObjects];
    [self configureNotifications];
    [self configureTableView];


}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureNavigationBar];
    
}

- (void)configureObjects
{
    self.mediaFocusViewController = [[URBMediaFocusViewController alloc] init];
    self.mediaFocusViewController.parallaxEnabled = NO;
    self.mediaFocusViewController.shouldShowPhotoActions = YES;
    self.mediaFocusViewController.shouldRotateToDeviceOrientation = NO;
    self.mediaFocusViewController.shouldBlurBackground = YES;
    
    self.commentsManager = [[CLCommentsManager alloc] init];
    
    self.tableActivityIndicator = [[GLPTableActivityIndicator alloc] initWithPosition:kActivityIndicatorMaxBottom withView:self.tableView];
    
    self.postChanged = YES;
    self.showUsersLikedThePost = NO;
}

- (void)configureTableView
{
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentTextCellView" bundle:nil] forCellReuseIdentifier:@"CommentTextCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ViewPostTitleCell" bundle:nil] forCellReuseIdentifier:@"ViewPostTitleCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GLPLikesCell" bundle:nil] forCellReuseIdentifier:@"GLPLikesCell"];
}


- (void)sizeHeaderToFit
{
    UIView *header = self.tableView.tableHeaderView;
    
    [header setNeedsLayout];
    [header layoutIfNeeded];
    
    CGFloat height = [header systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    CGRect frame = header.frame;
    
    frame.size.height = height;
    header.frame = frame;
    
    self.tableView.tableHeaderView = header;
}

- (void)configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageViewTouched:) name:GLPNOTIFICATION_CL_IMAGE_SHOULD_VIEWED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMoreOptions:) name:GLPNOTIFICATION_CL_SHOW_MORE_OPTIONS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showShareViewWithItems:) name:GLPNOTIFICATION_CL_SHOW_SHARE_OPTIONS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postChanged:) name:GLPNOTIFICATION_RELOAD_CL_COMMENTS_LIKES object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentsReceived:) name:GLPNOTIFICATION_COMMENTS_FETCHED object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CL_IMAGE_SHOULD_VIEWED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CL_SHOW_MORE_OPTIONS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CL_SHOW_SHARE_OPTIONS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_RELOAD_CL_COMMENTS_LIKES object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_COMMENTS_FETCHED object:nil];
    
}

- (void)configureNavigationBar
{
    self.fakeNavigationBar = [[CampusLiveFakeNavigationBarView alloc] init];
    [self.view addSubview:self.fakeNavigationBar];
    [self.navigationController.navigationBar invisible];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStyleBordered target:nil action:nil];
}

#pragma mark - Client

- (void)loadLiveEventPosts
{
    [[CampusLiveManager sharedInstance] getLiveEventPosts];
}

#pragma mark - NSNotification methods

- (void)imageViewTouched:(NSNotification *)notification
{
    UIImage *image = notification.userInfo[@"image"];
    [_mediaFocusViewController showImage:image fromView:self.view];
}

- (void)showMoreOptions:(NSNotification *)notification
{
    UIActionSheet *actionSheet = notification.userInfo[@"action_sheet"];
    [actionSheet showInView:[self.view window]];
}

- (void)showShareViewWithItems:(NSNotification *)notification
{
    UIActivityViewController *shareItems = notification.userInfo[@"share_items"];
    [self presentViewController:shareItems animated:YES completion:nil];
}

- (void)postChanged:(NSNotification *)notification
{
    self.selectedPost = notification.userInfo[@"post"];
    
    [self.tableActivityIndicator startActivityIndicator];
    self.postChanged = YES;
    
    [self performSelector:@selector(stopActivityIndicator) withObject:self afterDelay:1.0];
    
    [self.tableView reloadData];
    
    [self.commentsManager loadCommentsWithPost:self.selectedPost];
}

- (void)stopActivityIndicator
{
    [self.tableActivityIndicator stopActivityIndicator];
    
    self.postChanged = NO;
    
    [self.tableView reloadData];
}

- (void)commentsReceived:(NSNotification *)notification
{
    GLPPost *post = notification.userInfo[@"post"];
    
    if(self.selectedPost.remoteKey == post.remoteKey)
    {
        [self.tableView reloadData];
    }
    
}

#pragma mark - GLPLikesCellDelegate

- (void)likesCellTouched
{
    self.showUsersLikedThePost = YES;
    [self performSegueWithIdentifier:@"show users" sender:self];
}

#pragma mark - GLPLabelDelegate

- (void)labelTouchedWithTag:(NSInteger)tag
{
    DDLogDebug(@"GLPCampusLiveViewController labelTouchedWithTag %ld", (long)tag);
}

#pragma mark - GLPImageViewDelegate

- (void)imageTouchedWithImageView:(UIImageView *)imageView
{
    DDLogDebug(@"GLPCampusLiveViewController imageTouchedWithImageView %ld", (long)imageView.tag);
}

#pragma mark - Table view refresh cells

- (void)reloadCommentsCells
{
    NSInteger numberOfRows = 0;
    
    if([self.selectedPost isPostLiked])
    {
        ++numberOfRows;
    }
    
    if([self.commentsManager commentsCountWithPost:self.selectedPost] > 0)
    {
        numberOfRows += ([self.commentsManager commentsCountWithPost:self.selectedPost] + 1);
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for(NSInteger index = 1; index < numberOfRows; ++index)
    {
        [array addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }
    
//    [self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
//    [self.tableView reloadData];
    
}

- (void)reloadCellsWithAnimation
{

    
//    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
 //   [self.tableView endUpdates];

    
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogDebug(@"PollingPostView : didDeselectRowAtIndexPath %ld", (long)indexPath.row);
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        if(indexPath.row == 0)
        {
            if([self.selectedPost isPostLiked])
            {
                return [GLPLikesCell height];
            }
            else
            {
                return 30.0;
            }
        }
        else if (indexPath.row == 1)
        {
            if([self.selectedPost isPostLiked])
            {
                return 30.0;
            }
            else
            {
                GLPComment *comment = [self.commentsManager commentAtIndex:indexPath.row - 1 withPost:self.selectedPost];
                
                return [CommentCell getCellHeightWithContent:comment.content image:NO];
            }
        }
        else
        {
            if([self.selectedPost isPostLiked])
            {
                GLPComment *comment = [self.commentsManager commentAtIndex:indexPath.row-  2 withPost:self.selectedPost];
    
                return [CommentCell getCellHeightWithContent:comment.content image:NO];
            }
            else
            {
                GLPComment *comment = [self.commentsManager commentAtIndex:indexPath.row - 1 withPost:self.selectedPost];
    
                return [CommentCell getCellHeightWithContent:comment.content image:NO];
            }
        }
    
    return 100.0;
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.postChanged)
    {
        return 0;
    }
    
    NSInteger numberOfRows = 0;
    
    if([self.selectedPost isPostLiked])
    {
        ++numberOfRows;
    }
    
    if([self.commentsManager commentsCountWithPost:self.selectedPost] > 0)
    {
        numberOfRows += ([self.commentsManager commentsCountWithPost:self.selectedPost] + 1);
    }
    
    return numberOfRows;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifierComment = @"CommentTextCell";
    NSString *cellIdentifierTitle = @"ViewPostTitleCell";
    NSString *cellIdentifierLikesCell = @"GLPLikesCell";
    
    CommentCell *cell;
    ViewPostTitleCell *titleCell;
    GLPLikesCell *likesCell;
    
    if(indexPath.row == 0)
    {
        if([self.selectedPost isPostLiked])
        {
            likesCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierLikesCell forIndexPath:indexPath];
            [likesCell setLikedUsers:self.selectedPost.usersLikedThePost];
            likesCell.delegate = self;
            return likesCell;
        }
        else
        {
            titleCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierTitle forIndexPath:indexPath];
            [titleCell setTitle:@"COMMENTS"];
            return titleCell;
        }
    }
    else if (indexPath.row == 1)
    {
        if([self.selectedPost isPostLiked])
        {
            titleCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierTitle forIndexPath:indexPath];
            [titleCell setTitle:@"COMMENTS"];
            return titleCell;
        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierComment forIndexPath:indexPath];
            
            [cell setDelegate:self];
            
            GLPComment *comment = [self.commentsManager commentAtIndex:0 withPost:self.selectedPost];
            
            [cell setComment:comment withIndex:0 andNumberOfComments:[self.commentsManager commentsCountWithPost:self.selectedPost]];
            
            return cell;
        }
        
    }
    else
    {
        
        if([self.selectedPost isPostLiked])
        {
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierComment forIndexPath:indexPath];
            
            [cell setDelegate:self];
            
            GLPComment *comment = [self.commentsManager commentAtIndex:(indexPath.row - 2) withPost:self.selectedPost];
            
            [cell setComment:comment withIndex:indexPath.row - 2 andNumberOfComments:[self.commentsManager commentsCountWithPost:self.selectedPost]];
            
            return cell;
        }
        else
        {
            //TODO: Fix cell by removing the dynamic data generation.
            
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierComment forIndexPath:indexPath];
            
            [cell setDelegate:self];
            
            GLPComment *comment = [self.commentsManager commentAtIndex:indexPath.row - 1 withPost:self.selectedPost];
            
            [cell setComment:comment withIndex:indexPath.row - 1 andNumberOfComments:[self.commentsManager commentsCountWithPost:self.selectedPost]];
            
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([cell isKindOfClass:[GLPLikesCell class]])
    {
        
    }
}

//#pragma mark - SwipeViewDelegate
//
//- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
//{
//    //generate 100 item views
//    //normally we'd use a backing array
//    //as shown in the basic iOS example
//    //but for this example we haven't bothered
//    return [[CampusLiveManager sharedInstance] eventsCount];
//}
//
//- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
//{
//    DDLogDebug(@"swipeViewCurrentItemIndexDidChange %ld %ld", swipeView.currentItemIndex, swipeView.currentItemView.tag);
//    
//    //TODO: Here we need to just reload data on the CLPostTableView. (to focus on the first cell).
//    [(CLPostTableView *)swipeView.currentItemView setPost:[[CampusLiveManager sharedInstance] eventPostAtIndex:swipeView.currentItemIndex]];
//}
//
//#pragma mark - SwipeViewDataSource
//
//- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
//{
//    if (!view)
//    {
//        //load new item view instance from nib
//        //control events are bound to view controller in nib file
//        //note that it is only safe to use the reusingView if we return the same nib for each
//        //item view, if different items have different contents, ignore the reusingView value
//        
//        view = [[NSBundle mainBundle] loadNibNamed:@"CLPostTableView" owner:self options:nil][0];
//        view.tag = index;
//        [(CLPostTableView *)swipeView.currentItemView setPost:[[CampusLiveManager sharedInstance] eventPostAtIndex:swipeView.currentItemIndex]];
//    }
//    return view;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"show users"])
    {
        GLPShowUsersViewController *showUsersVC = segue.destinationViewController;
        showUsersVC.transparentNavBar = YES;
        
        if(self.showUsersLikedThePost)
        {
            showUsersVC.users = self.selectedPost.usersLikedThePost;
            showUsersVC.selectedTitle = @"LIKED BY";
        }
        else
        {
            showUsersVC.postRemoteKey = self.selectedPost.remoteKey;
            showUsersVC.selectedTitle = @"GUEST LIST";
        }
    }
}


@end
