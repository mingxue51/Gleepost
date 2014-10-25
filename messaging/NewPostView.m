//
//  NewPostView.m
//  Gleepost
//
//  Created by Σιλουανός on 1/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "NewPostView.h"
#import "ChatPanelView.h"
#import "GLPPost.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "SessionManager.h"

@implementation NewPostView


static BOOL visibility = NO;



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        CGRect screenSizeVar = [self screenSize];
        
        //Initialise elements.
        
        self.keyboardBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, screenSizeVar.size.height-216.0, 640.0, 250.0)];
        
        [self.keyboardBackground setBackgroundColor:[UIColor colorWithRed:75.0/255.0 green:204.0/255.0 blue:210.0/255.0 alpha:1.0]];
        
        [self.keyboardBackground setAlpha:0.0];
        [self addSubview:self.keyboardBackground];
        
        //[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showKeyboardEffect:) userInfo:nil repeats:NO];
        
        //[self showKeyboardEffect];
        //[self hideKeyboardEffect];
        //[self showKeyboardEffectFirst];
//        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showKeyboardEffect:) userInfo:nil repeats:YES];
//        
//        [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(hideKeyboardEffect:) userInfo:nil repeats:YES];
        
        
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
        
        
        //Add image holder.
        UIImage *avatarImg = [UIImage imageNamed:@"avatar"];
        self.imageHolderButton = [[UIButton alloc] initWithFrame:CGRectMake(230, 70, avatarImg.size.width/2, avatarImg.size.height/2)];
        [self.imageHolderButton setBackgroundImage:[UIImage imageNamed:@"avatar"] forState:UIControlStateNormal];
        [self.imageHolderButton addTarget:self action:@selector(addImage:) forControlEvents:UIControlEventTouchDown];
        
        
        [self addSubview:self.imageHolderButton];
        
        //Add cancel button.
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 25, 60, 30)];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        
        [cancelButton addTarget:self action:@selector(cancelPushed:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:cancelButton];

        
        
        //Add comment panel.
        ChatPanelView *chatPanelView = [[ChatPanelView alloc] initWithFrame:CGRectMake(0, textViewHeight+80, 320, 50)];
        
        [chatPanelView.commentButton addTarget:self action:@selector(postPost:) forControlEvents:UIControlEventTouchDown];
        [chatPanelView.cameraButton setHidden:YES];
        
        
        [self addSubview:chatPanelView];
        
        //Create gesture for text view.
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized:)];
        singleTap.numberOfTapsRequired = 1;
        [self.commentTextView addGestureRecognizer:singleTap];
        
        
        self.fdTakeController = [[FDTakeController alloc] init];
        self.fdTakeController.delegate = self;
        
        
        [self.commentTextView becomeFirstResponder];

    }
    return self;
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

-(CGRect) screenSize
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    return screenRect;
}



-(void)postPost:(id)sender
{
    GLPPost *post = [[GLPPost alloc] init];
    post.content = self.commentTextView.text;
    post.date = [NSDate date];
    
    
    
    if(self.imagePosted)
    {
        NSData* imageData = UIImagePNGRepresentation(self.uploadedImage.image);
        NSLog(@"Image size before: %d",imageData.length);
        
        
        //Resize image before uploading.
        //        CGSize newSize = CGSizeMake(300, 300);
        //        UIGraphicsBeginImageContext(newSize);
        //        [self.uploadedImage.image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        //        UIImage* imageToUpload = UIGraphicsGetImageFromCurrentImageContext();
        //        UIGraphicsEndImageContext();
        
        UIImage* imageToUpload = [self resizeImage:[self.uploadedImage image] WithSize:CGSizeMake(300, 300)];
        
        imageData = UIImagePNGRepresentation(imageToUpload);
        
        NSLog(@"Image size after: %d",imageData.length);
        
        int userRemoteKey = [[SessionManager sharedInstance]user].remoteKey;
        
        [WebClientHelper showStandardLoaderWithTitle:@"Uploading image" forView:self];
        
        
        [[WebClient sharedInstance] uploadImage:imageData ForUserRemoteKey:userRemoteKey callbackBlock:^(BOOL success, NSString* response) {
            
            [WebClientHelper hideStandardLoaderForView:self];
            
            
            if(success)
            {
                NSLog(@"IMAGE UPLOADED. URL: %@",response);
                
                post.imagesUrls = [[NSArray alloc] initWithObjects:response, nil];
                
                //[WebClientHelper showStandardErrorWithTitle:@"Image uploaded successfully" andContent:[NSString stringWithFormat:@"Url: %@",response]];
                
                
                [self createPost:post];
                
            }
            else
            {
                NSLog(@"ERROR");
                [WebClientHelper showStandardErrorWithTitle:@"Error uploading the image" andContent:@"Please check your connection and try again"];
                
            }
        }];
        
    }
    else
    {
        post.imagesUrls = nil;
        [self createPost:post];
    }
}

