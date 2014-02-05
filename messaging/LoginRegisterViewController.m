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
#import "RegisterPositionHelper.h"
#import "RegisterView.h"
#import "KeyboardHelper.h"

@interface LoginRegisterViewController ()

@property (strong, nonatomic) CustomPushTransitioningDelegate *transitionViewLoginController;
@property (weak, nonatomic) UIViewController *destinationViewController;

@property (weak, nonatomic) IBOutlet UIImageView *backPad;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIButton *signUpBtn;
@property (weak, nonatomic) IBOutlet UIButton *logInBtn;
@property (weak, nonatomic) IBOutlet UILabel *messageLbl;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (assign, nonatomic) CGRect mainViewFrame;
@property (assign, nonatomic) CGRect mainViewFrameInit;

@property (assign, nonatomic) int currentViewId;

@property (strong, nonatomic) RegisterView *currentView;

@property (assign, nonatomic) float ANIMATION_DURATION;


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
    
    [self initialiseViews];
    
    [self initialiseObjects];
    
    [self loadRegisterViews];
    
    _ANIMATION_DURATION = 0.25;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // keyboard management
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}


-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [super viewDidDisappear:animated];
}

/**
 
 Loads views into the dictionary and numbers them.
 
 */
-(void)loadRegisterViews
{
    
}

-(void)initialiseObjects
{
    _mainViewFrame = _mainView.frame;
    _mainViewFrameInit = _mainView.frame;
    

}

-(void)initialiseViews
{
    [_backBtn setHidden:YES];
    
    _currentViewId = 0;
}

#pragma mark - Fake navigators

- (IBAction)gleepostSignUp:(id)sender
{
    //Animate mainView to the middle of the screen.
//    [self continueToLoginSignUpAnimation];
    
    
    [self performSegueWithIdentifier:@"register" sender:self];
}


- (IBAction)signIn:(id)sender
{
    //LoginViewController
    
    //Load the login view.
    
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"LoginView" owner:self options:nil];
    
    _currentView = [array objectAtIndex:0];
    
    [_currentView setDelegate:self];
    
//    [_currentView becomeFirstFieldFirstResponder];
    
    [_currentView setAlpha:0.0];
    
    [_currentView setFrame:CGRectMake(_mainViewFrame.origin.x, _mainViewFrameInit.origin.y, _mainViewFrame.size.width, _mainViewFrame.size.height)];
    
    
    [self.view addSubview:_currentView];
    

    
    [self continueToLoginSignUpAnimationWithCallbackBlock:^(BOOL finished) {
        
    }];

    
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
//    LoginViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    
//    _destinationViewController.view.backgroundColor = self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
//    _destinationViewController.modalPresentationStyle = UIModalPresentationCustom;
//    
//    [_destinationViewController setTransitioningDelegate:self.transitionViewLoginController];
//    
//    [self.view setBackgroundColor:[UIColor whiteColor]];
//    [self presentViewController:_destinationViewController animated:YES completion:nil];
//    [self performSegueWithIdentifier:@"login" sender:self];
    
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

- (IBAction)goBack:(id)sender
{
    if(_currentViewId == 0 || _currentViewId == 1)
    {
        //Navigate to the first view.
        [self goBackToLoginRegisterAnimation];

    }
    else
    {
        //Navigate back to the previews view.
    }
    
}

#pragma mark - RegisterViewsProtocol delegate

-(void)login
{
    [self performSegueWithIdentifier:@"start" sender:self];
}



#pragma mark - Animations


-(void)continueToLoginSignUpAnimationWithCallbackBlock:(void (^) (BOOL finished))callbackBlock
{
    
    [_backBtn setAlpha:0.0f];
    
    [_backBtn setHidden:NO];

    
    [UIView animateWithDuration:_ANIMATION_DURATION animations:^{
        
        [_mainView setFrame:CGRectMake(_mainViewFrame.origin.x, [RegisterPositionHelper middleScreenY], _mainViewFrame.size.width, _mainViewFrame.size.height)];
        
        [_signUpBtn setAlpha:0.0];
        
        [_logInBtn setAlpha:0.0];
        
        [_messageLbl setAlpha:0.0];
        
        [_backBtn setAlpha:1.0f];
        

    } completion:^(BOOL finished) {
        
        [_signUpBtn setHidden:YES];
        
        [_logInBtn setHidden:YES];
        
        [_messageLbl setHidden:YES];
        
        callbackBlock(finished);
    }];
}

-(void)goBackToLoginRegisterAnimation
{
    [_currentView resignFieldResponder];
    
    [_signUpBtn setHidden:NO];
    
    [_logInBtn setHidden:NO];
    
    [_messageLbl setHidden:NO];
    
    [UIView animateWithDuration:_ANIMATION_DURATION animations:^{
        
        [_mainView setFrame:CGRectMake(_mainViewFrame.origin.x, _mainViewFrameInit.origin.y, _mainViewFrame.size.width, _mainViewFrame.size.height)];
        

        
        [_signUpBtn setAlpha:1.0];
        
        [_logInBtn setAlpha:1.0];
        
        [_messageLbl setAlpha:1.0];
        
        [_backBtn setAlpha:0.0];
        
    } completion:^(BOOL finished) {
        

        [_backBtn setHidden:YES];
        
        _currentView = nil;
        
    }];
}

-(void)showLoginView
{
    
    [_currentView setFrame:CGRectMake(_mainViewFrame.origin.x, [RegisterPositionHelper middleScreenY], _mainViewFrame.size.width, _mainViewFrame.size.height)];
    
    
    [_currentView setAlpha:1.0];
    
//    [_currentView setAlpha:0.0];
//    
//    [_currentView setFrame:CGRectMake(_mainViewFrame.origin.x, _mainViewFrameInit.origin.y, _mainViewFrame.size.width, _mainViewFrame.size.height)];
//
//    
//    [self.view addSubview:_currentView];
//    
//    [UIView animateWithDuration:_ANIMATION_DURATION animations:^{
//        
//        [_currentView setFrame:CGRectMake(_mainViewFrame.origin.x, [RegisterPositionHelper middleScreenY], _mainViewFrame.size.width, _mainViewFrame.size.height)];
//
//        
//        [_currentView setAlpha:1.0];
//        
//    } completion:^(BOOL finished) {
//        
//    }];
}

-(void)hideLoginView
{
    [_currentView setFrame:CGRectMake(_mainViewFrame.origin.x, _mainViewFrameInit.origin.y, _mainViewFrame.size.width, _mainViewFrame.size.height)];
    [_currentView setAlpha:0.0];
}

-(void)setImages
{
    
}

-(void) setBackground
{
    self.view.backgroundColor = [UIColor clearColor];
    
    UIImage *newChatImage = [UIImage imageNamed:@"background_login_pages"];
    
    UIImageView *backgroundImage = [[UIImageView alloc] init];
    
    [backgroundImage setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    backgroundImage.image = newChatImage;
    
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
}


#pragma mark - Keyboard management

- (void)keyboardWillShow:(NSNotification *)note{
    
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curve.intValue;
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame


    
    [UIView animateWithDuration:[duration doubleValue] delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|(animationCurve << 16)) animations:^{

        [self showLoginView];

        
        
    } completion:^(BOOL finished) {
//        [self.tableView setNeedsLayout];
    }];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curve.intValue;
	
	// get a rect for the textView frame

    
    [UIView animateWithDuration:[duration doubleValue] delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|(animationCurve << 16)) animations:^{
        
        [self hideLoginView];

    } completion:^(BOOL finished) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
