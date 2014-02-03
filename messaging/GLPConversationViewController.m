//
//  GLPConversationViewController.m
//  Gleepost
//
//  Created by Lukas on 1/30/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPConversationViewController.h"
#import "GLPPrivateProfileViewController.h"

#import "UIViewController+GAI.h"
#import "UIViewController+Flurry.h"

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

#import "GLPThemeManager.h"
#import "GLPIntroducedProfile.h"

@interface GLPConversationViewController ()

@property (weak, nonatomic) IBOutlet UIView *formView;
@property (weak, nonatomic) IBOutlet UITextField *formTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet HPGrowingTextView *formTextView;

@property (assign, nonatomic) NSInteger selectedUserId;
@property (strong, nonatomic) NSMutableArray *messages;

@end

@implementation GLPConversationViewController

@synthesize conversation=_conversation;
@synthesize messages=_messages;


- (void)viewDidLoad
{
    [super viewDidLoad];

    // configuration
    [self configureNavigationBar];
    [self configureHeader];
    [self configureTableView];
    [self configureForm];
    
    [self loadMessages];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self sendViewToGAI:NSStringFromClass([self class])];
    [self sendViewToFlurry:NSStringFromClass([self class])];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_NEW_MESSAGE object:nil];
}


# pragma mark - Configuration

- (void)configureNavigationBar
{
    [self.navigationController setNavigationBarHidden:NO];
    
    // navigate to profile through navigation bar for user-to-user conversation
    if(!_conversation.isGroup && ![self isNewChat]) {
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
    
    self.title = [self isNewChat] ? @"Connected" : _conversation.title;
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, nil]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTranslucent:YES];
    
    [AppearanceHelper setNavigationBarFontFor:self];
    [AppearanceHelper setNavigationBarColour:self];
}

-(void)configureHeader
{
    if([self isNewChat]) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"GLPIntroducedProfile" owner:self options:nil];
        
        GLPIntroducedProfile * introduced = [array objectAtIndex:0];
        [introduced updateContents:[_conversation getUniqueParticipant]];
        introduced.delegate = self;
        
        self.tableView.tableHeaderView = introduced;
    }
}

- (void)configureTableView
{
    _messages = [NSMutableArray array];
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


# pragma mark - Messages

- (void)loadMessages
{
    [self showTopLoader];
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


# pragma mark - Notifications (keyboard ones in form management mark)

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


#pragma mark - Navigation

-(void)navigateToProfile:(id)sender
{
    if([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *incomingUser = (UITapGestureRecognizer*) sender;
        UIImageView *incomingView = (UIImageView*)incomingUser.view;
        self.selectedUserId = incomingView.tag;
    }
    else if([sender isKindOfClass:[UIButton class]]) {
        UIButton *userButton = (UIButton*)sender;
        self.selectedUserId = userButton.tag;
    }
    if((self.selectedUserId == [[SessionManager sharedInstance]user].remoteKey)) {
        self.selectedUserId = -1;
        //Navigate to profile view controller.
        [self performSegueWithIdentifier:@"view profile" sender:self];
    }
    else if([[ContactsManager sharedInstance] navigateToUnlockedProfileWithSelectedUserId:self.selectedUserId]) {
        [self performSegueWithIdentifier:@"view private profile" sender:self];
    }
    else {
        [self performSegueWithIdentifier:@"view private profile" sender:self];
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
    //[self.liveChatsView removeView];
}


# pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"view private profile"]) {
        GLPPrivateProfileViewController *ppvc = segue.destinationViewController;
        ppvc.selectedUserId = self.selectedUserId;
        
    }
    else if([segue.identifier isEqualToString:@"view profile"]) {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    }
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


# pragma mark - Misc

-(BOOL)isNewChat
{
    NSUInteger numberOfViewControllersOnStack = [self.navigationController.viewControllers count];
    UIViewController *parentViewController = self.navigationController.viewControllers[numberOfViewControllersOnStack - 2];
    Class parentVCClass = [parentViewController class];
    NSString *className = NSStringFromClass(parentVCClass);
    
    if([className isEqualToString:@"ChatViewAnimationController"]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];
        return YES;
    }
    
    return NO;
}


@end
