//
//  EmptyMessage.m
//  Gleepost
//
//  Created by Silouanos on 06/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  By using this class developer are able to present an information message when table view is empty.
//  This class is encouraged to be used in situations like when there are no new notifications or posts.
//  Examples in GLPProfileViewController.
//

#import "EmptyMessage.h"

@implementation EmptyMessage

-(id)initWithText:(NSString *)text withPosition:(EmptyMessagePosition)position andTableView:(UITableView *)tableView
{
    self = [super init];
    
    if(self)
    {
        [self initialiseViewWithPosition:position];
        [self generateEmptyMessageViewWithText:text];
        [tableView insertSubview:_emptyMessageView belowSubview:tableView];
    }
    
    return self;
}

-(void)initialiseViewWithPosition:(EmptyMessagePosition)position
{
    float yPosition = 0.0f;
    
    switch (position)
    {
        case EmptyMessagePositionTop:
            
            break;
            
        case EmptyMessagePositionCenter:
            yPosition = 200.0f;
            break;
        case EmptyMessagePositionBottom:
            yPosition = 320.0f;
            break;
            
        case EmptyMessagePositionFurtherBottom:
            yPosition = 400.0f;
            break;
            
        default:
            break;
    }
    
    self.emptyMessageView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, yPosition, 320.0f, 50.0f)];

    
    
}

-(void)generateEmptyMessageViewWithText:(NSString *)text
{
    _emptyMessageView.backgroundColor = [UIColor clearColor];
    
    UILabel *matchesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 50.0f)];
    matchesLabel.font = [UIFont boldSystemFontOfSize:18];
    matchesLabel.numberOfLines = 1;
    matchesLabel.lineBreakMode = NSLineBreakByCharWrapping;
    matchesLabel.shadowColor = [UIColor lightTextColor];
    matchesLabel.textColor = [UIColor darkGrayColor];
    matchesLabel.shadowOffset = CGSizeMake(0, 1);
    matchesLabel.backgroundColor = [UIColor clearColor];
    matchesLabel.textAlignment =  NSTextAlignmentCenter;
    
    //Here is the text for when there are no results
    matchesLabel.text = text;
    
    _emptyMessageView.hidden = YES;
    [_emptyMessageView addSubview:matchesLabel];
    
}

#pragma mark - Modifiers

-(void)hideEmptyMessageView
{
    [_emptyMessageView setHidden:YES];
}

-(void)showEmptyMessageView
{
    [_emptyMessageView setHidden:NO];
}

@end
