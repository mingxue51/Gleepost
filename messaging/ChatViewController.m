//
//  ChatViewController.m
//  messaging
//
//  Created by Lukas on 8/29/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ChatViewController.h"
#import "ViewTopicViewController.h"
#import "MBProgressHUD.h"
#import "WebClient.h"
#import "ChatViewAnimations.h"

@interface ChatViewController ()

@property (strong, nonatomic) Conversation *conversation;
@property (strong, nonatomic) ChatViewAnimations *chatAnimations;
- (IBAction)startButtonClicked:(id)sender;
- (IBAction)startGroupButtonClicked:(id)sender;

@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"ChatViewController");
    //Change the format of the navigation bar.
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"new_chat_background"]]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar_trans"] forBarMetrics:UIBarMetricsDefault];
//    [self.view setBackgroundColor:[UIColor clearColor]];
    
    [self initialiseAnimationViewToTheViewController];
    [self addGleepostImageToNavigationBar];
    [self addSettingsImageToNavigationBar];
}

-(void) viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear");
    [super viewDidAppear:animated];
    
    
    
    [self initialiseAnimationViewToTheViewController];

}

-(void) viewDidDisappear:(BOOL)animated
{
    NSLog(@"viewDidDisappear");
    
    [super viewDidDisappear:animated];

    
    //Clear the sub view chatAnimations.
    for (UIView *subView in self.view.subviews)
    {
        if (subView.tag == 100)
        {
            [(ChatViewAnimations*)subView removeElements];
            [subView removeFromSuperview];
            
        }
    }
    
    [self initialiseAnimationViewToTheViewControllerWhenDissappearing];
    
}


-(void) addSettingsImageToNavigationBar
{
    UIImage *settingsIcon = [UIImage imageNamed:@"settings_icon"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:settingsIcon];
    [imageView setFrame:CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, settingsIcon.size.width, settingsIcon.size.height)];
    
    UIButton *btnBack=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(navigateToSettings:) forControlEvents:UIControlEventTouchUpInside];
    [btnBack setBackgroundImage:settingsIcon forState:UIControlStateNormal];
    [btnBack setFrame:CGRectMake(0, 0, 20, 20)];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    
    self.navigationItem.rightBarButtonItem = item;
}

-(void) navigateToSettings: (id)sender
{
    NSLog(@"Navigate to Settings.");
}

-(void) addGleepostImageToNavigationBar
{
    UIImage *image = [UIImage imageNamed:@"gleepost"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self.navigationController.navigationBar.topItem setTitleView:imageView];
}

/**
 This method used in order to smoothly navigate back to the view controller.
 
 */
-(void) initialiseAnimationViewToTheViewControllerWhenDissappearing
{
    self.chatAnimations = [[ChatViewAnimations alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.chatAnimations.chatViewController = self;
    self.chatAnimations.tag = 100;
    
    self.view = self.chatAnimations;
}

/**
 Initialise the animations to the view controller.
 
 */
-(void) initialiseAnimationViewToTheViewController
{
    self.chatAnimations = [[ChatViewAnimations alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.chatAnimations.chatViewController = self;
    self.chatAnimations.tag = 100;
    
//    self.view = self.chatAnimations;
    [self.view addSubview:self.chatAnimations];
    [self.view sendSubviewToBack:self.chatAnimations];
    
//    UIImage *newChatImage = [UIImage imageNamed:@"new_chat_background"];
//    
//    UIImageView *backgroundImage = [[UIImageView alloc] init];
//    
//    [backgroundImage setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    
//    backgroundImage.image = newChatImage;
//    
//    [self.view addSubview:backgroundImage];
//    [self.view sendSubviewToBack:backgroundImage];
}

-(void) setBackgroundToNavigationBar
{
    UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.f, -20.f, 320.f, 65.f)];
    
    
    
    [bar setBackgroundColor:[UIColor clearColor]];
    [bar setBackgroundImage:[UIImage imageNamed:@"navigationbar_4"] forBarMetrics:UIBarMetricsDefault];
    [bar setTranslucent:YES];
    
    
    //Change the format of the navigation bar.
    [self.navigationController.navigationBar setTranslucent:YES];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar_trans"] forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController.navigationBar insertSubview:bar atIndex:1];
}

- (IBAction)startButtonClicked:(id)sender
{
    //[self searchForConversationForGroup:NO];
}

- (IBAction)startGroupButtonClicked:(id)sender
{
    //[self searchForConversationForGroup:YES];
}

- (void)searchForConversationForGroup:(BOOL)group
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Looking for people";
    hud.detailsLabelText = @"Please wait few seconds";
    
    WebClient *client = [WebClient sharedInstance];
    
    void(^block)(BOOL success, Conversation *conversation);
    block = ^(BOOL success, Conversation *conversation) {
        [hud hide:YES];
        
        if(success) {
            self.conversation = conversation;
            
            NSLog(@"PARTICIPANTS:%@",self.conversation.getParticipantsNames);
            [self performSegueWithIdentifier:@"start" sender:self];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Conversation failed"
                                                            message:@"Check your your internet connection, dude."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    };
    
    if(group) {
        [client createGroupConversationWithCallbackBlock:block];
    } else {
        [client createOneToOneConversationWithCallbackBlock:block];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"start"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        ViewTopicViewController *vc = segue.destinationViewController;
        vc.conversation = self.conversation;
    }
}
@end
