//
//  FakeNavigationBar.m
//  Gleepost
//
//  Created by Silouanos on 27/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "FakeNavigationBar.h"
#import "ShapeFormatterHelper.h"

@interface FakeNavigationBar ()

@property (weak, nonatomic) IBOutlet UIButton *eventsBtn;


@end

@implementation FakeNavigationBar

const CGFloat WIDHT_FAKE = 320.0f;
const CGFloat HEIGH_FAKE = 64.0f;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self setFrame:CGRectMake(0.0f, 0.0f, WIDHT_FAKE, HEIGH_FAKE)];
    }
    
    return self;
}


-(void)formatElements
{
    [ShapeFormatterHelper setCornerRadiusWithView:self.eventsBtn andValue:10];
}

- (IBAction)createNewPost:(id)sender
{    
    [self.delegate newPostButtonClick];
}

- (IBAction)showTags:(id)sender
{
    [self.delegate showCategories:sender];
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
