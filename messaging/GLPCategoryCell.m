//
//  GLPCategoryCell.m
//  Gleepost
//
//  Created by Silouanos on 22/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPCategoryCell.h"
#import "GLPiOSSupportHelper.h"

@interface GLPCategoryCell ()

@property (weak, nonatomic) IBOutlet UIImageView *categoryImage;
@property (weak, nonatomic) IBOutlet UILabel *categoryNameLbl;

@end

@implementation GLPCategoryCell

NSString * const kGLPCategoryCell = @"CategoryCell";
CGFloat const CellMargin = 14.0;
CGFloat const BottomPadding = 12.0;
CGFloat const Multiplication = 0.1966;

- (void)updateCategory:(GLPCategory*)category withImage:(UIImage*)image
{
    if(category.uiSelected)
    {
        [self.categoryNameLbl setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0]];
    }
    else
    {
        [self.categoryNameLbl setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0]];
    }
    
    [self.categoryImage setImage:image];
    
    [self.categoryNameLbl setText:category.name];
}

+ (CGFloat)height
{
//    DDLogDebug(@"GLPCategoryCell : height %f - screen width %f", ([GLPiOSSupportHelper screenWidth] - CellMargin * 2), [GLPiOSSupportHelper screenWidth]);
    
    return ([GLPiOSSupportHelper screenWidth] - CellMargin * 2) * Multiplication + BottomPadding;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
