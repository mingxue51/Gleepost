//
//  GLPSearchBar.m
//  Gleepost
//
//  Created by Σιλουανός on 3/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPSearchBar.h"
#import "ShapeFormatterHelper.h"

@interface GLPSearchBar ()

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation GLPSearchBar

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self configureTextFieldView];
    
    [self configureTextField];
}

- (void)configureTextFieldView
{
    [ShapeFormatterHelper setRoundedView:_textField toDiameter:5.0];
    [self setLeftPaddingToTextField];
    
}

- (void)configureTextField
{
    [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)setLeftPaddingToTextField
{
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    _textField.leftView = paddingView;
    _textField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)setPlaceholderWithText:(NSString *)text
{
    [_textField setPlaceholder:text];
}

#pragma mark - Accessors

- (BOOL)isTextFieldFirstResponder
{
    return [_textField isFirstResponder];
}

- (BOOL)isTextFieldEmpty
{
    return (_textField.text.length == 0);
}

- (NSString *)currentText
{
    return _textField.text;
}

#pragma mark - Modifiers

- (void)resignTextFieldFirstResponder
{
    [_textField resignFirstResponder];
}

- (void)becomeTextFieldFirstResponder
{
    [_textField becomeFirstResponder];
}

- (void)startActivityIndicator
{
    [_activityIndicator startAnimating];
}

- (void)stopActivityIndicator
{
    [_activityIndicator stopAnimating];
}

- (void)addEmptyText
{
    [_textField setText:@""];
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if([_delegate respondsToSelector:@selector(glpSearchBarDidBeginEditing:)])
    {
        [_delegate glpSearchBarDidBeginEditing:textField];

    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if([_delegate respondsToSelector:@selector(glpSearchBarDidEndEditing:)])
    {
        [_delegate glpSearchBarDidEndEditing:textField];
    }
}

- (void)textFieldDidChange:(UITextField *)textField
{
    [_delegate textChanged:textField.text];
}

/*
//
 
 Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
