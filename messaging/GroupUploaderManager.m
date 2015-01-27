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
#import "GLPLiveGroupManager.h"

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
        
        
        remoteGroup.sendStatus = success ? kSendStatusSent : kSendStatusFailure;
        
//        group.remoteKey = success ? remoteGroup.remoteKey : 0;
        
        DDLogInfo(@"Group uploaded with success: %d and group remoteKey: %d", success, remoteGroup.remoteKey);
        
        remoteGroup.key = group.key;
        
        [GLPGroupDao updateGroupSendingData:remoteGroup];
        
        if(success)
        {
//            _uploadImageContentBlock(group);
//            [self notifyAfterGroupUploaded:remoteGroup];
            [[GLPLiveGroupManager sharedInstance] updateGroupAfterCreated:remoteGroup];
        }
    }];
}

- (void)uploadGroupWithTimestamp:(NSDate *)timestamp andImageUrl:(NSString *)url
{
    //Group ready to be uploaded.
    
    GLPGroup *group = nil;
    
    @synchronized(_readyGroups)
    {
        group = [_readyGroups objectForKey:timestamp];
        group.groupImageUrl = url;
    }
    
    DDLogInfo(@"Group uploading task started with group title: %@ and image url: %@.",group.name, group.groupImageUrl);
    
    
    //    _incomingPost.imagesUrls = [[NSArray alloc] initWithObjects:[self.urls objectForKey:[NSNumber numberWithInt:1]], nil];
    
    
    [[WebClient sharedInstance] createGroupWithGroup:group callback:^(BOOL success, GLPGroup *remoteGroup) {
        
        remoteGroup.sendStatus = success ? kSendStatusSent : kSendStatusFailure;
        
//        group.remoteKey = success ? remoteGroup.remoteKey : 0;
        
        remoteGroup.key = group.key;
        
        DDLogInfo(@"Group uploaded with success: %d and group remoteKey: %ld", success, (long)group.remoteKey);
        
        [GLPGroupDao updateGroupSendingData:remoteGroup];

        if(success)
        {
//            [self notifyAfterGroupUploaded:remoteGroup];
            [[GLPLiveGroupManager sharedInstance] updateGroupAfterCreated:remoteGroup];

            //Remove post from the NSDictionary.
            [self removeGroupWithTimestamp:timestamp];

        }
    }];
}

#pragma mark - Change group image

-(void)changeGroupImageWithImage:(UIImage *)image withGroup:(GLPGroup *)group
{
    //Remove if pending image exist.
    [self removeEntryFromPendingGroupImagesWithRemoteKey:group.remoteKey];
    
//    [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(test:) userInfo:nil repeats:YES];
    [_pendingGroupImages setObject:image forKey:[NSNumber numberWithInt:group.remoteKey]];

    NSData *imageData = [self convertImageToData:image];
    
    [self uploadImageWithData:imageData andGroup:group];
    
}

-(void)removeEntryFromPendingGroupImagesWithRemoteKey:(int)remoteKey
{
    DDLogDebug(@"Pending group images before: %@", _pendingGroupImages);

    [_pendingGroupImages removeObjectForKey:[NSNumber numberWithInt:remoteKey]];
    
    DDLogDebug(@"Pending group images: %@", _pendingGroupImages);
}


-(void)uploadImageWithData:(NSData *)imageData andGroup:(GLPGroup *)group
{
    [[WebClient sharedInstance] uploadImage:imageData forGroupWithRemoteKey:group.remoteKey callback:^(BOOL success, NSString *imageUrl) {
       
        if(success)
        {
            DDLogDebug(@"Image url: %@", imageUrl);
            
            [self removeEntryFromPendingGroupImagesWithRemoteKey:group.remoteKey];

            //If imageUrl is empty it means that the image canceled.
            if(![imageUrl isEqualToString:@""])
            {
                [self updateDatabaseWithGroup:group andUrl:imageUrl];
                
                //Send notification to groups view controller.
                [self notifyControllerWithGroup:group];
                
                [self setNewUrlToGroup:group withUrl:imageUrl];
            }

        }
        
    }];
}

-(void)setNewUrlToGroup:(GLPGroup *)group withUrl:(NSString *)url
{
    [[WebClient sharedInstance] uploadImageUrl:url withGroupRemoteKey:group.remoteKey callbackBlock:^(BOOL success) {
       
        if(success)
        {
//            [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_CHANGE_GROUP_IMAGE_PROGRESS object:self userInfo:@{@"image_ready": @""}];
            
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_CHANGE_GROUP_IMAGE_PROGRESS object:self userInfo:@{@"image_ready": @""}];
            
            //Tell to GLPLiveGroupManager that the new image is uploaded and attached to group.
            [[GLPLiveGroupManager sharedInstance] finishUploadingNewImageToGroup:group];
        }
        else
        {
            //TODO: Post notification an error and dismiss the progress bar.
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

//TODO: To be deleted.
-(void)notifyControllerWithGroup:(GLPGroup *)group
{
    
    if(group.groupImageUrl)
    {
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_NEW_GROUP_TO_BE_CREATED
                                                                        object:self
                                                                      userInfo:@{@"remoteKey":[NSNumber numberWithInt:group.remoteKey],
                                                                                 @"imageUrl": group.groupImageUrl,
                                                                                 @"key":[NSNumber numberWithInt:group.key]}];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_NEW_GROUP_TO_BE_CREATED
                                                                        object:self
                                                                      userInfo:@{@"remoteKey":[NSNumber numberWithInt:group.remoteKey],
                                                                                 @"key":[NSNumber numberWithInt:group.key]}];
    }
}

- (void)notifyAfterGroupUploaded:(GLPGroup *)group
{
    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_NEW_GROUP_TO_BE_CREATED
                                                                    object:self
                                                                  userInfo:@{@"group":group}];
}



@end
