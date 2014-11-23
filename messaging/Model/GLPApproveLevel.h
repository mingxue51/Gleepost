//
//  GLPApproveLevel.h
//  Gleepost
//
//  Created by Silouanos on 21/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ApproveLevel) {
    kNone = 0,
    kOnlyParties,
    kAllEvents,
    kAll
};

@interface GLPApproveLevel : NSObject

@property (assign, nonatomic) ApproveLevel approveLevel;

- (id)initWithApproveLevel:(NSUInteger)approveLevel;

@end
