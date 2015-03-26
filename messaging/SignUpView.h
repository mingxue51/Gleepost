//
//  SignUpView.h
//  Gleepost
//
//  Created by Silouanos on 26/03/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "RegisterView.h"

@interface SignUpView : RegisterView

- (NSString *)firstNameTextFieldText;
- (NSString *)lastNameTextFieldText;
- (void)becomeFirstNameFirstResponder;

@end
