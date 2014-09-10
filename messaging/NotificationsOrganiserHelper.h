//
//  NotificationsOrganiserHelper.h
//  Gleepost
//
//  Created by Σιλουανός on 10/9/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPNotification;

@interface NotificationsOrganiserHelper : NSObject

- (void)organiseNotifications:(NSArray *)notifications;
- (NSInteger)numberOfSections;
- (NSString *)headerInSection:(NSInteger)sectionIndex;
- (NSArray *)notificationsAtSectionIndex:(NSInteger)sectionIndex;
- (GLPNotification *)notificationWithIndex:(NSInteger)notificationIndex andSectionIndex:(NSInteger)sectionIndex;
- (void)resetData;
- (NSInteger)lastSection;

@end
