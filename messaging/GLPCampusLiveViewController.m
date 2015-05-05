//
//  GLPCampusLiveViewController.m
//  Gleepost
//
//  Created by Silouanos on 04/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPCampusLiveViewController.h"
#import "CampusLiveFakeNavigationBarView.h"
#import "SwipeView.h"
#import "CLPostTableView.h"
#import "CampusLiveManager.h"
#import "CampusLiveTableViewTopView.h"

#import "GLPiOSSupportHelper.h"

#import "TableViewHelper.h"

@interface GLPCampusLiveViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) CampusLiveFakeNavigationBarView *fakeNavigationBar;
//@property (nonatomic, strong) IBOutlet SwipeView *swipeView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet CampusLiveTableViewTopView *topView;

@end

@implementation GLPCampusLiveViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureNavigationBar];
    [self configureSwipeView];
    [self configureNotifications];
    [self loadLiveEventPosts];
    
    [self configureTableView];
    //TODO: Load the header view.
//    [self sizeHeaderToFit];
    
//    self.topView = [[NSBundle mainBundle] loadNibNamed:@"CampusLiveTableViewTopView" owner:self options:nil][0];

    
   
}

- (void)configureTableView
{
    [self.tableView registerNib:[UINib nibWithNibName:@"PostImageCell" bundle:nil] forCellReuseIdentifier:@"ImageCell"];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postsFetched:) name:GLPNOTIFICATION_CAMPUS_LIVE_POSTS_FETCHED object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CAMPUS_LIVE_POSTS_FETCHED object:nil];
}

- (void)configureSwipeView
{
    //configure swipe view
//    self.swipeView.alignment = SwipeViewAlignmentCenter;
//    self.swipeView.pagingEnabled = YES;
//    self.swipeView.itemsPerPage = 1;
//    [self.swipeView scrollToItemAtIndex:1 duration:0.0];
//    [self.swipeView scrollToItemAtIndex:0 duration:0.0];
}

- (void)configureNavigationBar
{
    self.fakeNavigationBar = [[CampusLiveFakeNavigationBarView alloc] init];
    [self.view addSubview:self.fakeNavigationBar];
}

#pragma mark - Client

- (void)loadLiveEventPosts
{
    [[CampusLiveManager sharedInstance] getLiveEventPosts];
}

#pragma mark - NSNotification methods

