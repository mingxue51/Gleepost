//
//  RegisterView.h
//  Gleepost
//
//  Created by Silouanos on 05/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegisterViewsProtocol.h"
#import "WebClientHelper.h"

@interface RegisterView : UIView

- (NSString *)emailTextFieldText;
- (NSString *)passwordTextFieldText;
- (void)setDelegate:(UIViewController<RegisterViewsProtocol> *)delegate;
- (UIViewController<RegisterViewsProtocol> *)getDelegate;
- (void)login;
- (void)resignFieldResponder;
- (void)nextView;
- (void)becomeEmailFieldFirstResponder;

@end
