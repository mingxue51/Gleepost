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

#import "GLPMessageCell.h"
#import "GLPLoadingCell.h"

#import "GLPMessageDao.h"
#import "SessionManager.h"
#import "AppearanceHelper.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "KeyboardHelper.h"
#import "NSString+Utils.h"
#import "ConversationManager.h"
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
#import "SoundHelper.h"
#import "UINavigationBar+Format.h"
#import "ShapeFormatterHelper.h"
#import "UIView+GLPDesign.h"
#import <TAPKeyboardPop/UIViewController+TAPKeyboardPop.h>
#import "GLPShowUsersViewController.h"
#import "GLPConversationHelper.h"
#import "GLPLiveGroupManager.h"
#import "GLPSystemMessage.h"

#import "GLPReadReceiptsManager.h"
#import "GLPReadReceipt.h"
#import "GLPMessageDetailsViewController.h"
#import "GLPViewImageHelper.h"
#import "ImageSelectorViewController.h"
#import "Gleepost-Swift.h"
#import "MRNavigationBarProgressView.h"

@interface GLPConversationViewController () <ImageSelectorViewControllerDelegate, ImagePickerSheetControllerDelegate, ImagePickerSheetiOS7ControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *formView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet HPGrowingTextView *formTextView;

@property (assign, nonatomic) NSInteger selectedUserId;
@property (strong, nonatomic) NSString *selectedShowUsersTitle;
@property (strong, nonatomic) NSArray *selectedShowUsers;
@property (strong, nonatomic) GLPMessage *selectedMessage;

@property (strong, nonatomic) NSMutableArray *messages;

@property (strong, nonatomic) GLPIntroducedProfile * introduced;

@property (assign, nonatomic) BOOL isEmptyConversation;
@property (assign, nonatomic) BOOL isWaitingForSyncConversation;


@property (assign, nonatomic) BOOL isFirstLoaded;

@property (strong, nonatomic) GLPConversationHelper *conversationHelper;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageFormViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageFormViewDistanceFromBottom;

/** This variable is used to prevent the resizing of the table view and of the text view when user navigates back
 to the previews VC using the sliding gesture. 
 Look in method keyboardWillShow: and in method tableViewClicked:.
 This variable is used with the compination of TAPKeyboardPop library.
 */
@property (assign, nonatomic, getter = isCommingFromTableViewClick) BOOL comesFromTableViewClick;

@property (assign, nonatomic, getter=isOffline) BOOL offline;

//Uploading stuff.
@property (strong, nonatomic) GLPPickImageHelper *pickImageHelper;
@property (strong, nonatomic) MRNavigationBarProgressView *uploadingMediaProgressView;

@end

@implementation GLPConversationViewController

@synthesize conversation=_conversation;
@synthesize messages=_messages;

static NSString * const kCellIdentifier = @"GLPMessageCell";

- (void)viewDidLoad
{
    [super viewDidLoad];

    // configuration
    [self configureHeader];
    [self initialiseObjects];
    [self configureTitleNavigationBar];
    [self configureForm];
    [self configureTableView];
    [self configureNavigationBarProgressView];
    [self configureViewDidLoadNotifications];
    
    _messages = [NSMutableArray array];
    [self reloadWithItems:_messages];
    
    _isEmptyConversation = _conversation.remoteKey == 0;
    DDLogInfo(@"Conversation is empty: %d", _isEmptyConversation);
    
    _isWaitingForSyncConversation = _conversation.isFromPushNotification;
    DDLogInfo(@"Conversation is waiting for sync: %d", _isWaitingForSyncConversation);
    
    if([self canLoadMessages]) {
        [self loadInitialMessages];
    }
    _isFirstLoaded = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureNavigationBar];
    
    [self hideNetworkErrorViewIfNeeded];
    
    [self configureNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self configureTitleNavigationBar];

    [self.tableView reloadData];
    
    [self syncWaitingConversation];
    
    //TODO: Removed.
    //[self loadInitialMessages];
    
    [self sendViewToGAI:NSStringFromClass([self class])];
    [self sendViewToFlurry:NSStringFromClass([self class])];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [[GLPLiveConversationsManager sharedInstance] resetLastShownMessageForConversation:_conversation];

    [self removeNotifications];
    
    [_conversationHelper resetLastShownMessageForConversation:_conversation];

    [self removeNavigationBarProgressView];
    
    [super viewWillDisappear:animated];
}

