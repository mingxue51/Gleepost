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
#import "GLPComment.h"
#import "SessionManager.h"
#import "WebClient.h"
#import "WebClientHelper.h"


@implementation NewCommentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CGRect screenSizeVar = [self screenSize];
        
        
        [self initialiseNotifications];
        
        self.keyboardBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, screenSizeVar.size.height-216.0, 640.0, 250.0)];
        
        [self.keyboardBackground setBackgroundColor:[UIColor colorWithRed:75.0/255.0 green:204.0/255.0 blue:210.0/255.0 alpha:1.0]];
        
        [self.keyboardBackground setAlpha:0.0];
        [self addSubview:self.keyboardBackground];
        
        //[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showKeyboardEffect:) userInfo:nil repeats:NO];
        
        //[self showKeyboardEffect];
        //[self hideKeyboardEffect];
        [self showKeyboardEffectFirst];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showKeyboardEffect:) userInfo:nil repeats:YES];

        [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(hideKeyboardEffect:) userInfo:nil repeats:YES];
        
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
        self.commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 70.0f, 300, textViewHeight)];
        [self.commentTextView setBackgroundColor:[UIColor clearColor]];
        [self.commentTextView setTextColor:[UIColor whiteColor]];
        [self.commentTextView setFont:[UIFont fontWithName:@"Helvetica Neue" size:18.0]];
        self.commentTextView.delegate = self;
        [self addSubview:self.commentTextView];
        
        
        //Create gesture for text view.
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized:)];
        singleTap.numberOfTapsRequired = 1;
        [self.commentTextView addGestureRecognizer:singleTap];
        
        //Add comment panel.
        ChatPanelView *chatPanelView = [[ChatPanelView alloc] initWithFrame:CGRectMake(0, textViewHeight+80, 320, 50)];
        
        [chatPanelView.commentButton addTarget:self action:@selector(postComment:) forControlEvents:UIControlEventTouchDown];
        
        [self addSubview:chatPanelView];
        
        
        [self.commentTextView becomeFirstResponder];
    }
    return self;
}


-(void)postComment:(id)sender
{
    if([self.commentTextView.text isEqualToString:@""])
    {
        //Don't do anything.
    }
    else
    {
        NSLog(@"Post Comment.");
        GLPComment *newComment = [[GLPComment alloc] init];
        NSLog(@"Comment Post: %@",self.post);
        
        newComment.content = self.commentTextView.text;
        newComment.date = [NSDate date];
        newComment.author = [SessionManager sharedInstance].user;
        newComment.post = self.post;
        
        [WebClientHelper showStandardLoaderWithTitle:@"Creating comment" forView:self];
        [[WebClient sharedInstance] createComment:newComment callbackBlock:^(BOOL success) {
            [WebClientHelper hideStandardLoaderForView:self];
            
            if(success) {
                [self cancelPushed:nil];

            } else {
                [WebClientHelper showStandardError];
            }
        }];
        
    }
}

//-(void)postComment:(GLPComment*)comment
//{
//    
//}

-(void)showKeyboardEffectFirst
{
    [UIView animateKeyframesWithDuration:1.0 delay:0.0 options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        
        [self.keyboardBackground setAlpha:1.0];
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void) showKeyboardEffect:(id)sender
{
    [UIView animateKeyframesWithDuration:2.0 delay:0.0 options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        
        [self.keyboardBackground setAlpha:1.0];
        
    } completion:^(BOOL finished) {
        
    }];
    
}

-(void)hideKeyboardEffect :(id)sender
{
    [UIView animateKeyframesWithDuration:2.0 delay:0.0 options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        
        [self.keyboardBackground setAlpha:0.0];
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void)initialiseNotifications
{
    // keyboard management
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)keyboardWillShow:(NSNotification *)note
{
    CGRect screenSizeVar = [self screenSize];
    
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curve.intValue;
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame



    
    [UIView animateWithDuration:[duration doubleValue] delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|(animationCurve << 16)) animations:^{

        
    } completion:^(BOOL finished) {


        
        
    }];
}

-(CGRect) screenSize
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
   
    return screenRect;
}




-(void) cancelPushed: (id)sender
{
    NSLog(@"Cancel Pushed");
    [self.delegate setPlusButtonToNavigationBar];
    [self.delegate setNavigationBarName];
    
    UIView *superView = [self superview];
	[super removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self  name:UIKeyboardWillShowNotification object:nil];

    
    
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
	CGPathRef roundRectPath = [self newPathWithRoundRect:rect withCorner:ROUND_RECT_CORNER_RADIUS];
    

	   
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	const CGFloat BACKGROUND_OPACITY = 0.67;
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
        [UIView animateKeyframesWithDuration:0.001 delay:0.0 options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionBeginFromCurrentState) animations:^{
            
            [self.keyboardBackground setAlpha:0.0];
            
        } completion:^(BOOL finished) {
            
        }];
        
        NSLog(@"Close");
        [self cancelPushed:nil];
        

        
    }
    else
    {
        NSLog(@"Remain");
    }
   
}


//
// NewPathWithRoundRect
//
// Creates a CGPathRect with a round rect of the given radius.
//
-(CGPathRef) newPathWithRoundRect:(CGRect) rect withCorner:(CGFloat) cornerRadius
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


@end
