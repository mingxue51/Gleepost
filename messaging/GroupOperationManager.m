//
//  GroupOperationManager.m
//  Gleepost
//
//  Created by Σιλουανός on 6/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GroupOperationManager.h"
#import "GroupUploaderManager.h"
#import "GLPGroupDao.h"
#import "GLPiOSSupportHelper.h"
#import "GLPLiveGroupManager.h"

@interface GroupOperationManager ()

@property (strong, nonatomic) GroupUploaderManager *groupUploader;

@end

@implementation GroupOperationManager

static GroupOperationManager *instance = nil;


+ (GroupOperationManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    //    once_token = &onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[GroupOperationManager alloc] init];
    });
    
    return instance;
}

-(id)init
{
    self = [super init];
    
    if(self)
    {
//        _imageUploader = [[GLPImageUploaderManager alloc] init];
//        _postUploader = [[GLPPostUploaderManager alloc] init];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetworkStatus:) name:@"GLPNetworkStatusUpdate" object:nil];

        _groupUploader = [[GroupUploaderManager alloc] init];
        
        super.checkForUploadingTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(checkForGroupUpload:) userInfo:nil repeats:YES];
        
        if(![GLPiOSSupportHelper isIOS6])
        {
            [super.checkForUploadingTimer setTolerance:5.0f];

        }
    }
    
    return self;
}

#pragma mark - Operation Methods

-(void)checkForGroupUpload:(id)sender
{
    for(NSDate* t in [_groupUploader pendingGroups])
    {
        NSString *url = [[super imageUploader] urlWithTimestamp:t];
        
        DDLogInfo(@"Ready URL: %@",url);
        
        
        if(url)
        {
            DDLogInfo(@"Post ready for upload!");
            
            //Group ready for uploading.
            [_groupUploader uploadGroupWithTimestamp:t andImageUrl:url];
            
            //Remove url from the Image Operation.
            [[super imageUploader] removeUrlWithTimestamp:t];
        }
        else
        {
            //Image not uploaded yet.
        }
    }
}



#pragma mark - Modifiers

-(void)setGroup:(GLPGroup *)group withTimestamp:(NSDate *)timestamp
{
    //Save to group local database.
    [[GLPLiveGroupManager sharedInstance] newGroupToBeCreated:group withTimestamp:timestamp];
    [_groupUploader addGroup:group withTimestamp:timestamp];
}

#pragma mark - Group uploader manager methods

-(void)changeGroupImageWithImage:(UIImage *)image withGroup:(GLPGroup *)group
{
    [_groupUploader changeGroupImageWithImage:image withGroup:group];
}

-(UIImage *)pendingGroupImageWithRemoteKey:(int)remoteKey
{
    return [_groupUploader pendingGroupImageWithRemoteKey:remoteKey];
}

@end
