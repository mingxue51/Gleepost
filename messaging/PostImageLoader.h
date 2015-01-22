//
//  PostImageLoader.h
//  Gleepost
//
//  Created by Silouanos on 22/01/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageObject : NSObject

- (id)initWithRemoteKey:(NSInteger)remoteKey andImageUrl:(NSString *)imageUrl;

@property (assign, nonatomic) NSInteger remoteKey;
@property (strong, nonatomic) NSString *imageUrl;

@end

@interface PostImageLoader : NSObject

/** The name of the NSNotification that we want to post once image is loaded or found. */
@property (strong, nonatomic, readonly) NSString *nsNotificationName;

- (void)addImageObjects:(NSArray *)imageObjects;
- (void)findImageWithUrl:(NSURL *)url callback:(void (^) (UIImage* image, BOOL found))callback;

@end
