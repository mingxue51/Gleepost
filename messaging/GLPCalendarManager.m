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
#import <EventKit/EKEvent.h>
#import <EventKit/EKCalendar.h>
#import <EventKit/EKSource.h>

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

- (void)addEventPostToCalendar:(GLPPost *)eventPost withCallback:(void (^) (CalendarEventStatus resultStatus))callback
{
    [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        // handle access here
        
        DDLogDebug(@"Error request %@", error);
        
        if(granted)
        {
            NSError *error = nil;
            
            BOOL s = [_eventStore saveEvent:[self generateEventWithEventPost:eventPost] span:EKSpanThisEvent commit:YES error:&error];
            
            DDLogDebug(@"Possible error %@ : %d", error, s);
            
            if(!s || error)
            {
                DDLogDebug(@"Other error");
                
                callback(kOtherError);
            }
            
            DDLogDebug(@"Success");
            
            callback(kSuccess);
        }
        else
        {
            callback(kPermissionsError);
            DDLogError(@"Permission denied");
        }
        

        
    }];
    

}

- (EKEvent *)generateEventWithEventPost:(GLPPost *)eventPost
{
    EKEvent *event = [EKEvent eventWithEventStore:_eventStore];
    
    event.title = eventPost.eventTitle;
    
    event.startDate = eventPost.dateEventStarts;
    event.endDate = [eventPost generateDateEventEnds];
    
    event.notes = eventPost.content;
    
    if(eventPost.location)
    {
        event.location = [eventPost locationDescription];
    }
        
//    EKCalendar *calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:_eventStore];
//    
//    calendar.title = @"iCloud";
    
//    EKSource *theSource = [[_eventStore defaultCalendarForNewEvents] source];
    
//    EKCalendar *calendar = [self generateCalendar];
    
    EKCalendar *calendar = [_eventStore defaultCalendarForNewEvents];
    
    DDLogDebug(@"Calendar name %@ Selected source %@", calendar.title ,calendar.source);
    event.calendar = calendar;
    
    return event;
}

- (EKCalendar *)generateCalendar
{
    EKCalendar *calendar = nil;
    NSString *calendarIdentifier = [[NSUserDefaults standardUserDefaults] valueForKey:@"nerdnation"];
 
    // when identifier exists, my calendar probably already exists
    // note that user can delete my calendar. In that case I have to create it again.
    if (calendarIdentifier)
    {
        calendar = [_eventStore calendarWithIdentifier:calendarIdentifier];
    }
    
    // calendar doesn't exist, create it and save it's identifier
    if (!calendar)
    {
        // http://stackoverflow.com/questions/7945537/add-a-new-calendar-to-an-ekeventstore-with-eventkit
        
        calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:_eventStore];
        
        // set calendar name. This is what users will see in their Calendar app
        [calendar setTitle:@"NerdNation"];
        
        // find appropriate source type. I'm interested only in local calendars but
        // there are also calendars in iCloud, MS Exchange, ...
        // look for EKSourceType in manual for more options
        for (EKSource *s in _eventStore.sources) {
            if (s.sourceType == EKSourceTypeLocal) {
                calendar.source = s;
                break;
            }
        }
        
        // save this in NSUserDefaults data for retrieval later
        NSString *calendarIdentifier = [calendar calendarIdentifier];
        
        NSError *error = nil;
        BOOL saved = [_eventStore saveCalendar:calendar commit:YES error:&error];
        if (saved) {
            // http://stackoverflow.com/questions/1731530/whats-the-easiest-way-to-persist-data-in-an-iphone-app
            // saved successfuly, store it's identifier in NSUserDefaults
            [[NSUserDefaults standardUserDefaults] setObject:calendarIdentifier forKey:@"nerdnation"];
        } else {
            // unable to save calendar
            return nil;
        }
    }
    
    return calendar;
}

- (EKSource *)chooseSource
{
    for(EKSource *source in _eventStore.sources)
    {
        if(source.sourceType == EKSourceTypeCalDAV)
        {
            return source;
        }
    }
    
    for(EKSource *source in _eventStore.sources)
    {
        if(source.sourceType == EKSourceTypeLocal)
        {
            return source;
        }
    }
    
    return nil;
}

@end
