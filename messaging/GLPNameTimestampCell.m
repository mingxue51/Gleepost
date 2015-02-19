//
//  GLPNameTimestampCell.m
//  Gleepost
//
//  Created by Silouanos on 18/02/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPNameTimestampCell.h"
#import "GLPImageView.h"
#import "GLPUser.h"
#import "GLPConversationRead.h"
#import "GLPImageHelper.h"
#import "ShapeFormatterHelper.h"
#import "UIColor+GLPAdditions.h"

@interface GLPNameTimestampCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet GLPImageView *userImageView;

@end

@implementation GLPNameTimestampCell

- (void)awakeFromNib
{
    [self formatImageView];
}

- (void)formatImageView
{
    [ShapeFormatterHelper setRoundedView:_userImageView toDiameter:_userImageView.frame.size.height];
}

- (void)setConversationRead:(GLPConversationRead *)conversationRead
{
    if(conversationRead.participant.fullName)
    {
        _nameLabel.text = conversationRead.participant.fullName;
    }
    else
    {
        _nameLabel.text = conversationRead.participant.name;
    }
    
    [_userImageView setImageUrl:conversationRead.participant.profileImageUrl withPlaceholderImage:[GLPImageHelper placeholderUserImagePath]];
    
    [self configureCustomSeparatorLine];
}

- (void)configureCustomSeparatorLine
{
    UIImageView *v = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, [GLPNameTimestampCell height] - 1, 320.0, 1.0)];
    
    [v setBackgroundColor:[UIColor colorWithR:237.0 withG:237.0 andB:237.0]];
    
    [self addSubview:v];
}

+ (CGFloat)height
{
    return 50.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
