//
//  PullDownScrollView.m
//  Gleepost
//
//  Created by Σιλουανός on 8/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "PullDownScrollView.h"

@implementation PullDownScrollView

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setContentSize:CGSizeMake(frame.size.width, frame.size.height+1)];
        [self initialiseElements];
        self.delegate = self;
        
    }
    return self;
}


-(void) initialiseElements
{
    UIImage *pullDownImage = [UIImage imageNamed:@"pull_down_button"];
    CGSize sizeOfCircleImage = pullDownImage.size;
    self.pullDownImageView = [[UIImageView alloc] initWithImage:pullDownImage];
    
    [self.pullDownImageView setFrame:CGRectMake((self.frame.size.width/2)-(sizeOfCircleImage.width/4), (self.frame.size.height/2)-(sizeOfCircleImage.height/2.5), sizeOfCircleImage.width/2, sizeOfCircleImage.height/2)];
    
    isLoading = false;
    
    /**
     [tableView setShowsHorizontalScrollIndicator:NO];
     [tableView setShowsVerticalScrollIndicator:NO];
     */
    //[self setShowsHorizontalScrollIndicator:NO];
    //[self setShowsVerticalScrollIndicator:NO];
    
    [self addSubview:self.pullDownImageView];
}

#pragma mark - Scroll View Delegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewWillBeginDragging");
    isDraging = YES;
}

-(void)scrollViewDidScroll:(UIScrollView *)myscrollView
{
    NSLog(@"scrollViewDidScroll: %f", myscrollView.contentOffset.y);
    
    if(!isLoading)
    {
        if (isDraging && myscrollView.contentOffset.y < 0 - REFHEIGHT)
        {
            NSLog(@"Animation.");
        }
        else
        {
            NSLog(@"No Animation.");
        }
    }

}

-(void)scrollViewDidEndDragging:(UIScrollView *)myscrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"scrollViewDidEndDragging");
    isDraging = NO;
    
    if (myscrollView.contentOffset.y < 0 - REFHEIGHT)
    {
        
    }
}



- (void)stopLoading
{
    NSLog(@"stopLoading");
}

- (void)stopLoadingComplete
{
    NSLog(@"stopLoadingComplete");
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
