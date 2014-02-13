//
//  GLPConversationViewController.m
//  Gleepost
//
//  Created by Lukas on 1/30/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPConversationViewController.h"
#import "GLPPrivateProfileViewController.h"

#import <QuartzCore/QuartzCore.h>

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
#import "GLPLiveConversationsManager.h"
#import "GLPNetworkManager.h"
#import "GLPViewControllerHelper.h"

#import "GLPMessage.h"
#import "GLPMessage+CellLogic.h"
#import "GLPUser.h"

#import "CurrentChatButton.h"



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

@property (strong, nonatomic) GLPIntroducedProfile * introduced;

@end

@implementation GLPConversationViewController

@synthesize conversation=_conversation;
@synthesize messages=_messages;


- (void)viewDidLoad
{
    [super viewDidLoad];

    // configuration
    [self configureHeader];
    [self configureNavigationBar];
    [self configureForm];
    [self initialiseObjects];
    
    _messages = [NSMutableArray array];
    [self reloadWithItems:_messages];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.tableView.frame.size.height < 465.0f) {
        [self.tableView setFrame:CGRectMake(0, 0, 320, 460)];
        
    }
    
    // keyboard management
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conversationSyncFromNotification:) name:GLPNOTIFICATION_ONE_CONVERSATION_SYNC object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncWithRemoteFromNotification:) name:GLPNOTIFICATION_SYNCHRONIZED_WITH_REMOTE object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
    [self loadInitialMessages]; 
    
    [self sendViewToGAI:NSStringFromClass([self class])];
    [self sendViewToFlurry:NSStringFromClass([self class])];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[GLPLiveConversationsManager sharedInstance] resetLastShownMessageForConversation:_conversation];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_ONE_CONVERSATION_SYNC object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_SYNCHRONIZED_WITH_REMOTE object:nil];
    
    [super viewWillDisappear:animated];
}



# pragma mark - Configuration

-(void)initialiseObjects
{
    self.introduced = nil;
}

- (void)configureNavigationBar
{
    [self.navigationController setNavigationBarHidden:NO];
    
    // navigate to profile through navigation bar for user-to-user conversation
    if(!_conversation.isGroup /*&& ![self isNewChat] */) {
        //Create a button instead of using the default title view for recognising gestures.
        UIButton *titleLabelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [titleLabelBtn setTitle:_conversation.title forState:UIControlStateNormal];
        [titleLabelBtn.titleLabel setFont:[UIFont fontWithName:GLP_TITLE_FONT size:20.0f]];
        titleLabelBtn.tag = [_conversation getUniqueParticipant].remoteKey;
        
        //Set colour to the view.
        [titleLabelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        //Set navigation to profile selector.
        titleLabelBtn.frame = CGRectMake(0, 0, 70, 44);
        [titleLabelBtn addTarget:self action:@selector(navigateToProfile:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.titleView = titleLabelBtn;
    }
    

    if([self isNewChat])
    {
        //Add the add user button to navigation bar.
        [self addRandomChatAddUser];
        
        //Add custom button to go back.
        [self addCustomBackButton];
    }
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, nil]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    [AppearanceHelper setNavigationBarFontFor:self];
    [AppearanceHelper setNavigationBarColour:self];
}

-(void)addCustomBackButton
{
    UIImage *img = [UIImage imageNamed:@"back"];
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:img forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(0, 0, 13, 21)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];
}

-(void)addRandomChatAddUser
{
    
    UIImage *img = [UIImage imageNamed:@"add_button"];
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self.introduced action:@selector(addUser:) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:img forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(0, 0, 25, 25)];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.rightBarButtonItem = addButton;
}


-(void)configureHeader
{
    if([self isNewChat]) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"GLPIntroducedProfile" owner:self options:nil];
        
        self.introduced = [array objectAtIndex:0];
        [self.introduced updateContents:[_conversation getUniqueParticipant]];
        self.introduced.delegate = self;
        
        self.tableView.tableHeaderView = self.introduced;
    }
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

- (void)loadInitialMessages
{
    [self loadNewMessages];
    [self scrollToTheEndAnimated:YES];
    
//    if([GLPNetworkManager sharedInstance].networkStatus != kGLPNetworkStatusOnline) {
//        DDLogInfo(@"No network, abort loading initial messages");
//        DDLogInfo(@"Network status: %d", [GLPNetworkManager sharedInstance].networkStatus);
//        [[GLPViewControllerHelper sharedInstance] showErrorNetworkMessage];
//        return;
//    }
    
    [self syncConversation];
}

- (void)syncConversation
{
    DDLogInfo(@"Syncing conversation");
    [[GLPLiveConversationsManager sharedInstance] syncConversation:_conversation];
    [self showBottomLoader];
}

