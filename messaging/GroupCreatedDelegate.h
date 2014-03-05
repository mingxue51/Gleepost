//
//  GroupCreatedDelegate.h
//  Gleepost
//
//  Created by Silouanos on 05/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPGroup.h"

@protocol GroupCreatedDelegate <NSObject>

@required

-(void)groupCreatedWithData:(GLPGroup *)group;

@end
