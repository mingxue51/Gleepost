//
//  ViewTopicViewController.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ViewTopicViewController.h"
#import "GLPPrivateProfileViewController.h"

#import "MessageCell.h"
#import "GLPLoadingCell.h"

#import "GLPMessageDao.h"
#import "SessionManager.h"
#import "AppearanceHelper.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "KeyboardHelper.h"
#import "NSString+Utils.h"
#import "ConversationManager.h"

#import "GLPMessage.h"
#import "GLPMessage+CellLogic.h"
#import "GLPUser.h"

#import "CurrentChatButton.h"

#import <QuartzCore/QuartzCore.h>

#import "LiveChatsView.h"
#import "ContactsManager.h"
#import "GLPProfileViewController.h"
#import "UIViewController+GAI.h"
#import "UIViewController+Flurry.h"

#import "GLPThemeManager.h"
#import "GLPIntroducedProfile.h"

const int textViewSizeOfLine = 12;
const int flexibleResizeLimit = 120;
const int limitTimeBar = 3600;
double timingBarCurrentWidth;
double resizeFactor;

float currentTime = 450;
CGRect firstTimingBarSize;
float timeInterval = 0.1;

@interface ViewTopicViewController ()

@property (weak, nonatomic) IBOutlet UIView *formView;
@property (weak, nonatomic) IBOutlet UITextField *formTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet HPGrowingTextView *formTextView;

@property (assign, nonatomic) float keyboardAppearanceSpaceY;
@property (strong, nonatomic) NSMutableArray *messages;

@property (assign, nonatomic) GLPLoadingCellStatus loadingCellStatus;
@property (assign, nonatomic) GLPLoadingCellStatus bottomLoadingCellStatus;
@property (assign, nonatomic) BOOL tableViewInScrolling;
@property (assign, nonatomic) BOOL tableViewDisplayedLoadingCell;
@property (assign, nonatomic) BOOL inLoading;

@property (assign, nonatomic) BOOL firstInitialization;


@property (strong, nonatomic) IBOutlet CurrentChatButton *currentChat;

@property (strong, nonatomic) LiveChatsView *liveChatsView;


@property (strong, nonatomic) NSTimer *timer1;

@property (strong, nonatomic) UIView *oldTitleView;

@property (assign, nonatomic) int selectedUserId;



- (IBAction)sendButtonClicked:(id)sender;
- (IBAction)tableViewClicked:(id)sender;

@end

@implementation ViewTopicViewController

@synthesize conversation=_conversation;
@synthesize messages=_messages;
@synthesize firstInitialization=_firstInitialization;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureTableView];
    
    [self loadElements];
    
    [self configureNavigationBar];
    
    [self configureForm];
    
    [self configureHeader];

    
//    [self.view setBackgroundColor:[UIColor colorWithRed:0.0/255.0f green:201.0/255.0f blue:201.0/255.0f alpha:1.0]];

}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    if(self.tableView.frame.size.height < 465.0f)
    {

        [self.tableView setFrame:CGRectMake(0, 0, 320, 460)];

    }
    
    
    //[AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar2" forBarMetrics:UIBarMetricsDefault];


    // keyboard management
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMessageFromNotification:) name:GLPNOTIFICATION_NEW_MESSAGE object:nil];
    
    
    //[self.tabBarController.tabBar setHidden:YES];
    
    // reload messages when coming back from other VC
    [self configureMessages];
    [self loadInitialMessages];
    
    //TODO: Add that to the new implementation.
    
    if(_conversation.key == 0 && !_conversation.isLive)
    {
        [ConversationManager saveConversation:_conversation];
        
    }
    
    

//    [self loadElements];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tabBarController.tabBar setHidden:YES];
//    [self.navigationController setNavigationBarHidden:NO];

    
    [self sendViewToGAI:NSStringFromClass([self class])];
    [self sendViewToFlurry:NSStringFromClass([self class])];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSUInteger numberOfViewControllersOnStack = [self.navigationController.viewControllers count];
    UIViewController *parentViewController = self.navigationController.viewControllers[numberOfViewControllersOnStack - 1];
    Class parentVCClass = [parentViewController class];
    NSString *className = NSStringFromClass(parentVCClass);
    
    if([className isEqualToString:@"ChatViewController"])
    {
//        [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
//        [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar_trans" forBarMetrics:UIBarMetricsDefault];
        [self.tabBarController.tabBar setHidden:NO];
//        [self.navigationController setNavigationBarHidden:YES];
    }
    else
    {
//        [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
        //[AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar2" forBarMetrics:UIBarMetricsDefault];
        //[AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:[[GLPThemeManager sharedInstance] imageForNavBar] forBarMetrics:UIBarMetricsDefault];
        
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPNewMessage" object:nil];
    
    //Hide live chats view.
    [self.liveChatsView removeView];
    

}

- (void)viewDidDisappear:(BOOL)animated
{

}

