//
//  CLFakeNavigationBarView.m
//  Gleepost
//
//  Created by Silouanos on 04/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "CampusLiveFakeNavigationBarView.h"
#import "GLPThemeManager.h"

@interface CampusLiveFakeNavigationBarView ()

@property (weak, nonatomic) IBOutlet UIImageView *topImageView;

@end

@implementation CampusLiveFakeNavigationBarView


- (instancetype)init
{
    self = [super initWithNibName:@"CampusLiveFakeNavigationBarView"];
    
    if (self)
    {
        [self configureTopImageView];
    }
    return self;
}

- (void)configureTopImageView
{
    CampusLiveFakeNavigationBarView *externalView = (CampusLiveFakeNavigationBarView *)self.externalView;

    externalView.topImageView.image = [[GLPThemeManager sharedInstance] topItemColouredImage:externalView.topImageView.image];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
