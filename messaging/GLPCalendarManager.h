//
//  GLPCalendarManager.h
//  Gleepost
//
//  Created by Silouanos on 14/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPPost;

@interface GLPCalendarManager : NSObject

+ (GLPCalendarManager *)sharedInstance;

- (void)addEventPostToCalendar:(GLPPost *)eventPost;

@end
