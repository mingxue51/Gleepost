//
//  MessengerViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 19/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "MessengerViewController.h"
#import "MessageTableViewCell.h"
#import "GLPLoadingCell.h"
#import "GLPLiveConversationsManager.h"
#import "GLPConversationViewController.h"
#import "UIViewController+GAI.h"
#import "UIViewController+Flurry.h"
#import "AppearanceHelper.h"
#import "UIColor+GLPAdditions.h"
#import "UINavigationBar+Format.h"
#import "UINavigationBar+Utils.h"
#import "NewGroupMessageViewController.h"
#import "GLPEmptyViewManager.h"
#import "GLPThemeManager.h"
#import "WebClientHelper.h"

@interface MessengerViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

//@property (weak, nonatomic) IBOutlet GLPSegmentView *segmentView;

@property (strong, nonatomic) NSMutableArray *conversations;

@property (strong, nonatomic) NSMutableArray *filteredConversations;

//@property (strong, nonatomic) NSMutableArray *groupConversations;

//@property (assign, nonatomic) ButtonType conversationType;

@property (strong, nonatomic) GLPSearchBar *glpSearchBar;

@property (weak, nonatomic) IBOutlet UIView *searchBarView;

@property (strong, nonatomic) GLPConversation *selectedConversation;

@property (strong, nonatomic) UITapGestureRecognizer *tap;


@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (assign, nonatomic) GLPLoadingCellStatus loadingCellStatus;
@property (strong, nonatomic) UITabBarItem *messagesTabbarItem;

//@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation MessengerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initialiseObjects];
    
    [self configureTableView];
    
    [self registerViews];
    
    [self reloadConversations];
    
    [self configureTabbar];
    
    [self configureGestures];
    
    [self addNavigationButtons];
    
    [self configureViewDidLoadNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureNotifications];
    
    [self configureNavigationBar];
    
    [self showNetworkErrorViewIfNeeded];
    
    [self.tabBarController.tabBar setHidden:NO];

    
    //Change the colour of the tab bar.
//    self.tabBarController.tabBar.tintColor = [UIColor colorWithR:75.0 withG:208.0 andB:210.0];
//    [AppearanceHelper setSelectedColourForTabbarItem:self.messagesTabbarItem withColour:[UIColor colorWithR:75.0 withG:208.0 andB:210.0]];
    
    self.tabBarController.tabBar.tintColor = [[GLPThemeManager sharedInstance] tabbarSelectedColour];
    [AppearanceHelper setSelectedColourForTabbarItem:self.messagesTabbarItem withColour:[AppearanceHelper redGleepostColour]];
    
    
//    if(self.needsReloadConversations) {
        [self reloadConversations];
//    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self sendViewToGAI:NSStringFromClass([self class])];
    [self sendViewToFlurry:NSStringFromClass([self class])];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // reload the local conversations next time the VC appears
//    self.needsReloadConversations = YES;
    [super viewDidDisappear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CONVERSATIONS_SYNC object:nil];
    [AppearanceHelper setUnselectedColourForTabbarItem:self.messagesTabbarItem];
    [super viewWillDisappear:animated];
}

- (void)configureGestures
{
    _tap = [[UITapGestureRecognizer alloc]
            initWithTarget:self
            action:@selector(viewTouched:)];
    
    _tap.cancelsTouchesInView = NO;
    
    [_tableView addGestureRecognizer:_tap];
}

#pragma mark - Configuration

- (void)registerTableViewCells
{
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MessageCell" bundle:nil] forCellReuseIdentifier:@"MessageCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:kGLPLoadingCellNibName bundle:nil] forCellReuseIdentifier:kGLPLoadingCellIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone; // start with no separator for loading cell
}

- (void)configureTableView
{
    [self registerTableViewCells];

    //Remove empty cells.
    [self.tableView setTableFooterView:[[UIView alloc] init]];
}

- (void)registerViews
{
//     NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"GLPSegmentView" owner:self options:nil];
//    
//    GLPSegmentView *view = [array lastObject];
//    [view setDelegate:self];
//    
//    CGRectSetX(view, 10);
//    
//    [_segmentView addSubview:view];
    
    
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"GLPSearchBar" owner:self options:nil];
    
    GLPSearchBar *view = [array lastObject];
    [view setDelegate:self];
    
    [view setPlaceholderWithText:@"Search for conversations"];
    
    view.tag = 101;
    
    _glpSearchBar = view;
    
    [_searchBarView addSubview:view];
    
}

- (void)initialiseObjects
{
    _conversations = [[NSMutableArray alloc] init];
    _filteredConversations = [[NSMutableArray alloc] init];
    
    // various control init
    self.loadingCellStatus = kGLPLoadingCellStatusLoading;
//    self.needsReloadConversations = NO;
    
//    _refreshControl = [[UIRefreshControl alloc] init];
//    [_refreshControl addTarget:self action:@selector(reloadConversations) forControlEvents:UIControlEventValueChanged];
//    
//    [self.tableView addSubview:_refreshControl];
}

