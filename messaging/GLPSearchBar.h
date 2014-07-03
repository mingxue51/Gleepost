//
//  GLPSearchBar.h
//  Gleepost
//
//  Created by Σιλουανός on 3/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GLPSearchBarDelegate <NSObject>

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
- (void)textFieldDidBeginEditing:(UITextField *)textField;
- (void)textFieldDidEndEditing:(UITextField *)textField;
- (void)typedText:(NSString *)text;

@end

@interface GLPSearchBar : UIView <UITextFieldDelegate>

@property (weak, nonatomic) UIViewController <GLPSearchBarDelegate> *delegate;

- (BOOL)isTextFieldFirstResponder;
- (void)setPlaceholderWithText:(NSString *)text;
- (void)resignTextFieldFirstResponder;
@end
