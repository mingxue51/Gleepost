//
//  RegisterView.h
//  Gleepost
//
//  Created by Silouanos on 05/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegisterViewsProtocol.h"

@interface RegisterView : UIView

//-(id)initWithCoder:(NSCoder *)aDecoder withFirstTextField:(UITextField *)first andSecond:(UITextField *)second;

-(void)setUpTextFields;
-(NSString*)textFirstTextField;
-(NSString*)textSecondTextField;
-(void)setDelegate:(UIViewController<RegisterViewsProtocol> *)delegate;
-(void)login;
-(void)becomeFirstFieldFirstResponder;
-(void)resignFieldResponder;
-(void)setTextToFirst:(NSString*)firstText andToSecond:(NSString*)secondText;

@end
