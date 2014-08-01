//
//  SettingsViewController.m
//  Gleepost
//
//  Created by Silouanos on 31/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "SettingsViewController.h"
#import "ShapeFormatterHelper.h"
#import "GLPLoginManager.h"
#import "GLPThemeManager.h"
#import "WebClientHelper.h"
#import "GLPInvitationManager.h"
#import <MessageUI/MessageUI.h>
#import "SessionManager.h"
#import "ChangePasswordViewController.h"
#import "AppearanceHelper.h"
#import "UINavigationBar+Utils.h"

@interface SettingsViewController () <MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *simpleNavigationBar;

@property (weak, nonatomic) IBOutlet UILabel *emailLbl;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *phoneLbl;
@property (weak, nonatomic) IBOutlet UILabel *passwordLbl;
@property (weak, nonatomic) IBOutlet UIButton *connectTwitterBtn;
@property (weak, nonatomic) IBOutlet UIButton *connectFacebookBtn;
@property (weak, nonatomic) IBOutlet UIButton *logOutBtn;
@property (weak, nonatomic) IBOutlet UIButton *inviteBtn;

@property (strong, nonatomic) MFMessageComposeViewController *messageComposeViewController;

@property (assign, nonatomic) BOOL isPassWordChanged;

@end

@implementation SettingsViewController

const int CORNER_VALUE = 16;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureView];
    
    [self loadInformation];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureNavigationBar];

    
}

#pragma mark - Configuration

-(void)configureView
{    
    //Format labels shapes.
    [ShapeFormatterHelper setCornerRadiusWithView:_emailLbl andValue:CORNER_VALUE];
    
    [ShapeFormatterHelper setCornerRadiusWithView:_nameLbl andValue:CORNER_VALUE];
    
    [ShapeFormatterHelper setCornerRadiusWithView:_phoneLbl andValue:CORNER_VALUE];
    
    [ShapeFormatterHelper setCornerRadiusWithView:_passwordLbl andValue:CORNER_VALUE];
    
    [ShapeFormatterHelper setCornerRadiusWithView:_connectFacebookBtn andValue:CORNER_VALUE];
    
    [ShapeFormatterHelper setCornerRadiusWithView:_connectTwitterBtn andValue:CORNER_VALUE];

    [ShapeFormatterHelper setCornerRadiusWithView:_logOutBtn andValue:CORNER_VALUE];
    
    [ShapeFormatterHelper setCornerRadiusWithView:_inviteBtn andValue:CORNER_VALUE];

    
    //Add push gesture to password label.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigateToChangePasswordView:)];
    [tap setNumberOfTapsRequired:1];
    [_passwordLbl addGestureRecognizer:tap];
    
    //Add push gesture to name label.
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigateToChangeNameView:)];
    [tap setNumberOfTapsRequired:1];
    [_nameLbl addGestureRecognizer:tap];
}

-(void)configureNavigationBar
{
    
    [AppearanceHelper setNavigationBarFontForNavigationBar:_simpleNavigationBar];

    
//
//    
//    [self.simpleNavigationBar setBackgroundColor:[UIColor clearColor]];
//    
//    [self.simpleNavigationBar setTranslucent:NO];
//    [self.simpleNavigationBar setFrame:CGRectMake(0.f, 0.f, 320.f, 65.f)];
//    self.simpleNavigationBar.tintColor = [UIColor whiteColor];
//    
//    [self.simpleNavigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor,[UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f], UITextAttributeFont, nil]];
    
//    [self.navigationController.navigationBar setHidden:NO];
//    [self.navigationController.navigationBar setBackgroundColor:[UIColor greenColor]];
//    [self.navigationController.navigationBar setTranslucent:NO];
//    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor,[UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f], UITextAttributeFont, nil]];
    
}

-(void)loadInformation
{
    [_emailLbl setText:[SessionManager sharedInstance].user.email];
    
//    [_passwordLbl setText:@"\uasdjaspdjksada"];
    _passwordLbl.text = @"\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022";
    
    [_nameLbl setText:[SessionManager sharedInstance].user.name];
}

#pragma mark - Selectors

- (IBAction)dismissModalView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)connectTwitter:(id)sender {
}

- (IBAction)connectFacebook:(id)sender {
}

- (IBAction)logOut:(id)sender
{
    //Pop up a bottom menu.
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Are you sure you want to logout?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Logout", nil];
    
    [actionSheet showInView:[self.view window]];
}

- (IBAction)inviteFriends:(id)sender
{
    [WebClientHelper showStandardLoaderWithTitle:@"Loading" forView:self.view];
    
    [[GLPInvitationManager sharedInstance] fetchInviteMessageWithCompletion:^(BOOL success, NSString *inviteMessage) {
        [WebClientHelper hideStandardLoaderForView:self.view];
        if (success) {
            [self showMessageViewControllerWithBody:inviteMessage];
        } else {
            [WebClientHelper showInternetConnectionErrorWithTitle:@"Failed to invite friends."];
        }
    }];
}

-(void)navigateToChangePasswordView:(id)sender
{
    _isPassWordChanged = YES;
    [self performSegueWithIdentifier:@"pass view" sender:self];
}

-(void)navigateToChangeNameView:(id)sender
{
    _isPassWordChanged = NO;
    [self performSegueWithIdentifier:@"pass view" sender:self];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(![segue.identifier isEqualToString:@"start"])
    {
        ChangePasswordViewController *change = segue.destinationViewController;
        
        change.isPasswordChange = _isPassWordChanged;
    }
}


#pragma mark - Actions

- (void)showMessageViewControllerWithBody:(NSString *)messageBody {
    if (![MFMessageComposeViewController canSendText]) {
        [WebClientHelper showStandardErrorWithTitle:@"Error" andContent:@"Your device doesn't support SMS."];
        return;
    }
    
    self.messageComposeViewController = [[MFMessageComposeViewController alloc] init];
    self.messageComposeViewController.messageComposeDelegate = self;
    [self.messageComposeViewController setBody:messageBody];
    
    [self presentViewController:self.messageComposeViewController animated:YES completion:nil];
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultFailed: {
            [WebClientHelper showStandardErrorWithTitle:@"Error" andContent:@"An error occurred while sending the SMS."];
            break;
        }
        case MessageComposeResultSent: {
            [WebClientHelper showStandardErrorWithTitle:@"Sent" andContent:@"SMS sent successfully."];
            break;
        }
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Action Sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [GLPLoginManager logout];
        [self.navigationController popViewControllerAnimated:YES];
        [self performSegueWithIdentifier:@"start" sender:self];
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subview in actionSheet.subviews)
    {
        if ([subview isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton*)subview;
            
            if([btn.titleLabel.text isEqualToString:@"Cancel"])
            {
                //btn.titleLabel.textColor = [UIColor colorWithRed:75.0/255.0 green:204.0/255.0 blue:210.0/255.0 alpha:0.8];
                btn.titleLabel.textColor = [[GLPThemeManager sharedInstance]colorForTabBar];
            }
            else
            {
                btn.titleLabel.textColor = [UIColor lightGrayColor];
            }
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
