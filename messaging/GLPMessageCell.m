//
//  GLPMessageCell.m
//  Gleepost
//
//  Created by Lukas on 2/28/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPMessageCell.h"

@interface GLPMessageCell()

@property (strong, nonatomic) GLPMessage *message;
@property (assign, nonatomic) CGFloat height;

@end


@implementation GLPMessageCell

static const CGFloat kProfileImageViewSize = 40;
static const CGFloat kErrorImageW = 13;
static const CGFloat kErrorImageH = 17;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    [self configureViews];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self) {
        return nil;
    }
    
    [self configureViews];
    
    return self;
}

- (void)configureViews
{
    // profile image
    [self addSubview:[UIImageView newWithImageName:@"default_user_image3"]];

    // timeview
    [self addSubview:[UILabel new]];
    
    // text view
    {
        UIView *view = [UIView new];
        [view addSubview:[UIImageView new]];
        [view addSubview:[UILabel new]];
    }
    
    // error image
    {
        UIImage *image = [UIImage imageNamed:@"message_cell_error"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(errorButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)configureWithMessage:(GLPMessage *)message
{
    _message = message;
    
    _height = 0;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{

}

# pragma mark - Actions

- (void)errorButtonClick
{
    [_delegate errorButtonClickForMessage:_message];
}

@end
