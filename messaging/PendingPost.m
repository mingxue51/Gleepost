//
//  PendingPost.m
//  Gleepost
//
//  Created by Silouanos on 29/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "PendingPost.h"
#import "GLPPost.h"

@interface PendingPost ()



@end

@implementation PendingPost

-(id)initWithPost:(GLPPost *)post
{
    self = [super init];
    
    if(self)
    {
        
    }
    
    return self;
    
}

-(id)init
{
    self = [super init];
    
    if(self)
    {
        [self resetFields];
    }
    
    return self;
}

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

-(void)resetFields
{
    _datePickerHidden = YES;
    _eventTitle = @"";
    _numberOfCharacters = 0;
    _currentDate = [[NSDate alloc] init];
}

@end
