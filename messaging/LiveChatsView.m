//
//  LiveChatsView.m
//  Gleepost
//
//  Created by Σιλουανός on 22/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "LiveChatsView.h"
#import "GLPLiveConversationsManager.h"
#import "GLPConversationPictureImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface LiveChatsView ()

@property (strong, nonatomic) NSMutableArray *conversationPictureImageViews;

@end


@implementation LiveChatsView

@synthesize conversationPictureImageViews=_conversationPictureImageViews;

static BOOL visibility;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _conversationPictureImageViews = [NSMutableArray arrayWithCapacity:3];
        
        [self createConversationPictureWithFrame:CGRectMake(42.5, 12.5, 45, 45) holder:@"whiteholder1"];
        [self createConversationPictureWithFrame:CGRectMake(12.5, 72.5, 45, 45) holder:@"whiteholder2"];
        [self createConversationPictureWithFrame:CGRectMake(72.5, 72.5, 45, 45) holder:@"whiteholder3"];
        
        [self setLiveChatsToView];
    }
    return self;
}

- (void)createConversationPictureWithFrame:(CGRect)frame holder:(NSString *)holder
{
    GLPConversationPictureImageView *imageView = [[GLPConversationPictureImageView alloc] initWithFrame:frame];
    imageView.image = [UIImage imageNamed:holder];
    imageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigateToChat:)];
    [imageView addGestureRecognizer:tap];
    
    [self addSubview:imageView];
    [_conversationPictureImageViews addObject:imageView];
}

-(void)setLiveChatsToView
{
//    int i = 0;
//    for(GLPConversation *c in [[GLPLiveConversationsManager sharedInstance] getConversations]) {
//        
//        GLPConversationPictureImageView *imageView = _conversationPictureImageViews[i];
//        [imageView configureWithConversation:c];
//        
//        imageView.clipsToBounds = YES;
//        imageView.layer.cornerRadius = 23;
//        
//        [[imageView layer] setBorderWidth:2.0f];
//        [[imageView layer] setBorderColor:[UIColor whiteColor].CGColor];
//
//        ++i;
//    }
}

-(void) navigateToChat: (id)sender
{
    UITapGestureRecognizer *incomingUser = (UITapGestureRecognizer*) sender;
    GLPConversationPictureImageView *imageView = (GLPConversationPictureImageView *)incomingUser.view;
    
    GLPConversation *conversation = [[GLPLiveConversationsManager sharedInstance] findByRemoteKey:imageView.conversationRemoteKey];
    
    if(conversation) {
        self.viewTopic.conversation = conversation;
        [self.viewTopic reloadElements];
        [self removeView];
    } else {
        [self removeView];
    }
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
