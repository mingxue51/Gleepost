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
#import "ContactsHelper.h"
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
@property (assign, nonatomic) BOOL tableViewInScrolling;
@property (assign, nonatomic) BOOL tableViewDisplayedLoadingCell;


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


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // various control init
    self.loadingCellStatus = kGLPLoadingCellStatusLoading;
    self.tableViewDisplayedLoadingCell = NO;
    self.tableViewInScrolling = NO;
    
    [self loadElements];
}


-(void) loadElements
{
    [self configureNavigationBar];
    [self configureForm];
    
    if(self.randomChat)
    {
        [self configureTimeBar];
    }
    else
    {
        [self hideTimeBarAndMaximizeTableView];
    }
    
    if(!self.randomChat)
    {
        [self loadMessages];
    }
    else
    {
        //Load live messages.
        [self loadLiveMessages];
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
    
    [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar2" forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTranslucent:YES];

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
    }
    else
    {
        [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
        [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar2" forBarMetrics:UIBarMetricsDefault];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self  name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPNewMessage" object:nil];

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
        titleLabel.tag = [[self.participants objectAtIndex:0] remoteKey];


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
    
    
    
//    [self.navigationItem.titleView setUserInteractionEnabled:YES];
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigateToProfile:)];
//    [tap setNumberOfTapsRequired:1];
//    [self.navigationItem.titleView addGestureRecognizer:tap];
    
    NSLog(@"Navigation title view: %@",self.navigationItem.titleView);
    
    
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"multipleusersicon"]];
    [imageView setFrame:CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, 30, 30)];
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


#pragma mark - Messages management

- (void)loadMessages
{
    [ConversationManager loadMessagesForConversation:self.conversation localCallback:^(NSArray *messages) {
        [self showMessages:messages];
        
    } remoteCallback:^(BOOL success, NSArray *messages) {
        //[WebClientHelper hideStandardLoaderForView:view];
        
        if(success) {
            if(messages) {
                [self showMessages:messages];
                self.loadingCellStatus = (messages.count == NumberMaxOfMessagesLoaded) ? kGLPLoadingCellStatusInit : kGLPLoadingCellStatusFinished;
            }
        } else {
            [WebClientHelper showStandardError];
        }
        
        self.loadingCellStatus = kGLPLoadingCellStatusInit;
    }];
    
    // conversation has no more unread messages
    [ConversationManager markConversationRead:self.conversation];
}


- (void)showMessages:(NSArray *)messages
{
    self.messages = [messages mutableCopy];
    
    [self configureMessagesDisplay];
    [self.tableView reloadData];
    [self scrollToTheEndAnimated:NO];
}

- (void)configureMessagesDisplay
{
    for (int i = 0; i < self.messages.count; i++) {
        GLPMessage *current = self.messages[i];
        
        if(i == 0) {
            [current configureAsFirstMessage];
        } else {
            GLPMessage *previous = self.messages[i-1];
            [current configureAsFollowingMessage:previous];
        }
    }
}


