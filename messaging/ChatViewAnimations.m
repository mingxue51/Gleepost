//
//  ChatViewAnimations.m
//  Gleepost
//
//  Created by Σιλουανός on 8/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ChatViewAnimations.h"
#import "GLPConversation.h"
#import "GLPConversationPictureImageView.h"
#import <QuartzCore/QuartzCore.h>


const int higherLimit = 50;
const int lowerLimit = 220;


@interface ChatViewAnimations()

@property (strong, nonatomic) NSMutableArray *conversationPictureImageViews;

@end

@implementation ChatViewAnimations

@synthesize conversations=_conversations;
@synthesize conversationPictureImageViews=_conversationPictureImageViews;

static BOOL initLiveChats;


+(BOOL) showLiveChat
{
    return initLiveChats;
}

+(void) setLiveChat:(BOOL)boolValue
{
    initLiveChats = boolValue;
}

//+(id) initAnimations
//{
//    if(!self)
//    {
//        return self;
//    }
//    
//    //Initialise animation elements.
//    
//    
//    
//    return self;
//}

-(void) initAnimations
{
    //Remove all suviews and initialise all again.
    
    
    [self initialiseCircles];

    [self initialiseLiveConversationBubbles];

    [self setBackgroundImage];
    [self initialiseScrollView];
    [self setUpTimers];
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gleepost1"]]];
        
        [self initialiseCircles];
        
//        if([ChatViewAnimations showLiveChat])
//        {
//            NSLog(@"Live Chat Initialised.");
            //[self initialiseLiveConversationBubbles];
//        }
        
        [self initialiseLiveConversationBubbles];
        
        [self setBackgroundImage];
        [self initialiseScrollView];
        [self setUpTimers];
        
       animationsFinished = NO;
  
    }
    return self;
}



-(void) initialiseBubbles
{
    [self initialiseCircles];
    [self setBackgroundImage];
    [self initialiseScrollView];
    [self setUpTimers];
    
    animationsFinished = NO;

}

/**
 Refresh live conversations bubbles.
 */
-(void) refreshLiveConversations: (NSMutableArray*) liveConversationsArray
{
    _conversations = liveConversationsArray;
    
    int i=0;
    for(GLPConversation *conv in liveConversationsArray) {
        GLPConversationPictureImageView *currentImageView = _conversationPictureImageViews[i];
        [currentImageView configureWithConversation:conv];
        
        [[currentImageView layer] setBorderWidth:2.0f];
        [[currentImageView layer] setBorderColor:[UIColor whiteColor].CGColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigateToChat:)];
        [tap setNumberOfTapsRequired:1];
        [currentImageView addGestureRecognizer:tap];
        
        ++i;
    }
}


/**
 Find the three live chat buttons and return them in an array.
 
 @return an array of UIButtons.
 
 */
//-(NSMutableArray*) findTheThreeLiveButtonsChats
//{
//    
//    NSArray *allSubviews = self.subviews;
//
//    NSMutableArray* buttons = [[NSMutableArray alloc] init];
//    
//    for(UIView* view in allSubviews)
//    {
//        if(view.tag == 10 || view.tag == 20 || view.tag == 30)
//        {
//            [buttons addObject:(UIImageView*)view];
//        }
//    }
//    
//    return buttons;
//}

-(void) navigateToChat: (id) sender
{
    
    UITapGestureRecognizer *incomingGesture = (UITapGestureRecognizer*) sender;
    
    UIImageView *imageView = (UIImageView*) incomingGesture.view;
    
    NSLog(@"Button with tag: %d",imageView.tag);
    
    NSLog(@"Navigate to chat");
    
    
    [self.chatViewController navigateToLiveChatWithIndex:(imageView.tag/10)-1];

}


-(void) initialiseLiveConversationBubbles
{
    self.bubblesPeople = [[NSMutableArray alloc] init];
    _conversationPictureImageViews = [[NSMutableArray alloc] init];
    
    for(int i = 0; i<3; ++i) {
        GLPConversationPictureImageView *convImageView = [[GLPConversationPictureImageView alloc] init];
        
        switch (i) {
            case 0:
                convImageView.frame = CGRectMake(60+i*80, 135, 50, 50);
                break;
            case 1:
                convImageView.frame = CGRectMake(135, 115, 50, 50);
                break;
            case 2:
                convImageView.frame = CGRectMake(210, 135, 50, 50);
                break;
        }
        
        [convImageView configureWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"whiteholder%d",i+1]]];
        
        [self addSubview:convImageView];
        [self bringSubviewToFront:convImageView];
        
        [_conversationPictureImageViews addObject:convImageView];
    }
}