-(void)configureHeader
{
    if([self isNewChat])
    {
        //Add header the introduced view.
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"GLPIntroducedProfile" owner:self options:nil];
        
        GLPIntroducedProfile * introduced = [array objectAtIndex:0];
        
        /**
         [titleLabel setTitle:_conversation.title forState:UIControlStateNormal];
         titleLabel.tag = [_conversation getUniqueParticipant].remoteKey;
         */
        
        [introduced updateContents:[_conversation getUniqueParticipant]];
        
        introduced.delegate = self;
        
        self.tableView.tableHeaderView = introduced;
    }
}


- (void)configureMessages
{
    // previous message top loading cell not displayed at the beginning
    self.loadingCellStatus = kGLPLoadingCellStatusFinished;
    self.tableViewDisplayedLoadingCell = NO;
    
    // new messages bottom loading cell
    self.bottomLoadingCellStatus = kGLPLoadingCellStatusFinished; //kGLPLoadingCellStatusInit;
    
    self.inLoading = NO;
    self.tableViewInScrolling = NO;

    self.messages = [NSMutableArray array];
    [self.tableView reloadData];
}

-(void) loadElements
{
    //TODO: Why this is here ? self response: because of livechatview probably

    self.keyboardAppearanceSpaceY = 0;
    
    if(_conversation.isLive) {
        //[self configureTimeBar];
        [self configureNavigationBarButton];
    } else {
//        [self hideTimeBarAndMaximizeTableView];
    }
    //[self hideTimeBarAndMaximizeTableView];

    
//    [self loadInitialMessages];
}

- (void)reloadElements
{
    [self configureMessages];
    [self loadElements];
}

//-(void) hideTimeBarAndMaximizeTableView
//{
//    self.timingBar.hidden = YES;
//    self.backTimingBar.hidden = YES;
//    //Remove the live chat button.
//    
//    
//    CGRect tableViewFrame = self.tableView.frame;
//    
//    
//    
//    [self.tableView setFrame:CGRectMake(tableViewFrame.origin.x, tableViewFrame.origin.y-7, tableViewFrame.size.width, tableViewFrame.size.height+8)];
//}

//-(void) configureTimeBar
//{
//    timingBarCurrentWidth = 320;
//
//    //Calculate the resizing factor.
//    [self calculateTheResizingFactor];
//    
//    firstTimingBarSize = self.timingBar.frame;
//    self.timer1 = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(animateTimeBar:) userInfo:nil repeats:YES];
//    [self.timer1 fire];
//}

-(void)calculateTheResizingFactor
{
    double firstElement = currentTime/timeInterval;
    
    resizeFactor = timingBarCurrentWidth/firstElement;
    
}

-(void) animateTimeBar: (id)sender
{
    //TODO: COMPLETE AND UNCOMMENT
//    //Calculate how many points needs to resize the timing bar.
//    float currentWidth = self.timingBar.frame.size.width;
//    timingBarCurrentWidth = timingBarCurrentWidth - resizeFactor;
//    
//    [self.timingBar setFrame:CGRectMake(firstTimingBarSize.origin.x, firstTimingBarSize.origin.y, timingBarCurrentWidth, firstTimingBarSize.size.height)];
//    
//    currentTime-=0.1;
//    
//    //NSLog(@"Current Time: %f : %f",currentTime, timingBarCurrentWidth);
//    
//    
//    //Shrink the timing bar.
//    
//    
}


- (IBAction)myAction:(UIButton *)sender forEvent:(UIEvent *)event
{
    
    //NSSet *touches = [event touchesForView:sender];
    //UITouch *touch = [touches anyObject];
    //CGPoint touchPoint = [touch locationInView:sender];
    
    UIButton *btn = (UIButton*) sender;
    
    btn.center = [[[event allTouches] anyObject] locationInView:self.view];
}



#pragma mark - Init and config

