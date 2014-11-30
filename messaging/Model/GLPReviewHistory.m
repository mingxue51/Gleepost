//
//  GLPReviewHistory.m
//  Gleepost
//
//  Created by Silouanos on 24/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPReviewHistory.h"
#import "GLPComment.h"

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

/**
 Converts the GLPReviewHistory object to GLPComment to be able 
 to be used in current comment UI implementation. See more
 in GLPViewPendingPostViewController.
 */
- (GLPComment *)toComment
{
    GLPComment *comment = [[GLPComment alloc] init];
    
    comment.content = self.reason;
    comment.date = self.dateHappened;
    comment.author = self.user;
    comment.sendStatus = kSendStatusSent;
    
    DDLogDebug(@"Review history content %@, Comment content %@", self.reason, comment.content);
    
    return comment;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"GLPReviewHistory: Action %d, Reason %@", _action, _reason];
}

@end
