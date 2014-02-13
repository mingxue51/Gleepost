//
//  EventBarView.m
//  Gleepost
//
//  Created by Silouanos on 12/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "EventBarView.h"

@interface EventBarView ()

@property (weak, nonatomic) IBOutlet UIImageView *bar1;
@property (weak, nonatomic) IBOutlet UIImageView *bar2;
@property (weak, nonatomic) IBOutlet UIImageView *bar3;
@property (weak, nonatomic) IBOutlet UIImageView *bar4;



@end

@implementation EventBarView


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
    }
    
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initialiseElements];
}

-(void)initialiseElements
{
    _bar1.tag = 1;
    _bar2.tag = 2;
    _bar3.tag = 3;
    _bar4.tag = 4;
}


-(void)increaseBarLevel:(int)level
{
    [self resetBars];

    
    if(level > 4 || level < 1)
    {
        return;
    }
    
    
    for(int i = 1; i<=level; ++i)
    {
        [self activateBarWithTag:i];
    }
}

-(void)decreaseBarLevel:(int)level
{
    for(int i = level; i>=1; --i)
    {
        [self deactivateBarWithTag:i];
    }
}

-(void)resetBars
{
    for(int i = 1; i<=4; ++i)
    {
        [self deactivateBarWithTag:i];
    }
}

-(void)deactivateBarWithTag:(int)tag
{
    UIImageView *imgView = [self.subviews objectAtIndex:tag-1];
    
    [imgView setImage:[UIImage imageNamed:@"bar1"]];
}

-(void)activateBarWithTag:(int)tag
{
    UIImageView *imgView = [self.subviews objectAtIndex:tag-1];
    
    [imgView setImage:[UIImage imageNamed:@"bar1_selected"]];
}

-(void)decreaseBar
{
    
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
