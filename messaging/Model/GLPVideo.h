//
//  GLPVideo.h
//  Gleepost
//
//  Created by Σιλουανός on 20/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPVideo : NSObject

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *thumbnailUrl;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSNumber *pendingKey;

- (id)initWithPendingKey:(NSNumber *)pendingKey;
- (id)initWithPath:(NSString *)path;
- (id)initWithUrl:(NSString *)url andThumbnailUrl:(NSString *)thumbnailUrl;
- (id)copyWithZone:(NSZone *)zone;

@end
