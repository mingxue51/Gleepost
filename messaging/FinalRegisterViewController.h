//
//  FinalRegisterViewController.h
//  Gleepost
//
//  Created by Σιλουανός on 16/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FinalRegisterViewController : UIViewController  <UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *addImageView;
@property (strong, nonatomic) NSArray *eMailPass;
@property (strong, nonatomic) NSArray *firstLastName;

@end