- (void)configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conversationsSyncFromNotification:) name:GLPNOTIFICATION_CONVERSATIONS_SYNC object:nil];
}

- (void)configureViewDidLoadNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeDidLoadNotifications) name:GLPNOTIFICATION_REMOVE_VC_NOTIFICATIONS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conversationSyncFromNotification:) name:GLPNOTIFICATION_ONE_CONVERSATION_SYNC object:nil];
}

- (void)removeDidLoadNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_ONE_CONVERSATION_SYNC object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_REMOVE_VC_NOTIFICATIONS object:nil];
}

- (void)configureTabbar
{
    NSArray *items = self.tabBarController.tabBar.items;
    
    self.messagesTabbarItem = [items objectAtIndex:1];
}

- (void)configureNavigationBar
{
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:NO];
    
    [self.navigationController.navigationBar setFontFormatWithColour:kBlack];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)addNavigationButtons
{
    float buttonsSize = 23.0;
    
    [self.navigationController.navigationBar setButton:kRight withImageName:@"pen" withButtonSize:CGSizeMake(buttonsSize, buttonsSize) withSelector:@selector(viewNewMessageView) andTarget:self];

}

- (void)showNetworkErrorViewIfNeeded
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_SHOW_ERROR_VIEW object:self userInfo:@{@"comingFromClass": [NSNumber numberWithBool:NO]}];
}

#pragma mark - Selectors

- (void)viewNewMessageView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    NewGroupMessageViewController *newGroupMessageVC = [storyboard instantiateViewControllerWithIdentifier:@"NewGroupMessageViewController"];
//    [newPostVC setDelegate:self];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newGroupMessageVC];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_filteredConversations.count == 0)
    {
        [[GLPEmptyViewManager sharedInstance] addEmptyViewWithKindOfView:kMessengerEmptyView withView:self.tableView];
    }
    else
    {
        [[GLPEmptyViewManager sharedInstance] hideViewWithKind:kMessengerEmptyView];
    }
    
    return _filteredConversations.count;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        FLog(@"Delete conversation with index path: %d", indexPath.row);
        
        GLPConversation *conversationToBeDeleted = _conversations[indexPath.row];
        [self deleteConversationFromTableViewWithIndexPath:indexPath];

        [[GLPLiveConversationsManager sharedInstance] deleteConversation:conversationToBeDeleted withCallbackBlock:^(BOOL success) {
            
            if(!success)
            {
                [WebClientHelper showFailedToDeleteConversationError];
                [self reloadConversations];
            }
        }];
    }
}

#pragma mark - Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *messageCellIdentifier = @"MessageCell";
    
    MessageTableViewCell *messageCell = nil;
    
    messageCell = [tableView dequeueReusableCellWithIdentifier:messageCellIdentifier forIndexPath:indexPath];
    
    GLPConversation *conversation = _filteredConversations[indexPath.row];
    
    [messageCell initialiseWithConversation: conversation];
    
    return messageCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedConversation = _filteredConversations[indexPath.row];
    
    [self performSegueWithIdentifier:@"view topic" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CONVERSATION_CELL_HEIGHT;
}

#pragma mark - Keyboard management

- (void)viewTouched:(id)sender
{
    [self hideKeyboardFromSearchBarIfNeeded];
}

-(void)hideKeyboardFromSearchBarIfNeeded
{
    //    if([self.searchBar isFirstResponder]) {
    //        [self.searchBar resignFirstResponder];
    //    }
    
    if([_glpSearchBar isTextFieldFirstResponder])
    {
        [_glpSearchBar resignTextFieldFirstResponder];
    }
}

#pragma mark - GLPSearchBarDelegate

- (void)glpSearchBarDidEndEditing:(UITextField *)textField
{
    //We are setting a delay here because otherwise setCancelsTouchesInView is called after the touch to
    //the collection view.
    
    [_tap performSelector:@selector(setCancelsTouchesInView:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.1];
}

- (void)glpSearchBarDidBeginEditing:(UITextField *)textField
{
    [_tap setCancelsTouchesInView:YES];
}

- (void)textChanged:(NSString *)searchText
{
    // remove all data that belongs to previous search
    
    [_filteredConversations removeAllObjects];
    
    if([searchText isEqualToString:@""] || searchText == nil)
    {
        _filteredConversations = _conversations.mutableCopy;
        
        [_tableView reloadData];
        
        return;
    }
    
    for(GLPConversation *conversation in _conversations)
    {
        if([self areParticipants:conversation.participants containedToSearchedText:searchText])
        {
            [_filteredConversations addObject:conversation];
        }
    }
    
    [_tableView reloadData];
}

#pragma mark - Conversations

- (NSArray *)sortedByDateOnArray:(NSArray *)array{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastUpdate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    return [array sortedArrayUsingDescriptors:sortDescriptors];
}

- (void)reloadConversations
{
    [self startLoading];
    
    FLog(@"MessengerViewController : reloadConversations Started");
    
    [[GLPLiveConversationsManager sharedInstance] conversationsList:^(NSArray *liveConversations, NSArray *regularConversations) {
        self.loadingCellStatus = kGLPLoadingCellStatusFinished;
//        _liveConversations = [NSMutableArray arrayWithArray:[self sortedByDateOnArray:liveConversations]];
        _conversations = [NSMutableArray arrayWithArray:[self sortedByDateOnArray:regularConversations]];
        //TODO: Maybe an issue here one there is a new message in a conversation.
        _filteredConversations = [NSMutableArray arrayWithArray:[self sortedByDateOnArray:regularConversations]];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self.tableView reloadData];
        [self stopLoading];
        FLog(@"MessengerViewController : reloadConversations Finished");
    }];
}