-(void) removeElements
{
    animateBubbles = YES;
}


-(void) initialiseScrollView
{
    self.pullDownScrollView = [[PullDownScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.pullDownScrollView setChatViewAnimations:self];
    
    [self addSubview:self.pullDownScrollView];
}



-(void) initialiseCircles
{

    UIImage *centralCircleImage = [UIImage imageNamed:@"lightbublle"] ;
    self.centralCircle = [[UIImageView alloc] initWithImage:centralCircleImage highlightedImage:nil];
    CGSize sizeOfCircleImage = centralCircleImage.size;
    
    [self.centralCircle setFrame:CGRectMake((self.frame.size.width/2)-(sizeOfCircleImage.width/7.5), (self.frame.size.height/2)-(sizeOfCircleImage.height/7.5), sizeOfCircleImage.width/3.5, sizeOfCircleImage.height/3.5)];
    
    
    
    [self addSubview:self.centralCircle];
    
    [self addBublesImageViews];
    
    [self addArrayToView];
    

}

-(void) addArrayToView
{
    for(UIImageView *imageView in self.bubblesOnTheScreen)
    {
        [self addSubview:imageView];
    }
    
    for(UIImageView *imageView in self.bubblesOffTheScreen)
    {
        [self addSubview:imageView];
    }
}

-(void) setUpTimers
{
    self.timer1 = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(animateCircles:) userInfo:nil repeats:YES];
    [self.timer1 fire];
    
    self.timer2 = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(animateCircles2:) userInfo:nil repeats:YES];
    [self.timer2 fire];
    
}

static BOOL goBack = NO;
static BOOL goBack2 = NO;

-(void) animateCircles: (id)sender
{
    
    //TODO: Add iOS7 effect on bubbles.
    
    // Set vertical effect
//    UIInterpolatingMotionEffect *verticalMotionEffect =
//    [[UIInterpolatingMotionEffect alloc]
//     initWithKeyPath:@"center.y"
//     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
//    verticalMotionEffect.minimumRelativeValue = @(-10);
//    verticalMotionEffect.maximumRelativeValue = @(10);
//    
//    
//    // Set horizontal effect
//    UIInterpolatingMotionEffect *horizontalMotionEffect =
//    [[UIInterpolatingMotionEffect alloc]
//     initWithKeyPath:@"center.x"
//     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
//    horizontalMotionEffect.minimumRelativeValue = @(-10);
//    horizontalMotionEffect.maximumRelativeValue = @(10);
//    
//    // Create group to combine both
//    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
//    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    // Add both effects to your view
//    [self addMotionEffect:group];
    
    srand(time(0));
    
    NSMutableArray *halfCircleElements = [[NSMutableArray alloc] init];
    
    for(int i=0; i<self.bubblesOnTheScreen.count; ++i)
    {
        if(i > self.bubblesOnTheScreen.count/2-1)
        {
            break;
        }
        else
        {
            [halfCircleElements addObject:[self.bubblesOnTheScreen objectAtIndex:i]];
        }
    }
    
    
    for(UIImageView *imageView in halfCircleElements)
    {
        [UIView animateWithDuration:2.5 animations:^{
            
            if(goBack)
            {
                //[imageView addMotionEffect:group];
                
                int rX = rand() % 20;
                int rY = rand() % 20;
                
                rX-=10;
                rY-=10;
                
                if([self isImageInTheLimit:imageView.frame.origin.y-rY])
                {
                    [imageView setFrame: CGRectMake(imageView.frame.origin.x+rX,imageView.frame.origin.y-rY , imageView.image.size.width/2, imageView.image.size.height/2)];
                }
                
            }
            else
            {

                
                
               // [imageView setBounds: CGRectMake(imageView.frame.origin.x+10,imageView.frame.origin.y+5 , imageView.image.size.width/2, imageView.image.size.height/2)];
                
        
                /**
                 
                 // Image to be rotated (in this case, found in the project as "/Assets/Images/loading_icon.png").
                 
                 UIImageView someImageView = new UIImageView(UIImage.FromBundle("Assets/Images/loading_icon"));
                 CABasicAnimation rotationAnimation = CABasicAnimation.FromKeyPath("transform.rotation");
                 rotationAnimation.To = NSNumber.FromDouble(Math.PI * 2); // full rotation (in radians)
                 rotationAnimation.RepeatCount = int.MaxValue; // repeat forever
                 rotationAnimation.Duration = 1;
                 
                 // Give the added animation a key for referencing it later (to remove, in this case).
                 
                 someImageView.Layer.AddAnimation(rotationAnimation, "rotationAnimation");
                 
                 */
                
                int rX = rand() % 20;
                int rY = rand() % 20;
                
                
                rX-=10;
                rY-=10;
                
                if([self isImageInTheLimit:imageView.frame.origin.y+rY])
                {
                    [imageView setFrame: CGRectMake(imageView.frame.origin.x-rX,imageView.frame.origin.y+rY , imageView.image.size.width/2, imageView.image.size.height/2)];

                }

            }
            
             
        }];
    }
    
    if(goBack)
    {
        goBack = NO;
    }
    else
    {
        goBack = YES;
    }
}

