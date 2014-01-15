//
//  GLPProfileLoader.m
//  Gleepost
//
//  Created by Silouanos on 15/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPProfileLoader.h"
#import "GLPContact.h"
#import "WebClient.h"
#import "SessionManager.h"

@interface GLPProfileLoader ()

@property (strong, nonatomic) NSMutableDictionary *contactsImages;

//userDetails contains one GLPContact and UIImage of the logged in user.
@property (strong, nonatomic) GLPUser *userDetails;
@property (strong, nonatomic) UIImage *userImage;

@end

@implementation GLPProfileLoader

static GLPProfileLoader *instance = nil;

@synthesize contactsImages = _contactsImages;
@synthesize userDetails = _userDetails;
@synthesize userImage = _userImage;

+ (GLPProfileLoader *)sharedInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[GLPProfileLoader alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        _contactsImages = [[NSMutableDictionary alloc] init];
        _userDetails = [[GLPUser alloc] init];
        
    }
    
    return self;
}

#pragma mark - Client

-(void)loadUserData
{
    [[WebClient sharedInstance] getUserWithKey:[SessionManager sharedInstance].user.remoteKey callbackBlock:^(BOOL success, GLPUser *user) {
        
        if(success)
        {
            _userDetails = user;
            
//            //Load user's image.
//            
//            NSURL *imageUrl = [NSURL URLWithString:user.profileImageUrl];
//            
//            NSData *data = [NSData dataWithContentsOfURL:imageUrl];
//            UIImage *img = [[UIImage alloc] initWithData:data];
//            
//            _userImage = img;
            
            [NSThread detachNewThreadSelector:@selector(loadImage:) toTarget:self withObject:user.profileImageUrl];
            
//            NSLog(@"User's data loaded: %@",_userDetails);
            
        }
        else
        {
        }
    }];
}

-(void)loadImage:(id)sender
{
    //Load user's image.
    
    NSString *str = (NSString*)sender;
    
    NSURL *imageUrl = [NSURL URLWithString:str];
    
    NSData *data = [NSData dataWithContentsOfURL:imageUrl];
    UIImage *img = [[UIImage alloc] initWithData:data];
    
    _userImage = img;
    
}

#pragma mark - Accessors

-(NSArray*)userData
{
    if(!_userDetails || !_userImage)
    {
        return nil;
    }
    else
    {
        NSArray *userDataArray = [[NSArray alloc] initWithObjects:_userDetails, _userImage, nil];
        
        return userDataArray;
    }
}

@end
