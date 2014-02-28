//
//  GLPCommonHelper.h
//  Gleepost
//
//  Created by Lukas on 2/12/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPApplicationHelper : NSObject

+ (NSString *)applicationStateToString:(UIApplicationState)applicationState;
+ (BOOL)isTheNextViewCampusWall:(NSArray *)viewControllersStuck;

@end