- (void)configureNavigationBar
{

    [self.navigationController setNavigationBarHidden:NO];

    // navigate to profile through navigation bar for user-to-user conversation
    if(!_conversation.isGroup && ![self isNewChat])
    {
        //Create a button instead of using the default title view for recognising gestures.
        UIButton *titleLabel = [UIButton buttonWithType:UIButtonTypeCustom];
        [titleLabel setTitle:_conversation.title forState:UIControlStateNormal];
        titleLabel.tag = [_conversation getUniqueParticipant].remoteKey;
        
        //Set colour to the view.
        [titleLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        //Set navigation to profile selector.
        titleLabel.frame = CGRectMake(0, 0, 70, 44);
        [titleLabel addTarget:self action:@selector(navigateToProfile:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.titleView = titleLabel;
    }
    
    if([self isNewChat])
    {
        self.title = @"Connected";
    }
    else
    {
        self.title = _conversation.title;
    }

//    [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar2" forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, nil]];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    self.navigationController.navigationBar.translucent = NO;
    
    [self.navigationController.navigationBar setTranslucent:YES];
    
    [AppearanceHelper setNavigationBarFontFor:self];
    
    
    [AppearanceHelper setNavigationBarColour:self];

    

}

/**
 
 -(void)configureNavigationBar
 {
 //    [self setNeedsStatusBarAppearanceUpdate];
 self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
 
 //Change the format of the navigation bar.
 //    [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:nil forBarMetrics:UIBarMetricsDefault];
 [AppearanceHelper setNavigationBarColour:self];
 
 //    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, nil]];
 
 [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
 
 [AppearanceHelper setNavigationBarFontFor:self];
 
 [self.navigationController.navigationBar setTranslucent:NO];
 
 [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
 
 }
 
 */

-(void)configureNavigationBarButton
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"multipleusersicon"]];
    [imageView setFrame:CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, 32, 32)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    UIButton *btnBack=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(navigateToChat:) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = imageView.bounds;
    [imageView addSubview:btnBack];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)configureForm
{
    self.formTextView.isScrollable = NO;
    self.formTextView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
	self.formTextView.minNumberOfLines = 1;
	self.formTextView.maxNumberOfLines = 4;
	self.formTextView.returnKeyType = UIReturnKeyDefault;
	self.formTextView.font = [UIFont systemFontOfSize:15.0f];
	self.formTextView.delegate = self;
    self.formTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    
    self.formTextView.backgroundColor = [UIColor whiteColor];
    self.formTextView.placeholder = @"Your message";
    
    // center vertically because textview height varies from ios version to screen
    CGRect formTextViewFrame = self.formTextView.frame;
    formTextViewFrame.origin.y = (self.formView.frame.size.height - self.formTextView.frame.size.height) / 2;
    self.formTextView.frame = formTextViewFrame;
    
    self.formTextView.layer.cornerRadius = 5;
}

- (void)configureTableView
{
    [self.tableView registerNib:[UINib nibWithNibName:kGLPLoadingCellNibName bundle:nil] forCellReuseIdentifier:kGLPLoadingCellIdentifier];
}


#pragma mark - Messages management

//// Load messages the first time
//- (void)loadInitalMessages
//{
//    if(self.inLoading) {
//        return;
//    }
//    
//    NSLog(@"Load initial messages");
//    self.inLoading = YES;
//    
//    [ConversationManager loadMessagesForConversation:self.conversation localCallback:^(NSArray *messages) {
//        if(messages.count > 0) {
//            self.messages = [messages mutableCopy];
//            
//            [self configureDisplayForMessages:self.messages];
//            [self.tableView reloadData];
//            [self scrollToTheEndAnimated:NO];
//        }
//    } remoteCallback:^(BOOL success, NSArray *newMessages) {
//        NSLog(@"Load initial messages remote callback success %d - new messages %d", success, newMessages.count);
//        
//        if(success) {
//            
//            // new messages to insert
//            if(newMessages && newMessages.count > 0) {
//                
//                // there is already messages from local callback, add with animation
//                if(self.messages.count > 0) {
//                    int firstIndex = self.messages.count;
//                    int lastIndex = self.messages.count + newMessages.count - 1;
//                    
//                    // insert messages after existing ones
//                    [self.messages insertObjects:newMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(firstIndex, newMessages.count)]];
//                    
//                    // set to delete the bottom loading cell
//                    self.bottomLoadingCellStatus = kGLPLoadingCellStatusFinished;
//                    
//                    // configure the display for new messages
//                    // existing messages wont need to change appearance
//                    [self configureDisplayForMessages: self.messages];
//                    
//                    // start updating tableview
//                    [self.tableView beginUpdates];
//                    
//                    // delete the bottom loading cell
//                    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:firstIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//                    
//                    // create new indexpaths for new rows starting at the end of existing messages
//                    // at this point we dont have top loading cell
//                    NSMutableArray *rowsInsertIndexPath = [[NSMutableArray alloc] init];
//                    for (NSInteger i = firstIndex; i <= lastIndex; i++) {
//                        NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
//                        [rowsInsertIndexPath addObject:tempIndexPath];
//                    }
//                    
//                    // insert the rows
//                    [self.tableView insertRowsAtIndexPaths:rowsInsertIndexPath withRowAnimation:UITableViewRowAnimationFade];
//                    
//                    [self.tableView endUpdates];
//                }
//                
//                // no existing messages, so just add the new ones at the beginning
//                else {
//                    self.messages = [newMessages mutableCopy];
//                    
//                    // configure the display
//                    [self configureDisplayForMessages:self.messages];
//                    
//                    // set to delete the bottom loading cell
//                    self.bottomLoadingCellStatus = kGLPLoadingCellStatusFinished;
//                    
//                    [self.tableView beginUpdates];
//                    
//                    // delete the bottom loading cell
//                    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//                    
//                    // create index paths
//                    NSMutableArray *rowsInsertIndexPath = [[NSMutableArray alloc] init];
//                    for (NSInteger i = 0; i < self.messages.count; i++) {
//                        NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
//                        [rowsInsertIndexPath addObject:tempIndexPath];
//                    }
//                    
//                    // insert the rows
//                    [self.tableView insertRowsAtIndexPaths:rowsInsertIndexPath withRowAnimation:UITableViewRowAnimationFade];
//                    
//                    [self.tableView endUpdates];
//                }
//                
//                // after populating table view, scroll to the last message
//                [self scrollToTheEndAnimated:YES];
//            }
//            
//            // no remote messages to insert
//            else {
//                // just remove the bootom loading cell
//                [self removeBottomLoadingCellWithAnimation:UITableViewRowAnimationFade];
//            }
//            
//            // if there some messages after the initial loading, maybe there is some previous messages as well
//            // activate the top loading cell
//            if(self.messages.count > 0) {
//                self.loadingCellStatus = kGLPLoadingCellStatusInit;
//                
//                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//                [self scrollToTheEndAnimated:NO];
//            }
//            
//        // error from remote request
//        } else {
//            // remove the bootom loading cell
//            [self removeBottomLoadingCellWithAnimation:UITableViewRowAnimationFade];
//            
//            //TODO: show better error
//            [WebClientHelper showStandardError];
//        }
//        
//        self.inLoading = NO;
//    }];
//    
//    // conversation has no more unread messages
//    [ConversationManager markConversationRead:self.conversation];
//}

