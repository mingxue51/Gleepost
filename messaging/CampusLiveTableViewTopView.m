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
#import "CLPostView.h"
#import "GLPPost.h"
#import "GLPVideoLoaderManager.h"

@interface CampusLiveTableViewTopView ()

@property (weak, nonatomic) IBOutlet SwipeView *swipeView;
@property (strong, nonatomic) NSMutableArray *lastVisibleCells;


@end

@implementation CampusLiveTableViewTopView


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        CGRectSetH(self, [CLPostView height]);
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self configureSwipeView];
    [self loadLiveEventPosts];
    [self configureNotifications];
}

- (void)configureSwipeView
{
    self.swipeView.alignment = SwipeViewAlignmentCenter;
    self.swipeView.pagingEnabled = YES;
    self.swipeView.itemsPerPage = 1;
    self.swipeView.defersItemViewLoading = YES;
}

- (void)configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postsFetched:) name:GLPNOTIFICATION_CAMPUS_LIVE_POSTS_FETCHED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postDeleted:) name:GLPNOTIFICATION_POST_DELETED object:nil];
    
    //For now don't use this approach because we are facing strange issues. SwipeView library is not able to reload cell at index.
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageForPostFetched:) name:GLPNOTIFICATION_CAMPUS_LIVE_IMAGE_LOADED object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CAMPUS_LIVE_POSTS_FETCHED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POST_DELETED object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CAMPUS_LIVE_IMAGE_LOADED object:nil];
}

#pragma mark - Client

- (void)loadLiveEventPosts
{
    [[CampusLiveManager sharedInstance] getLiveEventPosts];
    
    DDLogDebug(@"CampusLiveTableViewTopView loadLiveEventPosts");
}

#pragma mark - NSNotification methods

- (void)postsFetched:(NSNotification *)notification
{
    DDLogDebug(@"CampusLiveTableViewTopView : postsFetched %@", notification.userInfo);
    
    BOOL success = [notification.userInfo[@"posts_loaded_status"] boolValue];
    
    if(!success)
    {
        DDLogError(@"CampusLiveTableViewTopView Failed to load campus live posts.");
        return;
    }
    
    [self reloadCampusLiveTableViewWithPostIndex:0];
    
    [self.swipeView reloadData];
}

- (void)postDeleted:(NSNotification *)notification
{
    [self.swipeView reloadData];
}

#pragma mark - SwipeViewDelegate

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return [[CampusLiveManager sharedInstance] eventsCount];
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    [self reloadCampusLiveTableViewWithPostIndex:swipeView.currentItemIndex];
    
    [self setPostToItemViewWithIndex:swipeView.currentItemIndex];
    [self addDataToTheNextViewWithCurrentIndex:swipeView.currentItemIndex];
    [self addDataToThePreviousViewWithCurrentIndex:swipeView.currentItemIndex];
}

- (NSArray *)newIndexesWithCurrentIndexes:(NSArray *)indexes
{
    NSMutableArray *array = indexes.mutableCopy;
    
    [array removeObjectsInArray:self.lastVisibleCells];
    
    return array;
}

- (void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index
{
    GLPPost *post = [[CampusLiveManager sharedInstance] eventPostAtIndex:index];
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_CL_POST_TOUCHED object:self userInfo:@{@"post" : post}];
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
        
        view = [[NSBundle mainBundle] loadNibNamed:@"CLPostView" owner:self options:nil][0];

        CGRectSetY(view, -60);
        
        view.tag = index;
        
        GLPPost *post = [[CampusLiveManager sharedInstance] eventPostAtIndex:index];

        [(CLPostView *)view setPost:post];
    }
    
    return view;
}

#pragma mark - Post NSNotification

/**
 Post an NSNotification to GLPCampusLiveViewController to reload the Likes and comments
 data for the post with a specific index.
 
 @param index the post index.
 
 */
- (void)reloadCampusLiveTableViewWithPostIndex:(NSInteger)index
{
    GLPPost *post = [[CampusLiveManager sharedInstance] eventPostAtIndex:index];
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_RELOAD_CL_COMMENTS_LIKES object:self userInfo:@{@"post" : post}];
}

#pragma mark - Data operations

/**
 Reloads the next view.
 */
- (void)addDataToTheNextViewWithCurrentIndex:(NSInteger)currentIndex
{
    [self setPostToItemViewWithIndex:currentIndex + 1];
    [self setPostToItemViewWithIndex:currentIndex + 2];
}

/**
 Reloads the previous view.
 */
- (void)addDataToThePreviousViewWithCurrentIndex:(NSInteger)currentIndex
{
    if(currentIndex == 0)
    {
        return;
    }
    
    [self setPostToItemViewWithIndex:currentIndex - 1];
    [self setPostToItemViewWithIndex:currentIndex - 2];

}

- (void)setPostToItemViewWithIndex:(NSInteger)index
{
    if(index >= [[CampusLiveManager sharedInstance] eventsCount] || index < 0)
    {
        DDLogDebug(@"CampusLiveTableViewTopView : reached last or the first post abort.");
        
        return;
    }
    
    GLPPost *post = [[CampusLiveManager sharedInstance] eventPostAtIndex:index];
    
    CLPostView *itemView = (CLPostView *)[self.swipeView itemViewAtIndex:index];
    
    if([post isVideoPost])
    {
        DDLogDebug(@"CampusLiveTableViewTopView %@", post.eventTitle);
        [[GLPVideoLoaderManager sharedInstance] visiblePosts:@[post]];
    }
    
    [itemView setPost:post];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
