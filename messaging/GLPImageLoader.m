//
//  GLPImageLoader.m
//  Gleepost
//
//  Created by Silouanos on 10/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This class is a superclass of the Image Loaders like GLPPostImageLoader and GLPGroupImageLoader.


#import "GLPImageLoader.h"


@implementation GLPImageLoader

- (id)init
{
    self = [super init];
    
    if(self)
    {
        _loadingImages = [[NSMutableDictionary alloc] init];
        _imagesNotStarted = [[NSMutableArray alloc] init];
        
        self.networkAvailable = YES;
    }
    
    return self;
}

@end
