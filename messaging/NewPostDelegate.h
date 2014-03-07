//
//  NewPostDelegate.h
//  Gleepost
//
//  Created by Σιλουανός on 6/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPPost.h"

@protocol NewPostDelegate <NSObject>

@required
-(void)reloadNewImagePostWithPost:(GLPPost *)post;

//@optional
//-(void)setNavigationBarName;
//-(void)setButtonsToNavigationBar;

@end
