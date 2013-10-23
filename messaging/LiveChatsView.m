//
//  LiveChatsView.m
//  Gleepost
//
//  Created by Σιλουανός on 22/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "LiveChatsView.h"
#import <QuartzCore/QuartzCore.h>


//
// NewPathWithRoundRect
//
// Creates a CGPathRect with a round rect of the given radius.
//
//CGPathRef NewPathWithRoundRect(CGRect rect, CGFloat cornerRadius)
//{
//	//
//	// Create the boundary path
//	//
//	CGMutablePathRef path = CGPathCreateMutable();
//	CGPathMoveToPoint(path, NULL,
//                      rect.origin.x,
//                      rect.origin.y + rect.size.height - cornerRadius);
//    
//	// Top left corner
//	CGPathAddArcToPoint(path, NULL,
//                        rect.origin.x,
//                        rect.origin.y,
//                        rect.origin.x + rect.size.width,
//                        rect.origin.y,
//                        cornerRadius);
//    
//	// Top right corner
//	CGPathAddArcToPoint(path, NULL,
//                        rect.origin.x + rect.size.width,
//                        rect.origin.y,
//                        rect.origin.x + rect.size.width,
//                        rect.origin.y + rect.size.height,
//                        cornerRadius);
//    
//	// Bottom right corner
//	CGPathAddArcToPoint(path, NULL,
//                        rect.origin.x + rect.size.width,
//                        rect.origin.y + rect.size.height,
//                        rect.origin.x,
//                        rect.origin.y + rect.size.height,
//                        cornerRadius);
//    
//	// Bottom left corner
//	CGPathAddArcToPoint(path, NULL,
//                        rect.origin.x,
//                        rect.origin.y + rect.size.height,
//                        rect.origin.x,
//                        rect.origin.y,
//                        cornerRadius);
//    
//	// Close the path at the rounded rect
//	CGPathCloseSubpath(path);
//	
//	return path;
//}

@implementation LiveChatsView

