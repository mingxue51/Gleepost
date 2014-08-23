//
//  GLPVideoUploader.m
//  Gleepost
//
//  Created by Silouanos on 14/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPVideoUploader.h"
#import "GLPiOS6Helper.h"
#import "WebClient.h"
#import "NSMutableArray+QueueAdditions.h"
#import "GLPProgressManager.h"

@interface GLPVideoUploader ()

@property (strong, nonatomic) NSMutableDictionary *uploadedVideosIds;

@property (strong, nonatomic) NSMutableArray *pendingTimestamps;

@property (strong, nonatomic) NSMutableDictionary *pendingVideosPaths;

@property (strong, nonatomic) NSTimer *checker;

@property (assign, nonatomic) BOOL networkAvailable;

@end

@implementation GLPVideoUploader

-(id)init
{
    self = [super init];
    
    if(self)
    {

        [self initialiseObjects];
        
        [self configureNetwork];
    }
    
    return self;
}

#pragma mark - Configuration

-(void)initialiseObjects
{
    _uploadedVideosIds = [[NSMutableDictionary alloc] init];
    
    _pendingTimestamps = [[NSMutableArray alloc] init];
    _pendingVideosPaths = [[NSMutableDictionary alloc] init];
    _checker = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(startUploadVideo:) userInfo:nil repeats:YES];
    
    if(![GLPiOS6Helper isIOS6])
    {
        [_checker setTolerance:5.0f];
    }
    
    [_checker fire];
    
    
    self.networkAvailable = YES;
}

-(void)configureNetwork
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetworkStatus:) name:GLPNOTIFICATION_NETWORK_UPDATE object:nil];
    

//    [[WebClient sharedInstance] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//        
//        BOOL currentStatus = (status == AFNetworkReachabilityStatusNotReachable) ? NO : YES;
//        
//        if(currentStatus)
//        {
//            self.networkAvailable = YES;
//            //[self startConsume];
//            [self cancelOperations];
//            
//        }
//        else
//        {
//            self.networkAvailable = NO;
//            //No network.
//            [self cancelOperations];
//        }
//        
//    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_NETWORK_UPDATE object:nil];
}

#pragma mark - Network

- (void)updateNetworkStatus:(NSNotification *)notification
{
    BOOL isNetwork = [notification.userInfo[@"status"] boolValue];
    
    if(!isNetwork)
    {
        DDLogInfo(@"GLPVideoUploaded : Canceling all operations.");
        
        [self cancelOperations];
    }
}

#pragma mark - Managers

/**
 Cancel the execution of the two threads and refill the array with the
 videos' remote keys that were not finished.
 
 */
-(void)cancelOperations
{
    BOOL exist = NO;
    
    //Refill the array with the not finished remote keys.
    for (NSNumber *key in _pendingVideosPaths)
    {
        for(NSNumber *arrayKey in _pendingTimestamps)
        {
            if([arrayKey compare:key] == NSOrderedSame)
            {
                exist = YES;
                break;
            }
        }
        
        if(!exist)
        {
            [_pendingTimestamps insertObject:key atIndex:0];
        }
        else
        {
            exist = NO;
        }
    }
    
}

#pragma mark - Accessors

-(NSNumber *)videoKeyWithTimestamp:(NSDate*)timestamp
{
    return [_uploadedVideosIds objectForKey:timestamp];
}

#pragma mark - Client

-(void)uploadVideo:(NSString *)videoPath withTimestamp:(NSDate*)timestamp
{
    //Add image and timestamp to the pending NSDictionary.
    [_pendingVideosPaths setObject:videoPath forKey:timestamp];
    
    //Add timestamp to NSArray.
    [_pendingTimestamps enqueue:timestamp];
}

