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


@end

@implementation GLPSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self configureTextFieldView];
}

- (void)configureTextFieldView
{
    [ShapeFormatterHelper setRoundedView:_textField toDiameter:5.0];
    [self setLeftPaddingToTextField];
    
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

#pragma mark - Modifiers

- (void)resignTextFieldFirstResponder
{
    [_textField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    [_delegate textFieldShouldBeginEditing:textField];
//    
//    return YES;
//}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [_delegate textFieldDidBeginEditing:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [_delegate textFieldDidEndEditing:textField];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [_delegate typedText:string];
    
    return YES;
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
