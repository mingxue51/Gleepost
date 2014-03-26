//
//  GroupUploaderManager.m
//  Gleepost
//
//  Created by Σιλουανός on 6/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GroupUploaderManager.h"
#import "WebClient.h"
#import "GLPGroupDao.h"
#import "NSNotificationCenter+Utils.h"
#import "ImageFormatterHelper.h"
#import "SessionManager.h"


@interface GroupUploaderManager ()

@property (nonatomic, strong) NSMutableDictionary *readyGroups;

/** Preserves the pending images for groups. */
@property (strong, nonatomic) NSMutableDictionary *pendingGroupImages;

//@property (nonatomic, strong) NSMutableArray *uploadedGroups;

@end

@implementation GroupUploaderManager

-(id)init
{
    self = [super init];
    
    if(self)
    {
        _readyGroups = [[NSMutableDictionary alloc] init];
        _pendingGroupImages = [[NSMutableDictionary alloc] init];

    }
    
    return self;
}

#pragma mark - Getters Setters

-(NSDictionary *)pendingGroups
{
    return _readyGroups;
}


-(void)addGroup:(GLPGroup*)group withTimestamp:(NSDate*)timestamp
{
    if(timestamp == nil)
    {
        //Group without image.
        [self uploadGroupWithoutImage:group];
    }
    else
    {
        [_readyGroups setObject:group forKey:timestamp];
    }
    
}

-(void)removeGroupWithTimestamp:(NSDate*)timestamp
{
    [_readyGroups removeObjectForKey:timestamp];
}

#pragma mark - Client

-(void)uploadGroupWithoutImage:(GLPGroup *)group
{
    
    [[WebClient sharedInstance] createGroupWithGroup:group callback:^(BOOL success, GLPGroup *remoteGroup) {
        
        
        group.sendStatus = success ? kSendStatusSent : kSendStatusFailure;
        
        group.remoteKey = success ? remoteGroup.remoteKey : 0;
        
        DDLogInfo(@"Group uploaded with success: %d and group remoteKey: %d", success, group.remoteKey);
        
        [GLPGroupDao updateGroupSendingData:group];
        
        if(success)
        {
//            _uploadImageContentBlock(group);
            [self notifyControllerWithGroup:group];
        }
    }];
}

-(void)uploadGroupWithTimestamp:(NSDate*)timestamp andImageUrl:(NSString*)url
{
    //Group ready to be uploaded.
    
    void (^_uploadImageContentBlock)(GLPGroup*);
    
    GLPGroup *group = nil;
    
    @synchronized(_readyGroups)
    {
        group = [_readyGroups objectForKey:timestamp];
        group.groupImageUrl = url;
        
        _uploadImageContentBlock = ^(GLPGroup* group){
            
            
        //Notify ContactsViewController after finish.
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPGroupUploaded"
                                                                        object:nil
                                                                        userInfo:@{@"remoteKey":[NSNumber numberWithInt:group.remoteKey],
                                                                                    @"imageUrl":group.groupImageUrl,
                                                                                    @"key":[NSNumber numberWithInt:group.key]}];
            
        };
    }
    
    DDLogInfo(@"Group uploading task started with group title: %@ and image url: %@.",group.name, group.groupImageUrl);
    
    
    //    _incomingPost.imagesUrls = [[NSArray alloc] initWithObjects:[self.urls objectForKey:[NSNumber numberWithInt:1]], nil];
    
    
    [[WebClient sharedInstance] createGroupWithGroup:group callback:^(BOOL success, GLPGroup *remoteGroup) {
       
        
        group.sendStatus = success ? kSendStatusSent : kSendStatusFailure;
        
        group.remoteKey = success ? remoteGroup.remoteKey : 0;
        
        DDLogInfo(@"Group uploaded with success: %d and group remoteKey: %d", success, group.remoteKey);

        [GLPGroupDao updateGroupSendingData:group];
        
        if(success)
        {
            _uploadImageContentBlock(group);
        
            
            //Remove post from the NSDictionary.
            [self removeGroupWithTimestamp:timestamp];

        }
    }];
}

#pragma mark - Change group image

-(void)changeGroupImageWithImage:(UIImage *)image withGroup:(GLPGroup *)group
{
//    [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(test:) userInfo:nil repeats:YES];
    [_pendingGroupImages setObject:image forKey:[NSNumber numberWithInt:group.remoteKey]];

    NSData *imageData = [self convertImageToData:image];
    
    [self uploadImageWithData:imageData andGroup:group];
    
}

-(void)removeEntryFromPendingGroupImagesWithRemoteKey:(int)remoteKey
{
    [_pendingGroupImages removeObjectForKey:[NSNumber numberWithInt:remoteKey]];
}


-(void)uploadImageWithData:(NSData *)imageData andGroup:(GLPGroup *)group
{
    [[WebClient sharedInstance] uploadImage:imageData ForUserRemoteKey:[[SessionManager sharedInstance]user].remoteKey callbackBlock:^(BOOL success, NSString* response) {
        
        if(success)
        {
            [self updateDatabaseWithGroup:group andUrl:response];
            
            [self removeEntryFromPendingGroupImagesWithRemoteKey:group.remoteKey];
            
            //Send notification to contacts view controller.
            [self notifyControllerWithGroup:group];
            
            [self setNewUrlToGroup:group withUrl:response];
        }
        
    }];
}

-(void)setNewUrlToGroup:(GLPGroup *)group withUrl:(NSString *)url
{
    [[WebClient sharedInstance] uploadImageUrl:url withGroupRemoteKey:group.remoteKey callbackBlock:^(BOOL success) {
       
        if(!success)
        {
            
        }
        
    }];
}

-(void)updateDatabaseWithGroup:(GLPGroup *)group andUrl:(NSString *)url
{
    group.groupImageUrl = url;
    [GLPGroupDao updateGroup:group];
}

-(NSData *)convertImageToData:(UIImage *)image
{
    UIImage* imageToUpload = [ImageFormatterHelper imageWithImage:image scaledToHeight:320];
    
    NSData *imageData = UIImagePNGRepresentation(imageToUpload);
    
    return imageData;
}

#pragma mark - Accessors

-(UIImage *)pendingGroupImageWithRemoteKey:(int)remoteKey
{
    return [_pendingGroupImages objectForKey:[NSNumber numberWithInt:remoteKey]];
}

#pragma mark - Notifications

-(void)notifyControllerWithGroup:(GLPGroup *)group
{
    
    if(group.groupImageUrl)
    {
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPGroupUploaded"
                                                                        object:nil
                                                                      userInfo:@{@"remoteKey":[NSNumber numberWithInt:group.remoteKey],
                                                                                 @"imageUrl": group.groupImageUrl,
                                                                                 @"key":[NSNumber numberWithInt:group.key]}];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPGroupUploaded"
                                                                        object:nil
                                                                      userInfo:@{@"remoteKey":[NSNumber numberWithInt:group.remoteKey],
                                                                                 @"key":[NSNumber numberWithInt:group.key]}];
    }
    

}



@end
