//
//  CampusWallHeaderViewCell.m
//  Gleepost
//
//  Created by Silouanos on 23/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "CampusWallHeaderCell.h"

@interface CampusWallHeaderCell ()

@property (weak, nonatomic) IBOutlet UILabel *testLbl;


@end


@implementation CampusWallHeaderCell

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}


//-(id)initWithCoder:(NSCoder *)aDecoder
//{
//    
//}

-(id)initWithIdentifier:(NSString *)identifier
{
    
    self =  [super initWithIdentifier:identifier];
    
    if (self)
    {
        [self setFrame:CGRectMake(0, 0, 30, 50)];
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