- (void)postsFetched:(NSNotification *)notification
{
    DDLogDebug(@"GLPCampusLiveViewController : postsFetched %@", notification.userInfo);
    
//    [self.swipeView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogDebug(@"PollingPostView : didDeselectRowAtIndexPath %ld", (long)indexPath.row);
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //    if(indexPath.row == 0)
    //    {
    //        if([self.post imagePost] && ![_post isPollPost])
    //        {
    //            return [GLPPostCell getCellHeightWithContent:self.post cellType:kImageCell isViewPost:YES] + 10.0f;
    //
    //            //            return 650;
    //        }
    //        else if([self.post isVideoPost])
    //        {
    //            return [GLPPostCell getCellHeightWithContent:self.post cellType:kVideoCell isViewPost:YES] + 10.0f;
    //        }
    //        else if ([self.post isPollPost])
    //        {
    //            return [GLPPostCell getCellHeightWithContent:self.post cellType:kPollCell isViewPost:NO] + 10.0f;
    //        }
    //        else
    //        {
    //            return [GLPPostCell getCellHeightWithContent:self.post cellType:kTextCell isViewPost:YES] + 10.0f;
    //        }
    //        //return 200;
    //    }
    //    else if (indexPath.row == 1)
    //    {
    //        if([self.post isPostLiked])
    //        {
    //            return [GLPLikesCell height];
    //        }
    //        else
    //        {
    //            return 30.0;
    //        }
    //    }
    //    else if(indexPath.row == 2)
    //    {
    //        if([self.post isPostLiked])
    //        {
    //            return 30.0;
    //        }
    //        else
    //        {
    //            GLPComment *comment = [self.comments objectAtIndex:0];
    //
    //            return [CommentCell getCellHeightWithContent:comment.content image:NO];
    //        }
    //    }
    //    else
    //    {
    //        if([self.post isPostLiked])
    //        {
    //            GLPComment *comment = [self.comments objectAtIndex:indexPath.row-3];
    //
    //            return [CommentCell getCellHeightWithContent:comment.content image:NO];
    //        }
    //        else
    //        {
    //            GLPComment *comment = [self.comments objectAtIndex:indexPath.row-2];
    //
    //            return [CommentCell getCellHeightWithContent:comment.content image:NO];
    //        }
    //    }
    
    return 100.0;
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    NSInteger numberOfRows = 1;
    //
    ////    if(_postReadyToBeShown)
    ////    {
    //        //Add 1 in order to create another cell for post.
    //        //        return self.comments.count+2;
    //
    //        if([_post isPostLiked])
    //        {
    //            ++numberOfRows;
    //        }
    //
    //        if(self.comments.count > 0)
    //        {
    //            numberOfRows += (self.comments.count + 1);
    //        }
    //
    //        return numberOfRows;
    ////    }
    //
    //    return 0;

    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    static NSString *CellIdentifierWithImage = @"ImageCell";
    //    static NSString *CellIdentifierWithoutImage = @"TextCell";
    //    static NSString *CellIdentifierVideo = @"VideoCell";
    //    static NSString *CellIdentifierComment = @"CommentTextCell";
    //    static NSString *CellIdentifierTitle = @"ViewPostTitleCell";
    //    static NSString *CellIdentifierLikesCell = @"GLPLikesCell";
    //    static NSString *CellIdentifierPoll = @"PollCell";
    //
    //    GLPPostCell *postViewCell;
    //    CommentCell *cell;
    //    ViewPostTitleCell *titleCell;
    //    GLPLikesCell *likesCell;
    //
    //    if(indexPath.row == 0)
    //    {
    //        if([_post imagePost] && ![_post isPollPost])
    //        {
    //            //If image.
    //            postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithImage forIndexPath:indexPath];
    //            [postViewCell reloadMedia:YES];
    //        }
    //        else if ([_post isVideoPost])
    //        {
    //            postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierVideo forIndexPath:indexPath];
    //            //            [postViewCell reloadMedia:self.mediaNeedsToReload];
    //        }
    //        else if([_post isPollPost])
    //        {
    //            postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierPoll forIndexPath:indexPath];
    //        }
    //        else
    //        {
    //            //If text.
    //            postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithoutImage forIndexPath:indexPath];
    //        }
    //
    //        postViewCell.delegate = self;
    //        [postViewCell setIsViewPost:YES];
    //        [postViewCell setPost:_post withPostIndexPath:indexPath];
    //
    //        return postViewCell;
    //
    //    }
    //    else if(indexPath.row == 1)
    //    {
    //        if([self.post isPostLiked])
    //        {
    //            likesCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierLikesCell forIndexPath:indexPath];
    //            [likesCell setLikedUsers:self.post.usersLikedThePost];
    //            likesCell.delegate = self;
    //            return likesCell;
    //        }
    //        else
    //        {
    //            titleCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierTitle forIndexPath:indexPath];
    //            [titleCell setTitle:@"COMMENTS"];
    //            return titleCell;
    //        }
    //    }
    //    else if (indexPath.row == 2)
    //    {
    //        if([self.post isPostLiked])
    //        {
    //            titleCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierTitle forIndexPath:indexPath];
    //            [titleCell setTitle:@"COMMENTS"];
    //            return titleCell;
    //        }
    //        else
    //        {
    //            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierComment forIndexPath:indexPath];
    //
    //            [cell setDelegate:self];
    //
    //            GLPComment *comment = self.comments[0];
    //
    //            [cell setComment:comment withIndex:0 andNumberOfComments:_comments.count];
    //
    //            return cell;
    //        }
    //
    //    }
    //    else
    //    {
    //
    //        if([self.post isPostLiked])
    //        {
    //            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierComment forIndexPath:indexPath];
    //
    //            [cell setDelegate:self];
    //
    //            GLPComment *comment = self.comments[indexPath.row - 3];
    //
    //            [cell setComment:comment withIndex:indexPath.row - 3 andNumberOfComments:_comments.count];
    //            
    //            return cell;
    //        }
    //        else
    //        {
    //            //TODO: Fix cell by removing the dynamic data generation.
    //            
    //            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierComment forIndexPath:indexPath];
    //            
    //            [cell setDelegate:self];
    //            
    //            GLPComment *comment = self.comments[indexPath.row - 2];
    //            
    //            [cell setComment:comment withIndex:indexPath.row - 2 andNumberOfComments:_comments.count];
    //            
    //            return cell;
    //        }
    //    }
    
    return [TableViewHelper generateLoadingCell];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
