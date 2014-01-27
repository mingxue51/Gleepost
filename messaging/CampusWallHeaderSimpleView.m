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

@property (weak, nonatomic) IBOutlet UILabel *stanfordLbl;

@end

@implementation CampusWallHeaderSimpleView


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self setFrame:CGRectMake(0, 0, 320.0f, 280.0f)];
        
    }
    
    return self;
}

-(void)decreaseAlphaToBasicElements
{
    if(self.eventsBtn.alpha > 0.0)
    {
        self.eventsBtn.alpha -= 0.033;
        self.stanfordLbl.alpha -= 0.033;
        DDLogDebug(@"decrease: %f", self.eventsBtn.alpha);

    }

}

-(void)increaseAlphaToBasicElements
{
    if(self.eventsBtn.alpha < 1.0)
    {
        self.eventsBtn.alpha += 0.033;
        self.stanfordLbl.alpha += 0.033;
        
        DDLogDebug(@"increase: %f", self.eventsBtn.alpha);
    }
}

-(void)setAlphaToBasicElements:(CGFloat)alpha
{
    [self.eventsBtn setAlpha:alpha];
    [self.stanfordLbl setAlpha:alpha];
}

-(void)hideLoadingEvents
{
    
}

- (IBAction)showTags:(id)sender
{
    [self.delegate showCategories:sender];
}

- (IBAction)createNewPost:(id)sender
{
    [self.delegate newPostButtonClick];
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