- (void)loadInitialMessages
{
    if(self.inLoading) {
        return;
    }
    
    DDLogInfo(@"Load initial messages");
    self.inLoading = YES;
    
    NSArray *messages = [ConversationManager loadMessagesForConversation:self.conversation];
    [self loadInitialMessagesLocalCallback:messages];
    
    if(messages.count < 20) {
        DDLogInfo(@"Load previous messages");
        
        [ConversationManager loadPreviousMessagesForConversation:self.conversation before:[messages firstObject] localCallback:^(NSArray *messages) {
            // do nothing so far
        } remoteCallback:^(BOOL success, NSArray *previousMessages) {
            DDLogInfo(@"Previous messages remote callback %d", previousMessages.count);
            
            // insert messages before existing ones
            [self.messages insertObjects:previousMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, previousMessages.count)]];
            
            [self configureDisplayForMessages:self.messages];
            [self.tableView reloadData];
            [self scrollToTheEndAnimated:NO];
            
            self.inLoading = NO;
        }];
    }
    
    
    
    
//    [ConversationManager loadMessagesForConversation:self.conversation localCallback:^(NSArray *messages) {
//        [self loadInitialMessagesLocalCallback:messages];
//    } remoteCallback:^(BOOL success, NSArray *messages) {
//        [self loadInitialMessagesRemoteCallback:success newMessages:messages];
//    }];
    
    // conversation has no more unread messages
//    if(!_conversation.isLive) {
//        [ConversationManager markConversationRead:self.conversation];
//    }
}

//- (void)loadInitialMessages:(BOOL)live
//{
//    if(self.inLoading) {
//        return;
//    }
//    
//    NSLog(@"Load initial messages");
//    self.inLoading = YES;
//    
//    if(live) {
//        [LiveConversationManager loadMessagesForLiveConversation:self.liveConversation localCallback:^(NSArray *messages) {
//            [self loadInitialMessagesLocalCallback:messages];
//        } remoteCallback:^(BOOL success, NSArray *newMessages) {
//            [self loadInitialMessagesRemoteCallback:success newMessages:newMessages];
//        }];
//    } else {
//        [ConversationManager loadMessagesForConversation:self.conversation localCallback:^(NSArray *messages) {
//            [self loadInitialMessagesLocalCallback:messages];
//        } remoteCallback:^(BOOL success, NSArray *messages) {
//            [self loadInitialMessagesRemoteCallback:success newMessages:messages];
//        }];
//        
//        // conversation has no more unread messages
//        [ConversationManager markConversationRead:self.conversation];
//    }
//}

- (void)loadInitialMessagesLocalCallback:(NSArray *)messages
{
    if(messages.count > 0) {
        self.messages = [messages mutableCopy];
        
        [self configureDisplayForMessages:self.messages];
        [self.tableView reloadData];
        [self scrollToTheEndAnimated:NO];
    }
}

