//
//  ViewTopicViewController.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ViewTopicViewController.h"
#import "ProfileViewController.h"

#import "MessageCell.h"

#import "SessionManager.h"
#import "AppearanceHelper.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "KeyboardHelper.h"
#import "NSString+Utils.h"
#import "ConversationManager.h"

#import "GLPMessage.h"
#import "GLPMessage+CellLogic.h"
#import "User.h"

#import "CurrentChatButton.h"


const int textViewSizeOfLine = 12;
const int flexibleResizeLimit = 120;

@interface ViewTopicViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextField;
@property (retain, nonatomic) IBOutlet UIView *messageView;

//@property (retain, nonatomic) UIView *messageTestView;
@property (retain, nonatomic) UITextView *messageTestTextView;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) UIButton *cameraButton;

@property (assign, nonatomic) float keyboardAppearanceSpaceY;
@property (strong, nonatomic) NSMutableArray *messages;

@property (assign, nonatomic) BOOL longPollingRequestRunning;

@property (strong, nonatomic) NSString  *lastCellIdentifier;
@property (strong, nonatomic) NSMutableArray  *messagesCellIdentifiers;
@property (assign, nonatomic) NSInteger  lastRow;


@property (strong, nonatomic) IBOutlet CurrentChatButton *currentChat;


- (IBAction)sendButtonClicked:(id)sender;
- (IBAction)tableViewClicked:(id)sender;

@end

@implementation ViewTopicViewController

@synthesize conversation;



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.longPollingRequestRunning = NO;
    
    self.title = [self.conversation getParticipantsNames];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"chat_background"]];
    //self.view.backgroundColor = [UIColor whiteColor];

    [self.tableView setBackgroundColor:[UIColor clearColor]];

    [self.messageView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"typing_bar"]]];
    
    
    //Get the size of the messageView.
    CGRect messageViewRect = [self.messageView bounds];
    
    //Add the plus button to navigation bar.
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"+"]];
    UIButton *btnBack=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(addContact) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = imageView.bounds;
    [imageView addSubview:btnBack];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.navigationItem.rightBarButtonItem = item;
    
    
    
    //Create a button with the image and create selector for button.
    self.cameraButton = [[UIButton alloc] init];
    [self.cameraButton setBackgroundImage:[UIImage imageNamed:@"camera_icon"] forState:UIControlStateNormal];
    [self.cameraButton setFrame:CGRectMake(15.0f, messageViewRect.size.height/4, [UIImage imageNamed:@"camera_icon"].size.width, [UIImage imageNamed:@"camera_icon"].size.height)];
    [self.cameraButton addTarget:self
               action:@selector(addImageToTheChat:)
     forControlEvents:UIControlEventTouchDown];
    [self.messageView addSubview:self.cameraButton];
    
    
    self.keyboardAppearanceSpaceY = 0;
    
    //Resize the text field.
    float height = self.messageTextField.frame.size.height;
    CGRect sizeOfMessageTextField = self.messageTextField.frame;
    [self.messageTextField setFrame:CGRectMake(sizeOfMessageTextField.origin.x, sizeOfMessageTextField.origin.y, sizeOfMessageTextField.size.width, height)];
    self.messageTextField.layer.cornerRadius = 3;
    
    // init
    self.messagesCellIdentifiers = [NSMutableArray array];
    
    
    [self loadMessages];
    
    
    //Create and add chat button.
//    self.currentChat = [[CurrentChatButton alloc] initWithFrame:CGRectMake(290, 50, 40, 40)];
//    
//    [self.view addSubview:self.currentChat];
    
}

- (IBAction)myAction:(UIButton *)sender forEvent:(UIEvent *)event
{
    
    NSSet *touches = [event touchesForView:sender];
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:sender];
    
    UIButton *btn = (UIButton*) sender;
    
    btn.center = [[[event allTouches] anyObject] locationInView:self.view];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar2" forBarMetrics:UIBarMetricsDefault];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [self.tabBarController.tabBar setHidden:YES];

}

