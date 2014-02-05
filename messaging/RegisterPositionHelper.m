//
//  RegisterPositionHelper.m
//  Gleepost
//
//  Created by Silouanos on 05/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "RegisterPositionHelper.h"

@implementation RegisterPositionHelper

//const float bigScreenHeight = 568.0;
//const float smallScreenHeight = 480.0;
const int SMALL_MIDDLE_SCREEN_Y = 140;
const int BIG_MIDDLE_SCREEN_Y = 165;

const int SMALL_BOTTOM_SCREEN_Y = 226;
const int BIG_BOTTOM_SCREEN_Y = 314;

+(int)middleScreenY
{
    return ([RegisterPositionHelper screenSize].size.height == 568.0)? BIG_MIDDLE_SCREEN_Y : SMALL_MIDDLE_SCREEN_Y;
}

+(int)bottomScreenY
{
    return ([RegisterPositionHelper screenSize].size.height == 568.0)? BIG_BOTTOM_SCREEN_Y : SMALL_BOTTOM_SCREEN_Y;
}

+(CGRect) screenSize
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    return screenRect;
}

@end
