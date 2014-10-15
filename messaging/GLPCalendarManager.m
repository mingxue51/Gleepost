//
//  GLPCalendarManager.m
//  Gleepost
//
//  Created by Silouanos on 14/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This class has the responsibility of the Calendar management.
//  Because of Apple's suggestion (https://developer.apple.com/Library/ios/documentation/DataManagement/Conceptual/EventKitProgGuide/ReadingAndWritingEvents.html#//apple_ref/doc/uid/TP40004775-SW1) this Manager is a singleton.


#import "GLPCalendarManager.h"
#import "GLPPost.h"
#import <EventKit/EKEventStore.h>

@interface GLPCalendarManager ()

@property (strong, nonatomic) EKEventStore *eventStore;

@end

@implementation GLPCalendarManager

static GLPCalendarManager *instance = nil;

+ (GLPCalendarManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[GLPCalendarManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        _eventStore = [[EKEventStore alloc] init];
    }
    
    return self;
}

- (void)addEventPostToCalendar:(GLPPost *)eventPost
{
    
    [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        // handle access here
        
        
    }];

}

@end