-(UIImage*)resizeImage:(UIImage*)image WithSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* imageToUpload = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageToUpload;
}

-(void)createPost:(GLPPost*)post
{
//    [WebClientHelper showStandardLoaderWithTitle:@"Creating post" forView:self];
//    
//    [[WebClient sharedInstance] createPost:post callbackBlock:^(BOOL success) {
//        
//        [WebClientHelper hideStandardLoaderForView:self];
//        
//        if(success)
//        {
//            
//            [self removeView];
//        } else
//        {
//            [WebClientHelper showStandardError];
//            [self.commentTextView becomeFirstResponder];
//        }
//    }];
//    
}
-(void) cancelPushed: (id)sender
{
    NSLog(@"Cancel Pushed");
    
    UIView *superView = [self superview];
	[super removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self  name:UIKeyboardWillShowNotification object:nil];
    
    
    
    // Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	
	[[superView layer] addAnimation:animation forKey:@"layerAnimation"];
    
    visibility = NO;

}


+ (id)loadingViewInView:(UIView *)aSuperview
{
	NewPostView *loadingView = [[NewPostView alloc] initWithFrame:[aSuperview bounds]];
	if (!loadingView)
	{
        NSLog(@"Loading View nill");
		return nil;
	}
	
	loadingView.opaque = NO;
	loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[aSuperview addSubview:loadingView];
    
	// Set up the fade-in animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];
    
    visibility = YES;
	
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
    visibility = NO;
    

}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    const CGFloat RECT_PADDING = 10.0;
	rect = CGRectInset(rect, RECT_PADDING, RECT_PADDING);
    
    rect = CGRectMake(0, 63.0, 320, 640);
	
	const CGFloat ROUND_RECT_CORNER_RADIUS = 0.0;
	CGPathRef roundRectPath = [self newPathWithRoundRect:rect withCorner:ROUND_RECT_CORNER_RADIUS];
    
    
    
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	const CGFloat BACKGROUND_OPACITY = 0.75;
	CGContextSetRGBFillColor(context, 0, 0, 0, BACKGROUND_OPACITY);
	CGContextAddPath(context, roundRectPath);
	CGContextFillPath(context);
    
	const CGFloat STROKE_OPACITY = 0.25;
	CGContextSetRGBStrokeColor(context, 1, 1, 1, STROKE_OPACITY);
	CGContextAddPath(context, roundRectPath);
	CGContextStrokePath(context);
	
	CGPathRelease(roundRectPath);
}

- (void)singleTapRecognized:(UIGestureRecognizer *)gestureRecognizer
{
    
    if([self.commentTextView.text isEqualToString:@""])
    {
        
        NSLog(@"Close");
        [self cancelPushed:nil];
    
        
    }
    else
    {
        NSLog(@"Remain");
    }
    
}

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)in
{
    self.imagePosted = YES;
    
    self.uploadedImage.image = photo;
}

-(void)takeController:(FDTakeController *)controller didCancelAfterAttempting:(BOOL)madeAttempt
{
    [self.commentTextView becomeFirstResponder];

}

-(void)takeController:(FDTakeController *)controller didFailAfterAttempting:(BOOL)madeAttempt
{
    [self.commentTextView becomeFirstResponder];
    
}

- (IBAction)addImage:(id)sender
{
    
    [self.fdTakeController takePhotoOrChooseFromLibrary];
    [self.commentTextView becomeFirstResponder];

    
    
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

+(BOOL)visible
{
    return visibility;
}
+(void) setVisibility:(BOOL)vis
{
    visibility = vis;
}


@end
