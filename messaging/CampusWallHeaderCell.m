//
//  CampusWallHeaderViewCell.m
//  Gleepost
//
//  Created by Silouanos on 23/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "CampusWallHeaderCell.h"
#import "ShapeFormatterHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSDate+TimeAgo.h"
#import "AppearanceHelper.h"
#import "NSDate+HumanizedTime.h"
#import "EventBarView.h"

@interface CampusWallHeaderCell ()


//@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *contentLbl;
@property (weak, nonatomic) IBOutlet UILabel *attendingLbl;
@property (weak, nonatomic) IBOutlet UILabel *staticAttendingLbl;
@property (weak, nonatomic) IBOutlet UIButton *goingBtn;
@property (weak, nonatomic) IBOutlet UILabel *eventTitleLbl;
@property (weak, nonatomic) IBOutlet EventBarView *eventBarView;

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
    self.postData = post;
    
    [self setDataInElements:post];
    
    
    [self formatFontInElements];
}

-(GLPPost *)getData
{
    return self.postData;
}

-(void)setDataInElements:(GLPPost *)postData
{
    //Set user's image.
    [_profileImage setImageWithURL:[NSURL URLWithString:postData.author.profileImageUrl] placeholderImage:nil];
    
    [_eventTitleLbl setText:postData.eventTitle];
    
    [_contentLbl setText:postData.content];
    
    
//    [_timeLbl setText:[self takeTime:currentDate]];

    [self setTimeWithTime:postData.dateEventStarts];
  


    
    //TODO: set number of attending.
    [_attendingLbl setText:@"0"];
    
    //TODO: select the going button if the user is attending,
}

-(void)formatFontInElements
{
    [_userNameLbl setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@",GLP_TITLE_FONT] size:14.0f]];
    
    [_contentLbl setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@",GLP_TITLE_FONT] size:14.0f]];
    
    [_goingBtn.titleLabel setFont:[UIFont fontWithName:GLP_TITLE_FONT size:20]];
    
    [_attendingLbl setFont:[UIFont fontWithName:GLP_TITLE_FONT size:17]];
    
    [_staticAttendingLbl setFont:[UIFont fontWithName:GLP_TITLE_FONT size:17]];
    
    [_timeLbl setFont:[UIFont fontWithName:GLP_TITLE_FONT size:16]];
    
 
//    [_eventTitleLbl setFont:[UIFont fontWithName:GLP_TITLE_FONT size:24]];
}

-(void)setTimeWithTime:(NSDate *)date
{
    if ([[NSDate date] compare:date] == NSOrderedDescending) {
        [_timeLbl setText:[date timeAgo]];
        
    } else if ([[NSDate date] compare:date] == NSOrderedAscending) {
        
        [_timeLbl setText:[date stringWithHumanizedTimeDifference:NSDateHumanizedSuffixLeft withFullString:YES]];
        
    } else {
        [_timeLbl setText:[date timeAgo]];
        
    }
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
        [_eventBarView increaseBarLevel:1];

        
    }
    else
    {
        
        [self makeButtonUnselected:currentButton];
        [_eventBarView decreaseBarLevel:1];

    }
    

    
}


-(void)makeButtonUnselected:(UIButton *)btn
{
    [btn setTitleColor:[AppearanceHelper colourForNotFocusedItems] forState:UIControlStateNormal];
}

-(void)makeButtonSelected:(UIButton *)btn
{
    [btn setTitleColor:[UIColor colorWithRed:0.0/255.0 green:236.0/255.0 blue:172.0/255.0 alpha:1.0f] forState:UIControlStateNormal];
    
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
