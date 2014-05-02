//
//  ThermometerCircleView.h
//  Gleepost
//
//  Created by Σιλουανός on 2/5/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventBarView.h"

@interface ThermometerCircleView : UIImageView

-(id)initWithSuperView:(EventBarView *)superView;
-(void)animateCircleWithHeight:(float)height andY:(float)y;

@end
