//
//  GLPImageOperation.m
//  Gleepost
//
//  Created by Silouanos on 19/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPImageOperation.h"
#import "NSNotificationCenter+Utils.h"
#import "ImageFormatterHelper.h"
#import "WebClient.h"
#include <semaphore.h>

@interface GLPImageOperation ()

@property (nonatomic, strong) UIImage *image;
@end

@implementation GLPImageOperation

@synthesize image = _image;

- (void)main {
    
    @autoreleasepool
    {

        
        NSLog(@"GLPImageOperation");
        
        
        [self startUploadingImage];
        
//        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPImageUploaded" object:nil userInfo:@{@"remoteKey":@"TEST"}];

        
    }
}

-(id)initWithImage:(UIImage*)image
{
    self = [super init];
    
    if(self)
    {
        _image = image;
    }
    
    
    return self;
}




#pragma mark - Operational methods

- (void)startUploadingImage
{
//    _postImage = image;
//    _imageStatus = GLPImageStatusUploading;
    
    __block NSData *data;
    
    //NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        UIImage *resizedImage = [ImageFormatterHelper imageWithImage:_image scaledToHeight:640];
        data = UIImagePNGRepresentation(resizedImage);
    //}];
    
    //[operation setCompletionBlock:^{
        [self uploadResizedImageWithImageData:data];
        
    //}];
    
//    [[[NSOperationQueue alloc] init] addOperation:operation];
}

- (void)uploadResizedImageWithImageData:(NSData *)imageData {
    
    __block BOOL finished = NO;
    __block NSString *imageUrlSend = nil;
    
    //Lock.
    
    if (imageData) {
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
                    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPImageUploaded" object:nil userInfo:@{@"imageUrl":imageUrlSend}];
                    NSLog(@"Image url after notify: %@",imageUrlSend);

                }


                
            } else {
//                _imageStatus = GLPImageStatusFailed;
                
                NSLog(@"Error occured. Post image cannot be uploaded.");
            }
        }];
        
        //Unlock.


    }
}
@end
