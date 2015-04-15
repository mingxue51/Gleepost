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

@interface GLPLikesCell ()

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *images;
@property (weak, nonatomic) IBOutlet UILabel *leftNumberOfUsersLabel;

@property (assign, nonatomic) BOOL usersMoreThanSeven;

@property (strong, nonatomic) NSArray *users;

@end

@implementation GLPLikesCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setLikedUsers:(NSArray *)users
{
    [self configureCellStyle];
    self.users = users;
    [self configureBubbles];
    [self hideAllUnnecessaryBubbles];
    [self addImagesToImageViews];
}

- (void)configureCellStyle
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
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
        self.leftNumberOfUsersLabel.hidden = NO;
    }
    else
    {
        
    }
}

- (void)hideAllUnnecessaryBubbles
{
    for(NSUInteger index = self.users.count + 1; index <= 7; ++index)
    {
        DDLogDebug(@"-> index %ld", index);

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