-(void) animateCircles2: (id)sender
{
    srand(time(0));
    
    NSMutableArray *halfCircleElements = [[NSMutableArray alloc] init];
    
    for(int i=self.bubblesOnTheScreen.count-1; i<self.bubblesOnTheScreen.count; --i)
    {
        if(i < self.bubblesOnTheScreen.count/2)
        {
            break;
        }
        else
        {
            [halfCircleElements addObject:[self.bubblesOnTheScreen objectAtIndex:i]];
        }
    }
    
    for(UIImageView *imageView in halfCircleElements)
    {
        [UIView animateWithDuration:2 animations:^{
            
            if(goBack2)
            {
                int rX = rand() % 20;
                int rY = rand() % 20;
                
                rX-=10;
                rY-=10;
                
                if([self isImageInTheLimit:imageView.frame.origin.y-rY])
                {
                    [imageView setFrame: CGRectMake(imageView.frame.origin.x+rX,imageView.frame.origin.y-rY , imageView.image.size.width/2, imageView.image.size.height/2)];
                }
                
                
            }
            else
            {
                int rX = rand() % 20;
                int rY = rand() % 20;
                
                rX-=10;
                rY-=10;
                
                if([self isImageInTheLimit:imageView.frame.origin.y+rY])
                {
                    [imageView setFrame: CGRectMake(imageView.frame.origin.x-rX,imageView.frame.origin.y+rY , imageView.image.size.width/2, imageView.image.size.height/2)];
                }
            }
            
            
        }];
    }
    
    if(goBack2)
    {
        goBack2 = NO;
    }
    else
    {
        goBack2 = YES;
    }

}

/**
 Animates circles in fancy way when the pull down circled pulled.
 Move circles to the big central circle and make bigger the central one.
 */
static float widthLimit = 200;
static BOOL animateBubbles = YES;
-(void) animateCirclesFancy
{

    if(!animateBubbles)
    {
        
        NSLog(@"Animation Finished");
        return;
        
    }
    
    NSLog(@"Animation Started");

    
    CGRect mainCircleFrame = self.centralCircle.frame;
    
    if(mainCircleFrame.size.width > widthLimit) {
        return;
    }
    
    for(UIImageView* btn in _conversationPictureImageViews) {
        [UIView animateWithDuration:1.7 delay:0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
            [btn setAlpha:0.0];
        }completion:^(BOOL finished) {
   
        }];
    }
    
    
    CGSize sizeOfCircleImage = self.centralCircle.frame.size;
    
    //Animate the on screen bubbles.
    
    int i=0;
    for(UIImageView *imageView in self.bubblesOnTheScreen)
    {
        animateBubbles = NO;

        [self animateBubbleWithDuration:1.5 delay:0 imageView:imageView sizeOfCircle:sizeOfCircleImage andMainCircleFrameSize:mainCircleFrame];

        
        [UIView animateWithDuration:2.5 delay:0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
            
            
            [self.pullDownScrollView setAlpha:0.0];
            
        }completion:^(BOOL finished) {
            
            
        }];
        
        /**
         
         [UIView animateWithDuration:1 delay:0 options:(UIViewAnimationOptionCurveEaseIn) animations:^{
         
         
         [self.pullDownScrollView setAlpha:0.0];
         [self.centralCircle setFrame:CGRectMake(mainCircleFrame.origin.x-205, mainCircleFrame.origin.y-190, mainCircleFrame.size.width+400, mainCircleFrame.size.height+400)];
         
         
         }completion:^(BOOL finished) {
         
         }];
         
         */
        
        ++i;
    }
    

    
    //Resize central circle.
    [UIView animateWithDuration:1.5 delay:0 options:(UIViewAnimationOptionCurveLinear) animations:^{
        
        CGRect mainCircleFrame = self.centralCircle.frame;
        
        [self.centralCircle setFrame:CGRectMake(mainCircleFrame.origin.x-150, mainCircleFrame.origin.y-150, mainCircleFrame.size.width+300, mainCircleFrame.size.height+300)];
        
        
        
    }completion:^(BOOL finished) {
        
        [UIView animateWithDuration:1.5 delay:0 options:(UIViewAnimationOptionCurveLinear) animations:^{
            
            CGRect mainCircleFrame = self.centralCircle.frame;
            
            [self.centralCircle setFrame:CGRectMake(mainCircleFrame.origin.x-310, mainCircleFrame.origin.y-300, mainCircleFrame.size.width+600, mainCircleFrame.size.height+600)];
            
        }completion:^(BOOL finished) {
            
            
        }];

        
    }];
    
    //Animate the off screen bubbles.
    
    for(UIImageView *imageView in self.bubblesOffTheScreen)
    {
        [self animateBubbleWithDuration:1.5 delay:0.3 imageView:imageView sizeOfCircle:sizeOfCircleImage andMainCircleFrameSize:mainCircleFrame];
    }
    
    
    
    
    animationsFinished = YES;
}

