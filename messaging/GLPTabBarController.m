//
//  GLPTabBarController.m
//  Gleepost
//
//  Created by Lukas on 10/23/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPTabBarController.h"

@interface GLPTabBarController ()

@property (assign, nonatomic) NSInteger notificationsCount;

@end

@implementation GLPTabBarController

- (void)viewDidLoad
{
    self.notificationsCount = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementChatWithNotification:) name:@"GLPNewMessage" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPNewMessage" object:nil];
}

- (void)incrementChatWithNotification:(NSNotification *)notification
{
    if(self.selectedIndex == 1) {
        return;
    }
    
    self.notificationsCount++;
    [self updateChatBadge];
}

- (void)resetChatNotifications
{
    self.notificationsCount = 0;
    [self updateChatBadge];
}

- (void)decrementChatNotificationsBy:(NSInteger)count
{
    self.notificationsCount -= count;
    [self updateChatBadge];
}

- (void)updateChatBadge
{
    NSString *badge = self.notificationsCount > 0 ? [NSString stringWithFormat:@"%d", self.notificationsCount] : nil;
    [self.tabBar.items[1] setBadgeValue:badge];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if(item.tag == 1) {
        [self resetChatNotifications];
    }
}

@end
