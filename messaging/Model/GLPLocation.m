//
//  GLPLocation.m
//  Gleepost
//
//  Created by Σιλουανός on 1/9/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPLocation.h"

@implementation GLPLocation

- (id)initWithName:(NSString *)name address:(NSString *)address latitude:(double)lat longitude:(double)lng andDistance:(NSInteger)distance
{
    self = [super init];
    
    if(self)
    {
        _name = name;
        _address = address;
        _latitude = lat;
        _longitude = lng;
        _distance = distance;
    }
    
    return self;
}

- (id)initWithName:(NSString *)name address:(NSString *)address latitude:(double)lat longitude:(double)lng
{
    self = [super init];
    
    if(self)
    {
        _name = name;
        _address = address;
        _latitude = lat;
        _longitude = lng;
        _distance = 0;
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Name: %@, Address: %@, Lat: %f, Lng: %f, Distance: %ld", _name, _address, _latitude, _longitude, (long)_distance];
}

@end
