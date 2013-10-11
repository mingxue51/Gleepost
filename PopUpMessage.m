//
//  PopUpMessage.m
//  Gleepost
//
//  Created by Σιλουανός on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "PopUpMessage.h"

@implementation PopUpMessage

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(160, 160, 70, 70)];
    if (self)
    {
        [self setBackgroundColor:[UIColor blackColor]];
        
        
        UITextView* titleTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
        [titleTextView setTextColor:[UIColor blackColor]];
        [titleTextView setText:self.title];
        
        UITextView* messageTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 30, 70, 30)];
        [messageTextView setTextColor:[UIColor blackColor]];
        [titleTextView setText:self.message];
        
        [self addSubview:titleTextView];
        
        [self addSubview:messageTextView];
        
        //TODO: To be continued.
        //Remember to take the mobile's screen's size .
    }
    return self;
}

+(PopUpMessage*) showMessageWithSuperView: (UIView*) superView
{
    /**
     MBProgressHUD *hud = [[self alloc] initWithView:view];
     [view addSubview:hud];
     [hud show:animated];
     return MB_AUTORELEASE(hud);
     
     */
    
    
    
    PopUpMessage *pop = [[PopUpMessage alloc] initWithFrame:CGRectMake(160, 160, 70, 70)];
    pop.title = @"Loading.";
    pop.message = @"Test Message.";
    [superView addSubview:pop];
    [pop addSuperView:superView];
    
    [pop fireMessage];
    
    return pop;

}

-(void)addSuperView: (UIView*) superView
{
    [superView addSubview:self];
}

-(void) fireMessage
{
    NSTimer *timer1 = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
    [timer1 fire];
}

-(void) dismiss
{
    self.hidden = YES;
    [super removeFromSuperview];
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
