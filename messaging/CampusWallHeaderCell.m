//
//  CampusWallHeaderViewCell.m
//  Gleepost
//
//  Created by Silouanos on 23/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "CampusWallHeaderCell.h"
#import "ShapeFormatterHelper.h"
#import "GLPPost.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSDate+TimeAgo.h"

@interface CampusWallHeaderCell ()


//@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *contentLbl;

@end


@implementation CampusWallHeaderCell

const float CELL_HEIGHT = 115;
const float CELL_WIDTH = 200;


-(id)initWithIdentifier:(NSString *)identifier
{
    
    self =  [super initWithIdentifier:identifier];
    
    if (self)
    {
        [self setFrame:CGRectMake(0, 0, 30, 50)];
        
        [self setBackgroundColor:[UIColor clearColor]];
        
//        [ShapeFormatterHelper setCornerRadiusWithView:self.contentView andValue:17.0f];
        
        [ShapeFormatterHelper setCornerRadiusWithView:self andValue:17.0f];
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        //Format the image.
        [ShapeFormatterHelper setRoundedView:self.profileImage toDiameter:self.profileImage.frame.size.height];
        
        _profileImage.layer.borderWidth = 1.0;
        _profileImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    
    
    return self;
}

-(void)setData:(GLPPost*)post
{
    [self setFrame:CGRectMake(0, 0, 30, 50)];
    
    //Set user's image.
    [_profileImage setImageWithURL:[NSURL URLWithString:post.author.profileImageUrl] placeholderImage:nil];
    
    [_userNameLbl setText:post.author.name];
    
    [_contentLbl setText:post.content];
    
    NSDate *currentDate = post.date;

    [_timeLbl setText:[self takeTime:currentDate]];
}

-(NSString*)takeTime:(NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm"];
    NSString *timeString = [formatter stringFromDate:date];
    
    return timeString;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
