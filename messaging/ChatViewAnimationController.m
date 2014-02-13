//
//  ChatViewAnimationController.m
//  Gleepost
//
//  Created by Silouanos on 29/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "ChatViewAnimationController.h"
#import "ChatViewAnimationsStanford.h"
#import "WebClientHelper.h"
#import "WebClient.h"
#import "ViewTopicViewController.h"
#import "GLPConversation.h"
#import "GLPLiveConversationsManager.h"
#import "GLPConversationViewController.h"
#import "WalkThroughHelper.h"
#import "SessionManager.h"

@interface ChatViewAnimationController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *simpleNavigationBar;
@property (strong, nonatomic) ChatViewAnimationsStanford *chatStanfordAnimations;
@property (strong, nonatomic) GLPConversation *conversation;
@property (assign, nonatomic) BOOL controllerExist;
@end

@implementation ChatViewAnimationController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    [self.view setBackgroundColor:[UIColor greenColor]];

    _controllerExist = YES;
    [self configureView];
    
    [self configureNavigationBar];

    
    [self startAnimation];
    
}


#pragma mark - Animations

-(void)startAnimation
{
    [_simpleNavigationBar setHidden:YES];
    
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
            [(ChatViewAnimationsStanford*)subView removeElements];
            [subView removeFromSuperview];
        }

    }
    
    self.chatStanfordAnimations = [[ChatViewAnimationsStanford alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        
    self.chatStanfordAnimations.chatViewController = self;
    self.chatStanfordAnimations.tag = 100;
        
    [self.view addSubview:self.chatStanfordAnimations];
    [self.view sendSubviewToBack:self.chatStanfordAnimations];
    
    if([WalkThroughHelper isReadyToShowRandomChat])
    {
        [self startRegularRandomChatOperation];
    }
    else
    {
        [WalkThroughHelper showRandomChatMessageWithDelegate:self];
    }
}

-(void)startRegularRandomChatOperation
{
    [self.chatStanfordAnimations startRegularMode];
    
    [self performSelector:@selector(searchForNewChat:) withObject:nil afterDelay:3.0f];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self startRegularRandomChatOperation];
    }
    
}

#pragma mark - Selectors

- (IBAction)dismissModalView:(id)sender
{
    _controllerExist = NO;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)searchForNewChat:(id)sender
{
    //    [self searchingAnimations];
    
    [self performSelector:@selector(startSearchingIndicator) withObject:nil afterDelay:0.0];
    
    [self performSelector:@selector(stopSearchingIndicator) withObject:nil afterDelay:3.0];
    
    [self performSelector:@selector(navigateToNewRandomChat:) withObject:nil afterDelay:3.0];
    
}

-(void)navigateToNewRandomChat:(id)sender
{
   [self searchForConversation];
}

-(void) startSearchingIndicator
{
    [WebClientHelper showStandardLoaderWithoutSpinningAndWithTitle:@"Searching for people..." forView:self.chatStanfordAnimations];
    
}

-(void) stopSearchingIndicator
{
    [WebClientHelper hideStandardLoaderForView:self.chatStanfordAnimations];
}

#pragma mark - Client

- (void)searchForConversation
{
    [WebClientHelper showStandardLoaderWithoutSpinningAndWithTitle:@"Connecting with user" forView:self.view];
    DDLogInfo(@"Search for conversation");
    
    GLPConversation *conversation = [[GLPLiveConversationsManager sharedInstance] createRandomConversation];
    
    if(conversation) {
        if(_controllerExist) {
            [[SessionManager sharedInstance] playSound];
        }

        _conversation = conversation;
        [self navigateToChat];
    } else {
        [WebClientHelper showStandardError];
    }
}


-(void)playSound:(id)sender
{
    //Play the sound.
//    NSString *path = [[NSBundle mainBundle]pathForResource:@"mario" ofType:@"mp3"];
//    //            AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
//    //            NSURL* url = [[NSBundle mainBundle] URLForResource:@"mario" withExtension:@"mp3"];
//    
//    
//    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
////    audioPlayer.delegate = self;
//    [audioPlayer play];
    
    
    
    
    
//    NSURL* url = [[NSBundle mainBundle] URLForResource:@"mario" withExtension:@"mp3"];
//    NSAssert(url, @"URL is valid.");
//    NSError* error = nil;
//    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
//    
//    if(!audioPlayer)
//    {
//        NSLog(@"Error creating player: %@", error);
//    }     else
//    {
//        
//        [audioPlayer play];
//    }

}

#pragma mark - Configuration


-(void)configureView
{
    //Add touch gesture to view to give the opportunity to the user to cancel random chat.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissModalView:)];
    [tap setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tap];
}

-(void)configureNavigationBar
{
    [self.simpleNavigationBar setBackgroundColor:[UIColor clearColor]];
    
    [self.simpleNavigationBar setTranslucent:NO];
    [self.simpleNavigationBar setFrame:CGRectMake(0.f, 0.f, 320.f, 65.f)];
    self.simpleNavigationBar.tintColor = [UIColor whiteColor];
    
    [self.simpleNavigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor,[UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f], UITextAttributeFont, nil]];
    
    [self.navigationController setNavigationBarHidden:YES];
}


#pragma mark - Navigation

-(void)navigateToChat
{
    
    //Navigate to unlock profile.
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
//    ViewTopicViewController *vtvc = [storyboard instantiateViewControllerWithIdentifier:@"ViewTopicViewController"];
//    vtvc.conversation = _conversation;
    
    //Navigate to conversation view controller.
    [self performSegueWithIdentifier:@"random chat" sender:self];
    
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"random chat"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
//        ViewTopicViewController *vc = segue.destinationViewController;
//        vc.conversation = _conversation;
        
        GLPConversationViewController *convController = segue.destinationViewController;
        convController.conversation = _conversation;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
