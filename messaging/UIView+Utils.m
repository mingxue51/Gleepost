//
//  UIView+Utils.m
//  Gleepost
//
//  Created by Silouanos on 08/01/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "UIView+Utils.h"

@implementation UIView(Utils)

// retrieve an array containing all super views

-(NSArray *)getAllSuperviews
{
    NSMutableArray *superviews = [[NSMutableArray alloc] init];
    
    if(self.superview == nil) return nil;
    
    [superviews addObject:self.superview];
    [superviews addObjectsFromArray:[self.superview getAllSuperviews]];
    
    return superviews;
}

@end
