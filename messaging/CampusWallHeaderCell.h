//
//  CampusWallHeaderViewCell.h
//  Gleepost
//
//  Created by Silouanos on 23/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSScrollViewCell.h"
#import "GLPPost.h"

@interface CampusWallHeaderCell : VSScrollViewCell

extern const float CELL_HEIGHT;
extern const float CELL_WIDTH;

@property (strong, nonatomic) GLPPost *postData;

-(void)setData:(NSString*)str;
-(GLPPost *)getData;

@end
