//
//  ChatViewAnimations.m
//  Gleepost
//
//  Created by Σιλουανός on 8/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ChatViewAnimations.h"
const int higherLimit = 50;
const int lowerLimit = 220;



@implementation ChatViewAnimations




- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
       
       [self initialiseCircles];
       [self setBackgroundImage];
       [self initialiseScrollView];
       [self setUpTimers];
        
       animationsFinished = NO;
        
        

        
        
       // littleBubble.frame = CGRectMake(20, 20, 20, 20);
        
//        self.cirlcles = [[NSArray alloc] initWithObjects:littleBubble, nil];
        
//        UIImageView *animations = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 500)];
//        
//        
//        animations.animationImages = self.cirlcles;
//        
//        
//        
//        
//        [self addSubview:animations];
//        
        
        
       
        
       // [self addSubview:littleBubble];
        
       // [self runSpinAnimationOnView:littleBubble duration:30 rotations:100 repeat:100];
    }
    return self;
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
    
    NSLog(@"Size of view: %f:%f", self.frame.size.width, self.frame.size.height);
    
    [self.centralCircle setFrame:CGRectMake((self.frame.size.width/2)-(sizeOfCircleImage.width/7.5), (self.frame.size.height/2)-(sizeOfCircleImage.height/4.5), sizeOfCircleImage.width/3.5, sizeOfCircleImage.height/3.5)];
    
    
    
    
    [self addSubview:self.centralCircle];
    
    [self addBublesImageViews];
    [self addArrayToView];
}

