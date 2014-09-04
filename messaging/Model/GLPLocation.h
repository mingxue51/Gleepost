//
//  GLPLocation.h
//  Gleepost
//
//  Created by Σιλουανός on 1/9/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPLocation : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *address;
@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;
@property (assign, nonatomic) NSInteger distance;

- (id)initWithName:(NSString *)name address:(NSString *)address latitude:(double)lat longitude:(double)lng andDistance:(NSInteger)distance;
- (id)initWithName:(NSString *)name address:(NSString *)address latitude:(double)lat longitude:(double)lng;

@end
