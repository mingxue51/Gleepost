//
//  GLPReviewHistory.m
//  Gleepost
//
//  Created by Silouanos on 24/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPReviewHistory.h"

@implementation GLPReviewHistory

- (id)initWithActionString:(NSString *)actionStr withDateHappened:(NSDate *)dateHappened andReason:(NSString *)reason
{
    self = [super init];
    
    if (self)
    {
        [self configureAction:actionStr];
        _dateHappened = dateHappened;
        _reason = reason;
    }
    
    return self;
}

- (id)initWithAction:(Action)action withDateHappened:(NSDate *)dateHappened andReason:(NSString *)reason
{
    self = [super init];
    
    if (self)
    {
        _action = action;
        _dateHappened = dateHappened;
        _reason = reason;
    }
    
    return self;
}

- (id)initWithActionString:(NSString *)actionStr andDateHappened:(NSDate *)dateHappened
{
    self = [super init];
    
    if (self)
    {
        [self configureAction:actionStr];
        _dateHappened = dateHappened;
    }
    
    return self;
}

- (void)configureAction:(NSString *)actionStr
{
    if ([actionStr isEqualToString:@"rejected"])
    {
        _action = kRejected;
    }
    else if ([actionStr isEqualToString: @"approved"])
    {
        _action = kApproved;
    }
    else if ([actionStr isEqualToString:@"edited"])
    {
        _action = kEdited;
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"GLPReviewHistory: Action %d, Reason %@", _action, _reason];
}

@end