- (void)earthquake:(UIView*)itemView
{
    CGFloat t = 0.5;
    CGAffineTransform leftQuake  = CGAffineTransformTranslate(CGAffineTransformIdentity, t, -t);
    CGAffineTransform rightQuake = CGAffineTransformTranslate(CGAffineTransformIdentity, -t, t);
    
    itemView.transform = leftQuake;  // starting point
    
    [UIView beginAnimations:@"earthquake" context:(__bridge void *)(itemView)];
    [UIView setAnimationRepeatAutoreverses:YES]; // important
    [UIView setAnimationRepeatCount:4];
    [UIView setAnimationDuration:0.07];
    [UIView setAnimationDelay:0.8];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(earthquakeEnded:finished:context:)];
    
    itemView.transform = rightQuake; // end here & auto-reverse
    
    [UIView commitAnimations];
}

- (void)earthquakeEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([finished boolValue])
    {
        UIView* item = (__bridge UIView *)context;
        item.transform = CGAffineTransformIdentity;
    }
}

/**
 Animate person bubbles from the big circle to out.
 
 @param duration the duration of the animation.
 @param delay the delay of the animation.
 @param imageView the image.
 @param newPosition the new posistion.
 
 */
-(void) animatePersonBubbleWithDuration: (float)duration delay: (float)delay personImageView: (UIImageView*) imageView newPosition:(CGPoint)position
{
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
        
        imageView.hidden = NO;
        
        [imageView setFrame: CGRectMake(position.x, position.y, imageView.image.size.width/2, imageView.image.size.height/2)];
        
    }completion:^(BOOL finished) {
        
        [self earthquake:imageView];
        
        
    }];
}

-(void) animateBubbleWithDuration: (float)duration delay: (float)delay imageView: (UIImageView*) imageView sizeOfCircle: (CGSize)circleSize andMainCircleFrameSize: (CGRect)mainCircleFrame
{
    

    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
        
        [imageView setFrame: CGRectMake((self.frame.size.width/2)-(circleSize.width/7.5), (self.frame.size.height/2)-(circleSize.height/3.5), imageView.image.size.width/2, imageView.image.size.height/2)];
        


    }completion:^(BOOL finished) {
        
        

        [imageView setAlpha:0.0];
        
    }];

}

-(void) hideBubbles
{
    for(UIImageView *imageView in self.bubblesOnTheScreen)
    {
        [imageView setAlpha:0.0];
    }
}


/**
 
 Checks the limitation of the y value.
 
 @param yValue the y value.
 
 @return YES if the yValues belongs to the limit.
 
 */
-(BOOL) isImageInTheLimit: (int) yValue
{
   // NSLog(@"yValue: %d", yValue);
    if(yValue<higherLimit || yValue>lowerLimit)
    {
        return NO;
    }
    
    return YES;
}

