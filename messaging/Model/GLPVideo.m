//
//  GLPVideo.m
//  Gleepost
//
//  Created by Σιλουανός on 20/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPVideo.h"

@implementation GLPVideo

- (id)initWithPendingKey:(NSNumber *)pKey
{
    self = [super init];
    
    if(self)
    {        
        self.pendingKey = pKey.copy;
    }
    
    return self;
}

- (id)initWithUrl:(NSString *)url andThumbnailUrl:(NSString *)thumbnailUrl
{
    self = [super init];
    
    if(self)
    {
        self.url = url;
        self.thumbnailUrl = thumbnailUrl;
    }
    
    return self;
}

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    
    if(self)
    {
        self.path = path;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    GLPVideo *video = [[self class] allocWithZone:zone];
    video.url = [self.url copyWithZone:zone];
    video.thumbnailUrl = [self.thumbnailUrl copyWithZone:zone];
    video.path = [self.path copyWithZone:zone];
    video.pendingKey = [self.pendingKey copyWithZone:zone];
    return video;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Pending key: %@, Url: %@, Thumbnail: %@", _pendingKey, _url, _thumbnailUrl];
}



@end
