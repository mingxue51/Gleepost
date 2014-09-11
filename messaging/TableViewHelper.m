//
//  TableViewHelper.m
//  Gleepost
//
//  Created by Silouanos on 28/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "TableViewHelper.h"
#import "ShapeFormatterHelper.h"
#import "AppearanceHelper.h"

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

/**
 Default Gleepost header.
 
 @param title the title of the header.
 
 @return the header view.
 
 */
+ (UIView *)generateHeaderViewWithTitle:(NSString *)title
{
    UIView *titleViewSection = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 30.0)];
    
    [titleViewSection setBackgroundColor:[AppearanceHelper lightGrayGleepostColour]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 30.0)];
    
    [titleLabel setText:title];
    
    [titleLabel setFont:[UIFont fontWithName:GLP_CAMPUS_WALL_TITLE_FONT size:12.0]];
    
    [titleLabel setTextColor:[AppearanceHelper blueGleepostColour]];
    
    [titleViewSection addSubview:titleLabel];
    
    //Create the lines below and above the view.
    
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 1.0)];
    
    [lineImageView setBackgroundColor:[AppearanceHelper mediumGrayGleepostColour]];
    
//    [titleViewSection addSubview:lineImageView];
    
    lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 29.0, 320.0, 1.0)];
    
    [lineImageView setBackgroundColor:[AppearanceHelper mediumGrayGleepostColour]];
        
    [titleViewSection addSubview:lineImageView];
    
    
    
    return titleViewSection;
}

+ (UIView *)generateEmptyHeader
{
    UIView *view = [[UIView alloc] init];
    
    [view setBackgroundColor:[UIColor clearColor]];
    
    return view;
}

@end
