//
//  GLPCategoryCell.h
//  Gleepost
//
//  Created by Silouanos on 22/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPCategory.h"

@interface GLPCategoryCell : UITableViewCell

extern NSString * const kGLPCategoryCell;

-(void)updateCategory:(GLPCategory*)category;


@end
