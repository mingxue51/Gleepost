//
//  GLPCampusLiveViewController.m
//  Gleepost
//
//  Created by Silouanos on 04/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPCampusLiveViewController.h"
#import "UINavigationBar+Format.h"
#import "UINavigationBar+Utils.h"
#import "CampusLiveFakeNavigationBarView.h"
#import "SwipeView.h"
#import "CLPostTableView.h"
#import "CampusLiveManager.h"
#import "CampusLiveTableViewTopView.h"
#import "GLPiOSSupportHelper.h"
#import "TableViewHelper.h"
#import "GLPPost.h"
#import "CLCommentsManager.h"
#import "GLPLikesCell.h"
#import "CommentCell.h"
#import "ViewPostTitleCell.h"
#import "GLPTableActivityIndicator.h"
#import "GLPShowUsersViewController.h"
#import "ViewPostViewController.h"
#import "GLPBottomTextView.h"
#import "GLPCommentUploader.h"
#import "GLPPostNotificationHelper.h"
#import "GLPViewImageHelper.h"

@interface GLPCampusLiveViewController () <UITableViewDataSource, UITableViewDelegate, GLPLikesCellDelegate, GLPImageViewDelegate, GLPLabelDelegate, GLPBottomTextViewDelegate>

@property (strong, nonatomic) CampusLiveFakeNavigationBarView *fakeNavigationBar;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet CampusLiveTableViewTopView *topView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceTableViewFromBottom;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewDistanceFromBottom;

@property (strong, nonatomic) CLCommentsManager *commentsManager;

@property (strong, nonatomic) GLPPost *selectedPost;

@property (strong, nonatomic) GLPTableActivityIndicator *tableActivityIndicator;

@property (assign, nonatomic) BOOL showUsersLikedThePost;

@property (assign, nonatomic) BOOL postChanged;

@property (assign, nonatomic) BOOL focusOnCommentInViewPostVC;

@property (assign, nonatomic) BOOL reachedTheLastCell;

@property (assign, nonatomic) CGFloat lastContentOffset;

@property (weak, nonatomic) IBOutlet GLPBottomTextView *bottomTextView;

@end

@implementation GLPCampusLiveViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureObjects];
    [self configureNotifications];
    [self configureTableView];
    [self configureNavigationItems];
    
    //For now we show the bottom text view.
    [self.bottomTextView show];
    [self makeDistanceOfTableViewFromBottomFitWithTextView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureNavigationBar];
    
}

- (void)configureObjects
{
    self.commentsManager = [[CLCommentsManager alloc] init];
    self.tableActivityIndicator = [[GLPTableActivityIndicator alloc] initWithPosition:kActivityIndicatorMaxBottom withView:self.tableView];
    self.postChanged = YES;
    self.showUsersLikedThePost = NO;
    self.focusOnCommentInViewPostVC = NO;
    self.bottomTextView.delegate = self;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageViewTouched:) name:GLPNOTIFICATION_CL_IMAGE_SHOULD_VIEWED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMoreOptions:) name:GLPNOTIFICATION_CL_SHOW_MORE_OPTIONS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showShareViewWithItems:) name:GLPNOTIFICATION_CL_SHOW_SHARE_OPTIONS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postChanged:) name:GLPNOTIFICATION_RELOAD_CL_COMMENTS_LIKES object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentsReceived:) name:GLPNOTIFICATION_COMMENTS_FETCHED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postTouched:) name:GLPNOTIFICATION_CL_POST_TOUCHED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentButtonTouched:) name:GLPNOTIFICATION_CL_COMMENT_BUTTON_TOUCHED object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CL_IMAGE_SHOULD_VIEWED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CL_SHOW_MORE_OPTIONS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CL_SHOW_SHARE_OPTIONS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_RELOAD_CL_COMMENTS_LIKES object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_COMMENTS_FETCHED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CL_POST_TOUCHED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CL_COMMENT_BUTTON_TOUCHED object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)configureNavigationBar
{
    self.fakeNavigationBar = [[CampusLiveFakeNavigationBarView alloc] init];
    [self.view addSubview:self.fakeNavigationBar];
    [self.navigationController.navigationBar invisible];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStyleBordered target:nil action:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)configureNavigationItems
{
    [self.navigationController.navigationBar setButton:kLeft specialButton:kQuit withImageName:@"cancel" withButtonSize:CGSizeMake(19.0, 21.0) withSelector:@selector(dismissViewController) andTarget:self];
}

#pragma mark - Client

- (void)loadLiveEventPosts
{
    [[CampusLiveManager sharedInstance] getLiveEventPosts];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat currentOffset = scrollView.contentOffset.y;
    
    if(self.postChanged)
    {
        return;
    }
    
//    if([self heightOfRows] - 170.0f < currentOffset)
//    {
//        [self.bottomTextView show];
//        [self makeDistanceOfTableViewFromBottomFitWithTextView];
//    }
//    else
//    {
//        [self.bottomTextView hide];
//        [self makeDistanceOfTableViewFromBottomFitWithBottom];
//    }
    
    self.lastContentOffset = currentOffset;
}



#pragma mark - NSNotification methods

