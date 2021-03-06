//
//  RegisterAnimationsView.m
//  Gleepost
//
//  Created by Silouanos on 04/06/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "RegisterAnimationsView.h"
#import "ShapeFormatterHelper.h"

@interface RegisterAnimationsView ()

@property (strong, nonatomic) NSArray *imageViews;

@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UIImageView *img2;

@property (assign, nonatomic) NSInteger preTranslation;

@property (strong, nonatomic) InfiniteScrollViewPicker *infiniteScrollView;

@property (strong, nonatomic) NSArray *scrollableImages;

@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic, strong) NSDate *startTime;
@property (assign, nonatomic) CGPoint startOffset;
@property (assign, nonatomic) CGPoint destinationOffset;

@end

@implementation RegisterAnimationsView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self initialiseElements];
        
        [self loadScrollerImages];
        
        [self initialiseScrollView];
        
//        [self configureGestures];
    }
    return self;
}

- (void)loadScrollerImages
{
    NSMutableArray *mutableImages = [[NSMutableArray alloc] init];
    
    [mutableImages addObject:[UIImage imageNamed:@"baseball"]];
    [mutableImages addObject:[UIImage imageNamed:@"bowling"]];
    [mutableImages addObject:[UIImage imageNamed:@"bullseye"]];
    [mutableImages addObject:[UIImage imageNamed:@"calendar"]];
    [mutableImages addObject:[UIImage imageNamed:@"camping"]];
    [mutableImages addObject:[UIImage imageNamed:@"donut"]];
    [mutableImages addObject:[UIImage imageNamed:@"drink"]];
    [mutableImages addObject:[UIImage imageNamed:@"eggpaint"]];
    [mutableImages addObject:[UIImage imageNamed:@"fireside"]];
    [mutableImages addObject:[UIImage imageNamed:@"golf"]];
    [mutableImages addObject:[UIImage imageNamed:@"guitar"]];
    
    _scrollableImages = [[NSArray alloc] initWithArray:mutableImages copyItems:YES];
}

- (void)initialiseScrollView
{
    _infiniteScrollView = [[InfiniteScrollViewPicker alloc] initWithFrame:self.bounds];
    
    [_infiniteScrollView setItemSize:CGSizeMake(70.0f, 70.0f)];
    [_infiniteScrollView setAnimationSpeed:kMedium];
    [_infiniteScrollView setAutomaticScrollEnabled:YES];
    [_infiniteScrollView setImageArray:_scrollableImages];
    [_infiniteScrollView setSelectedItem:0];
    [_infiniteScrollView setDistanceBetweenElements:10];
    
    [self addSubview:_infiniteScrollView];
    
//    _infiniteScrollView = [[GBInfiniteScrollView alloc] initWithFrame:self.bounds];
//    
////    [_infiniteScrollView setDebug:YES];
////    [_infiniteScrollView setVerboseDebug:YES];
//    
//    _infiniteScrollView.infiniteScrollViewDataSource = self;
//    _infiniteScrollView.infiniteScrollViewDelegate = self;
//    
//    _infiniteScrollView.pageIndex = 0;
//    
//    [_infiniteScrollView setInterval:2.0f];
//    
////    [_infiniteScrollView setPagingEnabled:NO];
//
//    
//    [_infiniteScrollView reloadData];
//    
//    [_infiniteScrollView startAutoScroll];
//    
//    
//    [self addSubview:_infiniteScrollView];
}

- (void)configureGestures
{
    UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragView:)];
    [self addGestureRecognizer:panGestureRecognizer];
}


//- (void)awakeFromNib
//{
//    _startOffset = CGPointMake(0.0, 0.0);
//    
//    _destinationOffset = CGPointMake(100.0, 0.0);
//    
//    [_scroll setContentSize:CGSizeMake(_scroll.frame.size.width+2200, _scroll.frame.size.height)];
//    
//    
//    [self doAnimatedScrollTo:CGPointMake(2000.0, 0.0)];
//}

- (void)initialiseElements
{
    
//    _startOffset = CGPointMake(0.0, 0.0);
//    
//    _destinationOffset = CGPointMake(100.0, 0.0);
//
//    [_scroll setContentSize:CGSizeMake(_scroll.frame.size.width, _scroll.frame.size.height+2200)];
//
//    
//    [self doAnimatedScrollTo:CGPointMake(20000.0f, 0.0)];
    
//    [UIScrollView beginAnimations:@"scrollAnimation" context:nil];
//    
//    [UIScrollView setAnimationDuration:15.0f];
//    
//    [_scroll setContentOffset:CGPointMake(1000.0, 0.0)];
//    
//    [UIScrollView commitAnimations];
}

//#pragma mark - Animations
//
//- (void) animateScroll:(NSTimer *)timerParam
//{
//    const NSTimeInterval duration = 10.2;
//    
//    NSTimeInterval timeRunning = - [_startTime timeIntervalSinceNow];
//    
//
//    
//    
//    if (timeRunning >= duration)
//    {
//        
//        [_scroll setContentOffset:_destinationOffset animated:YES];
//        [_timer invalidate];
//        _timer = nil;
//        return;
//    }
//	CGPoint offset = [_scroll contentOffset];
//	offset.y = _startOffset.y + (_destinationOffset.y - _startOffset.y) * timeRunning / duration;
//	[_scroll setContentOffset:offset animated:YES];
//}
//
//- (void) doAnimatedScrollTo:(CGPoint)offset
//{
//    self.startTime = [NSDate date];
//    _startOffset = _scroll.contentOffset;
//    
//    _destinationOffset = offset;
//    
//    if (!_timer)
//    {
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01
//                                         target:self
//                                       selector:@selector(animateScroll:)
//                                       userInfo:nil
//                                        repeats:YES];
//    }
//}
//
//#pragma mark - Gestures
//
//- (void)dragView:(UIPanGestureRecognizer *)panGestureRecognizer
//{
//    
//    [self doAnimatedScrollTo:CGPointMake(2000.0, 0.0)];
//
////    CGPoint translation = [panGestureRecognizer translationInView:panGestureRecognizer.view];
////    CGPoint velocity = [panGestureRecognizer velocityInView:panGestureRecognizer.view];
////    CGPoint location = [panGestureRecognizer locationInView:self];
////    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan)
////    {
////        DDLogDebug(@"Began: Translation %f : %f, Velocity: %f : %f", translation.x, translation.y, velocity.x, velocity.y);
////        
////        [UIView animateWithDuration:2.0 delay:0
////                            options:UIViewAnimationOptionCurveEaseOut
////                         animations:^ {
//////                             _img.center = location;
//////                             _img2.center = location;
////                         }
////                         completion:NULL];
////        
////        _preTranslation = translation.x;
////    }
////    else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged)
////    {
////        DDLogDebug(@"Changed: Translation %f : %f, Velocity: %f : %f, Location: %f : %f", translation.x, translation.y, velocity.x, velocity.y, location.x, location.y);
////        if(_preTranslation != translation.x)
////        {
////            [_img setCenter:CGPointMake(_img.center.x + translation.x, _img.center.y)];
////        }
////        
////        DDLogDebug(@"Image point: %f", _img.center.x);
////        
//////        _img.center = location;
//////        _img2.center = location;
////    }
////    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded)
////    {
////        DDLogDebug(@"Ended: Translation %f : %f, Velocity: %f : %f", translation.x, translation.y, velocity.x, velocity.y);
////    }
//}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
