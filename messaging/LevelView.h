//
//  LevelView.h
//  Gleepost
//
//  Created by Σιλουανός on 2/5/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventBarView.h"

@interface LevelView : UIView

-(void)configureThermometer;
-(void)configureThermometerShadowWithSuperView:(EventBarView *)superView;
-(void)animateLevelViewDown;
-(void)animateLevelViewUp;
-(BOOL)isCurrentHeightZero;
-(void)initialiseHeightWithPopularity:(NSInteger)popularity;
-(void)animateLevelViewUpWithPopularity:(NSInteger)popularity andDelay:(BOOL)delay;
-(void)animateLevelViewDownWithPopularity:(NSInteger)popularity;

@end
