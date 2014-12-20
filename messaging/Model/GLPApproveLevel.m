//
//  GLPApproveLevel.m
//  Gleepost
//
//  Created by Silouanos on 21/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPApproveLevel.h"

@implementation GLPApproveLevel

- (id)initWithApproveLevel:(NSUInteger)approveLevel
{
    self = [super init];
    
    if(self)
    {
        self.approveLevel = approveLevel;
    }
    
    return self;
}

//- (void)configureLevelWithIntegerValue:(NSUInteger)approveLevelInt
//{
//    switch (approveLevelInt) {
//        case 0:
//            self.approveLevel =
//            break;
//            
//        default:
//            break;
//    }
//}

@end
