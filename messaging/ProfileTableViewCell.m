//
//  ProfileTableViewCell.m
//  Gleepost
//
//  Created by Silouanos on 09/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ProfileTableViewCell.h"
#import "ShapeFormatterHelper.h"
#import "GLPThemeManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ProfileTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *universityLabel;
@property (weak, nonatomic) IBOutlet UIButton *addContactButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;


@end

@implementation ProfileTableViewCell

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
    }
    
    return self;
}

-(void)initialiseElementsWithUserDetails:(GLPUser *)user
{
    
//    [self.course setText: user.course];
    
//    [self.personalMessage setText:user.personalMessage];
    
    [self.universityLabel setText:user.networkName];

    [ShapeFormatterHelper setRoundedView:self.profileImage toDiameter:self.profileImage.frame.size.height];
    
    self.profileImage.layer.borderWidth = 2.0;
    self.profileImage.layer.borderColor = [[GLPThemeManager sharedInstance]colorForTabBar].CGColor;
    
    
    if([user.profileImageUrl isEqualToString:@""])
    {
        //Set default image.
        [self.profileImage setImage:[UIImage imageNamed:@"default_user_image"]];
    }
    else
    {
        
        //Fetch the image from the server and add it to the image view.
        //[self.profileImage setImageWithURL:[NSURL URLWithString:user.profileImageUrl] placeholderImage:[UIImage imageNamed:@"default_user_image"]];
        
        [self.profileImage setImageWithURL:[NSURL URLWithString:user.profileImageUrl] placeholderImage:[UIImage imageNamed:@"default_user_image"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {

            
        }];
        
        //TODO: Create shadow to the image.
        
        //                self.profileImage.layer.shadowColor = [UIColor blackColor].CGColor;
        //                self.profileImage.layer.shadowOffset = CGSizeMake(-1, 1);
        //                self.profileImage.layer.shadowOpacity = 1;
        //                self.profileImage.layer.shadowRadius = 3.0;
        //                self.profileImage.clipsToBounds = NO;
        
        
        
        
        
        //                UIBezierPath *maskPath;
        //                maskPath = [UIBezierPath bezierPathWithRoundedRect:self.profileImage.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(10.0, 10.0)];
        //
        //                CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        //                maskLayer.frame = self.view.bounds;
        //                maskLayer.path = maskPath.CGPath;
        //                self.profileImage.layer.mask = maskLayer;
        
        
        
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFullProfileImage:)];
        [tap setNumberOfTapsRequired:1];
        [self.profileImage addGestureRecognizer:tap];
    }
}

-(void)showFullProfileImage:(id)sender
{
    NSLog(@"Show Full Size Image.");
}

- (IBAction)acceptUser:(id)sender {
}

- (IBAction)sendMessage:(id)sender {
}

- (IBAction)addUser:(id)sender {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
