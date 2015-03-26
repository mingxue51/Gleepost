//
//  RegisterView.h
//  Gleepost
//
//  Created by Silouanos on 05/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebClientHelper.h"

typedef NS_ENUM(NSUInteger, ErrorMessage) {
    kTextFieldsEmpty,
    kEmailInvalid
};

@protocol RegisterViewsProtocol <NSObject>

@required

//-(void)navigateToNextView;
- (void)login;
- (void)loginSignUpError:(ErrorMessage)error;
- (void)signUp;
//-(void)firstAndLastName:(NSArray*)firstLastName;
//-(void)emailAndPass:(NSArray*)emailPass;
//-(void)pickImage:(id)sender;

@end

@interface RegisterView : UIView

@property (weak, nonatomic) UIViewController <RegisterViewsProtocol> *delegate;

- (NSString *)emailTextFieldText;
- (NSString *)passwordTextFieldText;
- (BOOL)areTextFieldsEmpty;
- (BOOL)isEmalValid;
- (void)startLoading;
- (void)stopLoading;
- (void)resignFieldResponder;
- (void)becomeEmailFieldFirstResponder;
- (void)becomePasswordFieldFirstResponder;

@end
