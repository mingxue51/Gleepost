//
//  PullDownScrollView.m
//  Gleepost
//
//  Created by Σιλουανός on 8/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "PullDownScrollView.h"
#import "ChatViewAnimations.h"
#import "WebClientHelper.h"
#import "GLPThemeManager.h"


@implementation PullDownScrollView
@synthesize chatViewAnimations = _chatViewAnimations;

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:CGRectMake(75, 0, frame.size.width-150, frame.size.height)];
    if (self)
    {
        [self setContentSize:CGSizeMake(frame.size.width-160, frame.size.height+1)];
        [self initialiseElements];
        self.delegate = self;
        
    }
    return self;
}

-(void) setChatViewAnimations:(ChatViewAnimations *)chatViewAnimations
{
    _chatViewAnimations = chatViewAnimations;
}

-(void) initialiseElements
{
//    UIImage *pullDownImage = [UIImage imageNamed:@"pull_down_button"];
    UIImage *pullDownImage = [UIImage imageNamed:[[GLPThemeManager sharedInstance] pullDownButton]];
    
    CGSize sizeOfCircleImage = pullDownImage.size;
    self.pullDownImageView = [[UIImageView alloc] initWithImage:pullDownImage];
    
    [self.pullDownImageView setFrame:CGRectMake((self.frame.size.width/2)-(sizeOfCircleImage.width/4), (self.frame.size.height/2)-(sizeOfCircleImage.height/4), sizeOfCircleImage.width/2, sizeOfCircleImage.height/2)];
    
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
    isDraging = YES;
}

-(void)scrollViewDidScroll:(UIScrollView *)myscrollView
{
    if(!isLoading)
    {
        if (isDraging && myscrollView.contentOffset.y < 0 - REFHEIGHT)
        {
//            [_chatViewAnimations animateCirclesFancy];
           // isDraging = NO;
        }
        else
        {
        }
    }

}

-(void)scrollViewDidEndDragging:(UIScrollView *)myscrollView willDecelerate:(BOOL)decelerate
{
    isDraging = NO;
    
    if (myscrollView.contentOffset.y < 0 - REFHEIGHT)
    {
        //Add message to the user that the system is looking for people.

        [_chatViewAnimations animateCirclesFancy];

        [self performSelector:@selector(startSearchingIndicator) withObject:nil afterDelay:1.4];
        
        [self performSelector:@selector(stopSearchingIndicator) withObject:nil afterDelay:3.5];

        [_chatViewAnimations performSelector:@selector(navigateToNewRandomChat) withObject:nil afterDelay:3.5];
        myscrollView.scrollEnabled = NO;
    }
}

-(void) startSearchingIndicator
{
    [WebClientHelper showStandardLoaderWithoutSpinningAndWithTitle:@"Searching for people..." forView:_chatViewAnimations];

}

-(void) stopSearchingIndicator
{
    [WebClientHelper hideStandardLoaderForView:_chatViewAnimations];
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