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
#import "GLPiOSSupportHelper.h"

@interface EmptyMessage ()

@property (strong, nonatomic) UILabel *titleLabel;

@end

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

- (void)setTitle:(NSString *)title
{
    [_titleLabel setText:title];
}

-(void)initialiseViewWithPosition:(EmptyMessagePosition)position
{
    float yPosition = 0.0f;
    
    switch (position)
    {
        case EmptyMessagePositionTop:
            yPosition = 50.0f;
            break;
            
        case EmptyMessagePositionCenter:
            yPosition = [self positionForCenter];
            break;
        case EmptyMessagePositionBottom:
            yPosition = [self positionForBottom];
            break;
            
        case EmptyMessagePositionFurtherBottom:
            yPosition = [self positionForFurtherBottom];
            break;
            
        default:
            break;
    }
    
    self.emptyMessageView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, yPosition, 320.0f, 50.0f)];
}

-(float)positionForCenter
{
    return (IS_IPHONE_5) ? 200.0f : 180.0f;
}

-(float)positionForBottom
{
    return [GLPiOSSupportHelper screenHeight] * 0.6;
    
//    return (IS_IPHONE_5) ? 320.0f : 300.0f;
}

-(float)positionForFurtherBottom
{
    return (IS_IPHONE_5) ? 400.0f : 350.0f;
}

-(void)generateEmptyMessageViewWithText:(NSString *)text
{
    _emptyMessageView.backgroundColor = [UIColor clearColor];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [GLPiOSSupportHelper screenWidth], 50.0f)];
    _titleLabel.font = [UIFont boldSystemFontOfSize:18];
    _titleLabel.numberOfLines = 1;
    _titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
//    _titleLabel.shadowColor = [UIColor lightTextColor];
    _titleLabel.textColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
    _titleLabel.shadowOffset = CGSizeMake(0, 1);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textAlignment =  NSTextAlignmentCenter;
    
    //Here is the text for when there are no results
    _titleLabel.text = text;
    
    _emptyMessageView.hidden = YES;
    [_emptyMessageView addSubview:_titleLabel];
    
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
