//
//  LoginRegisterViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 16/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "LoginRegisterViewController.h"
#import "AppearanceHelper.h"
#import "LoginViewController.h"
#import "CustomPushTransitioningDelegate.h"

@interface LoginRegisterViewController ()

@property (strong, nonatomic) CustomPushTransitioningDelegate *transitionViewLoginController;
@property (weak, nonatomic) UIViewController *destinationViewController;

@property (weak, nonatomic) IBOutlet UIImageView *backPad;

@end

@implementation LoginRegisterViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Change the colour format of the navigation bar.
    [self.navigationController.navigationBar setTranslucent:YES];
    
    [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar_trans" forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    _destinationViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    
    _transitionViewLoginController = [[CustomPushTransitioningDelegate alloc] initWithFirstController:self andDestinationController:_destinationViewController];
    
    [self setBackground];
    
    [self setImages];
}



- (IBAction)gleepostSignUp:(id)sender
{
    [self performSegueWithIdentifier:@"register" sender:self];
}


- (IBAction)signIn:(id)sender
{
    //LoginViewController
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
//    LoginViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    
//    _destinationViewController.view.backgroundColor = self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
//    _destinationViewController.modalPresentationStyle = UIModalPresentationCustom;
//    
//    [_destinationViewController setTransitioningDelegate:self.transitionViewLoginController];
//    
//    [self.view setBackgroundColor:[UIColor whiteColor]];
//    [self presentViewController:_destinationViewController animated:YES completion:nil];
    [self performSegueWithIdentifier:@"login" sender:self];
    
//    [_backPad setHidden:NO];
//    CGRect frame = _backPad.frame;
//    
//    [UIView animateWithDuration:2.0f animations:^{
//        [_backPad setFrame:CGRectMake(0, frame.origin.y, frame.size.width, frame.size.height)];
//
//    } completion:^(BOOL finished) {
//        
//    }];
    
    
}

-(void)setImages
{
    
}

-(void) setBackground
{
    self.view.backgroundColor = [UIColor clearColor];
    
    UIImage *newChatImage = [UIImage imageNamed:@"loginnew2"];
    
    UIImageView *backgroundImage = [[UIImageView alloc] init];
    
    [backgroundImage setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    backgroundImage.image = newChatImage;
    
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
