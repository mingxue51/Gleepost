//
//  GLPEntity.h
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPEntity : NSObject

@property (assign, nonatomic) NSInteger key;
@property (assign, nonatomic) NSInteger remoteKey;

- (BOOL) isEqualToEntity:(GLPEntity *)entity;

@end
