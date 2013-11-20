//
//  ViewTopicViewController.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ViewTopicViewController.h"
#import "PrivateProfileViewController.h"

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
#import "LiveConversationManager.h"

#import "GLPMessage.h"
#import "GLPMessage+CellLogic.h"
#import "GLPUser.h"

#import "CurrentChatButton.h"

#import <QuartzCore/QuartzCore.h>

#import "LiveChatsView.h"
#import "ContactsManager.h"
#import "ProfileViewController.h"

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


@property (strong, nonatomic) IBOutlet CurrentChatButton *currentChat;

@property (strong, nonatomic) LiveChatsView *liveChatsView;

/** Timing panel. */
@property (strong, nonatomic) IBOutlet UIImageView *timingBar;
@property (strong, nonatomic) IBOutlet UIImageView *backTimingBar;

@property (strong, nonatomic) NSTimer *timer1;

@property (strong, nonatomic) UIView *oldTitleView;

@property (assign, nonatomic) int selectedUserId;

- (IBAction)sendButtonClicked:(id)sender;
- (IBAction)tableViewClicked:(id)sender;

@end

@implementation ViewTopicViewController

@synthesize conversation;
@synthesize messages=_messages;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureTableView];
    
    // previous message top loading cell not displayed at the beginning
    self.loadingCellStatus = kGLPLoadingCellStatusFinished;
    self.tableViewDisplayedLoadingCell = NO;
    
    // new messages bottom loading cell
    self.bottomLoadingCellStatus = kGLPLoadingCellStatusInit;
    
    self.inLoading = NO;
    self.tableViewInScrolling = NO;
    
    [self loadElements];
}


-(void) loadElements
{
    //TODO: Why this is here ?
    [self configureNavigationBar];
    [self configureForm];
    
    if(self.randomChat) {
        [self configureTimeBar];
        [self loadLiveMessages];
        [self configureNavigationBarButton];
    }
    else {
        [self hideTimeBarAndMaximizeTableView];
        [self loadInitalMessages];
    }
    
    
    
    self.keyboardAppearanceSpaceY = 0;
    //    self.formTextView.
    
    //Resize the text field.
    //    float height = self.messageTextField.frame.size.height;
    //    CGRect sizeOfMessageTextField = self.messageTextField.frame;
    //    [self.messageTextField setFrame:CGRectMake(sizeOfMessageTextField.origin.x, sizeOfMessageTextField.origin.y, sizeOfMessageTextField.size.width, height)];
    //    self.messageTextField.layer.cornerRadius = 3;
    
    
    
    
    
    //Create and add chat button.
    //    self.currentChat = [[CurrentChatButton alloc] initWithFrame:CGRectMake(290, 50, 40, 40)];
    //
    //    [self.view addSubview:self.currentChat];
}

-(void) hideTimeBarAndMaximizeTableView
{
    self.timingBar.hidden = YES;
    self.backTimingBar.hidden = YES;
    //Remove the live chat button.
    
    
    CGRect tableViewFrame = self.tableView.frame;
    
    
    
    [self.tableView setFrame:CGRectMake(tableViewFrame.origin.x, tableViewFrame.origin.y-7, tableViewFrame.size.width, tableViewFrame.size.height+8)];
}

-(void) configureTimeBar
{
    timingBarCurrentWidth = 320;

    //Calculate the resizing factor.
    [self calculateTheResizingFactor];
    
    firstTimingBarSize = self.timingBar.frame;
    self.timer1 = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(animateTimeBar:) userInfo:nil repeats:YES];
    [self.timer1 fire];
}

-(void)calculateTheResizingFactor
{
    double firstElement = currentTime/timeInterval;
    
    resizeFactor = timingBarCurrentWidth/firstElement;
    
}

-(void) animateTimeBar: (id)sender
{
    //Calculate how many points needs to resize the timing bar.
    float currentWidth = self.timingBar.frame.size.width;
    timingBarCurrentWidth = timingBarCurrentWidth - resizeFactor;
    
    [self.timingBar setFrame:CGRectMake(firstTimingBarSize.origin.x, firstTimingBarSize.origin.y, timingBarCurrentWidth, firstTimingBarSize.size.height)];
    
    currentTime-=0.1;
    
    //NSLog(@"Current Time: %f : %f",currentTime, timingBarCurrentWidth);
    
    
    //Shrink the timing bar.
    
    
}


