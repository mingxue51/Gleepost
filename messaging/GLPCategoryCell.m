//
//  GLPCategoryCell.m
//  Gleepost
//
//  Created by Silouanos on 22/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPCategoryCell.h"

@interface GLPCategoryCell ()

@property (weak, nonatomic) IBOutlet UIImageView *categoryImage;
@property (weak, nonatomic) IBOutlet UILabel *categoryNameLbl;

@end

@implementation GLPCategoryCell

NSString * const kGLPCategoryCell = @"CategoryCell";


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        
    }
    
    return self;
}



-(void)updateCategory:(GLPCategory*)category withImage:(UIImage*)image
{
    if(category.uiSelected)
    {
        [self.categoryNameLbl setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0]];
    }
    else
    {
        [self.categoryNameLbl setFont:[UIFont fontWithName:@"HelveticaNeue" size:17.0]];
    }
    
    [self.categoryImage setImage:image];
    
    [self.categoryNameLbl setText:category.name];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
