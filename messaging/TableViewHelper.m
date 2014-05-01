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

+(UIView *)generateNoMoreLabelWithText:(NSString *)message withFrame:(CGRect)rect andTableView:(UITableView *)tableView
{
    UIView *nomatchesView = [[UIView alloc] initWithFrame:rect];
    nomatchesView.backgroundColor = [UIColor clearColor];
    
    UILabel *matchesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,320,320)];
    matchesLabel.font = [UIFont boldSystemFontOfSize:18];
    matchesLabel.numberOfLines = 1;
    matchesLabel.lineBreakMode = NSLineBreakByCharWrapping;
    matchesLabel.shadowColor = [UIColor lightTextColor];
    matchesLabel.textColor = [UIColor darkGrayColor];
    matchesLabel.shadowOffset = CGSizeMake(0, 1);
    matchesLabel.backgroundColor = [UIColor clearColor];
    matchesLabel.textAlignment =  NSTextAlignmentCenter;
    
    //Here is the text for when there are no results
    matchesLabel.text = message;
    
    
    nomatchesView.hidden = YES;
    [nomatchesView addSubview:matchesLabel];
    
    return nomatchesView;
}

@end
