//
//  TableViewHelper.h
//  Gleepost
//
//  Created by Silouanos on 28/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableViewHelper : NSObject

+(UITableViewCell *)generateCellWithMessage:(NSString *)message;
+(UITableViewCell *)generateEmptyCellWithHeight:(float)height;
+ (UIView *)generateHeaderViewWithTitle:(NSString *)title;

@end
