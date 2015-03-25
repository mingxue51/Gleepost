//
//  RegisterView.h
//  Gleepost
//
//  Created by Silouanos on 05/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebClientHelper.h"

@protocol RegisterViewsProtocol <NSObject>

@required

//-(void)navigateToNextView;
- (void)login;
//-(void)firstAndLastName:(NSArray*)firstLastName;
//-(void)emailAndPass:(NSArray*)emailPass;
//-(void)pickImage:(id)sender;

@end

@interface RegisterView : UIView

- (NSString *)emailTextFieldText;
- (NSString *)passwordTextFieldText;
- (void)setDelegate:(UIViewController<RegisterViewsProtocol> *)delegate;
- (UIViewController<RegisterViewsProtocol> *)getDelegate;
- (void)login;
- (void)resignFieldResponder;
- (void)becomeEmailFieldFirstResponder;

@end
