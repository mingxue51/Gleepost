//
//  GLPTemporaryUserInformationManager.m
//  Gleepost
//
//  Created by Silouanos on 26/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This class is used in order to preserve user's credentials in case of verified and login from the
//  regular log in screen and not from the registration screen. Also is used to add communication between
//  LoginSignup view and verification view during facebook login.
//

#import "GLPTemporaryUserInformationManager.h"


@interface GLPTemporaryUserInformationManager ()

@property (assign, nonatomic) BOOL informationExist;

@end

static GLPTemporaryUserInformationManager *instance = nil;


@implementation GLPTemporaryUserInformationManager

+ (GLPTemporaryUserInformationManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[GLPTemporaryUserInformationManager alloc] init];
    });
    
    return instance;
}

-(id)init
{
    self = [super init];
    
    if(self)
    {
        _informationExist = NO;
    }
    
    return self;
}

- (void)setEmail:(NSString *)email password:(NSString *)password andImage:(UIImage *)image;
{
    _email = email;
    _image = image;
    _password = password;
    _informationExist = YES;
}

-(NSString *)email
{
    return _email;
}

- (NSString *)password
{
    return _password;
}

-(UIImage *)image
{
    return _image;
}

- (NSString *)university
{
    NSArray *emailEduArray = [self.email componentsSeparatedByString:@"@"];
    NSString *emailEdu = emailEduArray[1];
    
    return [[emailEdu componentsSeparatedByString:@"."] objectAtIndex:0];
}

-(BOOL)informationExistWithEmail:(NSString *)otherEmail
{
    if(!_informationExist)
    {
        return NO;
    }
    else
    {
        if([otherEmail isEqualToString:_email])
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
}

@end
