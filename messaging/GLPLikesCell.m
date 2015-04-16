//
//  GLPLikesCell.m
//  Gleepost
//
//  Created by Silouanos on 15/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPLikesCell.h"
#import "GLPUser.h"
#import "GLPImageView.h"
#import "ShapeFormatterHelper.h"
#import "UIColor+GLPAdditions.h"

@interface GLPLikesCell ()

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *images;
@property (weak, nonatomic) IBOutlet UILabel *leftNumberOfUsersLabel;
@property (weak, nonatomic) IBOutlet UIView *lastView;

@property (assign, nonatomic) BOOL usersMoreThanSeven;

@property (strong, nonatomic) NSArray *users;

@end

@implementation GLPLikesCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setLikedUsers:(NSArray *)users
{
    [self formatImages];
    [self configureCellStyle];
    self.users = users;
    [self configureBubbles];
    [self hideAllUnnecessaryBubbles];
    [self addImagesToImageViews];
    [self configureLastBubble];

}

- (void)configureCellStyle
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)configureLastBubble
{
    if(self.usersMoreThanSeven)
    {
        self.leftNumberOfUsersLabel.text = [NSString stringWithFormat:@"+%ld", (long)self.users.count - 6];
    }
}

- (void)addImagesToImageViews
{
    for(NSUInteger index = 0; index < self.users.count; ++index)
    {
        GLPUser *user = self.users[index];
        [self setImageWithUrl:user.profileImageUrl toImageViewTag:index + 1];
    }
}

/**
 Decides if there is a need to put number or image on the last cell.
 */
- (void)configureBubbles
{
    if(self.users.count > 7)
    {
        self.usersMoreThanSeven = YES;
        [self hideImageWithTag:7];
        [ShapeFormatterHelper setBorderToView:self.lastView withColour:[UIColor colorWithR:189 withG:189 andB:189] andWidth:1.0];
        [self formatPlusView];
        self.leftNumberOfUsersLabel.hidden = NO;
    }
    else
    {
        self.usersMoreThanSeven = NO;
    }
}

- (void)hideAllUnnecessaryBubbles
{
    for(NSUInteger index = self.users.count + 1; index <= 7; ++index)
    {
        [self hideImageWithTag:index];
    }
}

- (void)setImageWithUrl:(NSString *)imageUrl toImageViewTag:(NSInteger)tag
{
    for(GLPImageView *image in self.images)
    {
        if(image.tag == tag)
        {
            [image setImageUrl:imageUrl withPlaceholderImage:@""];
        }
    }
}

- (void)hideImageWithTag:(NSInteger)tag
{
    for(UIImageView *image in self.images)
    {
        if(image.tag == tag)
        {
            image.hidden = YES;
            break;
        }
    }
}

#pragma mark - Format

- (void)formatImages
{
    for(UIImageView *imageView in self.images)
    {
        [imageView layoutIfNeeded];
        [ShapeFormatterHelper setRoundedView:imageView toDiameter:imageView.frame.size.height];
    }
}

- (void)formatPlusView
{
    [self.lastView layoutIfNeeded];
    [ShapeFormatterHelper setRoundedView:self.lastView toDiameter:self.lastView.frame.size.height];
    [self.lastView setBackgroundColor:[UIColor whiteColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


#pragma mark - Static

+ (CGFloat)height
{
    return 100.0;
}

@end