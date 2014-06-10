//
//  InfiniteScrollPicker.m
//  InfiniteScrollPickerExample
//
//  Created by Philip Yu on 6/6/13.
//  Copyright (c) 2013 Philip Yu. All rights reserved.
//

#import "InfiniteScrollViewPicker.h"
#import "UIView+viewController.h"

@interface InfiniteScrollViewPicker ()

@property (assign, nonatomic) CGPoint destinationOffset;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic, getter = isAutomaticScrollEnabled) BOOL automaticScrollEnabled;
@property (assign, nonatomic, getter = isAnimationEnabled) BOOL animationEnabled;
@property (assign, nonatomic) ISVAnimationSpeed animationSpeed;

@end

@implementation InfiniteScrollViewPicker

@synthesize imageArray = _imageArray;
@synthesize itemSize = _itemSize;
@synthesize alphaOfobjs;
@synthesize heightOffset;
@synthesize positionRatio;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialiseObjects];
        
        
        
        [self startAutomaticScrolling];
    }
    return self;
}

#pragma mark - Configuration

- (void)initInfiniteScrollView
{
    [self initInfiniteScrollViewWithSelectedItem:0];
}

- (void)initialiseObjects
{
    alphaOfobjs = 1.0;
    heightOffset = 0.0;
    positionRatio = 1.0;
    
    _imageArray = [[NSMutableArray alloc] init];
    imageStore = [[NSMutableArray alloc] init];
    
    _automaticScrollEnabled = YES;
    _animationEnabled = YES;
    
    _animationSpeed = kSlow;
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([self isAnimationEnabled])
    {
        [self stopAutomaticScrolling];

        _animationEnabled = NO;
    }
    else
    {
        [self startAutomaticScrolling];
        _animationEnabled = YES;
    }
    
    
    [super touchesBegan:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"DEBUG: Touches ending" );

    if([self isAnimationEnabled])
    {
        [self startAutomaticScrolling];
    }
    
    [super touchesEnded:touches withEvent:event];
}

#pragma mark - Animations

- (void)animateScroll:(NSTimer *)timer
{
    if(![self isAutomaticScrollEnabled])
    {
        return;
    }
    
	CGPoint offset = [self contentOffset];
    
    offset.x = offset.x + _destinationOffset.x;
    
	[self setContentOffset:offset animated:YES];
}

- (void)doAnimatedScrollTo:(CGPoint)offset
{
    _destinationOffset = offset;
    
    if (![_timer isValid])
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                         target:self
                                       selector:@selector(animateScroll:)
                                       userInfo:nil
                                        repeats:YES];
    }
}

- (void)stopAutomaticScrolling
{
    _automaticScrollEnabled = NO;
    
    [_timer invalidate];
}

- (void)startAutomaticScrolling
{
    _automaticScrollEnabled = YES;
    
    NSLog(@"Animation speed: %d", _animationSpeed);
    
    [self doAnimatedScrollTo:CGPointMake(_animationSpeed, self.contentOffset.y)];
}


#pragma mark - Setters

- (void)initInfiniteScrollViewWithSelectedItem:(int)index
{
    if (_itemSize.width == 0 && _itemSize.height == 0)
    {
        if (_imageArray.count > 0)
        {
            _itemSize = [(UIImage *)[_imageArray objectAtIndex:0] size];
        }
        else
        {
//            _itemSize = CGSizeMake(self.frame.size.height/2, self.frame.size.height/2);
            _itemSize = CGSizeMake(self.frame.size.height - 5 , self.frame.size.height - 5);
        }
    }
    
    
    NSAssert((_itemSize.height < self.frame.size.height), @"item's height must not bigger than scrollpicker's height");
    
    self.pagingEnabled = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    
    if (_imageArray.count > 0)
    {
        // Init 5 set of images, 3 for user selection, 2 for
        for (int i = 0; i < (_imageArray.count*5); i++)
        {
            // Place images into the bottom of view
            UIImageView *temp = [[UIImageView alloc] initWithFrame:CGRectMake(i * _itemSize.width, self.frame.size.height - _itemSize.height, _itemSize.width, _itemSize.height)];
            temp.image = [_imageArray objectAtIndex:i%_imageArray.count];
            [imageStore addObject:temp];
            [self addSubview:temp];
        }
        
        self.contentSize = CGSizeMake(_imageArray.count * 5 * _itemSize.width, self.frame.size.height);
        
        float viewMiddle = _imageArray.count * 2 * _itemSize.width - self.frame.size.width/2 + _itemSize.width + (_itemSize.width * index);
        [self setContentOffset:CGPointMake(viewMiddle, 0)];
        
        self.delegate = self;
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^ {
            [self reloadView:viewMiddle];
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self snapToAnEmotion];
            });
        });
        
    }
    
}

