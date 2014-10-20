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
@optional
- (void)glpSearchBarDidBeginEditing:(UITextField *)textField;
- (void)glpSearchBarDidEndEditing:(UITextField *)textField;

@required
- (void)textChanged:(NSString *)text;

@end

@interface GLPSearchBar : UIView <UITextFieldDelegate>

@property (weak, nonatomic) UIViewController <GLPSearchBarDelegate> *delegate;

- (BOOL)isTextFieldFirstResponder;
- (BOOL)isTextFieldEmpty;
- (NSString *)currentText;
- (void)becomeTextFieldFirstResponder;
- (void)resignTextFieldFirstResponder;
- (void)setPlaceholderWithText:(NSString *)text;
- (void)startActivityIndicator;
- (void)stopActivityIndicator;
- (void)addEmptyText;

@end
