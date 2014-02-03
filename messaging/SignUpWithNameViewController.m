//
//  SignUpWithNameViewController.m
//  Gleepost
//
//  Created by Silouanos on 03/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "SignUpWithNameViewController.h"
#import "FinalRegisterViewController.h"
#import "WebClientHelper.h"
#import "AppearanceHelper.h"

@interface SignUpWithNameViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;


@end

@implementation SignUpWithNameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [AppearanceHelper setFormatForLoginNavigationBar:self];
    
    [self setBackground];
    
    [self setUpTextFields];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.nameTextField becomeFirstResponder];

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

-(void)setUpTextFields
{
    CGRect textFielFrame = self.nameTextField.frame;
    textFielFrame.size.height+=10;
    [self.nameTextField setFrame:textFielFrame];
    [self.nameTextField setBackgroundColor:[UIColor whiteColor]];
    [self.nameTextField setTextColor:[UIColor blackColor]];
    self.nameTextField.layer.cornerRadius = 20;
    self.nameTextField.layer.borderColor = [UIColor colorWithRed:28.0f/255.0f green:208.0f/255.0f blue:208.f/255.0f alpha:1.0f].CGColor;
    self.nameTextField.layer.borderWidth = 3.0f;
    self.nameTextField.clipsToBounds = YES;
    
    
    textFielFrame = self.lastNameTextField.frame;
    textFielFrame.size.height+=10;
    [self.lastNameTextField setFrame:textFielFrame];
    [self.lastNameTextField setBackgroundColor:[UIColor whiteColor]];
    [self.lastNameTextField setTextColor:[UIColor blackColor]];
    self.lastNameTextField.layer.cornerRadius = 20;
    self.lastNameTextField.layer.borderColor = [UIColor colorWithRed:28.0f/255.0f green:208.0f/255.0f blue:208.f/255.0f alpha:1.0f].CGColor;
    self.lastNameTextField.layer.borderWidth = 3.0f;
    self.lastNameTextField.clipsToBounds = YES;
}

- (IBAction)navigateToFinalView:(id)sender
{
    if([self areTheDetailsValid])
    {
        
        [self performSegueWithIdentifier:@"final register" sender:self];
    }
    else
    {
        [WebClientHelper showStandardErrorWithTitle:@"Please Check your details" andContent:@"Please check your details if are valid."];

    }
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    FinalRegisterViewController *finalForm = segue.destinationViewController;
    
    //finalRegistrationForm.eMailPass = [[NSArray alloc] initWithObjects:self.emailTextView.text, self.passwordTextView.text, nil];
    
    finalForm.eMailPass = self.eMailPass;
    
    finalForm.firstLastName = [[NSArray alloc] initWithObjects:self.nameTextField.text, self.lastNameTextField.text, nil];
}


-(BOOL)areTheDetailsValid
{
    return (![self.nameTextField.text isEqualToString:@""] && ![self.lastNameTextField.text isEqualToString:@""]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