#pragma mark - Configuration

- (void)configureNotifications
{
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conversationsSyncFromNotification:) name:GLPNOTIFICATION_CONVERSATIONS_SYNC object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncWithRemoteFromNotification:) name:GLPNOTIFICATION_SYNCHRONIZED_WITH_REMOTE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notSyncWithRemoteFromNotification:) name:GLPNOTIFICATION_NOT_SYNCHRONIZED_WITH_REMOTE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageSendUpdateFromNotification:) name:GLPNOTIFICATION_MESSAGE_SEND_UPDATE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedReadReceiptUpdate:) name:GLPNOTIFICATION_READ_RECEIPT_RECEIVED object:nil];
    
    
    //Image uploading
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageUploadingStatusChanged:) name:GLPNOTIFICATION_UPLOADING_IMAGE_CHANGED_STATUS object:nil];

}

- (void)configureViewDidLoadNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedImagesReceived:) name:GLPNOTIFICATION_SELECTED_IMAGES object:nil];
}

- (void)removeViewDidLoadNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_SELECTED_IMAGES object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_ONE_CONVERSATION_SYNC object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CONVERSATIONS_SYNC object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_SYNCHRONIZED_WITH_REMOTE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_NOT_SYNCHRONIZED_WITH_REMOTE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_MESSAGE_SEND_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_READ_RECEIPT_RECEIVED object:nil];
    
    //Image uploading.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_UPLOADING_IMAGE_CHANGED_STATUS object:nil];

}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if(!parent)
    {
        [self removeViewDidLoadNotifications];
    }
}


-(void)initialiseObjects
{
    self.introduced = nil;
    _offline = NO;
    _conversationHelper = [[GLPConversationHelper alloc] initWithBelongsToGroup:(_conversation.groupRemoteKey != 0) ? YES : NO];
    self.pickImageHelper = [[GLPPickImageHelper alloc] init];
}

- (void)configureTitleNavigationBar
{
    [self.navigationController setNavigationBarHidden:NO];
    
    if([_conversationHelper doesBelongToGroup])
    {
        [self setGroupTitleViewOnNavigationBar];
    }
    else
    {
        // navigate to profile through navigation bar for user-to-user conversation
        [self setTitleViewOnNavigationBar];
    }

    if([self isNewChat])
    {
        //Add the add user button to navigation bar.
        [self addRandomChatAddUser];
        
        //Add custom button to go back.
        [self addCustomBackButton];
    }
    
    _comesFromTableViewClick = NO;
    
}

- (void)setGroupTitleViewOnNavigationBar
{
    GLPGroup *group = [[GLPLiveGroupManager sharedInstance] groupWithRemoteKey:_conversation.groupRemoteKey];
    
    self.title = group.name.uppercaseString;
}

- (void)setTitleViewOnNavigationBar
{
    //Create a button instead of using the default title view for recognising gestures.
    UIButton *titleLabelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleLabelBtn setTitle:[_conversation.title uppercaseString] forState:UIControlStateNormal];
    [titleLabelBtn.titleLabel setFont:[UIFont fontWithName:GLP_CAMPUS_WALL_TITLE_FONT size:15.0]];
    
    if([_conversation isGroup])
    {
        titleLabelBtn.tag = -1;
    }
    else
    {
        titleLabelBtn.tag = [_conversation getUniqueParticipant].remoteKey;
    }
    
    //Set colour to the view.
    [titleLabelBtn setTitleColor:[[GLPThemeManager sharedInstance] navigationBarTitleColour] forState:UIControlStateNormal];
    
    //Set navigation to profile selector.
    titleLabelBtn.frame = CGRectMake(0, 0, 70, 44);
    [titleLabelBtn addTarget:self action:@selector(navigateToUserProfileOrShowUsers:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleLabelBtn;
}

- (void)configureNavigationBar
{
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
    [self.navigationController.navigationBar setFontFormatWithColour:kGreen];
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

- (void)hideNetworkErrorViewIfNeeded
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_HIDE_ERROR_VIEW object:self userInfo:nil];
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
//    if([self isNewChat]) {
//        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"GLPIntroducedProfile" owner:self options:nil];
//        
//        self.introduced = [array objectAtIndex:0];
//        [self.introduced updateContents:[_conversation getUniqueParticipant]];
//        self.introduced.delegate = self;
//        
//        self.tableView.tableHeaderView = self.introduced;
//    }
}

