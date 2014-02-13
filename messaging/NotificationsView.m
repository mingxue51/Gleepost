//
//  NotificationsView.m
//  Gleepost
//
//  Created by Silouanos on 10/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "NotificationsView.h"

@interface NotificationsView ()

@property (weak, nonatomic) IBOutlet UIImageView *notImageView;

@property (weak, nonatomic) IBOutlet UILabel *notLabel;

@property (readonly, nonatomic) GLPProfileViewController *delegate;


@end

@implementation NotificationsView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        self.frame = CGRectMake(0, 0, 30, 30);
    }
    
    return self;
}

-(void)setDelegate:(GLPProfileViewController *)delegate
{
    _delegate = delegate;
}

- (IBAction)showNotifications:(id)sender
{
//    [_delegate popUpNotifications:sender];
}

-(void)updateNotificationsWithNumber:(int)notNumber
{
    [self.notImageView setHidden:NO];
    
    [self.notLabel setHidden:NO];
    
    [self.notLabel setText:[NSString stringWithFormat:@"%d",notNumber]];
}

-(void)hideNotifications
{
    [self.notImageView setHidden:YES];
    
    [self.notLabel setHidden:YES];
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
