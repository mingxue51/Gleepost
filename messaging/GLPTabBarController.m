//
//  GLPTabBarController.m
//  Gleepost
//
//  Created by Lukas on 10/23/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPTabBarController.h"
#import "ChatViewAnimationController.h"

@interface GLPTabBarController ()

@property (assign, nonatomic) NSInteger messagesCount;
@property (assign, nonatomic) NSInteger profileNotificationsCount;

@end

@implementation GLPTabBarController

const float TABBAR_OFFSET_HEIGHT = 5.0f;

@synthesize messagesCount=_messagesCount;
@synthesize profileNotificationsCount=_profileNotificationsCount;

static BOOL isViewDidDisappearCalled = YES;

- (void)viewDidLoad
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.tabBarController = self;
    
    _messagesCount = 0;
    _profileNotificationsCount = 0;
    
    [self setDelegate:self];
    
    
    CGRect frame = self.tabBar.frame;

    
    [self.tabBar setFrame:CGRectMake(frame.origin.x, frame.origin.y+TABBAR_OFFSET_HEIGHT, frame.size.width, frame.size.height-TABBAR_OFFSET_HEIGHT)];
}


//TODO: BUG: View will appear called multible times.
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if(isViewDidDisappearCalled) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatBadge:) name:GLPNOTIFICATION_ONE_CONVERSATION_SYNC object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfileBadge:) name:GLPNOTIFICATION_NEW_NOTIFICATION object:nil];
        
        //Added new notification center. This is temporary called just from AppDelegate.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatCountBadge:) name:GLPNOTIFICATION_CONVERSATION_COUNT object:nil];

        
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

}


- (void)updateProfileBadge:(NSNotification *)notification
{
    if(self.selectedIndex == 4) {
        return;
    }
    
    _profileNotificationsCount++;
    [self updateBadgeForIndex:4 count:_profileNotificationsCount];
}

- (void)updateChatBadge:(NSNotification *)notification
{
    if(self.selectedIndex == 1) {
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
        [self updateBadgeForIndex:1 count:_messagesCount];
        
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
        case 1:
            _messagesCount = 0;
            break;
        case 2:
        case 3:
            break;
        case 4:
            _profileNotificationsCount = 0;
            break;
    }

    [self updateBadgeContentForIndex:item.tag count:0];
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController*)tabBarController shouldSelectViewController:(UIViewController*)viewController
{
    if(viewController.tabBarItem.tag == 2)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
        ChatViewAnimationController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"ChatViewAnimation"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:cvc];
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navigationController animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}


#pragma mark - Custom UIBarButtonItem
#pragma mark - DELETE THIS

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
