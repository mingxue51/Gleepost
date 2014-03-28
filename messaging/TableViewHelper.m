//
//  TableViewHelper.m
//  Gleepost
//
//  Created by Silouanos on 28/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "TableViewHelper.h"

@implementation TableViewHelper

+(UITableViewCell *)generateCellWithMessage:(NSString *)message
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = message;
    cell.textLabel.font = [UIFont fontWithName:GLP_APP_FONT size:12.0f];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [UIColor grayColor];
    cell.userInteractionEnabled = NO;
    return cell;
}

+(UITableViewCell *)generateEmptyCellWithHeight:(float)height
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    CGRectAddH(cell, height);
    cell.userInteractionEnabled = NO;
    return cell;
}

@end
