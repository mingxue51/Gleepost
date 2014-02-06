//
//  SignUpThreeView.m
//  Gleepost
//
//  Created by Σιλουανός on 6/2/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "SignUpThreeView.h"

@implementation SignUpThreeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)awakeFromNib
{
    [self becomeFirstFieldFirstResponder];
}

- (IBAction)goNext:(id)sender
{
    
    if([self areTheDetailsValid])
    {
        
        [[super getDelegate] firstAndLastName:[super firstAndSecondFields]];
        
        [super nextView];
    }
    else
    {
        [WebClientHelper showStandardErrorWithTitle:@"Please Check your details" andContent:@"Please check your details if are valid."];
        
    }
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self setUpTextFields];
    
}

@end
