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
@property (assign, nonatomic) NSInteger liveNotificationsCount;
@property (assign, nonatomic) NSInteger profileNotificationsCount;

@end

@implementation GLPTabBarController

@synthesize notificationsCount=_notificationsCount;
@synthesize liveNotificationsCount=_liveNotificationsCount;
@synthesize profileNotificationsCount=_profileNotificationsCount;

- (void)viewDidLoad
{
    _notificationsCount = 0;
    _liveNotificationsCount = 0;
    _profileNotificationsCount = 0;
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
    BOOL isLive = [notification.userInfo[@"isLive"] boolValue];
    int index;
    int count;
    
    if(isLive) {
        _liveNotificationsCount++;
        index = 2;
        count = _liveNotificationsCount;
    } else {
        _notificationsCount++;
        index = 1;
        count = _notificationsCount;
    }
    
    [self updateBadgeForIndex:index count:count];
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

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    switch (item.tag) {
        case 1:
            _notificationsCount = 0;
            break;
        case 2:
            _liveNotificationsCount = 0;
            break;
        case 4:
            _profileNotificationsCount = 0;
            break;
    }

    [self updateBadgeContentForIndex:item.tag count:0];
}

@end
