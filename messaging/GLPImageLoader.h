//
//  GLPImageLoader.h
//  Gleepost
//
//  Created by Silouanos on 10/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPImageLoader : NSObject

@property (strong, nonatomic) NSMutableDictionary *loadingImages;
@property (strong, nonatomic) NSMutableArray *imagesNotStarted;
@property (assign, nonatomic) BOOL networkAvailable;

-(void)startConsume;

@end
