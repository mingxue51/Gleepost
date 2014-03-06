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

@interface GroupUploaderManager ()

@property (nonatomic, strong) NSMutableDictionary *readyGroups;
//@property (nonatomic, strong) NSMutableArray *uploadedGroups;

@end

@implementation GroupUploaderManager

-(id)init
{
    self = [super init];
    
    if(self)
    {
        _readyGroups = [[NSMutableDictionary alloc] init];
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
    [_readyGroups setObject:group forKey:timestamp];
}

-(void)removeGroupWithTimestamp:(NSDate*)timestamp
{
    [_readyGroups removeObjectForKey:timestamp];
}

//-(NSDictionary*)pendingPosts
//{
//    
//}

#pragma mark - Client

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
            
            NSLog(@"Into uploadImageContentBlock");
            
            //TODO: Notify ContactsViewController after finish.
//            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPPostUploaded" object:nil userInfo:@{@"remoteKey":[NSNumber numberWithInt:post.remoteKey],
//                                                                                                                            @"imageUrl":[post.imagesUrls objectAtIndex:0],
//                                                                                                                            @"key":[NSNumber numberWithInt:post.key]}];
            
        };
    }
    
    NSLog(@"Group uploading task started with group title: %@ and image url: %@.",group.name, group.groupImageUrl);
    
    
    //    _incomingPost.imagesUrls = [[NSArray alloc] initWithObjects:[self.urls objectForKey:[NSNumber numberWithInt:1]], nil];
    
    
    [[WebClient sharedInstance] createGroupWithGroup:group callback:^(BOOL success, GLPGroup *remoteGroup) {
       
        
        group.sendStatus = success ? kSendStatusSent : kSendStatusFailure;
        
        group.remoteKey = success ? remoteGroup.remoteKey : 0;
        
        NSLog(@"Group uploaded with success: %d and group remoteKey: %d", success, group.remoteKey);

        [GLPGroupDao updateGroupSendingData:group];
        
        if(success)
        {
            _uploadImageContentBlock(group);
        
            
            //Remove post from the NSDictionary.
            [self removeGroupWithTimestamp:timestamp];

        }
    }];
}

@end
