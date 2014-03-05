//
//  NewGroupViewController.h
//  Gleepost
//
//  Created by Silouanos on 05/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDTakeController.h"
#import "GroupCreatedDelegate.h"

@interface NewGroupViewController : UIViewController <FDTakeDelegate>

-(void)setDelegate:(UIViewController<GroupCreatedDelegate> *)delegate;

@end
