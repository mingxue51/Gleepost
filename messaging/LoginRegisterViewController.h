//
//  LoginRegisterViewController.h
//  Gleepost
//
//  Created by Σιλουανός on 16/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegisterViewsProtocol.h"
#import "FDTakeController.h"

@interface LoginRegisterViewController : UIViewController <RegisterViewsProtocol, UINavigationControllerDelegate, FDTakeDelegate>

-(NSArray*)firstLastName;
-(NSArray*)emailPass;

@end
