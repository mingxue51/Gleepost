//
//  NewCommentView.m
//  Gleepost
//
//  Created by Σιλουανός on 4/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "NewCommentView.h"
#import "ChatPanelView.h"
#import <QuartzCore/QuartzCore.h>

//
// NewPathWithRoundRect
//
// Creates a CGPathRect with a round rect of the given radius.
//
CGPathRef NewPathWithRoundRect(CGRect rect, CGFloat cornerRadius)
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

@implementation NewCommentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CGRect screenSizeVar = [self screenSize];
        
        
        
        //Add cancel button.
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 25, 60, 30)];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        
        [cancelButton addTarget:self action:@selector(cancelPushed:) forControlEvents:UIControlEventTouchDown];
        
        [self addSubview:cancelButton];
        
        //Find comment text view height.
        float textViewHeight = screenSizeVar.size.height - (216.0 + 70.0 + 50.0);
        NSLog(@"Screen Height: %f",screenSizeVar.size.height);
        NSLog(@"textViewHeight: %f",textViewHeight);
        
        //Add text view.
        UITextView *commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 70.0f, 300, textViewHeight)];
        [commentTextView setBackgroundColor:[UIColor clearColor]];
        [commentTextView setTextColor:[UIColor whiteColor]];
        [commentTextView setFont:[UIFont fontWithName:@"Helvetica Neue" size:18.0]];
        commentTextView.delegate = self;
        [self addSubview:commentTextView];
        
        
        //Create gesture for text view.
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized:)];
        singleTap.numberOfTapsRequired = 1;
        [commentTextView addGestureRecognizer:singleTap];
        
        //Add comment panel.
        ChatPanelView *chatPanelView = [[ChatPanelView alloc] initWithFrame:CGRectMake(0, textViewHeight+80, 320, 50)];
        
        [self addSubview:chatPanelView];
        
        
        [commentTextView becomeFirstResponder];
    }
    return self;
}

-(CGRect) screenSize
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
   
    return screenRect;
}




-(void) cancelPushed: (id)sender
{
    NSLog(@"Cancel Pushed");
    [self.delegate removeComment];
    
    UIView *superView = [self superview];
	[super removeFromSuperview];
    
    // Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	
	[[superView layer] addAnimation:animation forKey:@"layerAnimation"];
}



+ (id)loadingViewInView:(UIView *)aSuperview
{
	NewCommentView *loadingView = [[NewCommentView alloc] initWithFrame:[aSuperview bounds]];
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
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
//   	rect.size.height -= 1;
//	rect.size.width -= 1;
	
	const CGFloat RECT_PADDING = 10.0;
	rect = CGRectInset(rect, RECT_PADDING, RECT_PADDING);
    
    rect = CGRectMake(0, 63.0, 320, 640);
	
	const CGFloat ROUND_RECT_CORNER_RADIUS = 0.0;
	CGPathRef roundRectPath = NewPathWithRoundRect(rect, ROUND_RECT_CORNER_RADIUS);
    

	   
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	const CGFloat BACKGROUND_OPACITY = 0.5;
	CGContextSetRGBFillColor(context, 0, 0, 0, BACKGROUND_OPACITY);
	CGContextAddPath(context, roundRectPath);
	CGContextFillPath(context);
    
	const CGFloat STROKE_OPACITY = 0.25;
	CGContextSetRGBStrokeColor(context, 1, 1, 1, STROKE_OPACITY);
	CGContextAddPath(context, roundRectPath);
	CGContextStrokePath(context);
	
	CGPathRelease(roundRectPath);
}


#pragma mark - Text View delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"textViewDidBeginEditing");
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSLog(@"textViewDidChange");

}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    NSLog(@"textViewDidChangeSelection");

}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"textViewDidEndEditing");

}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSLog(@"textViewShouldBeginEditing");

    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    NSLog(@"textViewShouldEndEditing");

    return YES;
}

- (UITextView*)commentView
{
    // Get the subviews of the view
    NSArray *subviews = [self subviews];
    
    for(UIView* view in subviews)
    {
        if([view isKindOfClass:[UITextView class]])
        {
            return (UITextView*)view;
        }
    }
    
    return nil;
}

- (void)singleTapRecognized:(UIGestureRecognizer *)gestureRecognizer
{
    UITextView* commentTextView = [self commentView];
    
    if([commentTextView.text isEqualToString:@""])
    {
        NSLog(@"Close");
        [self cancelPushed:nil];
    }
    else
    {
        NSLog(@"Remain");
    }
   
}


@end