-(void) viewWillDisappear:(BOOL)animated
{
    NSLog(@"ViewTopiController : viewWillDisappear");
    [super viewWillDisappear:animated];
    

    
    
    NSUInteger numberOfViewControllersOnStack = [self.navigationController.viewControllers count];
    UIViewController *parentViewController = self.navigationController.viewControllers[numberOfViewControllersOnStack - 1];
    Class parentVCClass = [parentViewController class];
    NSString *className = NSStringFromClass(parentVCClass);
    
    if([className isEqualToString:@"MessagesViewController"])
    {
        NSLog(@"MessageViewController Class");
        [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
        [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar2" forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        NSLog(@"Other Class");
        [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
        [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar_trans" forBarMetrics:UIBarMetricsDefault];
    }
    
    NSLog(@"Parent View Controller: %@",className);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self  name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [[WebClient sharedInstance] cancelMessagesLongPolling];
    self.longPollingRequestRunning = NO;
}


#pragma mark - Messages management

- (void)loadMessages
{
    id view = ([self.messageTextField isFirstResponder]) ? [[UIApplication sharedApplication].windows objectAtIndex:1] : self.view;
    
    [WebClientHelper showStandardLoaderWithoutSpinningAndWithTitle:@"Loading new messages" forView:view];
    
    [ConversationManager loadMessagesForConversation:self.conversation localCallback:^(NSArray *messages) {
        NSLog(@"local messages %d", messages.count);
        [self showMessages:messages];
        
    } remoteCallback:^(BOOL success, NSArray *messages) {
        [WebClientHelper hideStandardLoaderForView:view];
        
        if(success) {
            if(messages) {
                NSLog(@"remote messages %d", messages.count);
                [self showMessages:messages];
            }
            
            if(!self.longPollingRequestRunning) {
                [self startLongPollingRequest];
            }
        } else {
            [WebClientHelper showStandardError];
        }
    }];
}

- (void)showMessages:(NSArray *)messages
{
    self.messages = [messages mutableCopy];
    
    for (int i = 0; i < self.messages.count; i++) {
        GLPMessage *current = self.messages[i];
        if(i == 0) {
            [current configureAsFirstMessage];
        } else {
            GLPMessage *previous = self.messages[i-1];
            [current configureAsFollowingMessage:previous];
        }
    }

    [self.tableView reloadData];
    
    if(self.messages.count > 1) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
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
    
    // scroll to the last element
    if(self.messages.count > 1) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)createMessageFromForm
{
    GLPMessage *message = [ConversationManager createMessageWithContent:self.messageTextField.text toConversation:self.conversation sendCallback:^(GLPMessage *sentMessage, BOOL success) {
        
        [self.tableView reloadData];
    }];
    
    [self showMessage:message];
    
    self.messageTextField.text = @"";
}


#pragma mark - Request management

- (void)startLongPollingRequest
{
    self.longPollingRequestRunning = YES;
    NSLog(@"start long polling request");
    
    [[WebClient sharedInstance] longPollNewMessagesForConversation:self.conversation callbackBlock:^(BOOL success, GLPMessage *message) {
        NSLog(@"long polling request finish with result %d", success);
        
        if(success) {
            [self showMessage:message];
        }
        
        // restart long polling request if has to
        if(self.longPollingRequestRunning) {
            [self startLongPollingRequest];
        }
    }];
}


#pragma mark - Actions

- (IBAction)sendButtonClicked:(id)sender
{
    if([self.messageTextField.text isEmpty])
    {
        return;
    }
    
    [self createMessageFromForm];
}

- (IBAction)tableViewClicked:(id)sender
{
    [self hideKeyboardFromTextViewIfNeeded];
}

-(void) addContact
{
    NSLog(@"Add Contact.");
}

-(void)addImageToTheChat:(id) sender
{
    NSLog(@"Camera icon pushed!");
}

-(void)navigateToProfile:(id)sender
{
    [self performSegueWithIdentifier:@"view profile" sender:self];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLPMessage *message = self.messages[indexPath.row];
    
    if(!message.cellIdentifier) {
        [NSException raise:@"Cell identifier is null" format:@"Row is %d", indexPath.row];
    }
    
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:message.cellIdentifier forIndexPath:indexPath];
    
    [cell updateWithMessage:message first:message.hasHeader];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLPMessage *message = self.messages[indexPath.row];
    return [MessageCell getCellHeightWithContent:message.content first:message.hasHeader];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.tableView])
    {
        
        // Don't let selections of auto-complete entries fire the
        // gesture recognizer
        return NO;
    }
    
    [self hideKeyboardFromTextViewIfNeeded];
    
    return YES;
}


#pragma mark - Text View delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self performSelector:@selector(sendButtonClicked:) withObject:self];
    return YES;
}

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

