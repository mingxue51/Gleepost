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
#import "GLPUserDao.h"
#import "DatabaseManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ImageFormatterHelper.h"
#import "WebClientHelper.h"

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
    _userDetails = [SessionManager sharedInstance].user;
    
    [NSThread detachNewThreadSelector:@selector(loadImageForUser:) toTarget:self withObject:_userDetails.profileImageUrl];
    
}

-(void)loadImageForUser:(NSString *)profileImageUrl
{
    [[SDImageCache sharedImageCache] queryDiskCacheForKey:profileImageUrl done:^(UIImage *image, SDImageCacheType cacheType) {

        if(image)
        {
            DDLogDebug(@"Image loaded from cache.");
            
            _userImage = image;
        }
        else
        {
            DDLogDebug(@"Image not loaded from cache.");

            //Load user's image remotely.
            _userImage = [self loadImageWithUrl:profileImageUrl];
            
            [[SDImageCache sharedImageCache] storeImage:_userImage forKey:profileImageUrl];
        }
    }];
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

- (UIImage*)loadImageWithUrl:(NSString*)url
{
    
    NSURL *imageUrl = [NSURL URLWithString:url];
    
    NSData *data = [NSData dataWithContentsOfURL:imageUrl];
    UIImage *img = [[UIImage alloc] initWithData:data];
    
    
    return img;
}

#pragma mark - Operations

- (void)loadUsersDataWithLocalCallback:(void (^) (GLPUser *user))localCallback andRemoteCallback:(void (^) (BOOL success, BOOL updatedData, GLPUser *user))remoteCallback
{
    __block GLPUser *databaseUser;
    __block BOOL updatedData = NO;
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        databaseUser = [GLPUserDao findByRemoteKey:_userDetails.remoteKey db:db];
        
        DDLogDebug(@"User data from database: %@", databaseUser);
        
        if(_userImage)
        {
            databaseUser.profileImage = _userImage;
        }
        
        _userDetails = databaseUser;
        
        localCallback(databaseUser);

    }];
    
    [[WebClient sharedInstance] getUserWithKey:[SessionManager sharedInstance].user.remoteKey callbackBlock:^(BOOL success, GLPUser *remoteUser) {
        
        if(!success)
        {
            remoteCallback(NO, NO, nil);
            
            return;
        }
        
        updatedData = [self dataNeedsUpdateWithCurrentUserData:_userDetails andRemoteUserData:remoteUser];
        
        
        
        DDLogDebug(@"GLPProfileLoader : user data from server %@.\n Current data: %@", remoteUser, _userDetails);

        
        if(updatedData)
        {
            [GLPUserDao update:remoteUser];
            _userDetails = remoteUser;
            _userDetails.profileImage = _userImage;
        }
        
        remoteCallback(YES, updatedData, _userDetails);

    }];
}

/**
 Uploads and sets the new user's profile image.
 
 @param user's new image.
 
 */

- (void)uploadAndSetNewUsersImage:(UIImage *)image withCallbackBlock:(void (^) (BOOL success, NSString *url))callback
{
    UIImage* imageToUpload = [ImageFormatterHelper imageWithImage:image scaledToHeight:320];
    
    _userImage = imageToUpload;
    
    NSData *imageData = UIImagePNGRepresentation(imageToUpload);
    
    
    //[WebClientHelper showStandardLoaderWithTitle:@"Uploading image" forView:self.view];
    
    
    [[WebClient sharedInstance] uploadImage:imageData ForUserRemoteKey:[[SessionManager sharedInstance]user].remoteKey callbackBlock:^(BOOL success, NSString* response) {
        
        //[WebClientHelper hideStandardLoaderForView:self.view];
        
        
        if(success)
        {
            DDLogInfo(@"Image uploaded with response: %@",response);

            //Set image to user's profile.
            [self setNewImage:imageToUpload withUrl:response withCallBack:callback];
            
        }
        else
        {
            [WebClientHelper showStandardErrorWithTitle:@"Error uploading the image" andContent:@"Please check your connection and try again"];
            
        }
    }];
}

/**
 Communicates with the server, change the image, replace the new user's image with the old one
 in cache and the url in database.
 
 @param image the new user's image.
 @param url the new user's image url.
 
 */
- (void)setNewImage:(UIImage*)image withUrl:(NSString *)url withCallBack:(void (^) (BOOL success, NSString *url))callback
{
    [[WebClient sharedInstance] uploadImageToProfileUser:url callbackBlock:^(BOOL success) {
        
        if(success)
        {
            //Inform ChangeImageProgressBar that the image is ready.
            [self postReadyNotificationToProgressBar];
            
            //Update the local database with the new url.
            [GLPUserDao updateUserWithRemotKey:_userDetails.remoteKey andProfileImage:url];
            
            //Update the cache with the new image. Ideally remove the old image.
            [self replaceImageUrl:_userDetails.profileImageUrl WithImage:image];
            
            callback(success, url);
        }
    }];
}

- (void)postReadyNotificationToProgressBar
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_CHANGE_IMAGE_PROGRESS object:self userInfo:@{@"image_ready": @""}];
}

-(UIImage*)contactImageWithRemoteKey:(int)remoteKey
{
    UrlImage *currentUrlImage = [_contactsImages objectForKey:[NSNumber numberWithInt:remoteKey]];
    
    UIImage *currentImage = currentUrlImage.img;
    
    return currentImage;
}

#pragma mark - Modifiers

- (void)replaceImageUrl:(NSString *)url WithImage:(UIImage *)image
{
    [[SDImageCache sharedImageCache] removeImageForKey:_userDetails.profileImageUrl];

    [[SDImageCache sharedImageCache] storeImage:image forKey:url];
    
}

- (BOOL)dataNeedsUpdateWithCurrentUserData:(GLPUser *)currentData andRemoteUserData:(GLPUser *)remoteData
{
    if(!currentData)
    {
        return YES;
    }
    
    if(![currentData.name isEqualToString:remoteData.name])
    {
        return YES;
    }
    
    if(![currentData.profileImageUrl isEqualToString:remoteData.profileImageUrl])
    {
        return YES;
    }
    
    if(![currentData.course isEqualToString:remoteData.course])
    {
        return YES;
    }
    
    if(![currentData.personalMessage isEqualToString:remoteData.personalMessage])
    {
        return YES;
    }
    
    if(currentData.rsvpCount && remoteData.rsvpCount)
    {
        if(![currentData.rsvpCount isEqualToNumber:remoteData.rsvpCount])
        {
            return YES;
        }
    }
    
    if(currentData.postsCount && remoteData.postsCount)
    {
        if(![currentData.postsCount isEqualToNumber:remoteData.postsCount])
        {
            return YES;
        }
    }
    
    if(currentData.groupCount && remoteData.groupCount)
    {
        if(![currentData.groupCount isEqualToNumber:remoteData.groupCount])
        {
            return YES;
        }
    }
    
    return NO;
}

-(void)initialiseLoader
{
    _contactsImages = [[NSMutableDictionary alloc] init];
    _userDetails = [[GLPUser alloc] init];
    _userImage = [[UIImage alloc] init];
    self.loadingImagesExecuting = NO;
}

@end
