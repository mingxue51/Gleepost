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

@interface CampusWallHeader ()


//@property (weak, nonatomic) IBOutlet VSScrollView *scrollView;

@property (strong, nonatomic) NSArray *posts;

@end

@implementation CampusWallHeader

@synthesize posts = _posts;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self setFrame:CGRectMake(0, 0, 320.0f, 300.0f)];
        
        [self setDataSource:self];

        [self setPaginationEnabled:NO];
        [self setAllowVerticalScrollingForOutOfBoundsCell:YES];
        
        [self setDelegate:self];
        
        [self loadEvents];
        

        
        
//        [self.scrollView setScrollEnabled:YES];
//        [self.scrollView setContentSize:CGSizeMake(500.0f, 150.0f)];
//        
//        self.scrollView.layer.borderColor = [UIColor redColor].CGColor;
//        self.scrollView.layer.borderWidth = 2.0f;
        
    }
    
    return self;
}

#pragma mark - Client

-(void)loadEvents
{
    
    [self showLoadingLabel];
    
    [GLPPostManager loadEventsRemotePostsForUserRemoteKey:[SessionManager sharedInstance].user.remoteKey callback:^(BOOL success, NSArray *posts) {
       
        if(success)
        {
            _posts = posts;
            

            [self hideLoadingLabel];

            [self clearAndLoad];

            

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
//    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if(self.subviews.count >= 2)
    {
        DDLogError(@"PROBLEM HAVING TWO SCROLLVIEWS IN LIVE WALL IS PROBLEMATIC.");
    }
    
    
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
    if (position<20)
    {
        return 10.0;
        
    }
    else if (position<30)
    {
        return 50.0;
        
    }
    return 0.0;
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
    
    frame.origin.y = 10;
    
    [myCustomCell setFrame:frame];
}

-(void)didSelectCell:(id)sender
{
    DDLogDebug(@"didChangeValueForKey");

}


- (IBAction)chooseCategory:(id)sender
{
    DDLogDebug(@"Choose category.");
}

#pragma mark - Scroll View Delegate

//-(void)scrollViewDidScroll:(UIScrollView *)myscrollView
//{
////    DDLogDebug(@"scrollViewDidScroll : %f", myscrollView.);
//    
//    
//    
//    //Check if an element dessappeard from the scroll view.
//    
//    //if YES then regenerate it and add it to the end.
//    
//}
//
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
