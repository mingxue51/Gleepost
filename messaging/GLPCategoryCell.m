//
//  GLPCategoryCell.m
//  Gleepost
//
//  Created by Silouanos on 22/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPCategoryCell.h"

@interface GLPCategoryCell ()

@property (weak, nonatomic) IBOutlet UILabel *categoryname;
@property (weak, nonatomic) IBOutlet UIImageView *categoryImage;

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
    [self.categoryImage setImage:image];
    
    [self.categoryname setText:category.tag];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
