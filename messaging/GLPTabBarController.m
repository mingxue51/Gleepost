//
//  GLPTabBarController.m
//  Gleepost
//
//  Created by Lukas on 10/23/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPTabBarController.h"
#import "ChatViewAnimationController.h"
#import "GLPiOSSupportHelper.h"
#import "SessionManager.h"
#import "WebClient.h"
#import "ImageFormatterHelper.h"
#import "UIColor+GLPAdditions.h"
#import "GLPNetworkManager.h"
#import "GLPNetworkErrorView.h"
#import "GLPLiveGroupManager.h"

@interface GLPTabBarController ()

@property (assign, nonatomic) NSInteger messagesCount;
@property (assign, nonatomic) NSInteger profileNotificationsCount;
@property (assign, nonatomic) NSInteger groupPostsNotificationsCount;
@property (strong, nonatomic) GLPNetworkErrorView *networkErrorView;

/** This variable prevents the error view to be shown when user presses
    the dismiss button.
 **/
@property (assign, nonatomic) BOOL shouldHideErrorView;

@property (assign, nonatomic, getter = didShowGroupBadge) BOOL showGroupBadge;

@end

@implementation GLPTabBarController

const float TABBAR_OFFSET_HEIGHT = 5.0f;

@synthesize messagesCount=_messagesCount;
@synthesize profileNotificationsCount=_profileNotificationsCount;

static BOOL isViewDidDisappearCalled = YES;
static NSInteger lastTabbarIndex = 0;

- (void)viewDidLoad
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.tabBarController = self;
    
    _messagesCount = 0;
    _profileNotificationsCount = 0;
    _groupPostsNotificationsCount = 0;
    
    _showGroupBadge = NO;
    
    [self setDelegate:self];
    
    [self.tabBar setBackgroundImage:[UIImage imageNamed:@"messageboxwhite"]];

    
    [self.tabBar setShadowImage:[ImageFormatterHelper generateOnePixelHeightImageWithColour:[UIColor colorWithR:230.0 withG:230.0 andB:230.0]]];
    
    _networkErrorView = [[GLPNetworkErrorView alloc] init];
    _shouldHideErrorView = NO;
    _networkErrorView.tag = 100;
    
    
//    self.tabBar.layer.borderWidth = 1.0;
//    self.tabBar.layer.borderColor = [UIColor redColor].CGColor;
    

}

//TODO: BUG: View will appear called multible times.
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if(isViewDidDisappearCalled) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatBadge:) name:GLPNOTIFICATION_ONE_CONVERSATION_SYNC object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfileBadge:) name:GLPNOTIFICATION_NEW_NOTIFICATION object:nil];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroupCountBadge:) name:GLPNOTIFICATION_GROUP_POST_COUNT object:nil];
        
        //Added new notification center. This is temporary called just from AppDelegate.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatCountBadge:) name:GLPNOTIFICATION_CONVERSATION_COUNT object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetworkStatus:) name:GLPNOTIFICATION_NETWORK_UPDATE object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissErrorView) name:GLPNOTIFICATION_DISMISS_ERROR_VIEW object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(temporaryHideErrorView) name:GLPNOTIFICATION_HIDE_ERROR_VIEW object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(temporaryShowErrorView:) name:GLPNOTIFICATION_SHOW_ERROR_VIEW object:nil];
        
        [self updateGroupBadge];
        
        
        isViewDidDisappearCalled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    isViewDidDisappearCalled = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_ONE_CONVERSATION_SYNC object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_NEW_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CONVERSATION_COUNT object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_DISMISS_ERROR_VIEW object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_NETWORK_UPDATE object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_HIDE_ERROR_VIEW object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_SHOW_CAPTURE_VIEW object:nil];
}


/**
 This method checks if it's the first time that user logged in.
 If it is, sends request to server and checks if user has groups
 which means that he comes from facebook group invitation.
 If it has then adds a badge with the number of groups belogn to.
 
 TODO: Change that later. Bad object oriented approach.
 */
-(void)updateGroupBadge
{
    if([[SessionManager sharedInstance] isFirstTimeLoggedIn] && ![self didShowGroupBadge])
    {
        [[WebClient sharedInstance] getGroupswithCallbackBlock:^(BOOL success, NSArray *groups) {
           
            if(success)
            {
                [self updateGroupsContactsBadge:groups.count];
            }
            
        }];
    }
    
    _showGroupBadge = YES;

}

-(void)updateGroupsContactsBadge:(NSInteger)numberOfGroups
{
    if(self.selectedIndex == 2) {
        return;
    }
    
    [self updateBadgeContentForIndex:2 count:numberOfGroups];
}

