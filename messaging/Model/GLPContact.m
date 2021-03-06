//
//  GLPContact.m
//  Gleepost
//
//  Created by Σιλουανός on 25/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPContact.h"



@implementation GLPContact

NSString * const GLPContactTheyConfirmed = @"they_confirmed";
NSString * const GLPContactYouConfirmed = @"you_confirmed";
NSString * const GLPContactName = @"name";


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

-(NSString *)description
{
    return [NSString stringWithFormat:@"Name: %@, You confirmed: %d, They confirmed: %d", self.user.name, _youConfirmed, _theyConfirmed];
}

@end
