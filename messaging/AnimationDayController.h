//
//  AnimationDayController.h
//  Gleepost
//
//  Created by Silouanos on 13/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnimationDayController : NSObject

+ (AnimationDayController *)sharedInstance;



-(NSString*)backgroundImage;
-(NSString*)forground;
-(NSString*)sunMoon;
-(NSString*)cloud1;
-(NSString*)cloud2;
-(NSString*)cloud3;
-(NSString*)pole;
-(NSString*)blades;
-(NSString*)balloon;
-(NSString*)blimp;


@end
