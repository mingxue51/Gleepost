//
//  CampusWallHeader.m
//  Gleepost
//
//  Created by Silouanos on 22/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "CampusWallHeader.h"
#import "CampusWallHeaderCell.h"
#import "GLPPostManager.h"
#import "SessionManager.h"
#import "WebClientHelper.h"
#import "WebClient.h"
#import "DateFormatterHelper.h"
#import "CampusLiveManager.h"

@interface CampusWallHeader ()


//@property (weak, nonatomic) IBOutlet VSScrollView *scrollView;

@property (strong, nonatomic) NSArray *posts;
@property (assign, nonatomic) int lastPosition;

@property (weak, nonatomic) IBOutlet UILabel *happeningLbl;

//@property (assign, nonatomic) BOOL readyToAutomaticallyScroll;
//@property (strong, nonatomic) NSTimer *checkLatestEvent;
//@property (strong, nonatomic) NSTimer *runAutomaticScroll;

@end

@implementation CampusWallHeader

NSString *HAPPENING_NOW_MSG;
NSString *HAPPENING_TODAY_MSG;
NSString *HAPPENING_THIS_WEEK_MSG;
NSString *HAPPENING_LATER_MSG;

@synthesize posts = _posts;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self setFrame:CGRectMake(0, 0, 320.0f, 280.0f)];
        
        [self setDataSource:self];

        [self setPaginationEnabled:NO];
        [self setAllowVerticalScrollingForOutOfBoundsCell:YES];
        
        [self setDelegate:self];
        
        [self initialiseObjects];
        
        [self loadEvents];
        
        
        
//        [self.scrollView setScrollEnabled:YES];
//        [self.scrollView setContentSize:CGSizeMake(500.0f, 150.0f)];
//        
//        self.scrollView.layer.borderColor = [UIColor redColor].CGColor;
//        self.scrollView.layer.borderWidth = 2.0f;
        
    }
    
    return self;
}

-(void)initialiseObjects
{
    HAPPENING_NOW_MSG = @"Happening Now";
    HAPPENING_TODAY_MSG = @"Happening Today";
    HAPPENING_THIS_WEEK_MSG = @"Happening This Week";
    HAPPENING_LATER_MSG = @"Happening Later";
}

//-(void)initialiseObjects
//{
//    _readyToAutomaticallyScroll = YES;
//    
////    _checkLatestEvent = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(navigateToLatestEvent:) userInfo:nil repeats:YES];
////    [_checkLatestEvent setTolerance:5.0f];
////    
////    [_checkLatestEvent fire];
//    
//    _runAutomaticScroll = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(enableAutomaticScroll:) userInfo:nil repeats:NO];
//    [_runAutomaticScroll fire];
//}

#pragma mark - Client

-(void)loadEvents
{
//    [self showLoadingLabel];
    

    [[CampusLiveManager sharedInstance] loadCurrentLivePostsWithCallbackBlock:^(BOOL success, NSArray *posts) {
        
        if(success)
        {
            _posts = posts;
            
//            [self hideLoadingLabel];
            
            [self clearAndLoad];
            
//            [self scrollToPosition:1];
        }
        else
        {
            [WebClientHelper showStandardError];
        }
        
    }];
}

#pragma mark - UI methods

-(void)showLoadingLabel
{
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 50, 200, 20)];
    loadingLabel.tag = 100;
    
    [loadingLabel setTextColor:[UIColor lightGrayColor]];
    
    [loadingLabel setText:@"Loading Events..."];
    
    [self addSubview:loadingLabel];
}

-(void)hideLoadingLabel
{
    for(UIView *v in [self subviews])
    {
        if(v.tag == 100)
        {
            [v removeFromSuperview];
        }
    }
}

-(void)clearViews
{
    [self loadEvents];
}

-(void)clearAndLoad
{
    [UIView animateWithDuration:0.3f animations:^{
        
        [self setAlpha:0.0f];

    } completion:^(BOOL finished) {
        
        
        [UIView animateWithDuration:0.5f animations:^{
            
            [self reloadData];
            
            //Load to last position.
            [self scrollToPosition:_lastPosition];
            
            
        } completion:^(BOOL finished) {
            
            
            [UIView animateWithDuration:0.5f animations:^{
                [self setAlpha:1.0f];
                
                if(self.posts.count > 1)
                {
                    [self scrollToPosition:[[CampusLiveManager sharedInstance] findMostCloseToNowLivePostWithPosts:self.posts]];
                }
                
//                [self scrollToPosition:5];
                
                
            }];
            
        }];
        
    }];
   
    
    

}

//-(void)navigateToLatestEvent:(id)sender
//{
//    
//    if(_readyToAutomaticallyScroll && self.posts.count > 1)
//    {
//        DDLogDebug(@"POSISTION: %d", [[CampusLiveManager sharedInstance] findMostCloseToNowLivePostWithPosts:self.posts]);
//
//        [self scrollToPosition:[[CampusLiveManager sharedInstance] findMostCloseToNowLivePostWithPosts:self.posts]];
//        
//        _readyToAutomaticallyScroll = NO;
//    }
//    
//}

#pragma mark - VSScrollView Delegate

-(CGFloat)vsscrollView:(VSScrollView *)scrollView widthForViewAtPosition:(int)position
{
    return CELL_WIDTH;
}

-(CGFloat)vsscrollView:(VSScrollView *)scrollView heightForViewAtPosition:(int)position
{
    
    return CELL_HEIGHT;
    
}

-(CGFloat)cellSpacingAfterCellAtPosition:(int)position
{
//    if (position<20)
//    {
//        return 10.0;
//        
//    }
//    else if (position<30)
//    {
//        return 50.0;
//        
//    }
    return 18.0;
}


