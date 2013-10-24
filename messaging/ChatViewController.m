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

@interface ChatViewController ()

@property (strong, nonatomic) GLPConversation *conversation;
@property (strong, nonatomic) ChatViewAnimations *chatAnimations;
@property (strong, nonatomic) NSMutableArray *liveConversations;

- (IBAction)startButtonClicked:(id)sender;
- (IBAction)startGroupButtonClicked:(id)sender;

@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.liveConversations = [[NSMutableArray alloc] init];
    
    NSLog(@"ChatViewController");
    //Change the format of the navigation bar.
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"new_chat_background"]]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar_trans"] forBarMetrics:UIBarMetricsDefault];
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    [self addGleepostImageToNavigationBar];
    [self addSettingsImageToNavigationBar];
    
    [self initialiseAnimationViewToTheViewController];

}

-(void) viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];

    BOOL conversationExist = NO;

    NSLog(@"viewDidAppear");
    NSLog(@"Current conversation: %@", self.conversation.title);
    NSLog(@"CONVERSATIONS: %@", self.liveConversations);

    
    
    if(self.conversation.title != nil)
    {
        
        for(GLPConversation *c in self.liveConversations)
        {
            NSLog(@"Current Conversation: %@", c.title);
            
            if([self.conversation.title isEqualToString:c.title])
            {
                
            }
            else
            {

            }
        
        }
        
    }
    
    //Save the current conversation.
    if(self.conversation.title != nil)
    {
        //If there are already 3 conversations, then delete the oldest.
        //TODO: Bug here fix this. It should check this after new conversation detected.

        
        //Avoid adding the same conversation.
        for(GLPConversation *c in self.liveConversations)
        {
            if([self.conversation.description isEqualToString:c.description])
            {
                //Don't do anything.
                conversationExist = YES;
                break;
            }
            
        }
        
        if((self.liveConversations.count == 3) && (!conversationExist))
        {
            [self.liveConversations dequeue];
        }
        
        if(!conversationExist)
        {
            //Add conversation to array.
            [self.liveConversations enqueue:self.conversation];
        }
        
        NSLog(@"Conversation Description: %@",self.conversation.description);
        
    }
    
    [self initialiseAnimationViewToTheViewController];

}

-(void) viewDidDisappear:(BOOL)animated
{
    NSLog(@"viewDidDisappear");
    
    [super viewDidDisappear:animated];

    //[self.chatAnimations initialiseBubbles];
    
    //Clear the sub view chatAnimations.
    for (UIView *subView in self.view.subviews)
    {
        if (subView.tag == 100)
        {
            [(ChatViewAnimations*)subView removeElements];
            [subView removeFromSuperview];
            
        }
    }
    
//    [self initialiseAnimationViewToTheViewControllerWhenDissappearing];
    
    [self.chatAnimations initAnimations];
    
}

/**
 This method used in order to smoothly navigate back to the view controller.
 
 */
-(void) initialiseAnimationViewToTheViewControllerWhenDissappearing
{
    [ChatViewAnimations setLiveChat:NO];
    
    //    self.chatAnimations = [[ChatViewAnimations alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    //    self.chatAnimations.chatViewController = self;
    //    self.chatAnimations.tag = 100;
    //
    //    [self.chatAnimations refreshLiveConversations: self.liveConversations];
    //
    self.view = self.chatAnimations;
    
    //[self.chatAnimations refreshLiveConversations: self.liveConversations];
    
    
}

/**
 Initialise the animations to the view controller.
 
 */
-(void) initialiseAnimationViewToTheViewController
{
    NSLog(@"initialiseAnimationViewToTheViewController");
    
    //[ChatViewAnimations setLiveChat:YES];
    
    self.chatAnimations = [[ChatViewAnimations alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    //[self.chatAnimations initialiseLiveConversationBubbles: self.liveConversations];
    

    
    [self.chatAnimations refreshLiveConversations:self.liveConversations];
    
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
   // UIImageView *workaroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 98, 34)];

    
    UIImage *image = [UIImage imageNamed:@"GleepostS"];
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    
     UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
//    imageView.image = image;
    NSLog(@"Size of image: %f : %f", image.size.width, image.size.height);
    
    NSLog(@"Size of image view: %f : %f", imageView.frame.size.width, imageView.frame.size.height);
    

//    self.navigationController.navigationItem.titleView = imageView;
    self.navigationItem.titleView = imageView;
//    [self.navigationController.navigationBar.topItem setTitleView:imageView];
    
    
    //self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:image] autorelease];
    
    
    /**
     
     UIImageView *workaroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 98, 34)];
     [workaroundImageView addSubview:navigationImage];
     self.navigationItem.titleView=workaroundImageView;
     
     
     */
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
//    [WebClientHelper showStandardLoaderWithTitle:@"Looking for people" forView:self.view];
    
    [WebClientHelper showStandardLoaderWithoutSpinningAndWithTitle:@"Connecting with user" forView:self.view];

    
    WebClient *client = [WebClient sharedInstance];
    
    void(^block)(BOOL success, GLPConversation *conversation);
    block = ^(BOOL success, GLPConversation *conversation) {
        [WebClientHelper hideStandardLoaderForView:self.view];
        
        if(success) {
            self.conversation = conversation;
            self.newChat = YES;
            NSLog(@"New Conversation: %@", conversation.author.name);
            [self performSegueWithIdentifier:@"start" sender:self];
        } else {
            [WebClientHelper showStandardError];
        }
    };
    
    if(group) {
        [client createGroupConversationWithCallbackBlock:block];
    } else {
        [client createOneToOneConversationWithCallbackBlock:block];
    }
}

-(void)navigateToLiveChatWithIndex: (int)index
{
    self.newChat = NO;
    self.conversation = [self.liveConversations objectAtIndex:index];
    [self performSegueWithIdentifier:@"start" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"start"])
    {
        if(self.newChat)
        {
            [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
            ViewTopicViewController *vc = segue.destinationViewController;
            vc.randomChat = YES;
            vc.conversation = self.conversation;
        }
        else
        {
            [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
            ViewTopicViewController *vc = segue.destinationViewController;
            vc.randomChat = YES;
            vc.conversation = self.conversation;
        }

    }
}
@end
