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
#import "WebClientHelper.h"
#import "ChatViewAnimations.h"
#import "NSMutableArray+QueueAdditions.h"
#import "GLPConversation.h"
#import "ConversationManager.h"
#import "UIViewController+GAI.h"
#import "SessionManager.h"
#import "DatabaseManager.h"
#import "UIViewController+Flurry.h"
#import "GLPLiveConversationsManager.h"

@interface ChatViewController ()

@property (strong, nonatomic) GLPConversation *conversation;
@property (strong, nonatomic) ChatViewAnimations *chatAnimations;

- (IBAction)startButtonClicked:(id)sender;
- (IBAction)startGroupButtonClicked:(id)sender;

@end

@implementation ChatViewController

@synthesize conversation=_conversation;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Change the format of the navigation bar.
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"new_chat_background"]]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar_trans"] forBarMetrics:UIBarMetricsDefault];
    
    [self addGleepostImageToNavigationBar];
    //[self addSettingsImageToNavigationBar];
    


}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadLiveConversations];
    
    [self initialiseAnimationViewToTheViewController];

    [self sendViewToGAI:NSStringFromClass([self class])];
    [self sendViewToFlurry:NSStringFromClass([self class])];
}

-(void)loadLiveConversations
{
    [WebClientHelper showStandardLoaderWithTitle:@"Refreshing live chat" forView:self.view];
    
    [ConversationManager loadLiveConversationsWithCallback:^(BOOL success, NSArray *conversations) {
        [WebClientHelper hideStandardLoaderForView:self.view];
        
        if(!success) {
            [WebClientHelper showStandardErrorWithTitle:@"Refreshing live chat failed" andContent:@"Cannot connect to the live chat, check your network status and retry later."];
            return;
        }
        
        [GLPLiveConversationsManager sharedInstance].conversations = [conversations mutableCopy];
        [self initialiseAnimationViewToTheViewController];
    }];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self initialiseAnimationViewToTheViewController];
}


/**
 Initialise the animations to the view controller.
 
 */
- (void)initialiseAnimationViewToTheViewController
{
    for (UIView *subView in self.view.subviews)
    {
        if (subView.tag == 100)
        {
            [(ChatViewAnimations*)subView removeElements];
            [subView removeFromSuperview];
            
        }
    }
    
    //[ChatViewAnimations setLiveChat:YES];

    self.chatAnimations = [[ChatViewAnimations alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    //[self.chatAnimations initialiseLiveConversationBubbles: self.liveConversations];
    

    
    [self.chatAnimations refreshLiveConversations];
    
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
    UIImage *image = [UIImage imageNamed:@"GleepostS"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    self.navigationItem.titleView = imageView;
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

- (void)searchForConversation
{
    [WebClientHelper showStandardLoaderWithoutSpinningAndWithTitle:@"Connecting with user" forView:self.view];

    [[WebClient sharedInstance] createConversationWithCallback:^(BOOL success, GLPConversation *conversation) {
        [WebClientHelper hideStandardLoaderForView:self.view];
        
        if(success) {
            _conversation = conversation;
            [self performSegueWithIdentifier:@"start" sender:self];
        } else {
            [WebClientHelper showStandardError];
        }
    }];
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"start"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
        ViewTopicViewController *vc = segue.destinationViewController;
        vc.conversation = _conversation;

    }
}
@end
