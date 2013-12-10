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
- (IBAction)showNotifications:(id)sender {
}

-(void)updateNotificationsWithNumber:(int)notNumber
{
    
}

-(void)hideNotifications
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
