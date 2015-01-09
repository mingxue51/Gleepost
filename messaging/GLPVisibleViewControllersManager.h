//
//  GLPVisibleViewControllersManager.h
//  Gleepost
//
//  Created by Silouanos on 09/01/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPVisibleViewControllersManager : NSObject

+ (GLPVisibleViewControllersManager *)sharedInstance;
- (BOOL)isCampusWallVisible;
- (void)campusWallVisible:(BOOL)visible;

@end