-(void)loadLiveMessages
{
    id view = ([self.formTextView isFirstResponder]) ? [[UIApplication sharedApplication].windows objectAtIndex:1] : self.view;

    
    //[WebClientHelper showStandardLoaderWithoutSpinningAndWithTitle:@"Loading new live messages" forView:view];
    
    [LiveConversationManager loadMessagesForLiveConversation:self.liveConversation localCallback:^(NSArray *messages) {
        [self showMessages:messages];
        
    } remoteCallback:^(BOOL success, NSArray *messages) {
        //[WebClientHelper hideStandardLoaderForView:view];
        
        if(success) {
            if(messages) {
                [self showMessages:messages];
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


#pragma mark - Request management

- (void)startLoadingPreviousMessages
{
    if(self.messages.count == 0) {
        self.loadingCellStatus = kGLPLoadingCellStatusFinished;
        return;
    }
    
    if(self.loadingCellStatus == kGLPLoadingCellStatusLoading) {
        NSLog(@"Previous messages loading already in progress, don't run twice");
        return;
    }
    
    self.loadingCellStatus = kGLPLoadingCellStatusLoading;
    self.tableView.userInteractionEnabled = NO;
    
    [ConversationManager loadPreviousMessagesBefore:self.messages[0] callback:^(BOOL success, BOOL remains, NSArray *messages) {
        
        if(success) {
//            for(GLPMessage *m in messages) {
//                NSLog(@"message %d - %@ - %@", m.remoteKey, m.date, m.content);
//            }
            
            self.loadingCellStatus = remains ? kGLPLoadingCellStatusInit : kGLPLoadingCellStatusFinished;
            
            if(messages.count > 0) {
                [self.messages insertObjects:messages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, messages.count)]];
                [self configureMessagesDisplay];
                [self updateTableWithNewRowCount:messages.count];
            } else {
                [self reloadLoadingCell];
            }
            
            
            

        } else {
            self.loadingCellStatus = kGLPLoadingCellStatusError;
            [self reloadLoadingCell];
        }
        
        self.tableView.userInteractionEnabled = YES;
    }];
}


//- (void)startLongPollingRequest
//{
//    self.longPollingRequestRunning = YES;
//    NSLog(@"start long polling request");
//    
//    [[WebClient sharedInstance] longPollNewMessagesForConversation:self.conversation callbackBlock:^(BOOL success, GLPMessage *message) {
//        NSLog(@"long polling request finish with result %d", success);
//        
//        if(success) {
//            [self showMessage:message];
//            [GLPMessageDao save:message];
//        }
//        
//        // restart long polling request if has to
//        if(self.longPollingRequestRunning) {
//            [self startLongPollingRequest];
//        }
//    }];
//}


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
    else if([ContactsHelper navigateToUnlockedProfileWithSelectedUserId:self.selectedUserId])
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

-(void) updateTableWithNewRowCount : (int) rowCount
{
    //Save the tableview content offset

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
    return self.messages.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) {
        GLPLoadingCell *loadingCell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell" forIndexPath:indexPath];
        [loadingCell updateWithStatus:self.loadingCellStatus];
        return loadingCell;
    }
    
    int row = indexPath.row - 1;
    GLPMessage *message = self.messages[row];
    
    if(!message.cellIdentifier) {
        [NSException raise:@"Cell identifier is null" format:@"Row is %d", row];
    }
    
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
    if(indexPath.row == 0) {
        return (self.loadingCellStatus != kGLPLoadingCellStatusFinished) ? kGLPLoadingCellHeight : 0;
    }
    
    int row = indexPath.row - 1;
    GLPMessage *message = self.messages[row];
    return [MessageCell getCellHeightWithContent:message.content first:message.hasHeader];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 && self.loadingCellStatus == kGLPLoadingCellStatusInit) {
        NSLog(@"Load previous cell");
        
        // tableview in scrolling, delay the loading when scroll is finished
        if(self.tableViewInScrolling) {
            self.tableViewDisplayedLoadingCell = YES;
        } else {
            [self startLoadingPreviousMessages];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 && self.loadingCellStatus == kGLPLoadingCellStatusError) {
        self.loadingCellStatus = kGLPLoadingCellStatusInit;
        [self reloadLoadingCell];
    }
}


- (void)scrollToTheEndAnimated:(BOOL)animated
{
    if(self.messages.count > 1) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
    }
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
            [self startLoadingPreviousMessages];
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

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    if ([touch.view isDescendantOfView:self.tableView])
//    {
//        
//        // Don't let selections of auto-complete entries fire the
//        // gesture recognizer
//        return NO;
//    }
//    
//    [self hideKeyboardFromTextViewIfNeeded];
//    
//    return YES;
//}


#pragma mark - Text View delegate

//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [self performSelector:@selector(sendButtonClicked:) withObject:self];
//    return YES;
//}

//- (BOOL)textView:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    NSLog(@"UITextField: %@",textField.text);
//    
//    NSLog(@"Text Range Length: %d With Location: %d ",range.length, range.location);
//    
//    if(range.location%25 == 0)
//    {
//        CGRect frame = self.messageTextField.frame;
//        frame.size.height = frame.size.height+10;
//        self.messageTextField.frame = frame;
//        
//        CGRect frame2 = self.messageTestTextView.frame;
//        frame.size.height = frame.size.height+10;
//        self.messageTestTextView.frame = frame2;
//    }
//    
//    
//    
//   // CGSize  textSize = { 260.0, 10000.0 };
//    
////    CGSize sizeOfBackImgView =[textField.text sizeWithFont:[UIFont boldSystemFontOfSize:12]
////                                      constrainedToSize:textSize
////                                          lineBreakMode:NSLineBreakByWordWrapping];
//
//    
//    return YES;
//}

//- (void)textViewDidChange:(UITextView *)textView
//{
//
//    double numberOfLines = self.messageTextField.contentSize.height/self.messageTextField.font.lineHeight;
//    
//    numberOfLines-=1.0;
//    
//    
//    numberOfLines -= (double)1.1;
//    numberOfLines = ceil(numberOfLines);
//    
//    int noOfLines = (int) numberOfLines;
//
//    //Take the current height of the message view.
//    CGRect messageViewSize = self.messageView.frame;
//    
//    
//    /**
//        Resize the message view frame size, message text view size to smaller.
//        Resize table view to bigger.
//     */
//    if(numberOfLines < previousTextViewSize)
//    {
//        [self resizeChatElementsDependingOnText:NO];
//        
//        
//        previousTextViewSize = noOfLines;
//        
//        return;
//    }
//    
//    /** 
//        If current number of lines is different from the previous one
//        then change the size of chat view and text view.
//        Shrunk the size of the table view.
//     */
//    if(noOfLines != previousTextViewSize && flexibleResizeLimit >= messageViewSize.size.height)
//    {
//        
//        [self resizeChatElementsDependingOnText:YES];
//        
//        previousTextViewSize = noOfLines;
//    }
//
//   
//}

/**
 
 Resize chat elements depending on number of lines.
 
 @param bigger If YES then the size should turn to bigger otherwise to smaller.
 
 */
//-(void) resizeChatElementsDependingOnText:(BOOL) bigger
//{
//    CGRect messageViewSize = self.messageView.frame;
//    int resizeLevel = textViewSizeOfLine;
//    if(!bigger)
//    {
//        resizeLevel = (-textViewSizeOfLine);
//    }
//    
//    
//    //Change the size of message view.
//    [self.messageView setFrame:CGRectMake(messageViewSize.origin.x, messageViewSize.origin.y-resizeLevel, messageViewSize.size.width, messageViewSize.size.height+resizeLevel)];
//    
//    messageViewSize = self.messageView.frame;
//    
//    CGRect messageTextViewSize = self.messageTextField.frame;
//    
//    messageTextViewSize.size.height += resizeLevel;
//    
//    //Change the size of message text view.
//    [self.messageTextField setFrame:messageTextViewSize];
//    
//    
//    //Change the size of table view.
//    CGRect tableViewFrame = self.tableView.frame;
//    [self.tableView setFrame:CGRectMake(tableViewFrame.origin.x, tableViewFrame.origin.y, tableViewFrame.size.width, tableViewFrame.size.height-resizeLevel)];
//    
//    //Scroll down the table view.
//    CGPoint point = self.tableView.contentOffset;
//    [self.tableView setContentOffset:CGPointMake(point.x, point.y+resizeLevel)];
//    
//    //Change the position of send button and camera button.
//    CGRect cameraFrame = self.cameraButton.frame;
//    
//    //TODO: Change the position of send and camera button dynamically.
//    
//    //CGRect sendButtonFrame = self.sendButton.frame;
//    
//}

//- (void)textViewDidBeginEditing:(UITextView *)textField
//{
//
//    
//    
//    
//    
//
////    if(self.keyboardAppearanceSpaceY != 0)
////    {
////        return;
////    }
////    NSLog(@"keyboardWillShow");
////    
////    
////    NSLog(@"Message view dimensions: x:%f y:%f",self.messageView.frame.origin.x,self.messageView.frame.origin.y);
////    //NSLog(@"Keyboard Height: %f",[KeyboardHelper keyboardHeight:notification]);
////    
////    float height = 210;
////    
////    self.keyboardAppearanceSpaceY = height + 1;
////    
////    [self animateViewWithVerticalMovement:-self.keyboardAppearanceSpaceY duration:0.25 andKeyboardHide:NO];
//
//    
//    [textField becomeFirstResponder];
//}

//- (void)textViewDidEndEditing:(UITextView *)textField
//{
//    
// //   [textField resignFirstResponder];
//}
//
//- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView
//{
//    // you can create the accessory view programmatically (in code), or from the storyboard
//    if (self.messageTextField.inputAccessoryView == nil)
//    {
//        //self.messageTextField.inputAccessoryView = self.messageView;
//        
////        [self.messageView.inputAccessoryView setFrame:CGRectMake(0, 0, 320.f, 50.f)];
////        NSLog(@"Accessory View: %f:%f",self.messageView.inputAccessoryView.frame.size.height, self.messageView.inputAccessoryView.frame.size.width);
//    }
//    
//    return YES;
//}
//
//- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView
//{
//    
//    NSLog(@"textViewShouldEndEditing");
//    
//    //[aTextView resignFirstResponder];
//    //self.navigationItem.rightBarButtonItem = self.editButton;
//    
//    return YES;
//}


#pragma mark - Responding to keyboard events

//- (void)keyboardWillShow:(NSNotification *)notification
//{
//    
//    NSLog(@"keyboardWillShow");
//    
//    /*
//     Reduce the size of the text view so that it's not obscured by the keyboard.
//     Animate the resize so that it's in sync with the appearance of the keyboard.
//     */
//    
//    NSDictionary *userInfo = [notification userInfo];
//    
//    // Get the origin of the keyboard when it's displayed.
//    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
//    
//    // Get the top of the keyboard as the y coordinate of its origin in self's view's
//    // coordinate system. The bottom of the text view's frame should align with the top
//    // of the keyboard's final position.
//    //
//    CGRect keyboardRect = [aValue CGRectValue];
//    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
//    
//    CGFloat keyboardTop = keyboardRect.origin.y;
//    CGRect newTextViewFrame = self.view.bounds;
//    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
//    
//    // Get the duration of the animation.
//    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    NSTimeInterval animationDuration;
//    [animationDurationValue getValue:&animationDuration];
//
//    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:animationDuration];
//    
//    self.tableView.frame = newTextViewFrame;
//   
//    
//    //Set different y to message view.
////    CGRect messageViewFrame = self.messageView.frame;
//    
////    [self.messageView setFrame:CGRectMake(messageViewFrame.origin.x, messageViewFrame.origin.y+keyboardTop, messageViewFrame.size.width, messageViewFrame.size.height)];
//    
//    NSLog(@"newTextViewFrame: %f:%f - %f:%f",newTextViewFrame.size.height, newTextViewFrame.size.width, newTextViewFrame.origin.x, newTextViewFrame.origin.y);
//    
//    [UIView commitAnimations];
//}



//- (void)keyboardWillHide:(NSNotification *)notification
//{
//    
//    NSLog(@"keyboardWillHide");
//
//    
//    NSDictionary *userInfo = [notification userInfo];
//    
//    /*
//     Restore the size of the text view (fill self's view).
//     Animate the resize so that it's in sync with the disappearance of the keyboard.
//     */
//    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    NSTimeInterval animationDuration;
//    [animationDurationValue getValue:&animationDuration];
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:animationDuration];
//    
//    self.tableView.frame = self.view.bounds;
//
//    
//    [UIView commitAnimations];
//}




//
//- (void)applicationDidEnterBackground:(NSNotification *)notification
//{
//    [self hideKeyboardFromTextViewIfNeeded];
//}
//
//
////- (void)keyboardWillHideOrShow:(NSNotification *)note
////{
////    NSDictionary *userInfo = note.userInfo;
////    
////    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
////    NSLog(@"User Info: %f",duration);
////    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
////    
////    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
////    CGRect keyboardFrameForTextField = [self.messageView.superview convertRect:keyboardFrame fromView:nil];
////    
////    CGRect newTextFieldFrame = self.messageView.frame;
////    newTextFieldFrame.origin.y = keyboardFrameForTextField.origin.y - newTextFieldFrame.size.height;
////    
////    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
////        self.messageView.frame = newTextFieldFrame;
////    } completion:nil];
////}
//
//
//
//- (void)keyboardWillShow:(NSNotification *)notification
//{
//    
//    if(self.keyboardAppearanceSpaceY != 0)
//    {
//        return;
//    }
//    
//    
//    
//    float height = [KeyboardHelper keyboardHeight:notification];
//    
//    self.keyboardAppearanceSpaceY = height;
//    
//    [self animateViewWithVerticalMovement:-self.keyboardAppearanceSpaceY duration:[KeyboardHelper keyboardAnimationDuration:notification] andKeyboardHide:NO];
//    
//
//    
//}
//
//- (void)keyboardWillHide:(NSNotification *)notification
//{
//   // float height = [KeyboardHelper keyboardHeight:notification];
//
//
//   // float duration = [self keyboardAnimationDurationForNotification:notification];
//    
//  //  NSLog(@"DURATION: %f",duration);
//    
//    [self animateViewWithVerticalMovement:fabs(self.keyboardAppearanceSpaceY) duration:[KeyboardHelper keyboardAnimationDuration:notification] andKeyboardHide:YES];
//
//    
//    self.keyboardAppearanceSpaceY = 0;
//
//
//}
//
////- (NSTimeInterval)keyboardAnimationDurationForNotification:(NSNotification*)notification
////{
////    NSDictionary* info = [notification userInfo];
////    NSValue* value = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
////    NSTimeInterval duration = 0;
////    [value getValue:&duration];
////    return duration;
////}
//
///**
// Creates animation in case there is a need for disappearing the keyboard or appearing.
// 
// @param movement the distance of the elements' movements.
// @param duration the duration of the animbation.
// @param animationOptions animcation options.
// @param isKeyboardHide true if the method was called in order to hide the keyboard and false if it is called for show the keyboard.
// 
// */
//- (void) animateViewWithVerticalMovement:(float)movement duration:(float)duration andKeyboardHide:(BOOL)isKeyboardHide
//{
//    
//    
//    //0.21
//    
//    //UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionLayoutSubviews| UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionLayoutSubviews
//    
//    [UIView animateWithDuration:duration-3.0 delay:0 options:(UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveLinear) animations:^{
//        
//        
//        //Changes to commit in a view.
//        
//        
//        self.messageView.frame = CGRectOffset(self.messageView.frame, 0, movement);
//        
//        
//        if(isKeyboardHide)
//        {
//            //Set the y position +30 and after -30 in order to create a smoothly representation when the keyboard is going to be hide.
//            self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y+30, self.tableView.frame.size.width, self.tableView.frame.size.height + (movement));
//            
//            self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y-30, self.tableView.frame.size.width, self.tableView.frame.size.height);
//        }
//        else
//        {
//            self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height + (movement));
//        }
//        
//        if(self.messages.count > 1) {
//            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
//        }
//        
//        
//    } completion:^(BOOL finished) {
//        //Executes when the animation is going to be end.
//
//        
//    }];
//}


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