-(void) addArrayToView
{
    for(UIImageView *imageView in self.circles)
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
static int prevRandomX;
static int prevRandomY;
-(void) animateCircles: (id)sender
{
    srand(time(0));
    
    NSMutableArray *halfCircleElements = [[NSMutableArray alloc] init];
    
    for(int i=0; i<self.circles.count; ++i)
    {
        if(i > self.circles.count/2-1)
        {
            break;
        }
        else
        {
            [halfCircleElements addObject:[self.circles objectAtIndex:i]];
        }
    }
    
    
    for(UIImageView *imageView in halfCircleElements)
    {
        [UIView animateWithDuration:2.5 animations:^{
            
            if(goBack)
            {

              
                int rX = rand() % 20;
                int rY = rand() % 20;
                
                if([self isImageInTheLimit:imageView.frame.origin.y-rY])
                {
                    [imageView setFrame: CGRectMake(imageView.frame.origin.x+rX,imageView.frame.origin.y-rY , imageView.image.size.width/2, imageView.image.size.height/2)];
                }
               // NSLog(@"Rand: %d : %d",rX, rY);
                
                //imageView.center = CGPointMake(imageView.center.x-rX, imageView.center.y+rY);
                 //= ;
                //imageView.transform = CGAffineTransformRotate(imageView.transform, 30);
                
//                prevRandomX = rX;
//                prevRandomY = rY;
                
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
                
//                int r = rand() % 10;
                
                int rX = rand() % 20;
                int rY = rand() % 20;
                
                if([self isImageInTheLimit:imageView.frame.origin.y+rY])
                {
                    [imageView setFrame: CGRectMake(imageView.frame.origin.x-rX,imageView.frame.origin.y+rY , imageView.image.size.width/2, imageView.image.size.height/2)];

                }
                
//
               // NSLog(@"Pre random X: %d Pre random Y: %d",rX, rY);
                
                //imageView.center = CGPointMake(imageView.center.x+rX,imageView.center.x-rY);
                
                
               // imageView.layer.
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
    
    for(int i=self.circles.count-1; i<self.circles.count; --i)
    {
        if(i < self.circles.count/2)
        {
            break;
        }
        else
        {
            [halfCircleElements addObject:[self.circles objectAtIndex:i]];
        }
    }
    
    for(UIImageView *imageView in halfCircleElements)
    {
        [UIView animateWithDuration:2 animations:^{
            
            if(goBack2)
            {
                int rX = rand() % 20;
                int rY = rand() % 20;
                
                if([self isImageInTheLimit:imageView.frame.origin.y-rY])
                {
                    [imageView setFrame: CGRectMake(imageView.frame.origin.x+rX,imageView.frame.origin.y-rY , imageView.image.size.width/2, imageView.image.size.height/2)];
                }
                
                //NSLog(@"Rand: %d : %d",rX, rY);
                
            }
            else
            {
                int rX = rand() % 20;
                int rY = rand() % 20;
                
                if([self isImageInTheLimit:imageView.frame.origin.y+rY])
                {
                    [imageView setFrame: CGRectMake(imageView.frame.origin.x-rX,imageView.frame.origin.y+rY , imageView.image.size.width/2, imageView.image.size.height/2)];
                }
                //
               // NSLog(@"Pre random X: %d Pre random Y: %d",rX, rY);
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
    
    if(mainCircleFrame.size.width > widthLimit)
    {
        return;
    }
    
    
//    [UIView animateWithDuration:3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        
//                [self.centralCircle setFrame:CGRectMake(mainCircleFrame.origin.x-27, mainCircleFrame.origin.y-25, mainCircleFrame.size.width+50, mainCircleFrame.size.height+50)];
//        
//        
//    } completion:^(BOOL finished) {
//        
//    }];
    
    
//    if(!animateBubbles)
//    {
//        return;
//    }
    
    CGSize sizeOfCircleImage = self.centralCircle.frame.size;
    
    int i=0;
    for(UIImageView *imageView in self.circles)
    {
        animateBubbles = NO;


        if(i%2==0)
        {
            [self animateBubbleWithDuration:1 delay:0 imageView:imageView sizeOfCircle:sizeOfCircleImage andMainCircleFrameSize:mainCircleFrame];
        }
        else
        {
            [self animateBubbleWithDuration:1 delay:0.5 imageView:imageView sizeOfCircle:sizeOfCircleImage andMainCircleFrameSize:mainCircleFrame];
        }
        [UIView animateWithDuration:1.7 animations:^{
        
        [self.centralCircle setFrame:CGRectMake(mainCircleFrame.origin.x-53, mainCircleFrame.origin.y-50, mainCircleFrame.size.width+100, mainCircleFrame.size.height+100)];
        
        }];
        ++i;
        
    }
    
    animationsFinished = YES;
}


-(void) animateBubbleWithDuration: (float)duration delay: (float)delay imageView: (UIImageView*) imageView sizeOfCircle: (CGSize)circleSize andMainCircleFrameSize: (CGRect)mainCircleFrame
{
    

    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
        
        [imageView setFrame: CGRectMake((self.frame.size.width/2)-(circleSize.width/7.5), (self.frame.size.height/2)-(circleSize.height/3.5), imageView.image.size.width/2, imageView.image.size.height/2)];
        


        //(self.frame.size.width/2)-(sizeOfCircleImage.width/7.5), (self.frame.size.height/2)-(sizeOfCircleImage.height/4.5)
    }completion:^(BOOL finished) {
        
       // [self hideBubbles];
        

        
        /**
         
         [UIView animateWithDuration:0.5 animations:^{
         
         [self.centralCircle setFrame:CGRectMake(mainCircleFrame.origin.x-1.7, mainCircleFrame.origin.y-1.5, mainCircleFrame.size.width+5, mainCircleFrame.size.height+5)];
         
         
         } completion:^(BOOL finished) {
         
         }];
         
         */
        
        
        
        //            [self.timer1 invalidate];
        //
        //            [self.timer2 invalidate];
    }];

}

-(void) hideBubbles
{
    for(UIImageView *imageView in self.circles)
    {
        imageView.hidden = YES;
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
    
    
    

    
    self.circles = [[NSMutableArray alloc] init];
    
    [self.circles addObject:littleBubble];
    [self.circles addObject:littleBubble2];
    [self.circles addObject:littleBubble3];
    [self.circles addObject:littleBubble4];
    [self.circles addObject:littleBubble5];
    
    
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
    
    
    [self.circles addObject:littleBubble];
    [self.circles addObject:littleBubble2];
    [self.circles addObject:littleBubble3];
    [self.circles addObject:littleBubble4];
    [self.circles addObject:littleBubble5];
    
    
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
    
    
    [self.circles addObject:littleBubble];
    [self.circles addObject:littleBubble2];
    [self.circles addObject:littleBubble3];
    [self.circles addObject:littleBubble4];
    [self.circles addObject:littleBubble5];
    
    littleBubble3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble3"]];
    [littleBubble3 setFrame:CGRectMake(59, 250, [UIImage imageNamed:@"bubble3"].size.width/2, [UIImage imageNamed:@"bubble3"].size.height/2)];
    
    [self.circles addObject:littleBubble3];
    
    littleBubble3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble3"]];
    [littleBubble3 setFrame:CGRectMake(98, 79, [UIImage imageNamed:@"bubble3"].size.width/2, [UIImage imageNamed:@"bubble3"].size.height/2)];
    
    [self.circles addObject:littleBubble3];
    
    littleBubble3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble3"]];
    [littleBubble3 setFrame:CGRectMake(120, 39, [UIImage imageNamed:@"bubble3"].size.width/2, [UIImage imageNamed:@"bubble3"].size.height/2)];
    
    [self.circles addObject:littleBubble3];
    
    
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
    
    
    [self.circles addObject:littleBubble];
    [self.circles addObject:littleBubble2];
    [self.circles addObject:littleBubble3];
    [self.circles addObject:littleBubble4];
    [self.circles addObject:littleBubble5];
    
    
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
    
    [self.circles addObject:littleBubble];
    [self.circles addObject:littleBubble2];
    [self.circles addObject:littleBubble3];
    [self.circles addObject:littleBubble4];
    [self.circles addObject:littleBubble5];
    
    
    
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
    
    [self.circles addObject:littleBubble];
    [self.circles addObject:littleBubble2];
    [self.circles addObject:littleBubble3];
    [self.circles addObject:littleBubble4];
    [self.circles addObject:littleBubble5];
    
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


- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
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
