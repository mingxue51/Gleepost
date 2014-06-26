//
//  GLPTabBarController.m
//  Gleepost
//
//  Created by Lukas on 10/23/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPTabBarController.h"
#import "ChatViewAnimationController.h"
#import "GLPiOS6Helper.h"
#import "SessionManager.h"
#import "WebClient.h"
#import "ImageFormatterHelper.h"
#import "UIColor+GLPAdditions.h"

@interface GLPTabBarController ()

@property (assign, nonatomic) NSInteger messagesCount;
@property (assign, nonatomic) NSInteger profileNotificationsCount;

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
    
    _showGroupBadge = NO;
    
    [self setDelegate:self];
    
    [self.tabBar setBackgroundImage:[UIImage imageNamed:@"messageboxwhite"]];

    
    [self.tabBar setShadowImage:[ImageFormatterHelper generateOnePixelHeightImageWithColour:[UIColor colorWithR:230.0 withG:230.0 andB:230.0]]];
    
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
        
        //Added new notification center. This is temporary called just from AppDelegate.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatCountBadge:) name:GLPNOTIFICATION_CONVERSATION_COUNT object:nil];
        
        
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

- (void)updateProfileBadge:(NSNotification *)notification
{
    if(self.selectedIndex == 3) {
        return;
    }
    
    _profileNotificationsCount++;
    [self updateBadgeForIndex:3 count:_profileNotificationsCount];
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
            _profileNotificationsCount = 0;
            break;
    }

    [self updateBadgeContentForIndex:item.tag count:0];
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
