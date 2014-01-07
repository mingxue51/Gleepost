//
//  ChatViewAnimationsStanford.m
//  Gleepost
//
//  Created by Σιλουανός on 7/1/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "ChatViewAnimationsStanford.h"



@implementation ChatViewAnimationsStanford

static BOOL goBack = NO;


#pragma mark - Initialisations

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:[UIColor colorWithPatternImage:[ImageFormatterHelper resizeImage:[UIImage imageNamed:@"stanford_new_chat"] withSize:frame.size]]];
        
        [self initObjects];
        
        [self addCloudsImages];
        
        [self addCloudsArrayToView];
        
        [self setUpTimers];
        
    }
    return self;
}

-(void)setUpTimers
{
    self.timer1 = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(animateClouds:) userInfo:nil repeats:YES];
    [self.timer1 fire];
}

-(void)removeElements
{
    [self.timer1 invalidate];
    self.timer1 = nil;
}

-(void)initObjects
{
    self.clouds = [[NSMutableArray alloc] init];
}

-(void)addCloudsImages
{
    UIImageView *cloudSmall = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cloudsmall"]];
    [cloudSmall setFrame:CGRectMake(70, 120, [UIImage imageNamed:@"cloudsmall"].size.width/2, [UIImage imageNamed:@"cloudsmall"].size.height/2)];
    
    UIImageView *cloudMedium = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cloudmedium"]];
    [cloudMedium setFrame:CGRectMake(10, 40, [UIImage imageNamed:@"cloudmedium"].size.width/2, [UIImage imageNamed:@"cloudmedium"].size.height/2)];
    
    UIImageView *cloudBig = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cloudbig"]];
    [cloudBig setFrame:CGRectMake(155, 50, [UIImage imageNamed:@"cloudbig"].size.width/2, [UIImage imageNamed:@"cloudbig"].size.height/2)];
    
    [self.clouds addObject:cloudSmall];
    [self.clouds addObject:cloudMedium];
    [self.clouds addObject:cloudBig];

}

-(void)addCloudsArrayToView
{
    for(UIImageView *imageView in self.clouds)
    {
        [self addSubview:imageView];
    }
}

#pragma mark - Animations

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


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
