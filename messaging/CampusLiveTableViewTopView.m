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

@interface CampusLiveTableViewTopView ()

@property (weak, nonatomic) IBOutlet SwipeView *swipeView;
@property (strong, nonatomic) NSMutableArray *lastVisibleCells;


@end

@implementation CampusLiveTableViewTopView


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
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

#pragma mark - SwipeViewDataSource

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    if (!view)
    {
        //load new item view instance from nib
        //control events are bound to view controller in nib file
        //note that it is only safe to use the reusingView if we return the same nib for each
        //item view, if different items have different contents, ignore the reusingView value
        
        view = [[NSBundle mainBundle] loadNibNamed:@"PostImageView" owner:self options:nil][1];

        view.tag = index;
        
        GLPPost *post = [[CampusLiveManager sharedInstance] eventPostAtIndex:index];

        [(CLPostView *)view setPost:post];
    }
    
    return view;
}

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
    if(index >= [[CampusLiveManager sharedInstance] eventsCount] - 1 || index < 0)
    {
        DDLogDebug(@"CampusLiveTableViewTopView : reached last or the first post abort");
        
        return;
    }
    
    GLPPost *post = [[CampusLiveManager sharedInstance] eventPostAtIndex:index];
    
    CLPostView *itemView = (CLPostView *)[self.swipeView itemViewAtIndex:index];
    
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
