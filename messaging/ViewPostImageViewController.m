//
//  ViewPostImageViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 6/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//
//  This class should not be used. Instead use GLPViewImageViewController.

#import "ViewPostImageViewController.h"
#import "GLPiOSSupportHelper.h"

#define SWIPE_UP_THRESHOLD 20.0f
#define SWIPE_DOWN_THRESHOLD 650.0f
#define SWIPE_LEFT_THRESHOLD 40.0f
#define SWIPE_RIGHT_THRESHOLD 280.0f

@interface ViewPostImageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *viewImage;
@property (assign, nonatomic) CGFloat previousScale;
@property (assign, nonatomic) CGFloat scale;

@end

@implementation ViewPostImageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scale = 1.0f;
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.67]];
	[self.viewImage setImage:self.image];
    
    
    [self setupRecognizers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self hideNetworkErrorViewIfNeeded];
}

#pragma mark - Initialisers

- (void)setupRecognizers
{
    UIPinchGestureRecognizer *pgr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoom:)];
    pgr.delegate = self;
    [self.viewImage addGestureRecognizer:pgr];
    
//    UIPanGestureRecognizer* panSwipeRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanSwipe:)];
//    // Here you can customize for example the minimum and maximum number of fingers required
//    panSwipeRecognizer.minimumNumberOfTouches = 1;
//    [self.viewImage addGestureRecognizer:panSwipeRecognizer];
}

- (void)hideNetworkErrorViewIfNeeded
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_HIDE_ERROR_VIEW object:self userInfo:nil];
}

#pragma mark - Gestures handles

- (void)handlePanSwipe:(UIPanGestureRecognizer*)recognizer
{
    // Get the translation in the view
    CGPoint t = [recognizer translationInView:recognizer.view];
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
    
    self.viewImage.center = CGPointMake(self.viewImage.center.x + t.x, self.viewImage.center.y + t.y);
    
//    CGPoint vel = [recognizer velocityInView:recognizer.view];
    
    // But also, detect the swipe gesture
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint imagePoint = self.viewImage.center;
        
        CGFloat newX = imagePoint.x;
        CGFloat newY = imagePoint.y;
        
        if (self.viewImage.center.x < SWIPE_LEFT_THRESHOLD)
        {
            newX = SWIPE_LEFT_THRESHOLD;
        }
        else if (self.viewImage.center.x > SWIPE_RIGHT_THRESHOLD)
        {
            newX = SWIPE_RIGHT_THRESHOLD;
        }
        
        if (self.viewImage.center.y < SWIPE_UP_THRESHOLD)
        {
            newY = SWIPE_UP_THRESHOLD;
        }
        else if (self.viewImage.center.y > SWIPE_DOWN_THRESHOLD)
        {
            newY = SWIPE_DOWN_THRESHOLD;
        }
        else
        {
            // TODO:
            // Here, the user lifted the finger/fingers but didn't swipe.
            // If you need you can implement a snapping behaviour, where based on the location of your         targetView,
            // you focus back on the targetView or on some next view.
            // It's your call
        }
        
        if(newX != imagePoint.x || newY != imagePoint.y)
        {
            [UIView animateWithDuration:0.5f animations:^{
                
                self.viewImage.center = CGPointMake(newX, newY);
                
            }];
        }
    }
}

-(void)zoom:(UIPinchGestureRecognizer *)gesture
{
    
    if ([gesture state] == UIGestureRecognizerStateBegan)
    {
        self.previousScale = self.scale;
    }
    
    CGFloat currentScale = MAX(MIN([gesture scale] * self.scale, 5.0), 0.9);
    CGFloat scaleStep = currentScale / self.previousScale;
    
    [self.viewImage setTransform: CGAffineTransformScale(self.viewImage.transform, scaleStep, scaleStep)];
    
    self.previousScale = currentScale;
    
    if ([gesture state] == UIGestureRecognizerStateEnded ||
        [gesture state] == UIGestureRecognizerStateCancelled ||
        [gesture state] == UIGestureRecognizerStateFailed)
    {
        // Gesture can fail (or cancelled?) when the notification and the object is dragged simultaneously
        self.scale = currentScale;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Selectors

- (IBAction)goBack:(id)sender
{
    if([GLPiOSSupportHelper isIOS6])
    {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    else
    {
        [self.transitioningDelegate animationControllerForDismissedController:self];
        
        [UIView animateWithDuration:0.25 animations:^{
            
            self.view.alpha = 0;
            
        } completion:^(BOOL b){
            
            [self dismissViewControllerAnimated:NO completion:^{
                
            }];
        }];
    }
    
    

}





@end
