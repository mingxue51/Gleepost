//
//  GLPMapViewAnnotation.m
//  Gleepost
//
//  Created by Σιλουανός on 2/9/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPMapViewAnnotation.h"

@implementation GLPMapViewAnnotation

-(id)initWithTitle:(NSString *) title AndCoordinate:(CLLocationCoordinate2D)coordinate
{
    
    self = [super init];
    
    if(self)
    {
        _title = title;
        _coordinate = coordinate;
    }

    return self;
    
}




@end
