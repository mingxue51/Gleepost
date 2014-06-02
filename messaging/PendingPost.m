//
//  PendingPost.m
//  Gleepost
//
//  Created by Silouanos on 29/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "PendingPost.h"
#import "GLPPost.h"


@implementation PendingPost

-(id)init
{
    self = [super init];
    
    if(self)
    {
        [self resetFields];
    }
    
    return self;
}

/**
 Implement copyWithZone method in order to copy each object that is encapsulated 
 to PendingPost object and not just the reference of the PendingPost object.
 */
- (id)copyWithZone:(NSZone *)zone
{
    PendingPost *copy = [[[self class] alloc] init];
    
    if (copy) {
        // Copy NSObject subclasses
        
        copy.eventTitle = [self.eventTitle copyWithZone:zone];
        copy.numberOfCharacters = self.numberOfCharacters;
        
        // Set primitives
        copy.datePickerHidden = self.datePickerHidden;
    }
    
    return copy;
}

-(GLPPendingPostReady)isPostReady
{
    if([_eventTitle isEqualToString:@""])
    {
        return kTitleMissing;
    }
    
    if(!_currentDate)
    {
        return kDateMissing;
    }
    
    return kPostReady;
}

-(void)resetFields
{
    _datePickerHidden = YES;
    _eventTitle = @"";
    _numberOfCharacters = 0;
    _currentDate = nil;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"Title: %@, Date: %@", _eventTitle, _currentDate];
}

@end
