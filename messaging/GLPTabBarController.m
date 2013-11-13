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
@property (assign, nonatomic) NSInteger profileNotificationsCount;

@end

@implementation GLPTabBarController

- (void)viewDidLoad
{
    self.notificationsCount = 0;
    self.profileNotificationsCount = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatBadge:) name:@"GLPNewMessage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfileBadge:) name:@"GLPNewNotifications" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPNewMessage" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPNewNotifications" object:nil];
}


- (void)updateProfileBadge:(NSNotification *)notification
{
    self.profileNotificationsCount += [notification.userInfo[@"count"] intValue];
    [self updateBadgeForIndex:4 count:self.profileNotificationsCount];
}

- (void)updateChatBadge:(NSNotification *)notification
{
    self.notificationsCount += [notification.userInfo[@"count"] intValue];
    [self updateBadgeForIndex:1 count:self.notificationsCount];
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
    NSString *badge = self.profileNotificationsCount > 0 ? [NSString stringWithFormat:@"%d", count] : nil;
    [self.tabBar.items[index] setBadgeValue:badge];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if(item.tag == 1) {
        self.notificationsCount = 0;
        [self updateBadgeContentForIndex:item.tag count:0];
    } else if(item.tag == 4) {
        self.profileNotificationsCount = 0;
        [self updateBadgeContentForIndex:item.tag count:0];
    }
}

@end