#pragma mark - Notifications

//- (void)updateGroupCountBadge:(NSNotification *)notification
//{
//    DDLogDebug(@"updateGroupCountBadge with notification: %@", notification);
//}

- (void)updateNetworkStatus:(NSNotification *)notification
{
    BOOL isNetwork = [notification.userInfo[@"status"] boolValue];
    DDLogInfo(@"GLPTabBarController network status: %d", isNetwork);
    
    if(isNetwork)
    {
        if(_shouldHideErrorView)
        {
            _shouldHideErrorView = NO;
            return;
        }
        
        [self hideNoNetworkView];
    }
    else
    {
        [self showNoNetworkView];
    }
}

- (void)dismissErrorView
{
    _shouldHideErrorView = YES;
    [self hideNoNetworkView];
}

- (void)temporaryHideErrorView
{
    [self hideNoNetworkView];
}

- (void)temporaryShowErrorView:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    
    NSNumber *number = dic[@"comingFromClass"];
    
    
    if([number boolValue])
    {
        //Show error view with campus wall mode.
        [self showErrorViewInViewIfNeeded];
    }
    else
    {
        //Show error view with messenger mode.
        [self showErrorViewInMessengerViewIfNeeded];
    }
}

- (void)updateProfileBadge:(NSNotification *)notification
{
    if(self.selectedIndex == 3) {
        return;
    }
    
    NSDictionary *d = notification.userInfo;
    
    GLPNotification *internalNotification = d[@"new_notification"];
    
    DDLogDebug(@"NOTIFICATION FROM INTERNAL: %@", internalNotification.customParams);
    
    if(internalNotification.notificationType == kGLPNotificationTypeCreatedPostGroup)
    {
        _groupPostsNotificationsCount++;
        [self updateBadgeForIndex:2 count:_groupPostsNotificationsCount];
        
        NSInteger groupRemoteKey = [internalNotification.customParams[@"network"] integerValue];
        
        //Inform GroupLiveManager for notification.
        [[GLPLiveGroupManager sharedInstance] addUnreadPostWithGroupRemoteKey: groupRemoteKey];
    }
    else
    {
        _profileNotificationsCount++;
        [self updateBadgeForIndex:3 count:_profileNotificationsCount];
    }
}

- (void)updateChatBadge:(NSNotification *)notification
{
    //If the new messages is group then check if the selectedIndex
    //is 2. Otherwise do the current implementation.
    
    BOOL belongToGroupConversation = [notification.userInfo[@"belongsToGroup"] boolValue];
    
    if(belongToGroupConversation)
    {
        [self updateChatBadgeWithIndex:2 andNotification:notification];
    }
    else
    {
        [self updateChatBadgeWithIndex:1 andNotification:notification];
    }
    
//    if(self.selectedIndex == 1) {
//        return;
//    }
//    
//    DDLogInfo(@"Tab bar update message badge notification");
//    
//    BOOL localMessage = [notification.userInfo[@"newLocalMessage"] boolValue];
//    if(localMessage) {
//        DDLogInfo(@"Ignore locally posted messages");
//        return;
//    }
//    
//    BOOL newMessages = [notification.userInfo[@"newMessages"] boolValue];
//    if(newMessages) {
//        _messagesCount++;
//        [self updateBadgeForIndex:1 count:_messagesCount];
//        
//        DDLogInfo(@"Tab bar messages badge increment notification count");
//    }
}

- (void)updateChatBadgeWithIndex:(NSInteger)badgeIndex andNotification:(NSNotification *)notification
{
    if(self.selectedIndex == badgeIndex) {
        return;
    }
    
    DDLogInfo(@"Tab bar update message badge notification");
    
    BOOL localMessage = [notification.userInfo[@"newLocalMessage"] boolValue];
    if(localMessage) {
        DDLogInfo(@"Ignore locally posted messages");
        return;
    }
    
    BOOL newMessages = [notification.userInfo[@"newMessages"] boolValue];
    if(newMessages) {
        _messagesCount++;
        [self updateBadgeForIndex:badgeIndex count:_messagesCount];
        
        DDLogInfo(@"Tab bar messages badge increment notification count");
    }
}

-(void)updateChatCountBadge:(NSNotification *)notification
{
    int conversationCount = [notification.userInfo[@"conversationsCount"] integerValue];
    
    [self updateBadgeForIndex:1 count:conversationCount];

}


- (void)updateBadgeForIndex:(int)index count:(int)count
{
    if(self.selectedIndex == index) {
        return;
    }
    
    [self updateBadgeContentForIndex:index count:count];
}

