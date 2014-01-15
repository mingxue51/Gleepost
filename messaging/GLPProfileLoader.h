//
//  GLPProfileLoader.h
//  Gleepost
//
//  Created by Silouanos on 15/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPProfileLoader : NSObject

+ (GLPProfileLoader *)sharedInstance;

-(void)loadUserData;
-(NSArray*)userData;

@end
