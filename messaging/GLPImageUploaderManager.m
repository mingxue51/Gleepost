//
//  GLPImageUploaderManager.m
//  Gleepost
//
//  Created by Silouanos on 20/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPImageUploaderManager.h"
#import "WebClient.h"
#import "ImageFormatterHelper.h"
#import "NSMutableArray+QueueAdditions.h"

@interface GLPImageUploaderManager ()

@property (strong, nonatomic) NSMutableDictionary *uploadedImages;

@property (strong, nonatomic) NSMutableDictionary *pendingImages;
@property (strong, nonatomic) NSMutableArray *pendingTimestamps;
@property (strong, nonatomic) NSTimer *checker;
@property (assign, nonatomic) BOOL networkAvailable;


@end

@implementation GLPImageUploaderManager

@synthesize uploadedImages = _uploadedImages;
@synthesize pendingImages = _pendingImages;
@synthesize pendingTimestamps = _pendingTimestamps;
@synthesize checker = _checker;

const NSString *IMAGE_PENDING = @"PENDING";

-(id)init
{
    self = [super init];
    
    if(self)
    {
        _uploadedImages = [[NSMutableDictionary alloc] init];
        
        _pendingTimestamps = [[NSMutableArray alloc] init];
        _pendingImages = [[NSMutableDictionary alloc] init];
        _checker = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(startUploadImage:) userInfo:nil repeats:YES];
        [_checker setTolerance:5.0f];
        
        [_checker fire];
        
        
        self.networkAvailable = YES;
        
        //Called when there is change in status.
        
        [[WebClient sharedInstance] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            
            BOOL currentStatus = (status == AFNetworkReachabilityStatusNotReachable) ? NO : YES;
            
            if(currentStatus)
            {
                self.networkAvailable = YES;
                //[self startConsume];
                [self cancelOperations];

            }
            else
            {
                self.networkAvailable = NO;
                //No network.
                [self cancelOperations];
            }
            
        }];
        
                              //NSOrderedSame
    }
    
    return self;
}


#pragma mark - Helpers

/**
 Cancel the execution of the two threads and refill the array with the
 images' remote keys that were not finished.
 
 */
-(void)cancelOperations
{
    BOOL exist = NO;
    
    //Refill the array with the not finished remote keys.
    for (NSNumber *key in _pendingImages)
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

#pragma mark - Modifiers

-(NSString*)urlWithTimestamp:(NSDate*)timestamp
{
    return [_uploadedImages objectForKey:timestamp];
}

-(void)removeUrlWithTimestamp:(NSDate*)timestamp
{
    [_uploadedImages removeObjectForKey:timestamp];
}

/**
 Removes the image with a particular timestamp from pending and uploaded images data structures.
 
 @param timestamp.
 
 */
-(void)cancelImageWithTimestamp:(NSDate *)timestamp
{
    [_pendingImages removeObjectForKey:timestamp];
    [_uploadedImages removeObjectForKey:timestamp];
    [_pendingTimestamps removeObject:timestamp];
}


#pragma mark - Client

-(void)uploadImage:(UIImage*)image withTimestamp:(NSDate*)timestamp
{
    
    //Add timestamp to NSDictionary with url as pending.
//    [_uploadedImages setObject:IMAGE_PENDING forKey:timestamp];
    
    
    //Add image and timestamp to the pending NSDictionary.
    [_pendingImages setObject:image forKey:timestamp];
    
    
    //Add timestamp to NSArray.
    [_pendingTimestamps enqueue:timestamp];
    
    
    //Start thread if is not started.
//    if(![_checker isValid])
//    {
//        [_checker fire];
//    }
    
    //Start uploading the image.
   // [self startUploadingImage:image withTimestamp:timestamp];
    
}

//NEW METHOD NEW APPROACH.
- (void)startUploadImage:(id)sender
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

    
    UIImage *image = [_pendingImages objectForKey:timestamp];
    
    __block NSData *data;
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
        UIImage *resizedImage = [ImageFormatterHelper imageWithImage:image scaledToHeight:640];
        data = UIImagePNGRepresentation(resizedImage);
        
    }];
    
    [operation setCompletionBlock:^{
        
        [self uploadResizedImageWithImageData:data withTimestamp:timestamp];
        
    }];
    
    [[[NSOperationQueue alloc] init] addOperation:operation];
}

- (void)startUploadingImage:(UIImage*)image withTimestamp:(NSDate*)timestamp
{
    //    _postImage = image;
    //    _imageStatus = GLPImageStatusUploading;
    
    __block NSData *data;
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
        UIImage *resizedImage = [ImageFormatterHelper imageWithImage:image scaledToHeight:640];
        data = UIImagePNGRepresentation(resizedImage);
        
    }];
    
    [operation setCompletionBlock:^{
    
        [self uploadResizedImageWithImageData:data withTimestamp:timestamp];
    
    }];
    
    [[[NSOperationQueue alloc] init] addOperation:operation];
}

- (void)uploadResizedImageWithImageData:(NSData *)imageData withTimestamp:(NSDate*)timestamp
{
    
    __block BOOL finished = NO;
    __block NSString *imageUrlSend = nil;
    
    //Lock.
    
    if (imageData)
    {
        [[WebClient sharedInstance] uploadImage:imageData callback:^(BOOL success, NSString *imageUrl) {
            if (success) {

                
                finished = success;
                imageUrlSend = imageUrl;
                
                if(finished)
                {
                    
                    @synchronized(_pendingImages)
                    {
                        [_pendingImages removeObjectForKey:timestamp];
                    }
                    
                    //Add image url
                    [self updateImageToDictionary:imageUrl withTimestamp:timestamp];
                    
                    //NSLog(@"Image url after notify: %@",imageUrlSend);
                    
                }
                
                
                
            } else {
                NSLog(@"Error occured. Post image cannot be uploaded.");
                self.networkAvailable = NO;
            }
        }];
    }
}

-(void)updateImageToDictionary:(NSString*)imageUrl withTimestamp:(NSDate*)timestamp
{
    //Update dictionary.
    @synchronized(_uploadedImages)
    {
        [_uploadedImages setObject:imageUrl forKey:timestamp];
    }
}


@end
