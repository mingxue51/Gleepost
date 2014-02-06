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
#import "SignUpOneView.h"

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

@property (strong, nonatomic) NSDictionary *signUpViews;

@property (assign, nonatomic) float ANIMATION_DURATION;

@property (strong, nonatomic) NSArray *firstLastName;

@property (strong, nonatomic) NSArray *emailPass;


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
    
    
    [self initialiseViews];
    
    [self initialiseObjects];
    
    
    
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
//    _signUpViews = [[NSDictionary alloc] initWithObjectsAndKeys:[self loadNibWithName:@"SignUpOneView"], [NSNumber numberWithInt:1], [self loadNibWithName:@"SignUpTwoView"], [NSNumber numberWithInt:2] , nil];
    
    _signUpViews = [[NSDictionary alloc] initWithObjectsAndKeys:@"SignUpOneView", [NSNumber numberWithInt:1], @"SignUpTwoView", [NSNumber numberWithInt:2], @"SignUpThreeView", [NSNumber numberWithInt:3], @"SignUpFourView", [NSNumber numberWithInt:4], @"SignUpFiveView", [NSNumber numberWithInt:5], nil];
    
}

-(void)initialiseObjects
{
    _mainViewFrame = _mainView.frame;
    _mainViewFrameInit = _mainView.frame;
    
    _ANIMATION_DURATION = 0.25;

}

-(void)initialiseViews
{
    [_backBtn setHidden:YES];
    
    _currentViewId = 0;
    
    //Fetch all the views and add them to the dictonary in order.
   
    [self loadRegisterViews];

}

#pragma mark - Fake navigators

- (IBAction)gleepostSignUp:(id)sender
{
    //Animate mainView to the middle of the screen.
    //[self continueToLoginSignUpAnimation];
    
    //[self loadAndAddNibWithName:@"SignUpOneView"];
//    ++_currentViewId;

    
    [self navigateToNextView];
    
    [self continueToLoginSignUpAnimationWithCallbackBlock:^(BOOL finished) {
        
    }];
    
    //[self performSegueWithIdentifier:@"register" sender:self];
}


- (IBAction)signIn:(id)sender
{
    //LoginViewController
    
    //Load the login view.
    
    ++_currentViewId;
    
    [self loadAndAddNibWithName:@"LoginView"];
    

    
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
    DDLogDebug(@"GO BACK: %d", _currentViewId);
    
    if(_currentViewId == 1)
    {
        //Navigate to the first view.
        [self goBackToLoginRegisterAnimation];

    }
    else
    {
        //Navigate back to the previews view from right to left.
        [self goBackView];
    }
    
    --_currentViewId;
    
    
}

#pragma mark - Helpers

-(void)loadAndAddNibWithName:(NSString*)nibName
{
    
    _currentView = [self loadNibWithName:nibName];
    
    [_currentView setDelegate:self];
    
    [_currentView setAlpha:0.0];
    
    [_currentView setFrame:CGRectMake(_mainViewFrame.origin.x, _mainViewFrameInit.origin.y, _mainViewFrame.size.width, _mainViewFrame.size.height)];
    
    
    [self.view addSubview:_currentView];
}

-(RegisterView*)loadNibWithName:(NSString*)nibName
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    
    return [array objectAtIndex:0];
}

-(RegisterView*)loadAndAddViewWithId:(int)viewId
{
    
    _currentView = [self loadNibWithName:[_signUpViews objectForKey:[NSNumber numberWithInt:viewId]]];
    
    [_currentView setDelegate:self];
    
    [_currentView setAlpha:0.0];
    
    if([_currentView isKindOfClass:[SignUpOneView class]])
    {
        [_currentView setFrame:CGRectMake(_mainViewFrame.origin.x, _mainViewFrameInit.origin.y, _mainViewFrame.size.width, _mainViewFrame.size.height)];
    }
    else
    {
        [_currentView setFrame:CGRectMake(320.0f, [RegisterPositionHelper middleScreenY], _mainViewFrame.size.width, _mainViewFrame.size.height)];

    }
    
    _currentView.tag = viewId*10;
    
    
    for(UIView *v in self.view.subviews)
    {
        if(v.tag == viewId*10)
        {
            DDLogDebug(@"DUPLICATED!");
            
            //Show already exist view.
            [v setAlpha:1.0f];
            ([(RegisterView*)v becomeFirstResponder]);
            
            return _currentView;

        }
    }
    
    
    [self.view addSubview:_currentView];
    
    return _currentView;
}

