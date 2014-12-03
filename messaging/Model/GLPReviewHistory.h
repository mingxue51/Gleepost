//
//  GLPReviewHistory.h
//  Gleepost
//
//  Created by Silouanos on 24/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPEntity.h"

@class GLPUser;
@class GLPComment;

typedef NS_ENUM(NSUInteger, Action) {
    kRejected = 1,
    kApproved = 2,
    kEdited = 3,
    kPending = 4
};

@interface GLPReviewHistory : GLPEntity

@property (assign, nonatomic, readonly) Action action;
@property (strong, nonatomic, readonly) NSDate *dateHappened;
@property (strong, nonatomic, readonly) GLPUser *user;
@property (strong, nonatomic, readonly) NSString *reason;

- (id)initWithActionString:(NSString *)actionStr withDateHappened:(NSDate *)dateHappened reason:(NSString *)reason andUser:(GLPUser *)user;

- (id)initWithAction:(Action)action withDateHappened:(NSDate *)dateHappened reason:(NSString *)reason andUser:(GLPUser *)user;

- (id)initWithActionString:(NSString *)actionStr andDateHappened:(NSDate *)dateHappened;

- (GLPComment *)toComment;

@end
