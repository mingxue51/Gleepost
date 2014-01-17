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

@interface GLPImageUploaderManager ()

@property (strong, nonatomic) NSMutableDictionary *uploadedImages;

@end

@implementation GLPImageUploaderManager

@synthesize uploadedImages = _uploadedImages;

const NSString *IMAGE_PENDING = @"PENDING";

-(id)init
{
    self = [super init];
    
    if(self)
    {
        _uploadedImages = [[NSMutableDictionary alloc] init];
        
        //NSOrderedSame
    }
    
    return self;
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


#pragma mark - Client

-(void)uploadImage:(UIImage*)image withTimestamp:(NSDate*)timestamp
{
    
    //Add timestamp to NSDictionary with url as pending.
//    [_uploadedImages setObject:IMAGE_PENDING forKey:timestamp];
    
    //Start uploading the image.
    [self startUploadingImage:image withTimestamp:timestamp];
    
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
                //                _imageStatus    = GLPImageStatusUploaded;
                //                _imageURL       = imageUrl;
                //
                //                if (_uploadContentBlock) _uploadContentBlock();
                
                // NSLog(@"Image url before notify: %@",imageUrl);
                
                finished = success;
                imageUrlSend = imageUrl;
                
                if(finished)
                {
//                    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPImageUploaded" object:nil userInfo:@{@"imageUrl":imageUrlSend}];
                    //Add image url
                    
                    [self updateImageToDictionary:imageUrl withTimestamp:timestamp];
                    
                    NSLog(@"Image url after notify: %@",imageUrlSend);
                    
                }
                
                
                
            } else {
                //                _imageStatus = GLPImageStatusFailed;
                
                NSLog(@"Error occured. Post image cannot be uploaded.");
#warning TODO: show user an error(?)
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