#pragma mark - RegisterViewsProtocol delegate

-(void)login
{
    [self performSegueWithIdentifier:@"start" sender:self];
}

-(void)navigateToNextView
{
    //TODO: If the currentView is equal to 4 then try to navigate to the main view controller.

    ++_currentViewId;
    
    //Load the next view.
    [self goToNextViewWithView:[self loadAndAddViewWithId:_currentViewId]];
}

-(void)firstAndLastName:(NSArray *)firstLastName
{
    _firstLastName = firstLastName;
}

-(void)emailAndPass:(NSArray *)emailPass
{
    _emailPass = emailPass;
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
    //Remove all the subviews.
    
    [self removeAllTheSuviews];
    
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

-(void)goBackView
{
    //Hide current view.
    
    [UIView animateWithDuration:_ANIMATION_DURATION animations:^{
        
//        [_currentView setAlpha:0.0];
        [self exitNavigationWithView:_currentView];
        
    } completion:^(BOOL finished) {
        
        [self removePreviewsViewFromSubview];
        
    }];
    
    
    
    //Show the previews view.
    [self loadAndAddViewWithId:_currentViewId-1];
    
//    [UIView animateWithDuration:_ANIMATION_DURATION animations:^{
//        
//        [_currentView setFrame:CGRectMake(0.0f, [RegisterPositionHelper middleScreenY], _mainViewFrame.size.width, _mainViewFrame.size.height)];
//
//        
//    }];

}

-(void)exitNavigationWithView:(RegisterView*)view
{
    [view setFrame:CGRectMake(320.0f, [RegisterPositionHelper middleScreenY], _mainViewFrame.size.width, _mainViewFrame.size.height)];
    
    
   
}

-(void)goToNextViewWithView:(RegisterView*)view
{
    
    if(_currentViewId == 1)
    {
        //Do the default animation. (Keyboard is doing that for us don't do anything).
        
    }
    else
    {
        //Do the push animation.
        DDLogDebug(@"CURRENT VIEW PUSH ID: %d - %d", _currentViewId-1, _currentView.tag);


        
        [UIView animateWithDuration:_ANIMATION_DURATION animations:^{
            
            [self showNextView];

            
        } completion:^(BOOL finished) {
            
            //Remove the previous view from the parent view.
            
//            [self removeNotNeededSuviews];
            

            
        }];
    }
}

-(void)showNextView
{
    [_currentView setFrame:CGRectMake(0, [RegisterPositionHelper middleScreenY], _mainViewFrame.size.width, _mainViewFrame.size.height)];
    
    
    [_currentView setAlpha:1.0];
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

-(void)removeAllTheSuviews
{
    for(UIView *v in self.view.subviews)
    {
        if([v isKindOfClass:[RegisterView class]])
        {
            [v removeFromSuperview];
        }
    }
}

-(void)removePreviewsViewFromSubview
{
    for(UIView *v in self.view.subviews)
    {
        if([v isKindOfClass:[RegisterView class]])
        {
            if(_currentView.tag+10 == v.tag)
            {
                [UIView animateWithDuration:_ANIMATION_DURATION animations:^{
                    
                    [self exitNavigationWithView:(RegisterView*)v];
                    
                } completion:^(BOOL finished) {
                    
                    [v removeFromSuperview];

                }];
                
            }

            
        }
    }
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