- (void)setImageArrray:(NSArray *)imageArray
{
    _imageArray = imageArray;
    [self initInfiniteScrollView];
}

- (void)setItemSize:(CGSize)itemSize
{
    itemSize = itemSize;
    [self initInfiniteScrollView];
}

- (void)setSelectedItem:(int)index
{
    [self initInfiniteScrollViewWithSelectedItem:index];
}

- (void)setAutomaticScrollEnabled:(BOOL)automaticAnimationEnabled
{
    _automaticScrollEnabled = automaticAnimationEnabled;
}

- (void)setAnimationSpeed:(ISVAnimationSpeed)animationSpeed
{
    _animationSpeed = animationSpeed;
    [self stopAutomaticScrolling];
    [self startAutomaticScrolling];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.contentOffset.x > 0)
    {
        float sectionSize = _imageArray.count * _itemSize.width;
        
        if (self.contentOffset.x <= (sectionSize - sectionSize/2))
        {
            self.contentOffset = CGPointMake(sectionSize * 2 - sectionSize/2, 0);
        }
        else if (self.contentOffset.x >= (sectionSize * 3 + sectionSize/2))
        {
            self.contentOffset = CGPointMake(sectionSize * 2 + sectionSize/2, 0);
        }

        [self reloadView:self.contentOffset.x];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{    
    if([self isAnimationEnabled])
    {
        [self startAutomaticScrolling];
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if([self isAnimationEnabled])
    {
        [self stopAutomaticScrolling];
    }
    
    
}


#pragma mark - ScrollView manager

- (void)reloadView:(float)offset
{
    id biggestView;

    
    for (int i = 0; i < imageStore.count; i++)
    {
        UIView *cBlock = [imageStore objectAtIndex:i];
        cBlock.alpha = alphaOfobjs;

        if (i > 0)
        {
            UIView *pBlock = [imageStore objectAtIndex:i-1];
            cBlock.frame = CGRectMake(pBlock.frame.origin.x + pBlock.frame.size.width, cBlock.frame.origin.y, cBlock.frame.size.width, cBlock.frame.size.height);
        }
    }

    [(UIView *)biggestView setAlpha:1.0];
}

-(float)calculateFrameHeightByOffset:(float)offset
{
    return (-1 * fabsf((offset)*2 - self.frame.size.width/2) + self.frame.size.width/2)/4;
}

- (void)snapToAnEmotion
{
    float biggestSize = 0;
    UIImageView *biggestView;
    
    snapping = YES;
    
    float offset = self.contentOffset.x;
    
    for (int i = 0; i < imageStore.count; i++) {
        UIImageView *view = [imageStore objectAtIndex:i];
    
        if (view.center.x > offset && view.center.x < (offset + self.frame.size.width))
        {
            if (((view.center.x + view.frame.size.width) - view.center.x) > biggestSize)
            {
                biggestSize = ((view.frame.origin.x + view.frame.size.width) - view.frame.origin.x);
                biggestView = view;
            }
            
        }
    }
    
    float biggestViewX = biggestView.frame.origin.x + biggestView.frame.size.width/2 - self.frame.size.width/2;
    float dX = self.contentOffset.x - biggestViewX;
    float newX = self.contentOffset.x - dX/1.4;
    
    // Disable scrolling when snapping to new location
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^ {
        [self setScrollEnabled:NO];
        [self scrollRectToVisible:CGRectMake(newX, 0, self.frame.size.width, 1) animated:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            SEL selector = @selector(infiniteScrollPicker:didSelectAtImage:);
            if ([[self firstAvailableUIViewController] respondsToSelector:selector])
            {
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [[self firstAvailableUIViewController] performSelector:selector withObject:self withObject:biggestView.image];
                #pragma clang diagnostic pop
            }
            
            [self setScrollEnabled:YES];
            snapping = 0;
        });
    });
}

@end