- (void)loadInitialMessagesRemoteCallback:(BOOL)success newMessages:(NSArray *)newMessages
{
    NSLog(@"Load initial messages remote callback success %d - new messages %d", success, newMessages.count);
    
    if(success) {
        
        // new messages to insert
        if(newMessages && newMessages.count > 0) {
            
            // there is already messages from local callback, add with animation
            if(self.messages.count > 0) {
                int firstIndex = self.messages.count;
                int lastIndex = self.messages.count + newMessages.count - 1;
                
                // insert messages after existing ones
                [self.messages insertObjects:newMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(firstIndex, newMessages.count)]];
                
                // set to delete the bottom loading cell
                self.bottomLoadingCellStatus = kGLPLoadingCellStatusFinished;
                
                // configure the display for new messages
                // existing messages wont need to change appearance
                [self configureDisplayForMessages: self.messages];
                
                // start updating tableview
                [self.tableView beginUpdates];
                
                // delete the bottom loading cell
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:firstIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                
                // create new indexpaths for new rows starting at the end of existing messages
                // at this point we dont have top loading cell
                NSMutableArray *rowsInsertIndexPath = [[NSMutableArray alloc] init];
                for (NSInteger i = firstIndex; i <= lastIndex; i++) {
                    NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [rowsInsertIndexPath addObject:tempIndexPath];
                }
                
                // insert the rows
                [self.tableView insertRowsAtIndexPaths:rowsInsertIndexPath withRowAnimation:UITableViewRowAnimationFade];
                
                [self.tableView endUpdates];
            }
            
            // no existing messages, so just add the new ones at the beginning
            else {
                self.messages = [newMessages mutableCopy];
                
                // configure the display
                [self configureDisplayForMessages:self.messages];
                
                // set to delete the bottom loading cell
                self.bottomLoadingCellStatus = kGLPLoadingCellStatusFinished;
                
                [self.tableView beginUpdates];
                
                // delete the bottom loading cell
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                
                // create index paths
                NSMutableArray *rowsInsertIndexPath = [[NSMutableArray alloc] init];
                for (NSInteger i = 0; i < self.messages.count; i++) {
                    NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [rowsInsertIndexPath addObject:tempIndexPath];
                }
                
                // insert the rows
                [self.tableView insertRowsAtIndexPaths:rowsInsertIndexPath withRowAnimation:UITableViewRowAnimationFade];
                
                [self.tableView endUpdates];
            }
            
            // after populating table view, scroll to the last message
            [self scrollToTheEndAnimated:YES];
        }
        
        // no remote messages to insert
        else {
            // just remove the bootom loading cell
            [self removeBottomLoadingCellWithAnimation:UITableViewRowAnimationFade];
        }
        
        // if there some messages after the initial loading, maybe there is some previous messages as well
        // activate the top loading cell
        if(self.messages.count > 0 && self.conversation) {
            self.loadingCellStatus = kGLPLoadingCellStatusInit;
            
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [self scrollToTheEndAnimated:NO];
        }
        
        // error from remote request
    } else {
        // remove the bootom loading cell
        [self removeBottomLoadingCellWithAnimation:UITableViewRowAnimationFade];
        
        //TODO: show better error
        [WebClientHelper showStandardError];
    }
    
    self.inLoading = NO;
}

// Activated only when loadInitialMessages is complete
- (void)loadPreviousMessages
{
    if(self.loadingCellStatus != kGLPLoadingCellStatusInit) {
        return;
    }
    
    NSLog(@"Load previous messages");
    
    [ConversationManager loadPreviousMessagesBefore:self.messages[0] callback:^(BOOL success, BOOL remains, NSArray *previousMessages) {
        
        if(success) {
            
            // previous messages to insert
            if(previousMessages.count > 0) {
                NSLog(@"before msgs %d - %d", previousMessages.count, self.messages.count);
                
                // insert messages before existing ones
                [self.messages insertObjects:previousMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, previousMessages.count)]];
                
                NSLog(@"full %d - tableview count %d - %d", self.messages.count, [self.tableView numberOfRowsInSection:0], [self tableView:self.tableView numberOfRowsInSection:0]);
                
                
                // configure the display
                [self configureDisplayForMessages:self.messages];
                
                // re-init or set to delete the top loading cell
                self.loadingCellStatus = (NO) ? kGLPLoadingCellStatusInit : kGLPLoadingCellStatusFinished;
                
                [self updateTableWithNewRowCount:previousMessages.count];
                
//                // insert in the tableview while saving the scrolling state
//                CGPoint tableViewOffset = [self.tableView contentOffset];
//                [UIView setAnimationsEnabled:NO];
//                [self.tableView beginUpdates];
//                
//                // remove top loading cell if need, otherwise keep it animated
//                if(self.loadingCellStatus == kGLPLoadingCellStatusFinished) {
//                    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//                }
//                
                // new rows total height for saving the scrolling state
//                int heightForNewRows = 0;
//                
//                // add 1 if the top loading cell is present
//                int topLoadingCellCount = (self.loadingCellStatus == kGLPLoadingCellStatusFinished) ? 0 : 1;
//                
//                // create new indexpaths for new rows starting at 1 because 0 is the top loading cell
//                NSMutableArray *rowsInsertIndexPath = [[NSMutableArray alloc] init];
//                for (NSInteger i = 0; i < previousMessages.count; i++) {
//                    // index path
//                    NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:i+topLoadingCellCount inSection:0];
//                    [rowsInsertIndexPath addObject:tempIndexPath];
//                    
//                    // add the row height
//                    heightForNewRows = heightForNewRows + [self tableView:self.tableView heightForRowAtIndexPath:tempIndexPath];
//                    
//                    NSLog(@"insert %d", tempIndexPath.row);
//                }
//                
//                // insert the rows
//                [self.tableView insertRowsAtIndexPaths:rowsInsertIndexPath withRowAnimation:UITableViewRowAnimationNone];
//                
//                // reload every other rows because the configuration may changes (which message follows which, etc)
//                NSMutableArray *reloadRowsIndexPaths = [[NSMutableArray alloc] init];
//                for (NSInteger i = previousMessages.count; i < self.messages.count; i++) {
//                    // index path
//                    NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:i+topLoadingCellCount inSection:0];
//                    [reloadRowsIndexPaths addObject:rowIndexPath];
//                    NSLog(@"reload %d", rowIndexPath.row);
//                }
////                [self.tableView reloadRowsAtIndexPaths:reloadRowsIndexPaths withRowAnimation:UITableViewRowAnimationNone];
//                
//                NSLog(@"msgs %d - %d", self.messages.count, [self tableView:self.tableView numberOfRowsInSection:0]);
//                
//                
//                tableViewOffset.y += heightForNewRows;
//                
//                for(int i=0; i < 20; i++) {
//                    id cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
//                    NSLog(@"%d - %@", i, NSStringFromClass([cell class]));
//                }
//                
//                [self.tableView endUpdates];
//                [self.tableView setContentOffset:tableViewOffset animated:NO];
//                [UIView setAnimationsEnabled:YES];
//                
//                NSLog(@"msgs %d - %d", self.messages.count, [self tableView:self.tableView numberOfRowsInSection:0]);
                
            } else { // no messages from remote
                // remove top loading cell
                self.loadingCellStatus = kGLPLoadingCellStatusFinished;
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
        } else { // error from remote
            // show error on top loading cell
            self.loadingCellStatus = kGLPLoadingCellStatusError;
            [self reloadLoadingCell];
        }
    }];
}