- (void)startUploadVideo:(id)sender
{
    //Consume.
    
    if(_pendingTimestamps.count == 0)
    {
        //TODO: Pause thread.
        //[_checker setFireDate:];
        //DDLogCDebug(@"Queues empty: %@ - %@",_pendingTimestamps, _pendingImages);
        return;
    }
    
    if(!self.networkAvailable)
    {
        [self cancelOperations];
        
        return;
    }
    
    
    NSDate *timestamp = [_pendingTimestamps dequeue];
    
    // DDLogCDebug(@"Starting uploading image with timestamp: %@",timestamp);
    
    
    NSString *videoPath = [_pendingVideosPaths objectForKey:timestamp];
    
    __block NSData *videoData;
    
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
        NSError *error = [[NSError alloc] init];

        videoData = [NSData dataWithContentsOfFile:videoPath options:NSDataReadingMappedAlways error: &error];
        
    }];
    
    [operation setCompletionBlock:^{
        
        [self uploadVideoWithVideoData:videoData withTimestamp:timestamp];

    }];
    
    [[[NSOperationQueue alloc] init] addOperation:operation];
}

-(void)uploadVideoWithVideoData:(NSData *)videoData withTimestamp:(NSDate *)timestamp
{
//    __block BOOL finished = NO;
//    __block NSString *videoUrlSend = nil;
    
    [[GLPProgressManager sharedInstance] registerVideoWithTimestamp:timestamp];
    
    if (videoData)
    {
        [[WebClient sharedInstance] uploadVideoWithData:videoData callback:^(BOOL success, NSNumber *videoId) {
           
            if (success)
            {
//                finished = success;
                
                if(success)
                {
                    @synchronized(_pendingVideosPaths)
                    {
                        [_pendingVideosPaths removeObjectForKey:timestamp];
                    }
                    
                    
                    
                    //Add image url
                    [self updateVideoToDictionary:videoId withTimestamp:timestamp];
                    
                    NSLog(@"Video id after uploaded: %@", videoId);
                }
                
            }
            else
            {
                NSLog(@"Error occured. Post image cannot be uploaded.");
                self.networkAvailable = NO;
            }
            
        }];
        
        
//        [[WebClient sharedInstance] uploadVideo:videoData callback:^(BOOL success, NSString *videoUrl) {
//            
//            if (success)
//            {
//                finished = success;
//                videoUrlSend = videoUrl;
//                
//                if(finished)
//                {
//                    @synchronized(_pendingVideosPaths)
//                    {
//                        [_pendingVideosPaths removeObjectForKey:timestamp];
//                    }
//                    
//                    //Add image url
//                    [self updateVideoToDictionary:videoUrl withTimestamp:timestamp];
//                    
//                    NSLog(@"Image url after notify: %@", videoUrl);
//                }
//                
//            }
//            else
//            {
//                NSLog(@"Error occured. Post image cannot be uploaded.");
//                self.networkAvailable = NO;
//            }
//        }];
    }
}

-(void)updateVideoToDictionary:(NSNumber *)videoId withTimestamp:(NSDate*)timestamp
{
    //Update dictionary.
    @synchronized(_uploadedVideosIds)
    {
        [_uploadedVideosIds setObject:videoId forKey:timestamp];
        
        DDLogDebug(@"GLPVideoUploader : _uploadedVideosIds: %@", _uploadedVideosIds);
    }
}

//-(void)removeUrlWithTimestamp:(NSDate*)timestamp
//{
//    [_uploadedVideosUrls removeObjectForKey:timestamp];
//}

-(void)removeVideoIdWithTimestamp:(NSDate*)timestamp
{
    [_uploadedVideosIds removeObjectForKey:timestamp];
}

//- (NSDate *)timestampForVideoKey:(NSNumber *)videoKey
//{
//    for(NSNumber *vKey in _uploadedVideosIds)
//    {
//        if([vKey isEqualToNumber:videoKey])
//        {
//            return [_uploadedVideosIds objectForKey:vKey];
//        }
//    }
//    
//    return nil;
//}

/**
 Removes the video with a particular timestamp from pending and uploaded videos data structures.
 
 @param timestamp.
 
 */
-(void)cancelVideoWithTimestamp:(NSDate *)timestamp
{
    [_pendingVideosPaths removeObjectForKey:timestamp];
    [_uploadedVideosIds removeObjectForKey:timestamp];
    [_pendingTimestamps removeObject:timestamp];
}

@end
