//
//  GLPWalkthoughDataViewController.h
//  Gleepost
//
//  Created by Silouanos on 02/06/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GLPWalkthoughDataViewController : UIViewController

@property (strong, nonatomic) id dataObject;
@property (weak, nonatomic) IBOutlet UILabel *dataLabel;

-(NSInteger)currentViewTag;

@end