- (void)configureForm
{
    self.formTextView.isScrollable = NO;
    self.formTextView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
	self.formTextView.minNumberOfLines = 1;
	self.formTextView.maxNumberOfLines = 4;
    self.formTextView.minHeight = 36;
	self.formTextView.returnKeyType = UIReturnKeyDefault;
	self.formTextView.font = [UIFont systemFontOfSize:15.0f];
	self.formTextView.delegate = self;
    self.formTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    
    self.formTextView.backgroundColor = [AppearanceHelper lightGrayGleepostColour];
    [ShapeFormatterHelper setBorderToView:self.formTextView withColour:[AppearanceHelper mediumGrayGleepostColour] andWidth:1.0];
    self.formTextView.placeholder = @"Type a message...";
    
    self.formTextView.tag = 100;
    
    self.formTextView.layer.cornerRadius = 3;
    [self.formView setGleepostStyleTopBorder];
}

- (void)configureNavigationBarProgressView
{
    self.uploadingMediaProgressView = [MRNavigationBarProgressView progressViewForNavigationController:self.navigationController];
    self.uploadingMediaProgressView.progress = 0.0;
}

- (void)removeNavigationBarProgressView
{
    self.uploadingMediaProgressView.progress = 0.0;
}

- (void)configureTableView
{
    [self.tableView registerClass:[GLPMessageCell class] forCellReuseIdentifier:kCellIdentifier];
}


- (void)configureNewConversation:(GLPConversation *)conversation
{
    _conversation = conversation;

    [self configureHeader];
    [self configureTitleNavigationBar];
//    [self configureNavigationBar];
}


# pragma mark - Messages

- (BOOL)canLoadMessages
{
    return !_isEmptyConversation && !_isWaitingForSyncConversation;
}

- (void)loadInitialMessages
{
    [self loadNewMessages];
    [self scrollToTheEndWithDelay];
    [self syncConversation];
}

- (void)syncConversation
{
    DDLogInfo(@"Syncing conversation");
//    [[GLPLiveConversationsManager sharedInstance] syncConversation:_conversation];

    [_conversationHelper syncConversation:_conversation];
    
    if(_messages.count == 0) {
        [self showBottomLoader];
    }
}

- (void)loadNewMessages
{
    DDLogInfo(@"Load new messages");
    
//    NSArray *newMessages = [[GLPLiveConversationsManager sharedInstance] lastestMessagesForConversation:_conversation];

    NSArray *newMessages = [_conversationHelper lastestMessagesForConversation:_conversation];

    
    //Maybe bad practise of code.
    //If the variable is offline and the new messages count is not zero then clear the messages
    //because it means that already has messages from local database.
    if([self isOffline] && newMessages.count > 0)
    {
        [_messages removeAllObjects];
        _offline = NO;
    }
    
    [_messages addObjectsFromArray:newMessages];
    [self showLoadedMessages];
    
    //Mark the messages up to the last one as read.
    [self markMessagesAsReadUpToTheLastSeen];
}

- (void)loadPreviousMessages
{
    DDLogInfo(@"Load previous messages");
    
//    NSArray *previousMessages = [[GLPLiveConversationsManager sharedInstance] oldestMessagesForConversation:_conversation];

    NSArray *previousMessages = [_conversationHelper oldestMessagesForConversation:_conversation];

    
    [self saveScrollContentOffset];
    
    [_messages insertObjects:previousMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, previousMessages.count)]];
    [self showLoadedMessages];
    
    [self restoreScrollContentOffsetAfterInsertingNewItems:previousMessages];
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
        
        //Do not configure as following message if the previous message is system message.
        if ([current.author.name isEqualToString:previous.author.name] && ![previous isKindOfClass:[GLPSystemMessage class]]) {
            [current configureAsFollowingMessage:previous];
            previous = current;
        }
        else {
//            [current configureAsFirstMessage];
            [current configureAsOtherUsersFollowingMessage:previous];
            previous = current;
        }
    }
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
    [ConversationManager createMessageWithContent:self.formTextView.text toConversation:self.conversation];
    
    self.formTextView.text = @"";
}

