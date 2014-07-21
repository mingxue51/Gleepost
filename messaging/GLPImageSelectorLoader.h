//
//  GLPImageSelectorLoader.h
//  Gleepost
//
//  Created by Σιλουανός on 17/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GLPImageSelectorLoaderDelegate <NSObject>

@required
- (void)imagesLoaded;

@end

@interface GLPImageSelectorLoader : NSObject

@property (weak, nonatomic) UIViewController <GLPImageSelectorLoaderDelegate> *delegate;

- (UIImage *)thumbnailAtIndex:(NSInteger)index;
- (UIImage *)realImageAtIndex:(NSInteger)index;
- (NSInteger)numberOfImages;

@end
