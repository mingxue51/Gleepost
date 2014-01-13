//
//  ChatViewAnimationsStanford.m
//  Gleepost
//
//  Created by Σιλουανός on 7/1/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "ChatViewAnimationsStanford.h"
#import "AnimationDayController.h"

@interface ChatViewAnimationsStanford ()

//Elements.
@property (strong, nonatomic) NSMutableArray *clouds;
@property (strong, nonatomic) UIImageView *forground;
@property (strong, nonatomic) UIImageView *sunMoon;
@property (strong, nonatomic) UIImageView *windMillBlades;
@property (strong, nonatomic) UIImageView *windMillPole;
@property (strong, nonatomic) UIImageView *blimp;
@property (strong, nonatomic) UIImageView *balloon;

@property (strong, nonatomic) AnimationDayController *dayController;

@end

@implementation ChatViewAnimationsStanford

static BOOL goBack = NO;


#pragma mark - Initialisations

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.dayController = [AnimationDayController sharedInstance];
        
        
        [self setBackgroundColor:[UIColor colorWithPatternImage:[ImageFormatterHelper resizeImage:[UIImage imageNamed:[self.dayController backgroundImage]] withSize:frame.size]]];

        [self initObjectsWithFrame:frame];
        
        [self addStaticElements];
        
        [self startStandardAnimations];
        
        [self addCloudsImages];
        
        [self setUpTimers];
        
    }
    return self;
}

-(void)initObjectsWithFrame:(CGRect)frame
{
    self.clouds = [[NSMutableArray alloc] init];
    
    
    self.forground = [[UIImageView alloc] initWithImage:[ImageFormatterHelper resizeImage:[UIImage imageNamed:[self.dayController forground]] withSize:frame.size]];
    
    UIImage *sunImage = [UIImage imageNamed:[self.dayController sunMoon]];
    
    self.sunMoon = [[UIImageView alloc] initWithImage:sunImage];
    [self.sunMoon setFrame:CGRectMake(10.0f, 20.0f, sunImage.size.width/2, sunImage.size.height/2)];
    
    UIImage *windPole = [UIImage imageNamed:[self.dayController pole]];
    UIImage *windBlades = [UIImage imageNamed:[self.dayController blades]];
    
    self.windMillPole = [[UIImageView alloc] initWithImage:windPole];
    [self.windMillPole setFrame:CGRectMake(280.0f, 370.0f, windPole.size.width/2, windPole.size.height/2)];
    
    self.windMillBlades = [[UIImageView alloc] initWithImage:windBlades];
    [self.windMillBlades setFrame:CGRectMake(264.0f, 353.0f, windBlades.size.width/2, windBlades.size.height/2)];
    
    
    UIImage *ballonImg = [UIImage imageNamed:[self.dayController balloon]];
    self.balloon = [[UIImageView alloc] initWithImage:ballonImg];
    [self.balloon setFrame:CGRectMake(230.0f, 100.0f, ballonImg.size.width/2, ballonImg.size.height/2)];
    
    UIImage *blimpImg = [UIImage imageNamed:[self.dayController blimp]];
    self.blimp = [[UIImageView alloc] initWithImage:blimpImg];
    [self.blimp setFrame:CGRectMake(320, 100.0f, blimpImg.size.width/2, blimpImg.size.height/2)];
    
    
    
}

-(void)addStaticElements
{
    [self addSubview:self.sunMoon];
    [self addSubview:self.blimp];

    [self addSubview:self.forground];
    [self addSubview:self.windMillPole];
    [self addSubview:self.windMillBlades];
    [self addSubview:self.balloon];
}

-(void)startStandardAnimations
{
    [UIView animateWithDuration:3.0f delay:0.0f options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
        
        [self.sunMoon setFrame:CGRectMake(self.sunMoon.frame.origin.x, self.sunMoon.frame.origin.y, self.sunMoon.frame.size.width-10, self.sunMoon.frame.size.height-10)];
        
    } completion:^(BOOL finished) {
        
    }];
    
    //[self spinWithOptions:UIViewAnimationOptionCurveEaseIn withView:self.sunMoon];

    
    //[self runSpinAnimationOnView:self.windMillBlades duration:4.0f rotations:100.0f];
    [self spinWithOptions:UIViewAnimationOptionCurveEaseIn withView:self.windMillBlades];
    
    [UIView animateWithDuration:5.0f delay:0.0f options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
        
        [self.balloon setFrame:CGRectMake(self.balloon.frame.origin.x, self.balloon.frame.origin.y+20, self.balloon.frame.size.width, self.balloon.frame.size.height)];
        
    } completion:^(BOOL finished){

    }];
    
    [UIView animateWithDuration:20.0f delay:0.0f options:UIViewAnimationOptionRepeat animations:^{
        
        [self.blimp setFrame:CGRectMake(self.blimp.frame.origin.x-550, self.blimp.frame.origin.y, self.blimp.frame.size.width, self.blimp.frame.size.height)];

        
    } completion:^(BOOL finished) {
        
    }];
}

