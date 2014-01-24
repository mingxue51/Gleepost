//
//  CampusWallHeaderTableView.h
//  Gleepost
//
//  Created by Silouanos on 22/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPTimelineViewController.h"

@interface CampusWallHeaderSimpleView : UIView

@property (weak, nonatomic) GLPTimelineViewController *delegate;

-(void)hideLoadingEvents;

@end