- (void)textViewDidChange:(UITextView *)textView
{

    double numberOfLines = self.messageTextField.contentSize.height/self.messageTextField.font.lineHeight;
    
    numberOfLines-=1.0;
    
    
    numberOfLines -= (double)1.1;
    numberOfLines = ceil(numberOfLines);
    
    int noOfLines = (int) numberOfLines;

    //Take the current height of the message view.
    CGRect messageViewSize = self.messageView.frame;
    
    
    /**
        Resize the message view frame size, message text view size to smaller.
        Resize table view to bigger.
     */
    if(numberOfLines < previousTextViewSize)
    {
        [self resizeChatElementsDependingOnText:NO];
        
        
        previousTextViewSize = noOfLines;
        
        return;
    }
    
    /** 
        If current number of lines is different from the previous one
        then change the size of chat view and text view.
        Shrunk the size of the table view.
     */
    if(noOfLines != previousTextViewSize && flexibleResizeLimit >= messageViewSize.size.height)
    {
        
        [self resizeChatElementsDependingOnText:YES];
        
        previousTextViewSize = noOfLines;
    }

   
}

/**
 
 Resize chat elements depending on number of lines.
 
 @param bigger If YES then the size should turn to bigger otherwise to smaller.
 
 */
-(void) resizeChatElementsDependingOnText:(BOOL) bigger
{
    CGRect messageViewSize = self.messageView.frame;
    int resizeLevel = textViewSizeOfLine;
    if(!bigger)
    {
        resizeLevel = (-textViewSizeOfLine);
    }
    
    
    //Change the size of message view.
    [self.messageView setFrame:CGRectMake(messageViewSize.origin.x, messageViewSize.origin.y-resizeLevel, messageViewSize.size.width, messageViewSize.size.height+resizeLevel)];
    
    messageViewSize = self.messageView.frame;
    
    CGRect messageTextViewSize = self.messageTextField.frame;
    
    messageTextViewSize.size.height += resizeLevel;
    
    //Change the size of message text view.
    [self.messageTextField setFrame:messageTextViewSize];
    
    
    //Change the size of table view.
    CGRect tableViewFrame = self.tableView.frame;
    [self.tableView setFrame:CGRectMake(tableViewFrame.origin.x, tableViewFrame.origin.y, tableViewFrame.size.width, tableViewFrame.size.height-resizeLevel)];
    
    //Scroll down the table view.
    CGPoint point = self.tableView.contentOffset;
    [self.tableView setContentOffset:CGPointMake(point.x, point.y+resizeLevel)];
    
    //Change the position of send button and camera button.
    CGRect cameraFrame = self.cameraButton.frame;
    
    //TODO: Change the position of send and camera button dynamically.
    
    //CGRect sendButtonFrame = self.sendButton.frame;
    
}

