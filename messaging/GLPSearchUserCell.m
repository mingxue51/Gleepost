//
//  GLPSearchUserCell.m
//  Gleepost
//
//  Created by Lukas on 3/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPSearchUserCell.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "SDWebImageManager.h"
#import "UIImage+Masking.h"
#import "ShapeFormatterHelper.h"
#import "GLPImageHelper.h"

@interface GLPSearchUserCell()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkboxButton;

@property (strong, nonatomic) GLPUser *user;
@property (assign, nonatomic) BOOL checked;

@end


@implementation GLPSearchUserCell

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
    self.backgroundView = [UIView new];
}

- (void)configureWithUser:(GLPUser *)user checked:(BOOL)checked
{

    [self setUserInformationWithUser:user];
    
    _checked = checked;
    
    [self updateCheckbox];


    
    //Lukasz I removed this code because it was causing issues with images. I replaced this code with the code above! Let me know for any comments!
    
//    [_profileImageView setImageWithURL:[NSURL URLWithString:_user.profileImageUrl] placeholderImage:[UIImage imageNamed:@"user_image_bg"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//        if(!image) {
//            return;
//        }
//        
////        _profileImageView.image = [_profileImageView.image maskWithImage:[UIImage imageNamed:@"search_users_profile_image_mask"]];
//    }];
    
}


/**
 This method is called when we need just search for contacts.
 
 @param user User information
 
 */
-(void)configureWithUser:(GLPUser *)user
{
    [self setUserInformationWithUser:user];
    
    [_checkboxButton setHidden:YES];
}


-(void)setUserInformationWithUser:(GLPUser *)user
{
    _user = user;
    
    _userLabel.text = _user.name;
    
    [ShapeFormatterHelper setRoundedView:_profileImageView toDiameter:_profileImageView.frame.size.height];
    
    [_profileImageView sd_setImageWithURL:[NSURL URLWithString:_user.profileImageUrl] placeholderImage:[GLPImageHelper placeholderUserImage] options:SDWebImageRetryFailed];
}


- (void)updateCheckbox
{
    UIImage *checked = [UIImage imageNamed:@"search_users_checkbox_selected"];
    UIImage *unchecked = [UIImage imageNamed:@"search_users_checkbox_unselected"];
    UIImage *current, *opposite;
    
    if(_checked) {
        current = checked;
        opposite = unchecked;
    } else {
        current = unchecked;
        opposite = checked;
    }
    
    [_checkboxButton setImage:current forState:UIControlStateNormal];
    [_checkboxButton setImage:opposite forState:UIControlStateHighlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    
}


# pragma mark - Actions

- (IBAction)checkboxClick:(id)sender
{
    _checked = !_checked;
    [self updateCheckbox];
    
    [_delegate checkButtonClickForUser:_user];
}

- (IBAction)overlayViewClick:(id)sender
{
    DDLogInfo(@"c2");
    [_delegate overlayViewClickForUser:_user];
}

@end