- (void)configureDisplayForMessages:(NSArray *)messages
{
    for (int i = 0; i < messages.count; i++) {
        GLPMessage *current = messages[i];
        
        if(i == 0) {
            [current configureAsFirstMessage];
        } else {
            GLPMessage *previous = messages[i-1];
            [current configureAsFollowingMessage:previous];
        }
    }
}

- (void)showMessageFromNotification:(NSNotification *)notification
{
    GLPMessage *message = [notification userInfo][@"message"];
    NSLog(@"Show message from notification %@ : Date: %@", message, message.date);
    
    if(_conversation.remoteKey != message.conversation.remoteKey) {
        NSLog(@"Long poll message is not for the current conversation, ignore");
        return;
    }
    
    [self showMessage:message];
    
    // conversation has no more unread messages
    if(!_conversation.isLive) {
        [ConversationManager markConversationRead:self.conversation];
    }
}

- (void)showMessage:(GLPMessage *)message
{
    if(self.messages.count == 0) {
        [message configureAsFirstMessage];
    } else {
        GLPMessage *last = self.messages[self.messages.count - 1];
        [message configureAsFollowingMessage:last];
    }
    
    [self.messages addObject:message];
    [self.tableView reloadData];
    
    [self scrollToTheEndAnimated:YES];
}

- (void)createMessageFromForm
{
    [UIView animateWithDuration:2.0f animations:^{
       
        //Remove header view after first message.
        [self.tableView.tableHeaderView setAlpha:0.0f];
    }];
    
    
    [ConversationManager createMessageWithContent:self.formTextView.text toConversation:self.conversation localCallback:^(GLPMessage *localMessage) {
        [self showMessage:localMessage];
    }];
    
    self.formTextView.text = @"";
}


#pragma mark - Actions

- (IBAction)sendButtonClicked:(id)sender
{
    if([self.formTextView.text isEmpty]) {
        return;
    }
    
    [self createMessageFromForm];
}

- (IBAction)tableViewClicked:(id)sender
{
    [self hideKeyboardFromTextViewIfNeeded];
    
    //Hide the live chats bubble if exist.
    [self.liveChatsView removeView];
}


-(void) navigateToChat: (id)sender
{
    NSLog(@"here cl");
    if(![LiveChatsView visible])
    {
        self.liveChatsView = [LiveChatsView loadingViewInView:[self.view.window.subviews objectAtIndex:0]];
        self.liveChatsView.viewTopic = self;
        [LiveChatsView setVisibility:YES];
    }
    else
    {
        [self.liveChatsView removeView];
        [LiveChatsView setVisibility:NO];
        

    }

}

-(void)addImageToTheChat: (id)sender
{
    NSLog(@"Camera icon pushed!");
}

-(void)navigateToProfile:(id)sender
{
    
    if([sender isKindOfClass:[UITapGestureRecognizer class]])
    {
        UITapGestureRecognizer *incomingUser = (UITapGestureRecognizer*) sender;
        
        UIImageView *incomingView = (UIImageView*)incomingUser.view;
        
        self.selectedUserId = incomingView.tag;
   
    }
    else if([sender isKindOfClass:[UIButton class]])
    {
        UIButton *userButton = (UIButton*)sender;
        
        self.selectedUserId = userButton.tag;
        
    }
    
    
    if((self.selectedUserId == [[SessionManager sharedInstance]user].remoteKey))
    {
        self.selectedUserId = -1;
        //Navigate to profile view controller.
        [self performSegueWithIdentifier:@"view profile" sender:self];
        
        
    }
    else if([[ContactsManager sharedInstance] navigateToUnlockedProfileWithSelectedUserId:self.selectedUserId])
    {
        
        [self performSegueWithIdentifier:@"view private profile" sender:self];
    }
    else
    {
        //Navigate to private view controller.
        
        [self performSegueWithIdentifier:@"view private profile" sender:self];
    }

}


