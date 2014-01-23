//
//  CampusWallHeaderViewCell.m
//  Gleepost
//
//  Created by Silouanos on 23/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "CampusWallHeaderCell.h"
#import "ShapeFormatterHelper.h"

@interface CampusWallHeaderCell ()


@property (weak, nonatomic) IBOutlet UILabel *testLbl;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

@end


@implementation CampusWallHeaderCell

const float CELL_HEIGHT = 115;
const float CELL_WIDTH = 200;

-(id)initWithIdentifier:(NSString *)identifier
{
    
    self =  [super initWithIdentifier:identifier];
    
    if (self)
    {
        [self setFrame:CGRectMake(0, 0, 30, 50)];
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        [ShapeFormatterHelper setCornerRadiusWithView:self.contentView andValue:17.0f];
        
        [ShapeFormatterHelper setCornerRadiusWithView:self andValue:17.0f];
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        //Format the image.
        [ShapeFormatterHelper setRoundedView:self.profileImage toDiameter:self.profileImage.frame.size.height];
        
        self.profileImage.layer.borderWidth = 1.0;
        self.profileImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    
    
    return self;
}

-(void)setData:(NSString*)str
{
    [self setFrame:CGRectMake(0, 0, 30, 50)];

    [self.testLbl setText:str];
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