-(NSUInteger)numberOfViewInvsscrollview:(VSScrollView *)scrollview
{
    return [_posts count];
}

-(VSScrollViewCell *)vsscrollView:(VSScrollView *)scrollView viewAtPosition:(int)position
{
    static NSString *identifier = @"vsscrollerViewIdentifier";
    
    // VSScrollerView *myView = [scrollView dequeueReusableViewWithIdentifier:identifier];
    CampusWallHeaderCell *myView = (CampusWallHeaderCell *)[scrollView dequeueReusableVSScrollviewCellsWithIdentifier:identifier];

    
    if (!myView)
    {
        myView = [[CampusWallHeaderCell alloc]initWithIdentifier:identifier];
        
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectCell:)];
    [tap setNumberOfTapsRequired:1];
    [myView addGestureRecognizer:tap];
    
    _lastPosition = position;
    
    GLPPost *post = [_posts objectAtIndex:position];
    
    [myView setData: post];

    
    //Set new message to title label depending on event start time.
    
    if(position != 1)
    {
        [self refreshTitleLabelWithEventStartsDate:post.dateEventStarts];
    }
    
    
    return myView;
}


-(void)vsscrollView:(VSScrollView *)scrollview willDisplayCell:(VSScrollViewCell *)cell atPosition:(int)position
{
    
    CampusWallHeaderCell *myCustomCell = (CampusWallHeaderCell *)cell;
    
    CGRect frame = myCustomCell.frame;
//    frame.origin.y =  frame.size.height-(frame.size.height/[self.dataArray count])*position;
    
    frame.origin.y = 0;
    
    [myCustomCell setFrame:frame];
}


-(void)didSelectCell:(id)sender
{
   
    UIGestureRecognizer *g = (UIGestureRecognizer *)sender;
    
    
    
    CampusWallHeaderCell *headerCell = (CampusWallHeaderCell *)g.view;
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys: headerCell.postData, @"Post"
                              , nil];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GLPShowEvent" object:self userInfo:dataDict];

}


- (IBAction)chooseCategory:(id)sender
{
    DDLogDebug(@"Choose category.");
}

#pragma mark - Time management

-(void)refreshTitleLabelWithEventStartsDate:(NSDate *)date
{
    //If date is between current time and event time + 1 hour change title to happening now.
    NSDate *datePlusOneHour = [DateFormatterHelper generateDateAfterHours:1];
    NSDate *dateLastMinute = [DateFormatterHelper generateDateWithLastMinute];
    NSDate *datePlusOneDay = [DateFormatterHelper generateDateAfterDays:1];
    NSDate *datePlusSevenDays = [DateFormatterHelper generateDateAfterDays:7];
    
    
    if([DateFormatterHelper date:date isBetweenDate:[NSDate date] andDate:datePlusOneHour])
    {
        [_happeningLbl setText: HAPPENING_NOW_MSG];
    }
    else if([DateFormatterHelper date:date isBetweenDate:datePlusOneHour andDate:dateLastMinute])
    {
        [_happeningLbl setText:HAPPENING_TODAY_MSG];
    }
    else if([DateFormatterHelper date:date isBetweenDate:datePlusOneDay andDate:datePlusSevenDays])
    {
        [_happeningLbl setText:HAPPENING_THIS_WEEK_MSG];
    }
    else
    {
        [_happeningLbl setText:HAPPENING_LATER_MSG];
    }
    
    
}

#pragma mark - Scroll View Delegate

//-(void)scrollViewDidScroll:(UIScrollView *)myscrollView
//{
//    [super scrollViewDidScroll:myscrollView];
//    
//    _readyToAutomaticallyScroll = NO;
//    DDLogDebug(@"Now disabled!");
//
//    
//    //Check if an element dessappeard from the scroll view.
//    
//    //if YES then regenerate it and add it to the end.
//    
//}

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
////    [super scrollViewWillBeginDragging:scrollView];
//    
//    _readyToAutomaticallyScroll = NO;
//    DDLogDebug(@"Now disabled!");
//}
//
//-(void)scrollViewDidEndDragging:(UIScrollView *)myscrollView willDecelerate:(BOOL)decelerate
//{
//    
//    [super scrollViewDidEndDragging:myscrollView willDecelerate:decelerate];
//    
////    [self performSelector:@selector(enableAutomaticScroll) withObject:nil afterDelay:5.0f];
//    
//    
////    if (![_runAutomaticScroll isValid] || !_runAutomaticScroll)
//    if(!_readyToAutomaticallyScroll)
//    {
//
//        
//        [self performSelector:@selector(enableAutomaticScroll:) withObject:nil afterDelay:10.0f];
//        
//
//    }
//    
//    
//}
//     
//-(void)enableAutomaticScroll:(id)sender
//{
//    @synchronized(_runAutomaticScroll)
//    {
//        DDLogDebug(@"Now enabled!");
//        
//        _readyToAutomaticallyScroll = YES;
//        
////        _runAutomaticScroll = nil;
//    }
//}

//-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)myscrollView
//{
//    [super scrollViewDidScroll:myscrollView];
//    DDLogDebug(@"scrollViewWillBeginDragging");
//}




//-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    DDLogDebug(@"scrollViewWillBeginDragging");
//}
//
//
//
//-(void)scrollViewDidEndDragging:(UIScrollView *)myscrollView willDecelerate:(BOOL)decelerate
//{
//
//    [self addLabelInTheEnd];
//    DDLogDebug(@"scrollViewDidEndDragging");
//
//}
//
//-(void)addLabelInTheEnd
//{
//
//}


@end