- (IBAction)myAction:(UIButton *)sender forEvent:(UIEvent *)event
{
    
    //NSSet *touches = [event touchesForView:sender];
    //UITouch *touch = [touches anyObject];
    //CGPoint touchPoint = [touch locationInView:sender];
    
    UIButton *btn = (UIButton*) sender;
    
    btn.center = [[[event allTouches] anyObject] locationInView:self.view];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    
    [self.navigationController.navigationBar setTranslucent:YES];

    [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar2" forBarMetrics:UIBarMetricsDefault];

    // keyboard management
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMessageFromNotification:) name:@"GLPNewMessage" object:nil];
    
    
    [self.tabBarController.tabBar setHidden:YES];

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
        [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
        [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar_trans" forBarMetrics:UIBarMetricsDefault];
        [self.tabBarController.tabBar setHidden:NO];
    }
    else
    {
        [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
        [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar2" forBarMetrics:UIBarMetricsDefault];

        
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self  name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPNewMessage" object:nil];

    //Hide live chats view.
    [self.liveChatsView removeView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.timer1 invalidate];
    

}

#pragma mark - Init and config

- (void)configureNavigationBar
{
    
    //Create a button instead of using the default title view for recognising gestures.
    UIButton *titleLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    

    
    // navigation bar configuration
    if(self.randomChat)
    {
        self.title = self.liveConversation.title;
        [titleLabel setTitle:self.liveConversation.title forState:UIControlStateNormal];
        titleLabel.tag = [[self.liveConversation.participants objectAtIndex:0] remoteKey];


    }
    else
    {
        self.title = self.conversation.title;
        [titleLabel setTitle:self.conversation.title forState:UIControlStateNormal];
        titleLabel.tag = [[self.participants objectAtIndex:0] remoteKey];


    }
    
    //Set navigation to profile selector.
    titleLabel.frame = CGRectMake(0, 0, 70, 44);
    [titleLabel addTarget:self action:@selector(navigateToProfile:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleLabel;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    

}

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

// Load messages the first time
- (void)loadInitalMessages
{
    if(self.inLoading) {
        return;
    }
    
    NSLog(@"Load initial messages");
    self.inLoading = YES;
    
    [ConversationManager loadMessagesForConversation:self.conversation localCallback:^(NSArray *messages) {
        if(messages.count > 0) {
            self.messages = [messages mutableCopy];
            
            [self configureDisplayForMessages:self.messages];
            [self.tableView reloadData];
            [self scrollToTheEndAnimated:NO];
        }
    } remoteCallback:^(BOOL success, NSArray *newMessages) {
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
                
            //[self showMessages:messages];
            
            // keep top loading cell activated or desactivate it if there is no previous results
            //                self.loadingCellStatus = (messages.count == NumberMaxOfMessagesLoaded) ? kGLPLoadingCellStatusInit : kGLPLoadingCellStatusFinished;
            
        } else {
            // remove the bootom loading cell
            [self removeBottomLoadingCellWithAnimation:UITableViewRowAnimationFade];
            
            //TODO: show better error
            [WebClientHelper showStandardError];
        }
        
        self.inLoading = NO;
    }];
    
    // conversation has no more unread messages
    [ConversationManager markConversationRead:self.conversation];
}

- (void)loadPreviousMessages
{
    //TODO: Reloading delay mechanism
    if(self.inLoading) {
        return;
    }
    
    NSLog(@"Load previous messages");
    self.inLoading = YES;
    
    //    if(self.messages.count == 0) {
    //        self.loadingCellStatus = kGLPLoadingCellStatusFinished;
    //        return;
    //    }
    
    if(self.loadingCellStatus == kGLPLoadingCellStatusLoading) {
        NSLog(@"Previous messages loading already in progress, don't run twice");
        return;
    }
    
    // show the loading on top loading cell
    self.loadingCellStatus = kGLPLoadingCellStatusLoading;
    [self reloadLoadingCell];
    
    [ConversationManager loadPreviousMessagesBefore:self.messages[0] callback:^(BOOL success, BOOL remains, NSArray *messages) {
        
        if(success) {
            if(messages.count > 0) {
                // insert messages before existing ones
                [self.messages insertObjects:messages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, messages.count)]];
                
                // configure the display
                [self configureDisplayForMessages:self.messages];
                
                // insert in the tableview while saving the scrolling state
                CGPoint tableViewOffset = [self.tableView contentOffset];
                [UIView setAnimationsEnabled:NO];
                
                [self.tableView beginUpdates];
                
                // new rows total height for saving the scrolling state
                int heightForNewRows = 0;
                
                // create new indexpaths for new rows starting at 1 because 0 is the top loading cell
                NSMutableArray *rowsInsertIndexPath = [[NSMutableArray alloc] init];
                for (NSInteger i = 1; i <= messages.count; i++) {
                    // index path
                    NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [rowsInsertIndexPath addObject:tempIndexPath];
                    
                    // add the row height
                    heightForNewRows = heightForNewRows + [self tableView:self.tableView heightForRowAtIndexPath:tempIndexPath];
                }
                
                // insert the rows
                [self.tableView insertRowsAtIndexPaths:rowsInsertIndexPath withRowAnimation:UITableViewRowAnimationNone];
                
                // reload every other rows because the configuration may changes (which message follows which, etc)
                NSMutableArray *reloadRowsIndexPaths = [[NSMutableArray alloc] init];
                for (NSInteger i = messages.count; i < self.messages.count; i++) {
                    // index path
                    NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [reloadRowsIndexPaths addObject:rowIndexPath];
                }
                [self.tableView reloadRowsAtIndexPaths:reloadRowsIndexPaths withRowAnimation:UITableViewRowAnimationNone];
                
                // remove the top loading row if need
                if(!remains) {
                    self.loadingCellStatus = kGLPLoadingCellStatusFinished;
                    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                }
                // otherwise we keep the loading cell animation and re-init its state
                else {
                    self.loadingCellStatus = kGLPLoadingCellStatusInit;
                }
                
                tableViewOffset.y += heightForNewRows;
                
                [self.tableView endUpdates];
                [self.tableView setContentOffset:tableViewOffset animated:NO];
                [UIView setAnimationsEnabled:YES];
                
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
        
        self.inLoading = NO;
    }];
}

//- (void)showMessages:(NSArray *)messages
//{
//    self.messages = [messages mutableCopy];
//    
//    [self configureMessagesDisplay];
//    [self.tableView reloadData];
//    [self scrollToTheEndAnimated:NO];
//}

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


-(void)loadLiveMessages
{
    //id view = ([self.formTextView isFirstResponder]) ? [[UIApplication sharedApplication].windows objectAtIndex:1] : self.view;

    
    //[WebClientHelper showStandardLoaderWithoutSpinningAndWithTitle:@"Loading new live messages" forView:view];
    
    [LiveConversationManager loadMessagesForLiveConversation:self.liveConversation localCallback:^(NSArray *messages) {
        //[self showMessages:messages];
        
    } remoteCallback:^(BOOL success, NSArray *messages) {
        //[WebClientHelper hideStandardLoaderForView:view];
        
        if(success) {
            if(messages) {
                //[self showMessages:messages];
            }
        } else {
            [WebClientHelper showStandardError];
        }
    }];
    
    // conversation has no more unread messages
    //[ConversationManager markConversationRead:self.conversation];
    
}

- (void)showMessageFromNotification:(NSNotification *)notification
{
    GLPMessage *message = [notification userInfo][@"message"];
    NSLog(@"Show message from notification %@ : Date: %@", message, message.date);
    
    [self showMessage:message];
    
    // conversation has no more unread messages
    [ConversationManager markConversationRead:self.conversation];
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
    if(!self.randomChat)
    {
        GLPMessage *message = [ConversationManager createMessageWithContent:self.formTextView.text toConversation:self.conversation sendCallback:^(GLPMessage *sentMessage, BOOL success) {
            
            [self.tableView reloadData];
        }];
        
        [self showMessage:message];
        
        self.formTextView.text = @"";
    }
    else
    {
        GLPMessage *message = [LiveConversationManager createMessageWithContent:self.formTextView.text toLiveConversation:self.liveConversation sendCallback:^(GLPMessage *sentMessage, BOOL success) {
            
            [self.tableView reloadData];
        }];
        
        [self showMessage:message];
        
        self.formTextView.text = @"";
    }
    

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
        //Navigate to profile view controller.
        
        [self performSegueWithIdentifier:@"view profile" sender:self];
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
    
    for (NSInteger i = 0; i < rowCount; i++) {
        NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [rowsInsertIndexPath addObject:tempIndexPath];

        heightForNewRows = heightForNewRows + [self tableView:self.tableView heightForRowAtIndexPath:tempIndexPath];
    }


//    [self reloadLoadingCell];
//    [self.tableView insertRowsAtIndexPaths:rowsInsertIndexPath withRowAnimation:UITableViewRowAnimationNone];
    
    tableViewOffset.y += heightForNewRows;
    
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
    
    [cell updateWithMessage:message first:message.hasHeader withIdentifier:message.cellIdentifier andParticipants:self.participants];
    
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
        
        // tableview in scrolling, delay the loading when scroll is finished
        if(self.tableViewInScrolling) {
            self.tableViewDisplayedLoadingCell = YES;
        } else {
            [self loadPreviousMessages];
        }
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
    if(self.messages.count > 1) {
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
        
        PrivateProfileViewController *ppvc = segue.destinationViewController;
        
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
        
        ProfileViewController *profileViewController = segue.destinationViewController;
        
        GLPUser *incomingUser = [[GLPUser alloc] init];
        
        incomingUser.remoteKey = self.selectedUserId;
        
        if(self.selectedUserId == -1)
        {
            incomingUser = nil;
        }
        
        profileViewController.incomingUser = incomingUser;
    }
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
