//
//  RegisterView.m
//  Gleepost
//
//  Created by Silouanos on 05/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "RegisterView.h"

@interface RegisterView ()

@property (weak, nonatomic) IBOutlet UITextField *first;
@property (weak, nonatomic) IBOutlet UITextField *second;
@property (strong, nonatomic) UIViewController <RegisterViewsProtocol> *delegate;

@end

@implementation RegisterView

-(id)initWithCoder:(NSCoder *)aDecoder withFirstTextField:(UITextField *)first andSecond:(UITextField *)second
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        
    }
    
    return self;
}

#pragma mark - Navigators

-(void)login
{
    [_delegate login];
}

#pragma mark - Accessors

-(NSString*)textFirstTextField
{
    return _first.text;
}


-(NSString*)textSecondTextField
{
    return _second.text;
}



#pragma mark - Modifiers

-(void)setTextToFirst:(NSString*)firstText andToSecond:(NSString*)secondText
{
    _first.text = firstText;
    _second.text = secondText;
}

-(void)becomeFirstFieldFirstResponder
{
    [_first becomeFirstResponder];

}

-(void)resignFieldResponder
{
    if([_first isFirstResponder])
    {
        [_first resignFirstResponder];
    }
    
    if([_second isFirstResponder])
    {
        [_second resignFirstResponder];
    }
}


-(void)setDelegate:(UIViewController<RegisterViewsProtocol> *)delegate
{
    _delegate = delegate;
}

-(void)setUpTextFields
{
    CGRect textFielFrame = self.first.frame;
    textFielFrame.size.height=40;
    [self.first setFrame:textFielFrame];
    [self.first setBackgroundColor:[UIColor whiteColor]];
    [self.first setTextColor:[UIColor blackColor]];
    self.first.layer.cornerRadius = 20;
    self.first.layer.borderColor = [UIColor colorWithRed:28.0f/255.0f green:208.0f/255.0f blue:208.f/255.0f alpha:1.0f].CGColor;
    self.first.layer.borderWidth = 3.0f;
    self.first.clipsToBounds = YES;
    
    
    textFielFrame = self.second.frame;
    textFielFrame.size.height=40;
    [self.second setFrame:textFielFrame];
    [self.second setBackgroundColor:[UIColor whiteColor]];
    [self.second setTextColor:[UIColor blackColor]];
    self.second.layer.cornerRadius = 20;
    self.second.layer.borderColor = [UIColor colorWithRed:28.0f/255.0f green:208.0f/255.0f blue:208.f/255.0f alpha:1.0f].CGColor;
    self.second.layer.borderWidth = 3.0f;
    self.second.clipsToBounds = YES;
    

    
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code

}


@end
