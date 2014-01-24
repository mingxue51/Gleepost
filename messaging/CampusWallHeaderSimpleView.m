//
//  CampusWallHeaderTableView.m
//  Gleepost
//
//  Created by Silouanos on 22/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "CampusWallHeaderSimpleView.h"

@interface CampusWallHeaderSimpleView ()

@property (weak, nonatomic) IBOutlet UIButton *eventsBtn;


@end

@implementation CampusWallHeaderSimpleView


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self setFrame:CGRectMake(0, 0, 320.0f, 280.0f)];
        
        DDLogDebug(@"SUBVIEWS: %@",[self subviews]);
    }
    
    return self;
}

-(void)hideLoadingEvents
{
}

- (IBAction)showCategories:(id)sender
{
    DDLogDebug(@"showCategories");
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