- (void)textViewDidBeginEditing:(UITextView *)textField
{

    
    
    
    

//    if(self.keyboardAppearanceSpaceY != 0)
//    {
//        return;
//    }
//    NSLog(@"keyboardWillShow");
//    
//    
//    NSLog(@"Message view dimensions: x:%f y:%f",self.messageView.frame.origin.x,self.messageView.frame.origin.y);
//    //NSLog(@"Keyboard Height: %f",[KeyboardHelper keyboardHeight:notification]);
//    
//    float height = 210;
//    
//    self.keyboardAppearanceSpaceY = height + 1;
//    
//    [self animateViewWithVerticalMovement:-self.keyboardAppearanceSpaceY duration:0.25 andKeyboardHide:NO];

    
    [textField becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textField
{
    
 //   [textField resignFirstResponder];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView
{
    // you can create the accessory view programmatically (in code), or from the storyboard
    if (self.messageTextField.inputAccessoryView == nil)
    {
        //self.messageTextField.inputAccessoryView = self.messageView;
        
//        [self.messageView.inputAccessoryView setFrame:CGRectMake(0, 0, 320.f, 50.f)];
//        NSLog(@"Accessory View: %f:%f",self.messageView.inputAccessoryView.frame.size.height, self.messageView.inputAccessoryView.frame.size.width);
    }
    
    return YES;
}
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



- (void)hideKeyboardFromTextViewIfNeeded
{
    if([self.messageTextField isFirstResponder])
    {
        [self.messageTextField resignFirstResponder];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self hideKeyboardFromTextViewIfNeeded];
}


//- (void)keyboardWillHideOrShow:(NSNotification *)note
//{
//    NSDictionary *userInfo = note.userInfo;
//    
//    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    NSLog(@"User Info: %f",duration);
//    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
//    
//    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    CGRect keyboardFrameForTextField = [self.messageView.superview convertRect:keyboardFrame fromView:nil];
//    
//    CGRect newTextFieldFrame = self.messageView.frame;
//    newTextFieldFrame.origin.y = keyboardFrameForTextField.origin.y - newTextFieldFrame.size.height;
//    
//    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
//        self.messageView.frame = newTextFieldFrame;
//    } completion:nil];
//}



- (void)keyboardWillShow:(NSNotification *)notification
{
    
    if(self.keyboardAppearanceSpaceY != 0)
    {
        return;
    }
    
    
    
    float height = [KeyboardHelper keyboardHeight:notification];
    
    self.keyboardAppearanceSpaceY = height;
    
    [self animateViewWithVerticalMovement:-self.keyboardAppearanceSpaceY duration:[KeyboardHelper keyboardAnimationDuration:notification] andKeyboardHide:NO];
    

    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
   // float height = [KeyboardHelper keyboardHeight:notification];


   // float duration = [self keyboardAnimationDurationForNotification:notification];
    
  //  NSLog(@"DURATION: %f",duration);
    
    [self animateViewWithVerticalMovement:fabs(self.keyboardAppearanceSpaceY) duration:[KeyboardHelper keyboardAnimationDuration:notification] andKeyboardHide:YES];

    
    self.keyboardAppearanceSpaceY = 0;


}

//- (NSTimeInterval)keyboardAnimationDurationForNotification:(NSNotification*)notification
//{
//    NSDictionary* info = [notification userInfo];
//    NSValue* value = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    NSTimeInterval duration = 0;
//    [value getValue:&duration];
//    return duration;
//}

/**
 Creates animation in case there is a need for disappearing the keyboard or appearing.
 
 @param movement the distance of the elements' movements.
 @param duration the duration of the animbation.
 @param animationOptions animcation options.
 @param isKeyboardHide true if the method was called in order to hide the keyboard and false if it is called for show the keyboard.
 
 */
- (void) animateViewWithVerticalMovement:(float)movement duration:(float)duration andKeyboardHide:(BOOL)isKeyboardHide
{
    
    
    //0.21
    
    //UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionLayoutSubviews| UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionLayoutSubviews
    
    [UIView animateWithDuration:duration-3.0 delay:0 options:(UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveLinear) animations:^{
        
        
        //Changes to commit in a view.
        
        
        self.messageView.frame = CGRectOffset(self.messageView.frame, 0, movement);
        
        
        if(isKeyboardHide)
        {
            //Set the y position +30 and after -30 in order to create a smoothly representation when the keyboard is going to be hide.
            self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y+30, self.tableView.frame.size.width, self.tableView.frame.size.height + (movement));
            
            self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y-30, self.tableView.frame.size.width, self.tableView.frame.size.height);
        }
        else
        {
            self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height + (movement));
        }
        
        if(self.messages.count > 1) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
        }
        
        
    } completion:^(BOOL finished) {
        //Executes when the animation is going to be end.

        
    }];
}

@end