-(void)setUpTimers
{
    self.timer1 = [NSTimer scheduledTimerWithTimeInterval:3.5 target:self selector:@selector(startCloud:) userInfo:nil repeats:YES];
    [self.timer1 fire];
}

-(void)removeElements
{
    [self.timer1 invalidate];
    self.timer1 = nil;
}



-(void)addCloudsImages
{
    UIImage *cloud1Img = [UIImage imageNamed:[self.dayController cloud1]];
    
//    UIImageView *cloudSmall = [[UIImageView alloc] initWithImage:cloud1Img];
//    [cloudSmall setFrame:CGRectMake(70, 120, cloud1Img.size.width/2, cloud1Img.size.height/2)];
    
    UIImage *cloud2Img = [UIImage imageNamed:[self.dayController cloud2]];
    
//    UIImageView *cloudMedium = [[UIImageView alloc] initWithImage:cloud2Img];
//    [cloudMedium setFrame:CGRectMake(10, 40, cloud2Img.size.width/2, cloud2Img.size.height/2)];

    
    UIImage *cloud3Img = [UIImage imageNamed:[self.dayController cloud3]];
    
//    UIImageView *cloudBig = [[UIImageView alloc] initWithImage:cloud3Img];
//    [cloudBig setFrame:CGRectMake(155, 50, cloud3Img.size.width/2, cloud3Img.size.height/2)];
    
    [self.clouds addObject:cloud1Img];
    [self.clouds addObject:cloud2Img];
    [self.clouds addObject:cloud3Img];

}

#pragma mark - Animations

- (void) spinWithOptions: (UIViewAnimationOptions) options withView:(UIView*)view {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         view.transform = CGAffineTransformRotate(view.transform, M_PI / 2);
                     }
                     completion: ^(BOOL finished) {
//                         if (finished) {
//                             if (animating) {
//                                 // if flag still set, keep spinning with constant speed
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear withView:view];
//                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
//                                 // one last spin, with deceleration
//                                 [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
//                             }
//                         }
                     }];
}

- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    
    //[NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration];;
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = INFINITY;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}


/**
 Takes reandomly a new cloud and start the animation of the cloud from right to left.
 */
-(void)startCloud:(id)sender
{
    srand(time(0));
    
    UIImageView *selectedCloud = [self generateCloud];
    
    [self addSubview:selectedCloud];
    [self sendSubviewToBack:selectedCloud];

    [UIView animateWithDuration:30.0 animations:^{

        [selectedCloud setFrame: CGRectMake(-100, selectedCloud.frame.origin.y , selectedCloud.image.size.width/2, selectedCloud.image.size.height/2)];
        
    } completion:^(BOOL finished) {
        
    }];
    
//    NSLog(@"Clound random: %d",cCloud);

}

-(void)animateClouds:(id)sender
{
    srand(time(0));

    
    for(UIImageView *cloud in self.clouds)
    {
        [UIView animateWithDuration:2.5 animations:^{
            
//            int rY = rand() % 20;
            
            if(goBack)
            {
                int rX = rand() % 20;
                rX-=10;


                [cloud setFrame: CGRectMake(cloud.frame.origin.x+rX, cloud.frame.origin.y , cloud.image.size.width/2, cloud.image.size.height/2)];
                
                NSLog(@"Go back: %d - %d",goBack, rX);
            }
            else
            {
                int rX = rand() % 20;
                rX-=10;


                [cloud setFrame: CGRectMake(cloud.frame.origin.x-rX, cloud.frame.origin.y , cloud.image.size.width/2, cloud.image.size.height/2)];
                
                NSLog(@"Go back: %d - %d",goBack, rX);

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

-(UIImageView*)generateCloud
{
    srand(time(0));
    
    //UIImageView *cloudSmall = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cloudsmall"]];
    
    int cloudNumber = rand() % 3;
    
    UIImageView *currentCloud = nil;
    
    
    currentCloud = [[UIImageView alloc] initWithImage:[self.clouds objectAtIndex:cloudNumber]];
    
    int rY = rand() % 400;
    
    rY+=10;
//    rY-=10;
    
    [currentCloud setFrame:CGRectMake(320, rY, currentCloud.frame.size.width/2, currentCloud.frame.size.height/2)];

    return currentCloud;
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
