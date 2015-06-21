//
//  GLPBottomTextView.m
//  Gleepost
//
//  Created by Silouanos on 13/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  Bottom text view, with growing text view and prompted button, that lets user to add text and submit it.
//  Where is used: Bottom comment view in campus live.

#import "GLPBottomTextView.h"
#import "HPGrowingTextView.h"
#import "UIColor+GLPAdditions.h"
#import "UIView+GLPDesign.h"
#import "ShapeFormatterHelper.h"

@interface GLPBottomTextView () <HPGrowingTextViewDelegate>

@property (strong, nonatomic) IBOutlet HPGrowingTextView *growingTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeight;

@end

@implementation GLPBottomTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self configureGrowingTextView];
    
}

#pragma mark - Configuration

- (void)configureGrowingTextView
{
    self.growingTextView.isScrollable = NO;
    self.growingTextView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    self.growingTextView.minNumberOfLines = 1;
    self.growingTextView.maxNumberOfLines = 4;
    self.growingTextView.returnKeyType = UIReturnKeyDefault;
    self.growingTextView.font = [UIFont systemFontOfSize:15.0f];
    self.growingTextView.delegate = self;
    self.growingTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    self.growingTextView.backgroundColor = [UIColor whiteColor];
    self.growingTextView.placeholder = @"Write a comment...";
    self.growingTextView.layer.cornerRadius = 4;
    
    [ShapeFormatterHelper setBorderToView:self.growingTextView withColour:[UIColor colorWithR:240.0 withG:240.0 andB:240.0] andWidth:1.0];
    
//    [self.growingTextView setGleepostStyleTopBorder];
    
    self.alpha = 0.0;
}

#pragma mark - Keyboard

- (void)becomeTextViewFirstResponder
{
    [self.growingTextView becomeFirstResponder];
}

- (void)resignTextViewFirstResponder
{
    [self.growingTextView resignFirstResponder];
}

- (BOOL)isTextViewFirstResponder
{
    return [self.growingTextView isFirstResponder];
}

#pragma mark - Modifiers

/**
 Hides the view using a fade out animation.
 */
- (void)hide
{
    if(self.alpha == 0.0)
    {
        return;
    }
    
    if(![self.growingTextView.text isEqualToString:@""])
    {
        return;
    }
    
    [self hideKeyboardFromTextViewIfNeeded];
    
    [UIView animateWithDuration:0.6 animations:^{
        
        self.alpha = 0.0;
        
    } completion:^(BOOL finished) {
       
//        self.hidden = YES;
        
    }];
}

/**
 Shows the view using a fade in animation.
 */
- (void)show
{
    if(self.alpha == 1.0)
    {
        return;
    }
    
    self.alpha = 0.0;
//    self.hidden = NO;
    
    [UIView animateWithDuration:0.6 animations:^{
        
        self.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
        
    }];
}

- (void)hideKeyboardFromTextViewIfNeeded
{
    if([self isTextViewFirstResponder])
    {
        [self resignTextViewFirstResponder];
    }
}

#pragma mark - HPGrowingTextViewDelegate

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    CGFloat diff = (growingTextView.frame.size.height - height);
     self.viewHeight.constant -= diff;
}

#pragma mark - Selectors

- (IBAction)buttonTouched:(id)sender
{
    if([self.growingTextView.text isEqualToString:@""])
    {
        return;
    }
    
    [self.delegate userHitsSendButtonWithText:self.growingTextView.text];
    self.growingTextView.text = @"";
//    [self hide];
}

@end
