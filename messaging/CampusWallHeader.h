//
//  CampusWallHeader.h
//  Gleepost
//
//  Created by Silouanos on 22/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSScrollView.h"
#import "VSScrollViewCell.h"

@interface CampusWallHeader : VSScrollView <VSScrollerDatasource,VSScrollerDelegate>

-(void)clearViews;

@end
