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
#import "GLPPostManager.h"
#import "GLPThemeManager.h"
#import "AppearanceHelper.h"
#import "GLPCommentUploader.h"

@implementation NewCommentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        [self configNavigationBar];
        
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
        //UIBarButtonItem *cB = [[UIBarButtonItem alloc] init];
        
        //Add fake navigation bar.
        UIImageView *navBar = [[UIImageView alloc] init];
        
        [navBar setBackgroundColor:[AppearanceHelper defaultGleepostColour]];
        
        [navBar setFrame:CGRectMake(0, 0, 320, 64)];
        
        [self addSubview:navBar];
        
        [navBar sendSubviewToBack:self];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(105.0f, 25.0f, 140.0f, 30.0f)];
        
        [label setText:@"New Comment"];

        [AppearanceHelper formatTextWithLabel:label withSize:20.0];

        
        [label setTextColor:[UIColor whiteColor]];
        
        [self addSubview:label];
        
        
        
        UIColor *buttonsColour = [UIColor whiteColor];
        
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 25, 60, 30)];
        
        [cancelButton setTitleColor:buttonsColour forState:UIControlStateNormal];
        
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        
        [AppearanceHelper formatTextWithLabel:cancelButton.titleLabel withSize:16.0];
        
        [cancelButton addTarget:self action:@selector(cancelPushed:) forControlEvents:UIControlEventTouchDown];
        
        [self addSubview:cancelButton];
        
        //Find comment text view height.
        float textViewHeight = screenSizeVar.size.height - (216.0 + 70.0 + 50.0);
        
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
        
        //Add comment button.
        UIButton *commentButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 25, 60, 30)];
        [commentButton setTitle:@"Post" forState:UIControlStateNormal];
        
        [commentButton setTitleColor:buttonsColour forState:UIControlStateNormal];

        [AppearanceHelper formatTextWithLabel:commentButton.titleLabel withSize:16.0];

        
        [commentButton addTarget:self action:@selector(postComment:) forControlEvents:UIControlEventTouchDown];
        
        [self addSubview:commentButton];
        

        
//        ChatPanelView *chatPanelView = [[ChatPanelView alloc] initWithFrame:CGRectMake(0, textViewHeight+80, 320, 50)];
//        
//        [chatPanelView.commentButton addTarget:self action:@selector(postComment:) forControlEvents:UIControlEventTouchDown];
//        
//        [self addSubview:chatPanelView];
        
        
        [self.commentTextView becomeFirstResponder];
    }
    return self;
}


#pragma mark - Configuration

-(void)configNavigationBar
{
    self.profileDelegate.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    
    //Change the format of the navigation bar.
    [AppearanceHelper setNavigationBarBackgroundImageFor:self.profileDelegate imageName:nil forBarMetrics:UIBarMetricsDefault];
    [AppearanceHelper setNavigationBarColour:self.profileDelegate];
    
    //    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, nil]];
    
    [self.profileDelegate.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [AppearanceHelper setNavigationBarFontFor:self.profileDelegate];
    
    [self.profileDelegate.navigationController.navigationBar setTranslucent:NO];
    
    [self.profileDelegate.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
}


-(void)postComment:(id)sender
{
    if([self.commentTextView.text isEqualToString:@""])
    {
        //Don't do anything.
        [WebClientHelper showEmptyTextError];
    }
    else
    {
//        GLPComment *newComment = [[GLPComment alloc] init];
//        NSLog(@"Comment Post: %@",self.post);
//        
//        newComment.content = self.commentTextView.text;
//        newComment.date = [NSDate date];
//        newComment.author = [SessionManager sharedInstance].user;
//        newComment.post = self.post;
        
        DDLogDebug(@"New comment view post remote key: %d", self.post.remoteKey);
        
        GLPCommentUploader *commentUploader = [[GLPCommentUploader alloc] init];
        
        [commentUploader uploadCommentWithContent:self.commentTextView.text andPost:self.post];
        
        
        [self cancelPushed:nil];

//        [[WebClient sharedInstance] createComment:newComment callbackBlock:^(BOOL success) {
//            
//            if(success) {
//            
//            } else {
//                [WebClientHelper showStandardError];
//            }
//        }];
        
    }
}


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
//    CGRect screenSizeVar = [self screenSize];
    
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
//    [self.timeLineDelegate setPlusButtonToNavigationBar];
//    [self.timeLineDelegate setNavigationBarName];
    
    [self.profileDelegate setPreviousViewToNavigationBar];
    [self.profileDelegate setPreviousNavigationBarName];
    
    
    UIView *superView = [self superview];
	[super removeFromSuperview];
    
    
    
    if(!sender)
    {
        //Update the number of comments.
        [GLPPostManager updatePostWithRemoteKey:self.post.remoteKey andNumberOfComments:self.post.commentsCount+1];
        
        [self.profileDelegate navigateToViewPostFromCommentWithIndex:self.postIndex];
    }
    
    
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
    

//	CGRect labelFrame = CGRectMake(0, 0, DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_HEIGHT);
    

    
    
    
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
}

- (void)textViewDidChange:(UITextView *)textView
{

}

- (void)textViewDidChangeSelection:(UITextView *)textView
{

}

- (void)textViewDidEndEditing:(UITextView *)textView
{

}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
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
        
        [self cancelPushed:gestureRecognizer];
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