//- (void)loadExistingMessages
//{
//    DDLogInfo(@"Load existing messages");
//
//    _messages = [[[GLPLiveConversationsManager sharedInstance] messagesForConversation:_conversation startingAfter:nil] mutableCopy];
//    
//    [self showLoadedMessages];
//}

- (void)loadNewMessages
{
    DDLogInfo(@"Load new messages");
    
    NSArray *newMessages = [[GLPLiveConversationsManager sharedInstance] lastestMessagesForConversation:_conversation];
    
    [_messages addObjectsFromArray:newMessages];
    [self showLoadedMessages];
}

- (void)showLoadedMessages
{
    [self configureDisplayForMessages:_messages];
    [self reloadWithItems:_messages];
}

- (void)configureDisplayForMessages:(NSArray *)messages
{

    GLPMessage *previous;
    for (int i = 0; i < messages.count; i++) {
        GLPMessage *current = messages[i];
        if(i == 0) {
            [current configureAsFirstMessage];
            previous = current;
            continue;
        }
        
        if ([current.author.name isEqualToString:previous.author.name]) {
            [current configureAsFollowingMessage:previous];
            previous = current;
        }
        else {
            [current configureAsFirstMessage];
            previous = current;
        }
    }

    /*
    for (int i = 0; i < messages.count; i++) {
        
        NSLog(@"running loop %d", i);
        GLPMessage *current = messages[i];
        if(i == 0) {
            [current configureAsFirstMessage];

        } else {
            GLPMessage *previous = messages[i-1];
            [current configureAsFollowingMessage:previous];
        }
    }
     */
}

- (void)showMessage:(GLPMessage *)message
{
    if(_messages.count == 0) {
        [message configureAsFirstMessage];
    } else {
        GLPMessage *last = [_messages lastObject];
        [message configureAsFollowingMessage:last];
    }
    
    [_messages addObject:message];
    [self reloadWithItems:_messages];
    
    [self scrollToTheEndAnimated:YES];
}

- (void)createMessageFromForm
{
//    [UIView animateWithDuration:2.0f animations:^{
//        //Remove header view after first message.
//        [self.tableView.tableHeaderView setAlpha:0.0f];
//    }];
    
    [ConversationManager createMessageWithContent:self.formTextView.text toConversation:self.conversation];
    
    self.formTextView.text = @"";
}


# pragma mark - Notifications (keyboard ones in form management mark)

- (void)conversationSyncFromNotification:(NSNotification *)notification
{
    DDLogInfo(@"Conversation sync from notification");
    NSInteger conversationRemoteKey = [[notification userInfo][@"remoteKey"] integerValue];
    
    if(conversationRemoteKey != _conversation.remoteKey) {
        DDLogInfo(@"Conversation is not the current one, abort");
        return;
    }
    
    [self hideBottomLoader];
    
    BOOL hasNewMessages = [[notification userInfo][@"newMessages"] boolValue];
    if(hasNewMessages) {
        [self loadNewMessages];
        [self scrollToTheEndAnimated:YES];
    }
}

// Conversations list sync
// Scenario:
// - User on conversationVC
// - Goes background
// - Receive message (websocket closed)
// - Goes active
// - Web socket reconnect, resynch process, GET conversations list
// - Sync with remote notif
- (void)syncWithRemoteFromNotification:(NSNotification *)notification
{
    DDLogInfo(@"Synchronized with remote NSNotification");
    [self syncConversation];
}

//- (void)showMessageFromNotification:(NSNotification *)notification
//{
//    GLPMessage *message = [notification userInfo][@"message"];
//    NSLog(@"Show message from notification %@ : Date: %@", message, message.date);
//    
//    if(_conversation.remoteKey != message.conversation.remoteKey) {
//        NSLog(@"Long poll message is not for the current conversation, ignore");
//        return;
//    }
//    
//    [self showMessage:message];
//    
//    // conversation has no more unread messages
////    if(!_conversation.isLive) {
////        [ConversationManager markConversationRead:self.conversation];
////    }
//}


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

-(void)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)disableAddUserButton
{
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
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

        return YES;
    }
    
    return NO;
}


# pragma mark - GLPTableViewController

- (UITableViewCell *)cellForItem:(id)item forIndexPath:(NSIndexPath *)indexPath
{
    GLPMessage *message = (GLPMessage *)item;
    NSAssert(message.cellIdentifier, @"Cell identifier is required but null");
    
    MessageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:message.cellIdentifier forIndexPath:indexPath];
    
    // add touch gesture to avatar image view
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigateToProfile:)];
    [cell.avatarImageView addGestureRecognizer:tap];
    
    [cell updateWithMessage:message first:message.hasHeader];
    
    return cell;
}

- (CGFloat)heightForItem:(id)item
{
    GLPMessage *message = (GLPMessage *)item;
    return [MessageCell getCellHeightWithContent:message.content first:message.hasHeader];
}

- (void)loadingCellActivatedForPosition:(GLPLoadingCellPosition)position
{
    
}


@end
