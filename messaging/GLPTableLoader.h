//
//  GLPTableLoader.h
//  Gleepost
//
//  Created by Lukas on 1/26/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPLoadingCell.h"

@interface GLPTableLoader : NSObject

@property (assign, nonatomic) BOOL isVisible;
@property (strong, nonatomic) GLPLoadingCell *loadingCell;

@end
