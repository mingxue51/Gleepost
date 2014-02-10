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
#import "AppearanceHelper.h"

@interface CampusWallHeaderCell ()


//@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *contentLbl;
@property (weak, nonatomic) IBOutlet UILabel *attendingLbl;
@property (weak, nonatomic) IBOutlet UILabel *staticAttendingLbl;
@property (weak, nonatomic) IBOutlet UIButton *goingBtn;

@end


@implementation CampusWallHeaderCell

const float CELL_WIDTH = 198.0; //
const float CELL_HEIGHT = 132.0; //Change the height


-(id)initWithIdentifier:(NSString *)identifier
{
    
    self =  [super initWithIdentifier:identifier];
    
    if (self)
    {
//        [self setFrame:CGRectMake(0, 0, 30, 50)];
        
        [self setBackgroundColor:[UIColor clearColor]];
        
//        [ShapeFormatterHelper setCornerRadiusWithView:self.contentView andValue:17.0f];
        
//        [ShapeFormatterHelper setCornerRadiusWithView:self andValue:17.0f];
        
        
        //Format the image.
        [ShapeFormatterHelper setRoundedView:self.profileImage toDiameter:self.profileImage.frame.size.height];
        
        _profileImage.layer.borderWidth = 1.0;
        _profileImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
    }
    
    
    return self;
}

-(void)setData:(GLPPost*)post
{
//    [self setFrame:CGRectMake(0, 0, 30, 50)];
    
    [self setDataInElements:post];
    
    [self formatFontInElements];
}

-(void)setDataInElements:(GLPPost *)postData
{
    //Set user's image.
    [_profileImage setImageWithURL:[NSURL URLWithString:postData.author.profileImageUrl] placeholderImage:nil];
    
    [_userNameLbl setText:postData.author.name];
    
    [_contentLbl setText:postData.content];
    
    NSDate *currentDate = postData.date;
    
    [_timeLbl setText:[self takeTime:currentDate]];
    
    //TODO: set number of attending.
    [_attendingLbl setText:@"0"];
    
    //TODO: select the going button if the user is attending,
}

-(void)formatFontInElements
{
    [_userNameLbl setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@",GLP_TITLE_FONT] size:14.0f]];
    
    [_contentLbl setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@",GLP_TITLE_FONT] size:14.0f]];
    
    [_goingBtn.titleLabel setFont:[UIFont fontWithName:GLP_TITLE_FONT size:18]];
    
    [_attendingLbl setFont:[UIFont fontWithName:GLP_TITLE_FONT size:17]];
    
    [_staticAttendingLbl setFont:[UIFont fontWithName:GLP_TITLE_FONT size:17]];
}

-(NSString*)takeTime:(NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm"];
    NSString *timeString = [formatter stringFromDate:date];
    
    return timeString;
}
- (IBAction)goingToEvent:(id)sender
{
    UIButton *currentButton = (UIButton*)sender;
    
    if([[currentButton titleColorForState:UIControlStateNormal] isEqual:[AppearanceHelper colourForNotFocusedItems]])
    {
        
        [self makeButtonSelected:currentButton];
        
        
    }
    else
    {
        
        [self makeButtonUnselected:currentButton];
        
    }
    
}

-(void)makeButtonUnselected:(UIButton *)btn
{
    [btn setTitleColor:[AppearanceHelper colourForNotFocusedItems] forState:UIControlStateNormal];
    [btn.layer setBorderColor:[AppearanceHelper colourForNotFocusedItems].CGColor];
}

-(void)makeButtonSelected:(UIButton *)btn
{
    [btn setTitleColor:[AppearanceHelper defaultGleepostColour] forState:UIControlStateNormal];
    [btn.layer setBorderColor:[AppearanceHelper defaultGleepostColour].CGColor];
    
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
