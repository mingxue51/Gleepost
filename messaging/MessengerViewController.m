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



@interface MessengerViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet GLPSegmentView *segmentView;

@property (strong, nonatomic) NSMutableArray *privateConversations;

@property (strong, nonatomic) NSMutableArray *groupConversations;

@property (assign, nonatomic) ConversationType conversationType;

@property (strong, nonatomic) GLPConversation *selectedConversation;

// reload conversations when user comes back from chat view, in order to update last message and last update
@property (assign, nonatomic) BOOL needsReloadConversations;
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
    
    [self registerTableViewCells];
    
    [self registerViews];
    
    [self reloadConversations];
    
    [self configureTabbar];
    
    [self configureNavigationBar];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureNotifications];
    
    //Change the colour of the tab bar.
    self.tabBarController.tabBar.tintColor = [UIColor colorWithR:75.0 withG:208.0 andB:210.0];
    [AppearanceHelper setSelectedColourForTabbarItem:self.messagesTabbarItem withColour:[UIColor colorWithR:75.0 withG:208.0 andB:210.0]];
    
    
    if(self.needsReloadConversations) {
        [self reloadConversations];
    }
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
    self.needsReloadConversations = YES;
    
    [super viewDidDisappear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CONVERSATIONS_SYNC object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_ONE_CONVERSATION_SYNC object:nil];
    
    [AppearanceHelper setUnselectedColourForTabbarItem:self.messagesTabbarItem];
    
    [super viewWillDisappear:animated];
}

#pragma mark - Configuration

- (void)registerTableViewCells
{
    [self.tableView registerNib:[UINib nibWithNibName:@"MessageCell" bundle:nil] forCellReuseIdentifier:@"MessageCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:kGLPLoadingCellNibName bundle:nil] forCellReuseIdentifier:kGLPLoadingCellIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone; // start with no separator for loading cell
}

- (void)registerViews
{
     NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"GLPSegmentView" owner:self options:nil];
    
    GLPSegmentView *view = [array lastObject];
    [view setDelegate:self];
    
    CGRectSetX(view, 10);
    
    [_segmentView addSubview:view];

}

- (void)initialiseObjects
{
    _privateConversations = [[NSMutableArray alloc] init];
    _groupConversations = [[NSMutableArray alloc] init];
    _conversationType = kPrivate;
    
    // various control init
    self.loadingCellStatus = kGLPLoadingCellStatusLoading;
    self.needsReloadConversations = NO;
    
//    _refreshControl = [[UIRefreshControl alloc] init];
//    [_refreshControl addTarget:self action:@selector(reloadConversations) forControlEvents:UIControlEventValueChanged];
//    
//    [self.tableView addSubview:_refreshControl];
}

- (void)configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conversationSyncFromNotification:) name:GLPNOTIFICATION_ONE_CONVERSATION_SYNC object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conversationsSyncFromNotification:) name:GLPNOTIFICATION_CONVERSATIONS_SYNC object:nil];
}

- (void)configureTabbar
{
    NSArray *items = self.tabBarController.tabBar.items;
    
    self.messagesTabbarItem = [items objectAtIndex:1];
}

- (void)configureNavigationBar
{
    [AppearanceHelper setNavigationBarColour:self];
    [AppearanceHelper setNavigationBarFontFor:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (_conversationType)
    {
        case kPrivate:
            return _privateConversations.count;
            break;
            
        case kGroup:
            return _groupConversations.count;
            break;
            
        default:
            break;
    }
}


#pragma mark - Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *messageCellIdentifier = @"MessageCell";
    
    MessageTableViewCell *messageCell = nil;
    
    messageCell = [tableView dequeueReusableCellWithIdentifier:messageCellIdentifier forIndexPath:indexPath];
    
    GLPConversation *conversation = (_conversationType == kPrivate) ? _privateConversations[indexPath.row] : _groupConversations[indexPath.row];
    
    [messageCell initialiseWithConversation: conversation];
    
    return messageCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedConversation = (_conversationType == kPrivate) ? _privateConversations[indexPath.row] : _groupConversations[indexPath.row];
    
    [self performSegueWithIdentifier:@"view topic" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CONVERSATION_CELL_HEIGHT;
}

#pragma mark - GLPSegmentViewDelegate

- (void)segmentSwitched:(ConversationType)conversationsType
{
    _conversationType = conversationsType;
    
    [self.tableView reloadData];
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
    
    [[GLPLiveConversationsManager sharedInstance] conversationsList:^(NSArray *liveConversations, NSArray *regularConversations) {
        self.loadingCellStatus = kGLPLoadingCellStatusFinished;
//        _liveConversations = [NSMutableArray arrayWithArray:[self sortedByDateOnArray:liveConversations]];
        _privateConversations = [NSMutableArray arrayWithArray:[self sortedByDateOnArray:regularConversations]];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self.tableView reloadData];
        [self stopLoading];
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
        _privateConversations = [NSMutableArray arrayWithArray:[self sortedByDateOnArray:regularConversations]];
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
    
    NSMutableArray *array = (_conversationType == kPrivate) ? _privateConversations : _groupConversations;
    
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