- (void)syncWaitingConversation
{
    if(!_isWaitingForSyncConversation) {
        return;
    }
    
    DDLogInfo(@"Try to sync waiting conversation");
    
//    GLPConversation *conversation = [[GLPLiveConversationsManager sharedInstance] findByRemoteKey:_conversation.remoteKey];

    GLPConversation *conversation = [_conversationHelper findByRemoteKey:_conversation.remoteKey];

    
    if(!conversation) {
        DDLogInfo(@"Conversation waiting to be loaded not found");
        return;
    }
    
    _isWaitingForSyncConversation = NO;
    
    [self configureNewConversation:conversation];
    [self loadInitialMessages];
}

- (void)markMessagesAsReadUpToTheLastSeen
{
//    [[GLPLiveConversationsManager sharedInstance] markConversation:_conversation upToTheLastMessageAsRead:[_messages lastObject]];

    [_conversationHelper markConversation:_conversation upToTheLastMessageAsRead:[_messages lastObject]];
}

/**
 This method fetch from database the conversation's messages if the parameter messages array
 is empty. If the messages array is empty it might means two things:
 1) The conversation doesn't contains any messages yet. (This possibility should NOT appear!).
 2) The phone is disconnected from the network.

 */
- (void)loadInitialMessagesFromDatabase
{
//    NSArray *messages = [[GLPLiveConversationsManager sharedInstance] loadLatestMessagesForConversation:_conversation];

    NSArray *messages = [_conversationHelper loadLatestMessagesForConversation:_conversation];
    
    _messages = messages.mutableCopy;
    [self showLoadedMessages];
    [self scrollToTheEndAnimated:NO];

}

- (void)receivedReadReceiptUpdate:(NSNotification *)notification
{
    NSInteger messageRemoteKey = [notification.userInfo[@"message_remote_key"] integerValue];
    
    for(GLPMessage *msg in _messages)
    {
        if(messageRemoteKey == msg.remoteKey)
        {
            DDLogDebug(@"GLPConversationViewController : message reloaded %@", msg.content);
            [self reloadItem:msg sizeCanChange:NO];
        }
    }
    [self scrollToTheEndAnimated:YES];
}

# pragma mark - Notifications (keyboard ones in form management mark)

// Conversation is sync
- (void)conversationSyncFromNotification:(NSNotification *)notification
{
    if(![self canLoadMessages]) {
        return;
    }
    
    DDLogInfo(@"Conversation sync from notification");
    NSInteger conversationRemoteKey = [[notification userInfo][@"remoteKey"] integerValue];
    
    if(conversationRemoteKey != _conversation.remoteKey) {
        DDLogInfo(@"Conversation is not the current one, abort");
        return;
    }
    
    BOOL hasNewMessages = [[notification userInfo][@"newMessages"] boolValue];
    BOOL canHavePreviousMessages = [[notification userInfo][@"canHaveMorePreviousMessages"] boolValue];
    
    // previous messages loaded
    if([[notification userInfo][@"previousMessages"] boolValue]) {
        if(canHavePreviousMessages) {
            [self showTopLoader:YES saveOffset:NO];
        } else {
            [self hideTopLoader];
        }
        
        if(hasNewMessages) {
            [self loadPreviousMessages];
        }
    }
    // new messages loaded
    else {
        BOOL scrollAnimated = _messages.count > 0;
        
        // bottom loader displayed if messages's empty
        if(_messages.count == 0) {
            // hide bottom loader without animation if there are some messages to show
            [self hideBottomLoader:!hasNewMessages];
            
            [self loadInitialMessagesFromDatabase];
            
            _offline = YES;
        }
        
        if(canHavePreviousMessages) {
            [self showTopLoader:NO saveOffset:YES];
        }
        
        if(hasNewMessages) {
            [self loadNewMessages];
            [self scrollToTheEndAnimated:scrollAnimated];

        }
        
        if(canHavePreviousMessages) {
            if(scrollAnimated) {
                [self performSelector:@selector(activateTopLoader) withObject:nil afterDelay:0.3];
            } else {
                [self activateTopLoader];
            }
        } else {
            
            //TODO: Add sound once message received.
            
            if(_isFirstLoaded)
            {
                _isFirstLoaded= NO;

            }
            else
            {
                [[SoundHelper sharedInstance] messageSent];
            }
            
//            [self hideTopLoader];
        }
        _isFirstLoaded= NO;
        
    }
}

