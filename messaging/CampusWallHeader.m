//
//  CampusWallHeader.m
//  Gleepost
//
//  Created by Silouanos on 22/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "CampusWallHeader.h"
#import "CampusWallHeaderCell.h"

@interface CampusWallHeader ()


//@property (weak, nonatomic) IBOutlet VSScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation CampusWallHeader


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        
        [self setFrame:CGRectMake(0, 0, 320.0f, 300.0f)];
        
        [self setDataSource:self];

        [self setPaginationEnabled:NO];
        [self setAllowVerticalScrollingForOutOfBoundsCell:NO];
        
        [self setDelegate:self];

    
        self.dataArray = [NSMutableArray array];
        
        [self.dataArray addObject:@"TEST"];
        [self.dataArray addObject:@"TEST2"];
        [self.dataArray addObject:@"TEST3"];
        
//        [self.scrollView setScrollEnabled:YES];
//        [self.scrollView setContentSize:CGSizeMake(500.0f, 150.0f)];
//        
//        self.scrollView.layer.borderColor = [UIColor redColor].CGColor;
//        self.scrollView.layer.borderWidth = 2.0f;
        
    }
    
    return self;
}

#pragma mark - VSScrollView Delegate

-(CGFloat)vsscrollView:(VSScrollView *)scrollView widthForViewAtPosition:(int)position
{
    return 100.0;
    
//    if (position>10)
//    {
//        return 50;
//    }
//    return 200.0;
    // return scrollView.bounds.size.width;
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

-(CGFloat)vsscrollView:(VSScrollView *)scrollView heightForViewAtPosition:(int)position
{
    
    return 100.0f;
    
//    if (position>20 && position<40)
//    {
//        return 600.0;
//        
//    }
//    return scrollView.bounds.size.height;
    
}

-(NSUInteger)numberOfViewInvsscrollview:(VSScrollView *)scrollview
{
    
    return [self.dataArray count];
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
    myView.layer.borderWidth = 2.0;
    [myView setBackgroundColor:[UIColor brownColor]];
//    [myView.myImageView setImage:[UIImage imageNamed:@"batman.jpeg"]];
//    [myView.myImageView setBackgroundColor:[UIColor purpleColor]];
//    float alphaValue = (float)(position+1)/[dataArr count];
//    [myView.myImageView setAlpha:alphaValue];
//    myView.textLabel.text = [NSString stringWithFormat:@"  %@",[dataArr objectAtIndex:position]];
    
    [myView setData:[self.dataArray objectAtIndex:position]];
    
    return myView;
}


-(void)vsscrollView:(VSScrollView *)scrollview willDisplayCell:(VSScrollViewCell *)cell atPosition:(int)position
{
    
    CampusWallHeaderCell *myCustomCell = (CampusWallHeaderCell *)cell;
    
    CGRect frame = myCustomCell.frame;
//    frame.origin.y =  frame.size.height-(frame.size.height/[self.dataArray count])*position;
    
    frame.origin.y = 30;
    
    [myCustomCell setFrame:frame];
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
