//
//  CampusWallHeaderTableView.h
//  Gleepost
//
//  Created by Silouanos on 22/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPTimelineViewController.h"

@interface CampusWallHeaderSimpleView : UITableViewHeaderFooterView

@property (weak, nonatomic) GLPTimelineViewController *delegate;

-(void)setAlphaToBasicElements:(CGFloat)alpha;
-(void)formatElements;
-(void)groupFeedEnabled;
-(void)groupFeedDisabled;

@end
