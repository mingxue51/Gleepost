//
//  GLPContact.m
//  Gleepost
//
//  Created by Σιλουανός on 25/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPContact.h"

@implementation GLPContact
-(id)initWithUserName:(NSString*)name profileImage:(NSString*)img youConfirmed:(BOOL)you andTheyConfirmed:(BOOL)they
{
    self = [super init];
    
    if(self)
    {
        self.user = [[GLPUser alloc] init];
        
        self.user.name = name;
        self.user.profileImageUrl = img;
        self.youConfirmed = you;
        self.theyConfirmed = they;
        
        return self;
    }

    return nil;
}

@end
