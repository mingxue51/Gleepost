//
//  PendingPost.h
//  Gleepost
//
//  Created by Silouanos on 29/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPPost;

/**
 Temporary post class. This class is going to preserve the pending data of the
 cell like the event title, characters remaining etc.
 
 This class is used by SetEventInformationCell and GLPSelectCategoryViewController classes.
 
 This class is not used anymore.
 
 */

typedef NS_ENUM(NSInteger, GLPPendingPostReady) {
    kPostReady,
    kDateMissing,
    kTitleMissing
};

@interface PendingPost : NSObject

@property (strong, nonatomic) NSString *eventTitle;
@property (assign, nonatomic) NSInteger numberOfCharacters;
@property (strong, nonatomic) NSDate *currentDate;
@property (assign, nonatomic, getter = isDatePickerHidden) BOOL datePickerHidden;

-(void)resetFields;
-(GLPPendingPostReady)isPostReady;

@end
