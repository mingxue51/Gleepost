//
//  FinalRegisterViewController.h
//  Gleepost
//
//  Created by Σιλουανός on 16/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDTakeController.h"

@interface FinalRegisterViewController : UIViewController  <UINavigationControllerDelegate, FDTakeDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *addImageView;
@property (strong, nonatomic) NSArray *eMailPass;

@end