- (void)imageViewTouched:(NSNotification *)notification
{
    UIImage *image = notification.userInfo[@"image"];
    UIImageView *imageView = notification.userInfo[@"current_image_view"];
    imageView.image = image;
    [GLPViewImageHelper showImageInViewController:self withImageView:imageView];
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
    
    [self performSelector:@selector(stopActivityIndicatorAndReloadData) withObject:self afterDelay:1.0];
    
    [self.tableView reloadData];
    
    [self.commentsManager loadCommentsWithPost:self.selectedPost];
    
//    [self.bottomTextView hide];
//    [self makeDistanceOfTableViewFromBottomFitWithBottom];
}

- (void)stopActivityIndicatorAndReloadData
{
    [self.tableActivityIndicator stopActivityIndicator];
    
    self.postChanged = NO;
    
    [self.tableView reloadData];
    
//    [self.bottomTextView hide];
//    [self makeDistanceOfTableViewFromBottomFitWithBottom];
}

- (void)commentsReceived:(NSNotification *)notification
{
    GLPPost *post = notification.userInfo[@"post"];
    
    if(self.selectedPost.remoteKey == post.remoteKey)
    {
        [self.tableView reloadData];
    }
}

- (void)postTouched:(NSNotification *)notification
{
    self.focusOnCommentInViewPostVC = NO;
    [self performSegueWithIdentifier:@"view post" sender:self];
}

- (void)commentButtonTouched:(NSNotification *)notification
{
    self.focusOnCommentInViewPostVC = YES;
    [self performSegueWithIdentifier:@"view post" sender:self];
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

#pragma mark - GLPBottomTextViewDelegate

- (void)userHitsSendButtonWithText:(NSString *)text
{
    DDLogDebug(@"GLPCampusLiveViewController userHitsSendButtonWithText %@", text);
    
    GLPCommentUploader *commentUploader = [[GLPCommentUploader alloc] init];
    
    GLPComment *comment = [commentUploader uploadCommentWithContent:text andPost:self.selectedPost];
    
    [self reloadNewComment:comment];
    
    [self updatePostWithNewComment];
}


#pragma mark - Table view delegate

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Positioning management

- (void)makeDistanceOfTableViewFromBottomFitWithBottom
{
    self.distanceTableViewFromBottom.constant = -50.0;
}

- (void)makeDistanceOfTableViewFromBottomFitWithTextView
{
    self.distanceTableViewFromBottom.constant = 5.0;
}

#pragma mark - Table view UI

- (void)scrollToTheEndAnimated:(BOOL)animated
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self numberOfRows] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

- (void)reloadNewComment:(GLPComment *)comment
{
    [self.commentsManager addNewComment:comment toTheListWithPost:self.selectedPost];
    [self scrollToBottomAndUpdateTableViewWithNewComment];
}

- (void)scrollToBottomAndUpdateTableViewWithNewComment
{
    NSMutableArray *rowsInsertIndexPath = [[NSMutableArray alloc] init];

    NSInteger commentsCount = [self.commentsManager commentsCountWithPost:self.selectedPost];
    
    for(NSInteger i = commentsCount; i < commentsCount + 1; ++i)
    {
        [rowsInsertIndexPath addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    [self.tableView reloadData];
}

- (void)updatePostWithNewComment
{
    //Increase the number of comments to the post.
    ++self.selectedPost.commentsCount;
    
    //Notify timeline view controller.
    [GLPPostNotificationHelper updatePostWithNotifiationName:@"GLPPostUpdated" withObject:self remoteKey:self.selectedPost.remoteKey numberOfLikes:self.selectedPost.likes andNumberOfComments:self.selectedPost.commentsCount];
}

#pragma mark - Keyboard management

- (void)keyboardWillShow:(NSNotification *)note
{
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curve.intValue;
    
    if(keyboardBounds.size.height == 0)
    {
        return;
    }
    
    [self.tableView layoutIfNeeded];
    [self.bottomTextView layoutIfNeeded];
    
    [UIView animateWithDuration:[duration doubleValue] delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|(animationCurve << 16)) animations:^{

        self.bottomViewDistanceFromBottom.constant = keyboardBounds.size.height;
        [self.bottomTextView layoutIfNeeded];
        [self.tableView layoutIfNeeded];
    
    } completion:^(BOOL finished) {

    }];
    
    [self scrollToTheEndAnimated:YES];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curve.intValue;
    
    [self.tableView layoutIfNeeded];
    [self.bottomTextView layoutIfNeeded];
    
    [UIView animateWithDuration:[duration doubleValue] delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|(animationCurve << 16)) animations:^{
        
        self.bottomViewDistanceFromBottom.constant = 0;
        [self.bottomTextView layoutIfNeeded];
        [self.tableView layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        [self.tableView setNeedsLayout];
    }];
}

#pragma mark - Helpers

- (NSInteger)numberOfRows
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
    
    return numberOfRows;
}

- (CGFloat)heightOfRows
{
    CGFloat heightOfRows = 0.0;
    
    if([self.selectedPost isPostLiked])
    {
        heightOfRows += [GLPLikesCell height];
    }
    
    heightOfRows += [self.commentsManager commentCellsHeightWithPost:self.selectedPost];
    
    return heightOfRows;
}

#pragma mark - Selectors

- (void)dismissViewController
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
    else if([segue.identifier isEqualToString:@"view post"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
        ViewPostViewController *vc = segue.destinationViewController;
        
        /**
         Forward data of the post the to the view. Or in future just forward the post id
         in order to fetch it from the server.
         */
        vc.commentJustCreated = nil;
        vc.isFromCampusLive = NO;
        vc.post = self.selectedPost;
        vc.showComment = self.focusOnCommentInViewPostVC;
    }
}


@end