static BOOL visibility;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        NSLog(@"Initialise live chats view.");
        UIButton *chat1 = [[UIButton alloc] initWithFrame:CGRectMake(42.5, 12.5, 45, 45)];
        //UIButton *chat1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [chat1 setBackgroundImage:[UIImage imageNamed:@"userchangeimg"] forState:UIControlStateNormal];
        [chat1 addTarget:self action:@selector(navigateToChat:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:chat1];
        
        UIButton *chat2 = [[UIButton alloc] initWithFrame:CGRectMake(12.5, 72.5, 45, 45)];
        //UIButton *chat1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [chat2 setBackgroundImage:[UIImage imageNamed:@"userchangeimg"] forState:UIControlStateNormal];
        [chat2 addTarget:self action:@selector(navigateToChat:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:chat2];
        
        UIButton *chat3 = [[UIButton alloc] initWithFrame:CGRectMake(72.5, 72.5, 45, 45)];
        //UIButton *chat1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [chat3 setBackgroundImage:[UIImage imageNamed:@"userchangeimg"] forState:UIControlStateNormal];
        [chat3 addTarget:self action:@selector(navigateToChat:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:chat3];
        
    }
    return self;
}

-(void) navigateToChat: (id)sender
{
    [self removeView];
}


+ (id)loadingViewInView:(UIView *)aSuperview
{
	LiveChatsView *loadingView = [[LiveChatsView alloc] initWithFrame:CGRectMake(180, 80, 130, 130)];
	if (!loadingView)
	{
        NSLog(@"Loading View nill");
		return nil;
	}
	
	loadingView.opaque = NO;
	loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[aSuperview addSubview:loadingView];
    
	const CGFloat DEFAULT_LABEL_WIDTH = 280.0;
	const CGFloat DEFAULT_LABEL_HEIGHT = 50.0;
	CGRect labelFrame = CGRectMake(0, 0, DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_HEIGHT);
    

    
    //	UILabel *loadingLabel =
    //    [[UILabel alloc] initWithFrame:labelFrame];
    //	loadingLabel.text = NSLocalizedString(@"Loading...", nil);
    //	loadingLabel.textColor = [UIColor whiteColor];
    //	loadingLabel.backgroundColor = [UIColor clearColor];
    //	loadingLabel.textAlignment = NSTextAlignmentCenter;
    //	loadingLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    //	loadingLabel.autoresizingMask =
    //    UIViewAutoresizingFlexibleLeftMargin |
    //    UIViewAutoresizingFlexibleRightMargin |
    //    UIViewAutoresizingFlexibleTopMargin |
    //    UIViewAutoresizingFlexibleBottomMargin;
	
    //	[loadingView addSubview:loadingLabel];
    //	UIActivityIndicatorView *activityIndicatorView =
    //    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    //	[loadingView addSubview:activityIndicatorView];
    //	activityIndicatorView.autoresizingMask =
    //    UIViewAutoresizingFlexibleLeftMargin |
    //    UIViewAutoresizingFlexibleRightMargin |
    //    UIViewAutoresizingFlexibleTopMargin |
    //    UIViewAutoresizingFlexibleBottomMargin;
    //	[activityIndicatorView startAnimating];
	
    //	CGFloat totalHeight =
    //    loadingLabel.frame.size.height + activityIndicatorView.frame.size.height;
    //	labelFrame.origin.x = floor(0.5 * (loadingView.frame.size.width - DEFAULT_LABEL_WIDTH));
    //	labelFrame.origin.y = floor(0.5 * (loadingView.frame.size.height - totalHeight));
    //	loadingLabel.frame = labelFrame;
	
    //	CGRect activityIndicatorRect = activityIndicatorView.frame;
    //	activityIndicatorRect.origin.x =
    //    0.5 * (loadingView.frame.size.width - activityIndicatorRect.size.width);
    //	activityIndicatorRect.origin.y =
    //    loadingLabel.frame.origin.y + loadingLabel.frame.size.height;
    //	activityIndicatorView.frame = activityIndicatorRect;
	
	// Set up the fade-in animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];
	
	return loadingView;
}


-(CGPathRef) newPathWithRoundRect: (CGRect) rect withCorner: (CGFloat) cornerRadius
{
	//
	// Create the boundary path
	//
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL,
                      rect.origin.x,
                      rect.origin.y + rect.size.height - cornerRadius);
    
	// Top left corner
	CGPathAddArcToPoint(path, NULL,
                        rect.origin.x,
                        rect.origin.y,
                        rect.origin.x + rect.size.width,
                        rect.origin.y,
                        cornerRadius);
    
	// Top right corner
	CGPathAddArcToPoint(path, NULL,
                        rect.origin.x + rect.size.width,
                        rect.origin.y,
                        rect.origin.x + rect.size.width,
                        rect.origin.y + rect.size.height,
                        cornerRadius);
    
	// Bottom right corner
	CGPathAddArcToPoint(path, NULL,
                        rect.origin.x + rect.size.width,
                        rect.origin.y + rect.size.height,
                        rect.origin.x,
                        rect.origin.y + rect.size.height,
                        cornerRadius);
    
	// Bottom left corner
	CGPathAddArcToPoint(path, NULL,
                        rect.origin.x,
                        rect.origin.y + rect.size.height,
                        rect.origin.x,
                        rect.origin.y,
                        cornerRadius);
    
	// Close the path at the rounded rect
	CGPathCloseSubpath(path);
	
	return path;
}

//
// removeView
//
// Animates the view out from the superview. As the view is removed from the
// superview, it will be released.
//
- (void)removeView
{
	UIView *aSuperview = [self superview];
	[super removeFromSuperview];
    
	// Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	
	[[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];
    visibility = NO;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //   	rect.size.height -= 1;
    //	rect.size.width -= 1;
	
	const CGFloat RECT_PADDING = 0.0;
	rect = CGRectInset(rect, RECT_PADDING, RECT_PADDING);
    
    rect = CGRectMake(0, 0, 130, 130);
	
	const CGFloat ROUND_RECT_CORNER_RADIUS = 10.0;
    NSLog(@"View Frame: %f : %f : %f : %f",self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    CGPathRef roundRectPath = [self newPathWithRoundRect:rect withCorner:ROUND_RECT_CORNER_RADIUS];
    
    
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	const CGFloat BACKGROUND_OPACITY = 0.65;
	CGContextSetRGBFillColor(context, 0, 0, 0, BACKGROUND_OPACITY);
	CGContextAddPath(context, roundRectPath);
	CGContextFillPath(context);
    
	const CGFloat STROKE_OPACITY = 0.25;
	CGContextSetRGBStrokeColor(context, 1, 1, 1, STROKE_OPACITY);
	CGContextAddPath(context, roundRectPath);
	CGContextStrokePath(context);
	
	CGPathRelease(roundRectPath);
}

+(BOOL)visible
{
    return visibility;
}
+(void) setVisibility:(BOOL)vis
{
    visibility = vis;
}

@end