// Conversations list is sync
- (void)conversationsSyncFromNotification:(NSNotification *)notification
{
    DDLogInfo(@"Conversations sync from notificaiton");
    
    [self syncWaitingConversation];
}

// Sync with remote
// Scenario:
// - User on conversationVC
// - Goes background
// - Receive message (websocket closed)
// - Goes active
// - Web socket reconnect, resynch process, GET conversations list
// - Sync with remote notif
- (void)syncWithRemoteFromNotification:(NSNotification *)notification
{
    if(![self canLoadMessages]) {
        return;
    }
    
    DDLogInfo(@"Synchronized with remote from NSNotification");
    [self syncConversation];
}

- (void)notSyncWithRemoteFromNotification:(NSNotification *)notification
{
    if(![self canLoadMessages]) {
        return;
    }
    
    DDLogInfo(@"Not synchronized with remote from NSNotification");
    
    if(_messages.count == 0) {
        [self hideBottomLoader:YES];
    }
    
    
    [self hideTopLoader];
}

- (void)messageSendUpdateFromNotification:(NSNotification *)notification
{
    if(![self canLoadMessages]) {
        return;
    }
    
    DDLogInfo(@"Message send update from NSNotification");
    NSInteger key = [[notification userInfo][@"key"] integerValue];
    NSInteger remoteKey = [[notification userInfo][@"remote_key"] integerValue];
    BOOL sent = [[notification userInfo][@"sent"] boolValue];
    NSString *updatedContent = [notification userInfo][@"updated_content"];
    
    NSArray *filtered = [_messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"key = %d", key]];
    if(filtered.count != 1) {
        DDLogError(@"Grave inconsistency: cannot find message in local messages for key: %ld - filtered array count: %lu", (long)key, (unsigned long)filtered.count);
        return;
    }
    
    GLPMessage *message = [filtered firstObject];
    
    if(sent) {
        message.sendStatus = kSendStatusSent;
        message.remoteKey = remoteKey;
        message.content = (updatedContent) ? updatedContent : message.content;
    } else {
        message.sendStatus = kSendStatusFailure;
    }
    
    [self reloadWithItems:_messages];
    
//    [self reloadItem:message sizeCanChange:YES];
//    DDLogInfo(@"Reload message key: %d - remote key: %d - content: %@", message.key, message.remoteKey, message.content);
}

#pragma mark - Actions

- (void) backButtonTapped
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)sendButtonClicked:(id)sender
{
    if([self.formTextView.text isEmpty]) {
        return;
    }
    
    if(_isEmptyConversation) {
        
        //Bring support of group conversation.
        
        if(_conversation.isGroup)
        {
            //Create new group conversation.
//            [[GLPLiveConversationsManager sharedInstance] createRegularConversationWithUsers:_conversation.participants callback:^(GLPConversation *conversation) {
//               
//                _conversation = conversation;
//                _isEmptyConversation = NO;
//                
//                [self createMessageFromForm];
//                
//            }];
            
            [_conversationHelper createRegularConversationWithUsers:_conversation.participants callback:^(GLPConversation *conversation) {
                
                _conversation = conversation;
                _isEmptyConversation = NO;
                
                [self createMessageFromForm];
                
            }];
        }
        else
        {
//            [[GLPLiveConversationsManager sharedInstance] createRegularConversationWithUser:[_conversation getUniqueParticipant] callback:^(GLPConversation *conversation) {
//                _conversation = conversation;
//                _isEmptyConversation = NO;
//                [self createMessageFromForm];
//            }];

            [_conversationHelper createRegularConversationWithUser:[_conversation getUniqueParticipant] callback:^(GLPConversation *conversation) {
                _conversation = conversation;
                _isEmptyConversation = NO;
                [self createMessageFromForm];
            }];
        }
        

    } else {
        [self createMessageFromForm];
    }
}

- (IBAction)tableViewClicked:(id)sender
{
    _comesFromTableViewClick = YES;
    
    [self hideKeyboardFromTextViewIfNeeded];
}