- (void)reloadLiveConversations
{
    [[GLPLiveConversationsManager sharedInstance] conversationsList:^(NSArray *liveConversations, NSArray *regularConversations) {
        self.loadingCellStatus = kGLPLoadingCellStatusFinished;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//        _liveConversations = [NSMutableArray arrayWithArray:[self sortedByDateOnArray:liveConversations]];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

- (void)reloadRegularConversations
{
    [[GLPLiveConversationsManager sharedInstance] conversationsList:^(NSArray *liveConversations, NSArray *regularConversations) {
        self.loadingCellStatus = kGLPLoadingCellStatusFinished;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _conversations = [NSMutableArray arrayWithArray:[self sortedByDateOnArray:regularConversations]];
        _filteredConversations = [NSMutableArray arrayWithArray:[self sortedByDateOnArray:regularConversations]];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

#pragma mark - Notifications

// One conversation sync
- (void)conversationSyncFromNotification:(NSNotification *)notification
{
    NSInteger conversationRemoteKey = [[notification userInfo][@"remoteKey"] integerValue];
    DDLogInfo(@"Conversation sync notification for conversation with remote key: %d", conversationRemoteKey);
    
    GLPConversation *conversation = [[GLPLiveConversationsManager sharedInstance] findByRemoteKey:conversationRemoteKey];
    
    NSMutableArray *array = _conversations;
    
    NSUInteger index = [array indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        
        if(((GLPConversation *)obj).remoteKey == conversation.remoteKey) {
            return YES;
        }
        
        return NO;
    }];
    
    if(index == NSNotFound) {
        DDLogError(@"Cannot find conversation in the local list, abort");
        return;
    }
    
    array[index] = conversation;
    
    self.loadingCellStatus = kGLPLoadingCellStatusLoading;
    
    //TODO: Implement here the group conversations when is supported by the server.
    
    [self reloadConversations];
    
//    if(conversation.isLive) {
//        self.loadingCellStatus = kGLPLoadingCellStatusLoading;
//        [self reloadLiveConversations];
//    } else {
//        self.loadingCellStatus = kGLPLoadingCellStatusLoading;
//        [self reloadRegularConversations];
//    }
    
    DDLogInfo(@"Conversation with remote key %d reloaded successfuly", conversation.remoteKey);
}

// Conversations list sync
- (void)conversationsSyncFromNotification:(NSNotification *)notification
{
    [self reloadConversations];
}

#pragma mark - Helpers

- (BOOL)areParticipants:(NSArray *)participants containedToSearchedText:(NSString *)searchedText
{
    for(GLPUser *user in participants)
    {
        NSRange r = [user.name rangeOfString:searchedText options:NSCaseInsensitiveSearch];
        
        if(r.location != NSNotFound)
        {
            //that is we are checking only the start of the names.
            
            if(r.location == 0)
            {
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark - Refresh

// Create the refresh control
// Should be called only when the loading cell is hidden because it does not make sense to have both
// And obviously do not create refresh control twice
//- (void)createRefreshIfNeed
//{
//    if(self.refreshControl) {
//        return;
//    }
//    
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    [self.refreshControl addTarget:self action:@selector(loadConversations) forControlEvents:UIControlEventValueChanged];
//}
//
- (void)startLoading
{
    //[_refreshControl beginRefreshing];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)stopLoading
{
    //[_refreshControl endRefreshing];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)removeCellWithIndexPath:(NSIndexPath *)indexPathRow
{
    [self.tableView deleteRowsAtIndexPaths:@[indexPathRow] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)deleteConversationFromTableViewWithIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_conversations removeObjectAtIndex:indexPath.row];
        
        [_filteredConversations removeObjectAtIndex:indexPath.row];
        
        //Remove conversation from table view.
        [self removeCellWithIndexPath:indexPath];
        
    });
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"view topic"]) {
        GLPConversationViewController *vc = segue.destinationViewController;
        vc.conversation = self.selectedConversation;
        vc.hidesBottomBarWhenPushed = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
