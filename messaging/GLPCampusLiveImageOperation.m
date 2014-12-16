//
//  GLPCampusLiveImageOperation.m
//  Gleepost
//
//  Created by Silouanos on 16/12/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPCampusLiveImageOperation.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface GLPCampusLiveImageOperation ()

@property (strong, nonatomic) NSString *imageUrl;
@property (assign, nonatomic) NSInteger remoteKey;

@end

@implementation GLPCampusLiveImageOperation

- (id)initWithImageUrl:(NSString *)imageUrl andRemoteKey:(NSInteger)remoteKey
{
    self = [super init];
    
    if(self)
    {
        _imageUrl = imageUrl;
        _remoteKey = remoteKey;
    }
    
    return self;
}


- (void)main {
    @autoreleasepool {
        DDLogInfo(@"GLPCampusLiveImageOperation : operation started %@ : %ld", _imageUrl, (long)_remoteKey);
        
        [self startLoadingImage];
    }
}

- (void)startLoadingImage
{
    UIImage *img = [self loadImage];
    [[SDImageCache sharedImageCache] storeImage:img forKey:_imageUrl];
    
    if(!img)
    {
        DDLogError(@"GLPCampusLiveImageOperation : Connection lost retry with url %@", _imageUrl);
        return;
    }
    
    [self.delegate operationFinishedWithImage:img andRemoteKey:_remoteKey];
}

- (UIImage *)loadImage
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_imageUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:600.0];
    
    NSURLResponse *response = [NSURLResponse new];
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    UIImage *img = [[UIImage alloc] initWithData:data];
    
    return img;
}

@end
