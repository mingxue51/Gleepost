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
#import "GLPImageCacheHelper.h"

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
        
        DDLogInfo(@"Group uploaded with success: %d and group remoteKey: %d", success, remoteGroup.remoteKey);
        
        remoteGroup.key = group.key;
        
        [GLPGroupDao updateGroupSendingData:remoteGroup];
        
        if(success)
        {
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
    
    
    
    [[WebClient sharedInstance] createGroupWithGroup:group callback:^(BOOL success, GLPGroup *remoteGroup) {
        
        remoteGroup.sendStatus = success ? kSendStatusSent : kSendStatusFailure;
        remoteGroup.key = group.key;
        
        DDLogInfo(@"Group uploaded with success: %d and group remoteKey: %ld", success, (long)group.remoteKey);
        
        [GLPGroupDao updateGroupSendingData:remoteGroup];

        if(success)
        {
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
    [[WebClient sharedInstance] uploadImage:imageData forGroupWithRemoteKey:group.remoteKey callback:^(BOOL success, NSString *imageUrl) {
       
        if(success)
        {
            DDLogDebug(@"GroupUploadedManager : Updated image url %@", imageUrl);
            
            //If imageUrl is empty it means that the image canceled.
            if(![imageUrl isEqualToString:@""])
            {
                [self updateDatabaseAndCacheWithGroup:group andUrl:imageUrl];
                [self setNewUrlToGroup:group withUrl:imageUrl];
            }
            
            [self removeEntryFromPendingGroupImagesWithRemoteKey:group.remoteKey];
        }
        
    }];
}

-(void)setNewUrlToGroup:(GLPGroup *)group withUrl:(NSString *)url
{
    [[WebClient sharedInstance] uploadImageUrl:url withGroupRemoteKey:group.remoteKey callbackBlock:^(BOOL success) {
       
        if(success)
        {
            //Tell to GLPLiveGroupManager that the new image is uploaded and attached to group.
            [[GLPLiveGroupManager sharedInstance] finishUploadingNewImageToGroup:group];
        }
        else
        {
            //TODO: Post notification an error and dismiss the progress bar.
        }
        
    }];
}

-(void)updateDatabaseAndCacheWithGroup:(GLPGroup *)group andUrl:(NSString *)url
{
    UIImage *pendingImage = [_pendingGroupImages objectForKey:@(group.remoteKey)];
    [GLPImageCacheHelper replaceImage:pendingImage withImageUrl:url andOldImageUrl:group.groupImageUrl];
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

@end