#pragma mark - Table view

- (void)removeBottomLoadingCellWithAnimation:(UITableViewRowAnimation)animation
{
    
    self.bottomLoadingCellStatus = kGLPLoadingCellStatusFinished;
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messages.count inSection:0]] withRowAnimation:animation];
}

-(void) updateTableWithNewRowCount:(int)rowCount
{
    CGPoint tableViewOffset = [self.tableView contentOffset];
    
    [UIView setAnimationsEnabled:NO];
    
//    [self.tableView beginUpdates];
    
    NSMutableArray *rowsInsertIndexPath = [[NSMutableArray alloc] init];
    
    int heightForNewRows = 0;
    heightForNewRows -= 40;
    
    for (NSInteger i = 0; i < rowCount; i++) {
        NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:i+1 inSection:0];
        [rowsInsertIndexPath addObject:tempIndexPath];

        heightForNewRows = heightForNewRows + [self tableView:self.tableView heightForRowAtIndexPath:tempIndexPath];
    }


//    [self reloadLoadingCell];
//    [self.tableView insertRowsAtIndexPaths:rowsInsertIndexPath withRowAnimation:UITableViewRowAnimationNone];
    
    tableViewOffset.y += heightForNewRows;
    
    if(tableViewOffset.y < 0) {
        tableViewOffset.y = 0;
    }
    
    [self.tableView reloadData];
    [self.tableView setContentOffset:tableViewOffset animated:NO];
    
    
    [UIView setAnimationsEnabled:YES];
}

- (void)reloadLoadingCell
{
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = self.messages.count;
    
    // add top loading cell
    if([self hasTopLoadingCellRow]) {
        count++;
    }
    
    // add bottom loading cell
    if([self hasBottomLoadingCellRow]) {
        count++;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // display one of the loading rows
    if([self isLoadingCellForIndexPath:indexPath]) {
        GLPLoadingCell *loadingCell = [tableView dequeueReusableCellWithIdentifier:kGLPLoadingCellIdentifier forIndexPath:indexPath];

        // top loading cell
        if([self hasTopLoadingCellRow] && indexPath.row == [self getTopLoadingCellRow]) {
            [loadingCell updateWithStatus:self.loadingCellStatus];
            loadingCell.delegate = self;
            [loadingCell.loadMoreButton setTitle:@"Load more messages" forState:UIControlStateNormal];
        }
        
        // bottom loading cell
        else if([self hasBottomLoadingCellRow] && indexPath.row == [self getBottomLoadingCellRow]) {
            [loadingCell updateWithStatus:self.bottomLoadingCellStatus];
            loadingCell.shouldShowError = NO; // we dont want to show error at the bottom, we will just remove it
        }
        
        return loadingCell;
    }
    
    // otherwise display message
    GLPMessage *message = [self getMessageForIndexPath:indexPath];
    
    
    NSAssert(message.cellIdentifier, @"Cell identifier is required but null");
    
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:message.cellIdentifier forIndexPath:indexPath];
    
    //Add touch gesture to avatar image view.
     UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigateToProfile:)];
     [tap setNumberOfTapsRequired:1];
     [cell.avatarImageView addGestureRecognizer:tap];
    
    [cell updateWithMessage:message first:message.hasHeader];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self isLoadingCellForIndexPath:indexPath]) {
        return kGLPLoadingCellHeight;
    }
    
    GLPMessage *message = [self getMessageForIndexPath:indexPath];
    return [MessageCell getCellHeightWithContent:message.content first:message.hasHeader];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 0 && self.loadingCellStatus == kGLPLoadingCellStatusInit) {
        NSLog(@"Display and activate top loading cell");
        [self performSelector:@selector(loadPreviousMessages) withObject:nil];
        
//        // tableview in scrolling, delay the loading when scroll is finished
//        if(self.tableViewInScrolling) {
//            self.tableViewDisplayedLoadingCell = YES;
//        } else {
//            [self loadPreviousMessages];
//        }
    }
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if(indexPath.row == 0 && self.loadingCellStatus == kGLPLoadingCellStatusError) {
//        self.loadingCellStatus = kGLPLoadingCellStatusInit;
//        [self reloadLoadingCell];
//    }
//}


- (void)scrollToTheEndAnimated:(BOOL)animated
{
    if(self.messages.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
    }
}

- (int)getTopLoadingCellRow
{
    return 0;
}

// has top cell row only if messages are not empty
- (BOOL)hasTopLoadingCellRow
{
    return self.loadingCellStatus != kGLPLoadingCellStatusFinished && self.messages.count > 0;
}

- (int)getBottomLoadingCellRow
{
    // after the last message
    int row = self.messages.count;
    
    // add +1 if there is a top loading cell row
    if([self hasTopLoadingCellRow]) {
        row++;
    }
    
    return row;
}

- (BOOL)hasBottomLoadingCellRow
{
    return self.bottomLoadingCellStatus != kGLPLoadingCellStatusFinished;
}

- (BOOL)isLoadingCellForIndexPath:(NSIndexPath *)indexPath
{
    return ([self hasTopLoadingCellRow] && indexPath.row == [self getTopLoadingCellRow]) ||
    ([self hasBottomLoadingCellRow] && indexPath.row == [self getBottomLoadingCellRow]);
}

- (int)getMessageRowForIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    
    // top loading cell, remove additional 1
    if([self hasTopLoadingCellRow]) {
        row--;
    }
    
    NSAssert(row >= 0, @"Message row %d for indexpath %d cannot be negative", row, indexPath.row);
    
    return row;
}

