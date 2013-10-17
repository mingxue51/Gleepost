//
//  DatabaseManager.h
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatabaseManager : NSObject

+ (void)createDatabase;
+ (void)dropDatabase;

@end
