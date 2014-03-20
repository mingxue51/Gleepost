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
#import "WebClient.h"
#import "WebClientHelper.h"
#import "ImageFormatterHelper.h"
#import "ReflectedImageView.h"
#import "UIImage+Alpha.h"

@interface CampusWallHeaderCell ()


//@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *eventImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *contentLbl;
@property (weak, nonatomic) IBOutlet UILabel *attendingLbl;
@property (weak, nonatomic) IBOutlet UILabel *staticAttendingLbl;
@property (weak, nonatomic) IBOutlet UIButton *goingBtn;
@property (weak, nonatomic) IBOutlet UILabel *eventTitleLbl;
@property (weak, nonatomic) IBOutlet EventBarView *eventBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelWidth;

@end


@implementation CampusWallHeaderCell

const float CELL_WIDTH = 230.0; //198
const float CELL_HEIGHT = 215.0; //Change the height //132
const float TITLE_LABEL_MAX_WIDTH = 180.0;
const float TITLE_LABEL_MAX_HEIGHT = 50.0;

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
//        [ShapeFormatterHelper setRoundedView:self.eventImage toDiameter:self.eventImage.frame.size.height];
        
//        [ShapeFormatterHelper setCornerRadiusWithView:self.eventImage andValue:self.eventImage.frame.size.height];
        
        
        
        [self formatEventImage];
        
//        _eventImage.layer.borderWidth = 1.0;
//        _eventImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
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
    
    NSURL *imgUrl = nil;
    
    if(postData.imagesUrls)
    {
       imgUrl = [NSURL URLWithString:postData.imagesUrls[0]];
    }
    
    
    //Set post's image.
    [_eventImage setImageWithURL:imgUrl placeholderImage:nil];
    
    
//    [_eventImage setImageWithURL:imgUrl placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//        
//        //Create the reflection effect.
//        //TODO: Fix that, only add image when the image is loaded.
////        [_reflectedEventImage reflectionImageWithImage:_eventImage.image];
//        
//        UIImage *croppedImg = image;
//        
//        croppedImg = [ImageFormatterHelper cropImage:croppedImg withRect:CGRectMake(0, 0, croppedImg.size.width, croppedImg.size.height-300)];
//        
//        [croppedImg setAlpha:0.5];
////        
////        UIImage *finalImg = [ImageFormatterHelper addImageToImage:image withImage2:croppedImg withImageView:_eventImage andRect:CGRectMake(0, 0, croppedImg.size.width, croppedImg.size.height-300)];
//        
//        UIImage *finalImg = [ImageFormatterHelper maskImage:image withMask:image];
//        
//        
//        [_eventImage setImage:finalImg];
//        
//    }];
    
    
    
    CGSize labelSize = [CampusWallHeaderCell getContentLabelSizeForContent:postData.eventTitle];
    
    [_eventTitleLbl setText:postData.eventTitle];
    
    [_titleLabelWidth setConstant: labelSize.height];
    
    [self setTimeWithTime:postData.dateEventStarts];
  
    
    [_eventBarView increaseBarLevel:postData.popularity];
    
//    [_attendingLbl setText:@"0"];
    
    //Select the going button if the user is attending,
    if(_postData.attended)
    {
        [self makeButtonSelected:_goingBtn];
    }
    else
    {
        [self makeButtonUnselected:_goingBtn];
    }
}

+ (CGSize)getContentLabelSizeForContent:(NSString *)content
{
    if(!content)
    {
        return CGSizeMake(0, 0);
    }
    
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:17.0];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName: font}];
    
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){TITLE_LABEL_MAX_WIDTH, TITLE_LABEL_MAX_HEIGHT}
                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               context:nil];
    
    CGSize size = rect.size;
    
    
    return size;
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

-(void)formatEventImage
{
    //Resize the image.
//    [ImageFormatterHelper imageWithImage:<#(UIImage *)#> scaledToWidth:<#(float)#>]
    
    
    //Set alpha to a specific part of the image.
    
    //http://stackoverflow.com/questions/14107979/blur-an-image-of-specific-part-rectangular-circular
    
    //Format the image.
    [ShapeFormatterHelper createTwoTopCornerRadius:self.eventImage withViewBounts:self.eventImage.frame andSizeOfCorners:CGSizeMake(7.0f, 7.0f)];
    

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
    
//    if([[currentButton titleColorForState:UIControlStateNormal] isEqual:[AppearanceHelper colourForNotFocusedItems]])
    if(currentButton.tag == 2)
    {
        
        //Communicate with server to attend post.
        
        [[WebClient sharedInstance] postAttendInPostWithRemoteKey:_postData.remoteKey callbackBlock:^(BOOL success) {
            
            if(success)
            {
                _postData.attended = YES;
            }
            else
            {
                //Error message.
                [WebClientHelper showStandardError];
            }
            
        }];
        
        [self makeButtonSelected:currentButton];

        
    }
    else
    {
        
        //Communicate with server to remove your attendance form the post.
        
        [[WebClient sharedInstance] removeAttendFromPostWithRemoteKey:_postData.remoteKey callbackBlock:^(BOOL success) {
            
            if(success)
            {
                _postData.attended = NO;

                [self makeButtonUnselected:currentButton];
            }
            else
            {
                //Error message.
                [WebClientHelper showStandardError];
            }
            
        }];
    }
    
}


-(void)makeButtonUnselected:(UIButton *)btn
{
//    [btn setTitleColor:[AppearanceHelper colourForNotFocusedItems] forState:UIControlStateNormal];
    
    [btn setImage:[UIImage imageNamed:@"going"] forState:UIControlStateNormal];
    btn.tag = 2;
}

-(void)makeButtonSelected:(UIButton *)btn
{
//    [btn setTitleColor:[UIColor colorWithRed:0.0/255.0 green:236.0/255.0 blue:172.0/255.0 alpha:1.0f] forState:UIControlStateNormal];
    
    [btn setImage:[UIImage imageNamed:@"going_pressed"] forState:UIControlStateNormal];
    btn.tag = 1;
    
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