-(void) addBublesImageViews
{
    UIImageView *littleBubble = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble1"]];
    [littleBubble setFrame:CGRectMake(70, 100, [UIImage imageNamed:@"bubble1"].size.width/2, [UIImage imageNamed:@"bubble1"].size.height/2)];
    
    UIImageView *littleBubble2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble2"]];
    [littleBubble2 setFrame:CGRectMake(30, 220, [UIImage imageNamed:@"bubble2"].size.width/2, [UIImage imageNamed:@"bubble2"].size.height/2)];
    
    UIImageView *littleBubble3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble3"]];
    [littleBubble3 setFrame:CGRectMake(150, 200, [UIImage imageNamed:@"bubble3"].size.width/2, [UIImage imageNamed:@"bubble3"].size.height/2)];
    
    UIImageView *littleBubble4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble4"]];
    [littleBubble4 setFrame:CGRectMake(200, 200, [UIImage imageNamed:@"bubble4"].size.width/2, [UIImage imageNamed:@"bubble4"].size.height/2)];
    
    UIImageView *littleBubble5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble5"]];
    [littleBubble5 setFrame:CGRectMake(200, 70, [UIImage imageNamed:@"bubble5"].size.width/2, [UIImage imageNamed:@"bubble5"].size.height/2)];
    
    
    

    
    self.bubblesOnTheScreen = [[NSMutableArray alloc] init];
    self.bubblesOffTheScreen = [[NSMutableArray alloc] init];
    
    [self.bubblesOnTheScreen addObject:littleBubble];
    [self.bubblesOnTheScreen addObject:littleBubble2];
    [self.bubblesOnTheScreen addObject:littleBubble3];
    [self.bubblesOnTheScreen addObject:littleBubble4];
    [self.bubblesOnTheScreen addObject:littleBubble5];
    
    
    //Repeat the images and change the positiong of them.
    
    
    littleBubble = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble1"]];
    [littleBubble setFrame:CGRectMake(170, 100, [UIImage imageNamed:@"bubble1"].size.width/2, [UIImage imageNamed:@"bubble1"].size.height/2)];
    
    littleBubble2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble2"]];
    [littleBubble2 setFrame:CGRectMake(130, 50, [UIImage imageNamed:@"bubble2"].size.width/2, [UIImage imageNamed:@"bubble2"].size.height/2)];
    
    littleBubble3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble3"]];
    [littleBubble3 setFrame:CGRectMake(200, 200, [UIImage imageNamed:@"bubble3"].size.width/2, [UIImage imageNamed:@"bubble3"].size.height/2)];
    
    littleBubble4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble4"]];
    [littleBubble4 setFrame:CGRectMake(300, 200, [UIImage imageNamed:@"bubble4"].size.width/2, [UIImage imageNamed:@"bubble4"].size.height/2)];
    
    littleBubble5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble5"]];
    [littleBubble5 setFrame:CGRectMake(250, 80, [UIImage imageNamed:@"bubble5"].size.width/2, [UIImage imageNamed:@"bubble5"].size.height/2)];
    
    
    [self.bubblesOnTheScreen addObject:littleBubble];
    [self.bubblesOnTheScreen addObject:littleBubble2];
    [self.bubblesOnTheScreen addObject:littleBubble3];
    [self.bubblesOnTheScreen addObject:littleBubble4];
    [self.bubblesOnTheScreen addObject:littleBubble5];
    
    
    littleBubble = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble1"]];
    [littleBubble setFrame:CGRectMake(190, 120, [UIImage imageNamed:@"bubble1"].size.width/2, [UIImage imageNamed:@"bubble1"].size.height/2)];
    
    littleBubble2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble2"]];
    [littleBubble2 setFrame:CGRectMake(30, 50, [UIImage imageNamed:@"bubble2"].size.width/2, [UIImage imageNamed:@"bubble2"].size.height/2)];
    
    littleBubble3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble3"]];
    [littleBubble3 setFrame:CGRectMake(59, 200, [UIImage imageNamed:@"bubble3"].size.width/2, [UIImage imageNamed:@"bubble3"].size.height/2)];
    
    littleBubble4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble4"]];
    [littleBubble4 setFrame:CGRectMake(300, 80, [UIImage imageNamed:@"bubble4"].size.width/2, [UIImage imageNamed:@"bubble4"].size.height/2)];
    
    littleBubble5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble5"]];
    [littleBubble5 setFrame:CGRectMake(200, 40, [UIImage imageNamed:@"bubble5"].size.width/2, [UIImage imageNamed:@"bubble5"].size.height/2)];
    
    
    [self.bubblesOnTheScreen addObject:littleBubble];
    [self.bubblesOnTheScreen addObject:littleBubble2];
    [self.bubblesOnTheScreen addObject:littleBubble3];
    [self.bubblesOnTheScreen addObject:littleBubble4];
    [self.bubblesOnTheScreen addObject:littleBubble5];
    
    
    littleBubble = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble1"]];
    [littleBubble setFrame:CGRectMake(300, 120, [UIImage imageNamed:@"bubble1"].size.width/2, [UIImage imageNamed:@"bubble1"].size.height/2)];
    
    littleBubble2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble2"]];
    [littleBubble2 setFrame:CGRectMake(250, 50, [UIImage imageNamed:@"bubble2"].size.width/2, [UIImage imageNamed:@"bubble2"].size.height/2)];
    
    littleBubble3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble3"]];
    [littleBubble3 setFrame:CGRectMake(200, 100, [UIImage imageNamed:@"bubble3"].size.width/2, [UIImage imageNamed:@"bubble3"].size.height/2)];
    
    littleBubble4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble4"]];
    [littleBubble4 setFrame:CGRectMake(220, 80, [UIImage imageNamed:@"bubble4"].size.width/2, [UIImage imageNamed:@"bubble4"].size.height/2)];
    
    littleBubble5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble5"]];
    [littleBubble5 setFrame:CGRectMake(240, 40, [UIImage imageNamed:@"bubble5"].size.width/2, [UIImage imageNamed:@"bubble5"].size.height/2)];
    
    
    [self.bubblesOnTheScreen addObject:littleBubble];
    [self.bubblesOnTheScreen addObject:littleBubble2];
    [self.bubblesOnTheScreen addObject:littleBubble3];
    [self.bubblesOnTheScreen addObject:littleBubble4];
    [self.bubblesOnTheScreen addObject:littleBubble5];
    
    littleBubble3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble3"]];
    [littleBubble3 setFrame:CGRectMake(59, 250, [UIImage imageNamed:@"bubble3"].size.width/2, [UIImage imageNamed:@"bubble3"].size.height/2)];
    
    [self.bubblesOnTheScreen addObject:littleBubble3];
    
    littleBubble3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble3"]];
    [littleBubble3 setFrame:CGRectMake(98, 79, [UIImage imageNamed:@"bubble3"].size.width/2, [UIImage imageNamed:@"bubble3"].size.height/2)];
    
    [self.bubblesOnTheScreen addObject:littleBubble3];
    
    littleBubble3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble3"]];
    [littleBubble3 setFrame:CGRectMake(120, 39, [UIImage imageNamed:@"bubble3"].size.width/2, [UIImage imageNamed:@"bubble3"].size.height/2)];
    
    [self.bubblesOnTheScreen addObject:littleBubble3];
    
    
    //Add not appeard bubbles.
    littleBubble = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble1"]];
    [littleBubble setFrame:CGRectMake(190, -120, [UIImage imageNamed:@"bubble1"].size.width/2, [UIImage imageNamed:@"bubble1"].size.height/2)];
    
    littleBubble2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble2"]];
    [littleBubble2 setFrame:CGRectMake(30, -100, [UIImage imageNamed:@"bubble2"].size.width/2, [UIImage imageNamed:@"bubble2"].size.height/2)];
    
    littleBubble3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble3"]];
    [littleBubble3 setFrame:CGRectMake(59, -500, [UIImage imageNamed:@"bubble3"].size.width/2, [UIImage imageNamed:@"bubble3"].size.height/2)];
    
    littleBubble4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble4"]];
    [littleBubble4 setFrame:CGRectMake(-300, -800, [UIImage imageNamed:@"bubble4"].size.width/2, [UIImage imageNamed:@"bubble4"].size.height/2)];
    
    littleBubble5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble5"]];
    [littleBubble5 setFrame:CGRectMake(200, -250, [UIImage imageNamed:@"bubble5"].size.width/2, [UIImage imageNamed:@"bubble5"].size.height/2)];
    
    
    [self.bubblesOffTheScreen addObject:littleBubble];
    [self.bubblesOffTheScreen addObject:littleBubble2];
    [self.bubblesOffTheScreen addObject:littleBubble3];
    [self.bubblesOffTheScreen addObject:littleBubble4];
    [self.bubblesOffTheScreen addObject:littleBubble5];
    
    
    littleBubble = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble1"]];
    [littleBubble setFrame:CGRectMake(100, -150, [UIImage imageNamed:@"bubble1"].size.width/2, [UIImage imageNamed:@"bubble1"].size.height/2)];
    
    littleBubble2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble2"]];
    [littleBubble2 setFrame:CGRectMake(80, -80, [UIImage imageNamed:@"bubble2"].size.width/2, [UIImage imageNamed:@"bubble2"].size.height/2)];
    
    littleBubble3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble3"]];
    [littleBubble3 setFrame:CGRectMake(-700, -800, [UIImage imageNamed:@"bubble3"].size.width/2, [UIImage imageNamed:@"bubble3"].size.height/2)];
    
    littleBubble4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble4"]];
    [littleBubble4 setFrame:CGRectMake(-300, -600, [UIImage imageNamed:@"bubble4"].size.width/2, [UIImage imageNamed:@"bubble4"].size.height/2)];
    
    littleBubble5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble5"]];
    [littleBubble5 setFrame:CGRectMake(-400, -250, [UIImage imageNamed:@"bubble5"].size.width/2, [UIImage imageNamed:@"bubble5"].size.height/2)];
    
    [self.bubblesOffTheScreen addObject:littleBubble];
    [self.bubblesOffTheScreen addObject:littleBubble2];
    [self.bubblesOffTheScreen addObject:littleBubble3];
    [self.bubblesOffTheScreen addObject:littleBubble4];
    [self.bubblesOffTheScreen addObject:littleBubble5];
    
    
    
    littleBubble = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble1"]];
    [littleBubble setFrame:CGRectMake(355, -250, [UIImage imageNamed:@"bubble1"].size.width/2, [UIImage imageNamed:@"bubble1"].size.height/2)];
    
    littleBubble2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble2"]];
    [littleBubble2 setFrame:CGRectMake(320, -80, [UIImage imageNamed:@"bubble2"].size.width/2, [UIImage imageNamed:@"bubble2"].size.height/2)];
    
    littleBubble3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble3"]];
    [littleBubble3 setFrame:CGRectMake(320, -800, [UIImage imageNamed:@"bubble3"].size.width/2, [UIImage imageNamed:@"bubble3"].size.height/2)];
    
    littleBubble4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble4"]];
    [littleBubble4 setFrame:CGRectMake(320, -600, [UIImage imageNamed:@"bubble4"].size.width/2, [UIImage imageNamed:@"bubble4"].size.height/2)];
    
    littleBubble5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble5"]];
    [littleBubble5 setFrame:CGRectMake(320, -250, [UIImage imageNamed:@"bubble5"].size.width/2, [UIImage imageNamed:@"bubble5"].size.height/2)];
    
    [self.bubblesOffTheScreen addObject:littleBubble];
    [self.bubblesOffTheScreen addObject:littleBubble2];
    [self.bubblesOffTheScreen addObject:littleBubble3];
    [self.bubblesOffTheScreen addObject:littleBubble4];
    [self.bubblesOffTheScreen addObject:littleBubble5];
    
    
    
    littleBubble = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble1"]];
    [littleBubble setFrame:CGRectMake(-200, -200, [UIImage imageNamed:@"bubble1"].size.width/2, [UIImage imageNamed:@"bubble1"].size.height/2)];
    
    littleBubble2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble2"]];
    [littleBubble2 setFrame:CGRectMake(50, -200, [UIImage imageNamed:@"bubble2"].size.width/2, [UIImage imageNamed:@"bubble2"].size.height/2)];
    
    littleBubble3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble3"]];
    [littleBubble3 setFrame:CGRectMake(150, -800, [UIImage imageNamed:@"bubble3"].size.width/2, [UIImage imageNamed:@"bubble3"].size.height/2)];
    
    littleBubble4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble4"]];
    [littleBubble4 setFrame:CGRectMake(200, -600, [UIImage imageNamed:@"bubble4"].size.width/2, [UIImage imageNamed:@"bubble4"].size.height/2)];
    
    littleBubble5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble5"]];
    [littleBubble5 setFrame:CGRectMake(320, -1000, [UIImage imageNamed:@"bubble5"].size.width/2, [UIImage imageNamed:@"bubble5"].size.height/2)];
    
    [self.bubblesOffTheScreen addObject:littleBubble];
    [self.bubblesOffTheScreen addObject:littleBubble2];
    [self.bubblesOffTheScreen addObject:littleBubble3];
    [self.bubblesOffTheScreen addObject:littleBubble4];
    [self.bubblesOffTheScreen addObject:littleBubble5];
    
    
    
    
    littleBubble = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble1"]];
    [littleBubble setFrame:CGRectMake(-200, -260, [UIImage imageNamed:@"bubble1"].size.width/2, [UIImage imageNamed:@"bubble1"].size.height/2)];
    
    littleBubble2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble2"]];
    [littleBubble2 setFrame:CGRectMake(50, -260, [UIImage imageNamed:@"bubble2"].size.width/2, [UIImage imageNamed:@"bubble2"].size.height/2)];
    
    littleBubble3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble3"]];
    [littleBubble3 setFrame:CGRectMake(150, -860, [UIImage imageNamed:@"bubble3"].size.width/2, [UIImage imageNamed:@"bubble3"].size.height/2)];
    
    littleBubble4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble4"]];
    [littleBubble4 setFrame:CGRectMake(200, -660, [UIImage imageNamed:@"bubble4"].size.width/2, [UIImage imageNamed:@"bubble4"].size.height/2)];
    
    littleBubble5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble5"]];
    [littleBubble5 setFrame:CGRectMake(320, -1060, [UIImage imageNamed:@"bubble5"].size.width/2, [UIImage imageNamed:@"bubble5"].size.height/2)];
    
    [self.bubblesOffTheScreen addObject:littleBubble];
    [self.bubblesOffTheScreen addObject:littleBubble2];
    [self.bubblesOffTheScreen addObject:littleBubble3];
    [self.bubblesOffTheScreen addObject:littleBubble4];
    [self.bubblesOffTheScreen addObject:littleBubble5];
    
    
    littleBubble = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble1"]];
    [littleBubble setFrame:CGRectMake(-289, -200, [UIImage imageNamed:@"bubble1"].size.width/2, [UIImage imageNamed:@"bubble1"].size.height/2)];
    
    littleBubble2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble2"]];
    [littleBubble2 setFrame:CGRectMake(139, -200, [UIImage imageNamed:@"bubble2"].size.width/2, [UIImage imageNamed:@"bubble2"].size.height/2)];
    
    littleBubble3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble3"]];
    [littleBubble3 setFrame:CGRectMake(239, -800, [UIImage imageNamed:@"bubble3"].size.width/2, [UIImage imageNamed:@"bubble3"].size.height/2)];
    
    littleBubble4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble4"]];
    [littleBubble4 setFrame:CGRectMake(289, -600, [UIImage imageNamed:@"bubble4"].size.width/2, [UIImage imageNamed:@"bubble4"].size.height/2)];
    
    littleBubble5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble5"]];
    [littleBubble5 setFrame:CGRectMake(409, -1000, [UIImage imageNamed:@"bubble5"].size.width/2, [UIImage imageNamed:@"bubble5"].size.height/2)];
    
    [self.bubblesOffTheScreen addObject:littleBubble];
    [self.bubblesOffTheScreen addObject:littleBubble2];
    [self.bubblesOffTheScreen addObject:littleBubble3];
    [self.bubblesOffTheScreen addObject:littleBubble4];
    [self.bubblesOffTheScreen addObject:littleBubble5];
}

-(void) setBackgroundImage
{
    self.backgroundColor = [UIColor clearColor];
    
    UIImage *newChatImage = [UIImage imageNamed:@"new_chat_background"];
    
    UIImageView *backgroundImage = [[UIImageView alloc] init];
    
    [backgroundImage setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    backgroundImage.image = newChatImage;
    
    [self addSubview:backgroundImage];
    [self sendSubviewToBack:backgroundImage];
}

//TODO: The method is not used.
//- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat
//{
//    CABasicAnimation* rotationAnimation;
//    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
//    rotationAnimation.duration = duration;
//    rotationAnimation.cumulative = YES;
//    rotationAnimation.repeatCount = repeat;
//    
//    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
//}

-(void) navigateToNewRandomChat
{
    [self.chatViewController searchForConversationForGroup:NO];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    NSLog(@"drawRect");
}


@end
