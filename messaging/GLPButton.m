//
//  GLPButton.m
//  Gleepost
//
//  Created by Σιλουανός on 12/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPButton.h"

@interface GLPButton ()

@property (assign, nonatomic) GLPNavButtonType buttonKind;

@end

@implementation GLPButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _buttonKind = kText;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        _buttonKind = kText;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame andKind:(GLPNavButtonType)kind
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        _buttonKind = kind;
    }
    
    return self;
}


- (UIEdgeInsets)alignmentRectInsets
{
    UIEdgeInsets insets;
    
    DDLogDebug(@"alignmentRectInsets");
    
    //If tag = 0 then it means that the current button is the left.
    //else the current button is the right.
    
    if(_buttonKind == kText)
    {
        
        //TODO: Do those dynamically.
        
        if(self.tag == 0)
        {
            insets = UIEdgeInsetsMake(0, 5.0f, 0, 0);
        }
        else
        {
            insets = UIEdgeInsetsMake(0, 0, 0, 20.0f);
        }
    }
    else if (_buttonKind == kLeftImage)
    {
        CGRectSetX(self, 10);
    }
    else if (_buttonKind == kRightImage)
    {
        //x + width = 310
        
       // CGRectSetX(self, 310 - self.frame.size.width);
        
        [self setFrame:CGRectMake(310 - self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
        
        DDLogDebug(@"Dimensions: %f : %f", self.frame.size.width, self.frame.origin.x);

    }
    

    
    return insets;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
