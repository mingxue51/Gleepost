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
@property (assign, nonatomic) BOOL readyToAutomaticallyScroll;
@property (strong, nonatomic) NSTimer *checkLatestEvent;


@end

@implementation CampusWallHeader

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
        
//        if(self.subviews.count >= 2)
//        {
//            [WebClientHelper showStandardErrorWithTitle:@"ERROR in horizontal" andContent:@"Subview removed"];
//            
//            UIView *v = [self.subviews objectAtIndex:1];
//            
//            if(v)
//            {
//                [v removeFromSuperview];
//            }
//        }

        

        
        
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
    _readyToAutomaticallyScroll = NO;
    
    _checkLatestEvent = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(navigateToLatestEvent:) userInfo:nil repeats:YES];
    [_checkLatestEvent setTolerance:5.0f];
    
    [_checkLatestEvent fire];
}

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
    
//    [[WebClient sharedInstance] getEventPostsAfterDate:date withCallbackBlock:^(BOOL success, NSArray *posts) {
//       
//        if(success)
//        {
//            _posts = posts;
//            
//            [self hideLoadingLabel];
//            
//            [self clearAndLoad];
//            
//            [self scrollToPosition:1];
//            
//        }
//        else
//        {
//            [WebClientHelper showStandardError];
//        }
//        
//    }];
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
//    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    
//    if(self.subviews.count >= 2)
//    {
//        [WebClientHelper showStandardErrorWithTitle:@"ERROR in horizontal" andContent:@"Problem in horizontal scroll view detected! Please contact with developer!"];
//        UIView *v = [self.subviews objectAtIndex:1];
//        [v removeFromSuperview];
//        
//    }
    
    
    [self loadEvents];
}

-(void)clearAndLoad
{
//    for(UIView *v in self.subviews)
//    {
//        if([v isKindOfClass:[UIScrollView class]])
//        {
//            [v removeFromSuperview];
//            break;
//        }
//    }
    
    
    [self reloadData];
}

-(void)navigateToLatestEvent:(id)sender
{
    DDLogDebug(@"POSISTION: %d", [[CampusLiveManager sharedInstance] findMostCloseToNowLivePostWithPosts:self.posts]);
    
    if(_readyToAutomaticallyScroll)
    {
        [self scrollToPosition:[[CampusLiveManager sharedInstance] findMostCloseToNowLivePostWithPosts:self.posts]];
    }
    
}

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
    

    
    [myView setData:[_posts objectAtIndex:position]];
    
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
}



-(void)didSelectCell:(id)sender
{
   
    UIGestureRecognizer *g = (UIGestureRecognizer *)sender;
    
    
    
    CampusWallHeaderCell *headerCell = (CampusWallHeaderCell *)g.view;
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys: headerCell.postData, @"Post"
                              , nil];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GLPShowEvent" object:self userInfo:dataDict];

//    [_timeLineDelegate showEventPost:nil];
}


- (IBAction)chooseCategory:(id)sender
{
    DDLogDebug(@"Choose category.");
}

#pragma mark - Scroll View Delegate

-(void)scrollViewDidScroll:(UIScrollView *)myscrollView
{
    [super scrollViewDidScroll:myscrollView];
    
    _readyToAutomaticallyScroll = NO;
    
    //Check if an element dessappeard from the scroll view.
    
    //if YES then regenerate it and add it to the end.
    
}


-(void)scrollViewDidEndDragging:(UIScrollView *)myscrollView willDecelerate:(BOOL)decelerate
{
    
    [super scrollViewDidEndDragging:myscrollView willDecelerate:decelerate];
    
    _readyToAutomaticallyScroll = YES;
    
}

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
