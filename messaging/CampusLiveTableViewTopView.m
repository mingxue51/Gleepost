//
//  CampusLiveTableViewTopView.m
//  Gleepost
//
//  Created by Silouanos on 04/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "CampusLiveTableViewTopView.h"
#import "GLPiOSSupportHelper.h"
#import "SwipeView.h"
#import "CampusLiveManager.h"
#import "GLPPostCell.h"

@interface CampusLiveTableViewTopView ()

@property (weak, nonatomic) IBOutlet SwipeView *swipeView;

@end

@implementation CampusLiveTableViewTopView


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        DDLogDebug(@"CampusLiveTableViewTopView : init with coder");
        [self configureSwipeView];
        [self configureNotifications];
    }
    return self;
}

- (void)configureSwipeView
{
    self.swipeView.alignment = SwipeViewAlignmentCenter;
    self.swipeView.pagingEnabled = YES;
    self.swipeView.itemsPerPage = 2;
    [self.swipeView scrollToItemAtIndex:1 duration:0.0];
    [self.swipeView scrollToItemAtIndex:0 duration:0.0];
}

- (void)configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postsFetched:) name:GLPNOTIFICATION_CAMPUS_LIVE_POSTS_FETCHED object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CAMPUS_LIVE_POSTS_FETCHED object:nil];
}

#pragma mark - Client

- (void)loadLiveEventPosts
{
    [[CampusLiveManager sharedInstance] getLiveEventPosts];
}

#pragma mark - NSNotification methods

- (void)postsFetched:(NSNotification *)notification
{
    DDLogDebug(@"CampusLiveTableViewTopView : postsFetched %@", notification.userInfo);
    
    [self.swipeView reloadData];
    
    
}

#pragma mark - SwipeViewDelegate

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    //generate 100 item views
    //normally we'd use a backing array
    //as shown in the basic iOS example
    //but for this example we haven't bothered
    return [[CampusLiveManager sharedInstance] eventsCount];
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    DDLogDebug(@"swipeViewCurrentItemIndexDidChange %ld %ld - %@", swipeView.currentItemIndex, swipeView.currentItemView.tag, swipeView.indexesForVisibleItems);
    
    //TODO: Here we need to just reload data on the CLPostTableView. (to focus on the first cell).
//    [(GLPPostCell *)swipeView.currentItemView setPost:[[CampusLiveManager sharedInstance] eventPostAtIndex:swipeView.currentItemIndex]];
    
    GLPPost *post = [[CampusLiveManager sharedInstance] eventPostAtIndex:swipeView.currentItemIndex];
    [(GLPPostCell *)swipeView.currentItemView setPost:post withPostIndexPath:[NSIndexPath indexPathForRow:swipeView.currentItemIndex inSection:0]];
    
    CGFloat height = [GLPPostCell getCellHeightWithContent:post cellType:kImageCell isViewPost:NO];
    
    
    
    CGRectSetH(swipeView.currentItemView, height);
}


- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    if([[CampusLiveManager sharedInstance] eventsCount] == 0)
    {
        return CGSizeMake(0.0, 0.0);
    }
    
    GLPPost *post = [[CampusLiveManager sharedInstance] eventPostAtIndex:swipeView.currentItemIndex];

    CGFloat height = [GLPPostCell getCellHeightWithContent:post cellType:kImageCell isViewPost:NO];
    
    DDLogDebug(@"CampusLiveTableViewTopView : index %ld height %f", swipeView.currentItemIndex, height);
    
    return CGSizeMake([GLPiOSSupportHelper screenWidth] * 0.91, height);
}

#pragma mark - SwipeViewDataSource

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    if (!view)
    {
        //load new item view instance from nib
        //control events are bound to view controller in nib file
        //note that it is only safe to use the reusingView if we return the same nib for each
        //item view, if different items have different contents, ignore the reusingView value
        
        view = [[NSBundle mainBundle] loadNibNamed:@"PostImageView" owner:self options:nil][0];
        view.tag = index;
        GLPPost *post = [[CampusLiveManager sharedInstance] eventPostAtIndex:swipeView.currentItemIndex];
        [(GLPPostCell *)swipeView.currentItemView setPost:post withPostIndexPath:[NSIndexPath indexPathForRow:swipeView.currentItemIndex inSection:0]];
//        [(CLPostTableView *)swipeView.currentItemView setPost:[[CampusLiveManager sharedInstance] eventPostAtIndex:swipeView.currentItemIndex]];
    }
    return view;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
