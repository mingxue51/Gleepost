//
//  EventBarView.h
//  Gleepost
//
//  Created by Silouanos on 12/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventBarView : UIView

-(void)increaseBarLevel:(int)level;
-(void)decreaseBarLevel:(int)level;
-(void)increaseLevelWithNumberOfAttendees:(NSInteger)number andPopularity:(NSInteger)popularity;
-(void)decreaseLevelWithPopularity:(NSInteger)popularity;
-(void)setLevelWithPopularity:(int)popularity;
//-(void)setFixedHeight:(float)height;
//-(void)setCurrentHeight:(float)currentHeight;

@end
