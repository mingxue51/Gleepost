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

@interface ChatViewController ()

@property (strong, nonatomic) GLPConversation *conversation;
@property (strong, nonatomic) GLPLiveConversation *liveConversation;
@property (strong, nonatomic) ChatViewAnimations *chatAnimations;
@property (strong, nonatomic) NSMutableArray *conversations;
@property (assign, nonatomic) BOOL searchForConversation;

- (IBAction)startButtonClicked:(id)sender;
- (IBAction)startGroupButtonClicked:(id)sender;

@end

@implementation ChatViewController

@synthesize conversation=_conversation;
@synthesize conversations=_conversations;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _conversations = [[NSMutableArray alloc] init];
    
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

    self.searchForConversation = NO;

    
//    BOOL conversationExist = NO;
//
//    
////    //Save the current conversation.
////    if(self.conversation.title != nil)
////    {
////        //If there are already 3 conversations, then delete the oldest.
////        //TODO: Bug here fix this. It should check this after new conversation detected.
////
////        
////        //Avoid adding the same conversation.
////        for(GLPLiveConversation *c in self.liveConversations)
////        {
////            if(self.conversation.remoteKey == c.remoteKey)
////            {
////                //Don't do anything.
////                conversationExist = YES;
////                break;
////            }
////            
////        }
////        
//////        if((self.liveConversations.count == 3) && (!conversationExist))
//////        {
//////            GLPLiveConversation *liveConv = [self.liveConversations objectAtIndex:0];
//////            [self.liveConversations dequeue];
//////            
//////            //Delete conversation with key from database.
//////            [self deleteConversationFromDbWithKey:liveConv.key];
//////            //[self loadLiveConversations];
//////            
//////        }
////        
////        if(!conversationExist)
////        {
////            //Convert conversation to live conversation.
////            GLPLiveConversation *liveConv = [[GLPLiveConversation alloc] initWithConversation:self.conversation];
////            
////
////            //Add new conversation to database.
////            [self addNewConversationToDb:liveConv];
////            
////            
////            //Add conversation to array.
////            [self.liveConversations enqueue:liveConv];
////        }
////    }
    
    [self initialiseAnimationViewToTheViewController];

    [self sendViewToGAI:NSStringFromClass([self class])];
    [self sendViewToFlurry:NSStringFromClass([self class])];
}

-(void)loadLiveConversations
{
    [WebClientHelper showStandardLoaderWithTitle:@"Connecting to the live chat" forView:self.view];
    
    [ConversationManager loadLiveConversationsWithCallback:^(BOOL success, NSArray *conversations) {
        [WebClientHelper hideStandardLoaderForView:self.view];
        
        if(!success) {
            [WebClientHelper showStandardErrorWithTitle:@"Connection failed" andContent:@"Cannot connect to the live chat, check your network status and retry later."];
            return;
        }
        
        _conversations = [conversations mutableCopy];
        [self initialiseAnimationViewToTheViewController];
    }];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self initialiseAnimationViewToTheViewController];
}

/**
 This method used in order to smoothly navigate back to the view controller.
 
 */
//-(void) initialiseAnimationViewToTheViewControllerWhenDissappearing
//{
////    [ChatViewAnimations setLiveChat:NO];
//    self.chatAnimations = [[ChatViewAnimations alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    self.chatAnimations.chatViewController = self;
////    self.chatAnimations.tag = 100;
//    
//    [self.chatAnimations refreshLiveConversations: self.liveConversations];
//    
//    self.view = self.chatAnimations;
//    
//    
//    
//}

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
    

    
    [self.chatAnimations refreshLiveConversations:_conversations];
    
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

- (IBAction)startButtonClicked:(id)sender
{
    [self searchForConversationForGroup:NO];
}

- (IBAction)startGroupButtonClicked:(id)sender
{
    [self searchForConversationForGroup:YES];
}

- (void)searchForConversationForGroup:(BOOL)group
{
    self.searchForConversation = YES;
    
    [WebClientHelper showStandardLoaderWithoutSpinningAndWithTitle:@"Connecting with user" forView:self.view];

    [[WebClient sharedInstance] createConversationWithCallback:^(BOOL success, GLPConversation *conversation) {
        [WebClientHelper hideStandardLoaderForView:self.view];
        
        if(success) {
            _conversation = conversation;
            self.newChat = YES;
            
            [self performSegueWithIdentifier:@"start" sender:self];
        } else {
            [WebClientHelper showStandardError];
        }
    }];
}

-(void)navigateToLiveChatWithIndex: (int)index
{
    ViewTopicViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewTopicViewController"];
    vc.conversation = _conversations[index];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"start"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
        
//        if((self.liveConversations.count == 3) && (self.searchForConversation))
//        {
//            GLPLiveConversation *liveConv = [self.liveConversations objectAtIndex:0];
//            [self.liveConversations dequeue];
//            
//            //Delete conversation with key from database.
//            [self deleteConversationFromDbWithKey:liveConv.key];
//            
//            self.searchForConversation = NO;
//            //[self loadLiveConversations];
//            
//        }

        
        /////
        
        ViewTopicViewController *vc = segue.destinationViewController;
        vc.conversation = _conversation;

    }
}
@end
