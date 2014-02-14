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

/**
 Inner class. Check if this methodology is the most appropriate.
 */

@interface UrlImage : NSObject

@property (strong, nonatomic) UIImage *img;
@property (strong, nonatomic) NSString *url;

@end

@implementation UrlImage

-(id)initWithImage:(UIImage*)img andUrl:(NSString*)url
{
    self = [super init];
    
    if(self)
    {
        self.img = img;
        self.url = url;
    }
    
    return self;
}

@end



@interface GLPProfileLoader ()

@property (strong, nonatomic) NSMutableDictionary *contactsImages;

//userDetails contains one GLPContact and UIImage of the logged in user.
@property (strong, nonatomic) GLPUser *userDetails;
@property (strong, nonatomic) UIImage *userImage;
@property (assign, nonatomic) BOOL loadingImagesExecuting;

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
        [self initialiseLoader];
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
            
            [NSThread detachNewThreadSelector:@selector(loadImageForUser:) toTarget:self withObject:user.profileImageUrl];
        }
        else
        {
        }
    }];
}

-(void)loadImageForUser:(id)sender
{
    //Load user's image.
    _userImage = [self loadImageWithUrl:(NSString*)sender];
    
}

-(void)loadContactsImages:(NSArray*)contacts
{
    [NSThread detachNewThreadSelector:@selector(loadImageWithContacts:) toTarget:self withObject:contacts];
}

-(void)loadImageWithContacts:(id)sender
{
    NSArray *contacts = (NSArray*)sender;
    
    for(GLPContact *contact in contacts)
    {
        [self loadImageWithUrl:contact.user.profileImageUrl withContactRemoteKeyAndAddIt:contact.remoteKey];
    }
    
}

-(void)refreshContactsImages:(NSArray*)contacts
{
    if(!self.loadingImagesExecuting)
    {
        [NSThread detachNewThreadSelector:@selector(refreshImagesWithContacts:) toTarget:self withObject:contacts];
    }
}

-(void)refreshImagesWithContacts:(id)sender
{
    self.loadingImagesExecuting = YES;
    
    NSArray *contacts = (NSArray*)sender;
    
    for(GLPContact *contact in contacts)
    {
        UrlImage *oldUrlImage = [_contactsImages objectForKey:[NSNumber numberWithInt:contact.remoteKey]];
        NSString *oldProfileUrl = oldUrlImage.url;
        
        //If the oldProfileUrl is nil then the image is not added yet.
        //If the current url is not equal with the old one then we
        //need to load new image and replace it with the old one.
        if(!oldProfileUrl)
        {
            [self loadImageWithUrl:contact.user.profileImageUrl withContactRemoteKeyAndAddIt:contact.remoteKey];
        }
        else if(![contact.user.profileImageUrl isEqualToString:oldProfileUrl])
        {
            [self loadImageWithUrl:contact.user.profileImageUrl withContactRemoteKeyAndAddIt:contact.remoteKey];
        }

    }
    
    self.loadingImagesExecuting = NO;
}

-(void)loadImageWithUrl:(NSString*)url withContactRemoteKeyAndAddIt:(int)remoteKey
{
    UIImage *userImg = [self loadImageWithUrl:url];
    
    if(userImg)
    {
        //Add url and image to the object and add it to the Dictionary.
        
        UrlImage *urlImage = [[UrlImage alloc] initWithImage:userImg andUrl:url];
        
        [_contactsImages setObject:urlImage forKey:[NSNumber numberWithInteger:remoteKey]];
    }
}

-(UIImage*)loadImageWithUrl:(NSString*)url
{
    
    NSURL *imageUrl = [NSURL URLWithString:url];
    
    NSData *data = [NSData dataWithContentsOfURL:imageUrl];
    UIImage *img = [[UIImage alloc] initWithData:data];
    
    
    return img;
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


-(UIImage*)contactImageWithRemoteKey:(int)remoteKey
{
    UrlImage *currentUrlImage = [_contactsImages objectForKey:[NSNumber numberWithInt:remoteKey]];
    
    UIImage *currentImage = currentUrlImage.img;
    
    return currentImage;
}

-(void)initialiseLoader
{
    _contactsImages = [[NSMutableDictionary alloc] init];
    _userDetails = [[GLPUser alloc] init];
    self.loadingImagesExecuting = NO;
}

@end