- (void)updateBadgeContentForIndex:(int)index count:(int)count
{
    NSString *badge = count > 0 ? [NSString stringWithFormat:@"%d", count] : nil;
    [self.tabBar.items[index] setBadgeValue:badge];
}

- (void)messagesBadgeUnknownNumber
{
    _messagesCount = 0;
    [self.tabBar.items[1] setBadgeValue:@""];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    switch (item.tag) {
        case 0:
            [self showErrorViewInViewIfNeeded];
            break;
        case 1:
            [self showErrorViewInMessengerViewIfNeeded];
            _messagesCount = 0;
            break;
        case 2:
            _groupPostsNotificationsCount = 0;
            break;
        case 3:
            [self removeErrorViewFromViewIfNeeded];
            _profileNotificationsCount = 0;
            break;
    }

    [self updateBadgeContentForIndex:item.tag count:0];
}

#pragma mark - Helpers

- (void)showErrorViewInViewIfNeeded
{
    [_networkErrorView moveViewBelowNavigationBar];

    if(_shouldHideErrorView)
    {
        return;
    }
    else
    {
        if([_networkErrorView isHidden] && [[GLPNetworkManager sharedInstance] networkStatus] == kGLPNetworkStatusOffline)
        {
            [self showNoNetworkView];
        }
    }
}

- (void)showErrorViewInMessengerViewIfNeeded
{
    [self showErrorViewInViewIfNeeded];
    
    [_networkErrorView moveViewBelowSearchBar];
}

- (void)removeErrorViewFromViewIfNeeded
{
    if([_networkErrorView isHidden])
    {
        return;
    }
    
    
    [self hideNoNetworkView];
}

#pragma mark - UI

- (void)showNoNetworkView
{
    
    DDLogInfo(@"Show no network view.");
    
    [_networkErrorView setHidden:NO];
    
    NSArray *subViews = [[[UIApplication sharedApplication] keyWindow] subviews];

    for(UIView *v in subViews)
    {
        if(v.tag == 100)
        {
            return;
        }
    }

    
    [[[UIApplication sharedApplication] keyWindow] addSubview:_networkErrorView];
}

- (void)hideNoNetworkView
{
    
    DDLogInfo(@"Hide network view");
    
    [_networkErrorView setHidden:YES];
    
}

- (UIViewController *)currentViewController
{
    UINavigationController *currentNavigationVC = (UINavigationController *) self.selectedViewController;
    
    NSArray *viewControllers = currentNavigationVC.viewControllers;
    
    UIViewController *currentViewController = viewControllers[viewControllers.count - 1];
    
    DDLogDebug(@"Current view controller: %@", [currentViewController class]);
    
    return currentViewController;
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController*)tabBarController shouldSelectViewController:(UIViewController*)viewController
{
    //If user pushed twice the home tab bar button the send notification to
    //GLPTimelineViewController.
    
    if(lastTabbarIndex == 0 && viewController.tabBarItem.tag == 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_HOME_TAPPED_TWICE object:nil];
    }
    
    lastTabbarIndex = viewController.tabBarItem.tag;
    
    return YES;
}


#pragma mark - Custom UIBarButtonItem
#pragma mark DELETE THIS

-(void) createAndAddCustomUIBarButtonItemWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(7.5, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    
    [button addTarget:self action:@selector(findNewChat:) forControlEvents:UIControlEventTouchUpInside];
    
    //    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, buttonImage.size.width+15.0f, buttonImage.size.height+12.0f)];
    v.center = self.tabBar.center;
    
    [v setBackgroundColor:[UIColor clearColor]];
    [v setUserInteractionEnabled:YES];
    
    UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, buttonImage.size.height+3.0f, buttonImage.size.width+15.0f, 10.0f)];
    
    lblName.textAlignment = NSTextAlignmentCenter;
    
    
    [lblName setText:@"NewChat"];
    [lblName setFont:[UIFont fontWithName:@"Helvetica" size:9.5f]];
    [lblName setTextColor:[UIColor colorWithRed:115.0f/255.0f green:133.0f/255.0f blue:148.0f/255.0f alpha:1.0f]];
    
    [v addSubview:button];
    [v addSubview:lblName];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(findNewChat:)];
    [tap setNumberOfTapsRequired:1];
    [v addGestureRecognizer:tap];
    
    
    [self.view addSubview:v];
    
}


-(void)findNewChat:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    ChatViewAnimationController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"ChatViewAnimation"];
    
    
    
    [self presentViewController:cvc animated:YES completion:nil];
}


@end