- (GLPMessage *)getMessageForIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:[self getMessageRowForIndexPath:indexPath]];
}


#pragma mark - Scroll

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.tableViewInScrolling = YES;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    self.tableViewInScrolling = NO;
    
    if(self.tableViewDisplayedLoadingCell) {
        NSIndexPath *firstVisibleIndexPath = [[self.tableView indexPathsForVisibleRows] objectAtIndex:0];
        
        if(firstVisibleIndexPath.row == 0) {
            [self loadPreviousMessages];
        }
        
        self.tableViewDisplayedLoadingCell = NO;
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.identifier isEqualToString:@"view private profile"])
    {
        
        GLPPrivateProfileViewController *ppvc = segue.destinationViewController;
        
//        if(self.participants.count == 0)
//        {
//            NSArray *participants = self.liveConversation.participants;
//            
//            for(GLPUser *participant in participants)
//            {
//                if(participant.remoteKey != [[SessionManager sharedInstance]user].remoteKey)
//                {
//                    ppvc.selectedUserId = participant.remoteKey;
//                }
//            }
//            
//            
//            //ppvc.selectedUserId = ;
//        }
//        else
//        {
//            ppvc.selectedUserId = [[self.participants objectAtIndex:0] remoteKey];
//        }
        
        
        ppvc.selectedUserId = self.selectedUserId;
        
    }
    else if([segue.identifier isEqualToString:@"view profile"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
//        GLPProfileViewController *profileViewController = segue.destinationViewController;
//
//        GLPUser *incomingUser = [[GLPUser alloc] init];
//        
//        incomingUser.remoteKey = self.selectedUserId;
//        
//        if(self.selectedUserId == -1)
//        {
//            incomingUser = nil;
//        }
//        
//        profileViewController.incomingUser = incomingUser;
    }
}

#pragma mark - Helper methods

-(BOOL)isNewChat
{
    NSUInteger numberOfViewControllersOnStack = [self.navigationController.viewControllers count];
    UIViewController *parentViewController = self.navigationController.viewControllers[numberOfViewControllersOnStack - 2];
    Class parentVCClass = [parentViewController class];
    NSString *className = NSStringFromClass(parentVCClass);

    if([className isEqualToString:@"ChatViewAnimationController"])
    {
        //Add header the introduced view.
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];

        
        return YES;
    }
    
//    if(numberOfViewControllersOnStack == 1)
//    {
//        [self performSelector:@selector(dismiss:) withObject:nil afterDelay:2.0f];
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];
//        
//        return YES;
//    }
    
    return NO;
}

-(void)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Loading Cell Delegate

- (void)loadingCellDidReload
{
    // only the top loading cell can show error so we dont have to determine which loading cell is reloaded
    [self loadPreviousMessages];
}


#pragma mark - form management

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
	CGRect containerFrame = self.formView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
	CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.height = containerFrame.origin.y - self.tableView.frame.origin.y;
    
    [UIView animateWithDuration:[duration doubleValue] delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|(animationCurve << 16)) animations:^{
        self.formView.frame = containerFrame;
        self.tableView.frame = tableViewFrame;
        
        [self scrollToTheEndAnimated:NO];
        
    } completion:^(BOOL finished) {
        [self.tableView setNeedsLayout];
    }];
}

- (void)keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curve.intValue;
	
	// get a rect for the textView frame
	CGRect containerFrame = self.formView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
	CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.height = containerFrame.origin.y - self.tableView.frame.origin.y;
    
    [UIView animateWithDuration:[duration doubleValue] delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|(animationCurve << 16)) animations:^{
        self.formView.frame = containerFrame;
        self.tableView.frame = tableViewFrame;
        
    } completion:^(BOOL finished) {
        [self.tableView setNeedsLayout];
    }];
}

- (void)hideKeyboardFromTextViewIfNeeded
{
    if([self.formTextView isFirstResponder]) {
        [self.formTextView resignFirstResponder];
    }
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = self.formView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	self.formView.frame = r;
    
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.height += diff;
    self.tableView.frame = tableViewFrame;
    
    [self scrollToTheEndAnimated:NO];
}


@end