-(void)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)disableAddUserButton
{
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

#pragma mark - form management

- (void)keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    
    DDLogDebug(@"keyboardWillShow Y %f", self.tableView.frame.origin.y);

    
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curve.intValue;
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
//	CGRect containerFrame = self.formView.frame;
//    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
//    
//	CGRect tableViewFrame = self.tableView.frame;
//    tableViewFrame.size.height = containerFrame.origin.y - self.tableView.frame.origin.y;
    
    if(keyboardBounds.size.height == 0)
    {
        return;
    }
    
    [_formView layoutIfNeeded];
    [self.tableView layoutIfNeeded];
    
    DDLogDebug(@"Keyboard will show");
    
    [UIView animateWithDuration:[duration doubleValue] delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|(animationCurve << 16)) animations:^{
//        self.formView.frame = containerFrame;
//        self.tableView.frame = tableViewFrame;
//        
//        [self scrollToTheEndAnimated:NO];
        
        _messageFormViewDistanceFromBottom.constant = keyboardBounds.size.height;
        [_formView layoutIfNeeded];
        [self.tableView layoutIfNeeded];
        
    } completion:^(BOOL finished) {
//        [self.tableView setNeedsLayout];
    }];

    [self scrollToTheEndAnimated:YES];

}

- (void)keyboardWillHide:(NSNotification *)note{
    
    
    if(![self isCommingFromTableViewClick])
    {
        
        return;
    }
    
    DDLogDebug(@"keyboardWillHide Y %f", self.tableView.frame.origin.y);
    
    _comesFromTableViewClick = NO;
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curve.intValue;
	
	// get a rect for the textView frame
//	CGRect containerFrame = self.formView.frame;
//    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
//    
//	CGRect tableViewFrame = self.tableView.frame;
//    tableViewFrame.size.height = containerFrame.origin.y - self.tableView.frame.origin.y;
    
    [_formView layoutIfNeeded];
    [self.tableView layoutIfNeeded];
    
    [UIView animateWithDuration:[duration doubleValue] delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|(animationCurve << 16)) animations:^{
//        self.formView.frame = containerFrame;
//        self.tableView.frame = tableViewFrame;
        
        _messageFormViewDistanceFromBottom.constant = 0;
        [_formView layoutIfNeeded];
        [self.tableView layoutIfNeeded];
        
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
    
//	CGRect r = self.formView.frame;
//    r.size.height -= diff;
//    r.origin.y += diff;
//	self.formView.frame = r;
//    
//    CGRect tableViewFrame = self.tableView.frame;
//    tableViewFrame.size.height += diff;
//    self.tableView.frame = tableViewFrame;
    _messageFormViewHeight.constant -= diff;
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
//    NSAssert(message.cellIdentifier, @"Cell identifier is required but null");
    
    GLPMessageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    
    [cell configureWithMessage:message];
    
    return cell;
}

- (CGFloat)heightForItem:(id)item
{
    GLPMessage *message = (GLPMessage *)item;
    return [GLPMessageCell viewHeightForMessage:message];
}

- (void)loadingCellActivatedForPosition:(GLPLoadingCellPosition)position
{
    DDLogInfo(@"Loading cell activated for position: %d", position);
    if(position != kGLPLoadingCellPositionTop) {
        return;
    }
    
//    [[GLPLiveConversationsManager sharedInstance] syncConversationPreviousMessages:_conversation];
    [_conversationHelper syncConversationPreviousMessages:_conversation];

}

//- (BOOL)animateAlongsideTransition:(void (^)(id <UIViewControllerTransitionCoordinatorContext>context))animation
//                        completion:(void (^)(id <UIViewControllerTransitionCoordinatorContext>context))completion
//{
//    DDLogDebug(@"animateAlongsideTransition");
//    
//    
//    return YES;
//}
//
//- (BOOL)animateAlongsideTransitionInView:(UIView *)view animation:(void (^)(id<UIViewControllerTransitionCoordinatorContext> context))animation completion:(void (^)(id<UIViewControllerTransitionCoordinatorContext> context))completion
//{
//    DDLogDebug(@"animateAlongsideTransitionInView");
//    
//    return YES;
//}
//
//- (void)notifyWhenInteractionEndsUsingBlock:(void (^)(id<UIViewControllerTransitionCoordinatorContext> context))handler
//{
//    DDLogDebug(@"notifyWhenInteractionEndsUsingBlock");
//}

# pragma mark - GLPMessageCellDelegate

- (void)profileImageClickForMessage:(GLPMessage *)message
{
    [self navigateToUserProfile:message.author];
}
- (void)errorButtonClickForMessage:(GLPMessage *)message
{
    //TODO: Implement that.
    DDLogDebug(@"Message: %@ not sent.", message.content);
}

- (void)mainViewClickForMessage:(GLPMessage *)message
{
    _selectedMessage = message;
    [self performSegueWithIdentifier:@"show message details" sender:self];
}

- (void)readReceitClickForMessage:(GLPMessage *)message
{
    _selectedMessage = message;
    [self performSegueWithIdentifier:@"show message details" sender:self];
}

- (void)messageImageClickedForMessage:(GLPMessage *)message withImageView:(UIImageView *)imageView
{
    [GLPViewImageHelper showImageInViewController:self withImageView:imageView];
}

#pragma mark - ImageSelectorViewControllerDelegate

- (void)takeImage:(UIImage *)image
{
    [self sendImageMessages:@[image]];
}

#pragma mark - NSNotifications

- (void)selectedImagesReceived:(NSNotification *)notification
{
    NSArray *images = notification.userInfo[@"images"];
    DDLogDebug(@"GLPConversationViewController images received %@", images);
    [self sendImageMessages:images];
}

/**
    Notification contains timestamp and progress status.
 */

- (void)imageUploadingStatusChanged:(NSNotification *)notification
{
    CGFloat status = [notification.userInfo[@"status"] floatValue];
    NSString *timestamp = notification.userInfo[@"timestamp"];
    
    DDLogDebug(@"GLPConversationViewController imageUploadingStatusChanged status %f - %@", status, timestamp);
    
    self.uploadingMediaProgressView.progress = status;
}

#pragma mark - ImagePickerSheetControllerDelegate

- (void)presentCameraView
{
    [self.pickImageHelper presentCamera:self];
}

- (void)presentFullSizeImagePicker
{
    [self performSegueWithIdentifier:@"pick image" sender:self];
}

#pragma mark - Image progressing

- (void)sendImageMessages:(NSArray *)images
{
    NSArray *timestamps = [[GLPImageUploader sharedInstance] addItems:images];
    [ConversationManager createImageMessagesWithTimestamps:timestamps toConversation:self.conversation];
}

#pragma mark - Selectors

- (IBAction)pickImage:(id)sender
{
    [self.pickImageHelper presentImagePickerWithViewController:self];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"view private profile"]) {
        GLPPrivateProfileViewController *ppvc = segue.destinationViewController;
        ppvc.selectedUserId = self.selectedUserId;
        
    }
    else if([segue.identifier isEqualToString:@"view profile"]) {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    }
    else if([segue.identifier isEqualToString:@"show users"])
    {
        GLPShowUsersViewController *showUsers = segue.destinationViewController;
        showUsers.selectedTitle = _selectedShowUsersTitle;
        showUsers.users = _selectedShowUsers;
    }
    else if([segue.identifier isEqualToString:@"show message details"])
    {
        GLPMessageDetailsViewController *messageDetailsVC = segue.destinationViewController;
        messageDetailsVC.message = _selectedMessage;
        messageDetailsVC.reads = _conversation.reads;
    }
    else if([segue.identifier isEqualToString:@"pick image"])
    {
        ImageSelectorViewController *imgSelectorVC = segue.destinationViewController;
        imgSelectorVC.fromGroupViewController = NO;
        [imgSelectorVC setDelegate:self];
    }
}

#pragma mark - Navigation

-(void)navigateToUserProfileOrShowUsers:(id)sender
{
    UIButton *userButton = (UIButton *)sender;
    
    if(userButton.tag == -1)
    {
        _selectedShowUsersTitle = @"PARTICIPANTS";
        _selectedShowUsers = _conversation.participants;
        
        //Navigate to view a list of users like the attending list.
        [self performSegueWithIdentifier:@"show users" sender:self];
    }
    else
    {
        [self navigateToUserProfile:[[GLPUser alloc] initWithRemoteKey:userButton.tag]];
    }
}

-(void)navigateToUserProfile:(GLPUser *)user
{
    self.selectedUserId = user.remoteKey;
    
    if([[ContactsManager sharedInstance] userRelationshipWithId:self.selectedUserId] == kCurrentUser)
    {
        self.selectedUserId = -1;
        
        [self performSegueWithIdentifier:@"view profile" sender:self];
    }
    else
    {
        [self performSegueWithIdentifier:@"view private profile" sender:self];
    }
}

@end
