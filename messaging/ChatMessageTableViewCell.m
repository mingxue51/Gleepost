//
//  ChatMessageTableViewCell.m
//  Gleepost
//
//  Created by Σιλουανός on 20/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ChatMessageTableViewCell.h"

@implementation ChatMessageTableViewCell

@synthesize messageTextView;
@synthesize date;
@synthesize backgroundImageView;
@synthesize userImageButton;
@synthesize timeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
//        date = [[UILabel alloc] init];
//        [self.date setFrame:CGRectMake(10, 5, 300, 20)];
//        [self.date setFont:[UIFont systemFontOfSize:11.0]];
//        [self.date setTextColor:[UIColor lightGrayColor]];
//        [self.contentView addSubview:self.date];
//        
//        userImageButton = [[UIButton alloc] init];
//        //[self.userImageView setBackgroundColor:[UIColor clearColor]];
//        //[self.userImageView setFrame:CGRectMake(0.0f, 0.0f, 50.0, 50.0)];
//        self.userImageButton.userInteractionEnabled = YES;
//        //[self.userImageButton sizeToFit];
//        [self.contentView addSubview:self.userImageButton];
//        
//        self.backgroundImageView = [[UIImageView alloc] init];
//        [self.backgroundImageView setFrame:CGRectZero];
//        UIImage* imgBack = [UIImage imageNamed:@"MessageBox2small"];
//        [backgroundImageView setImage:imgBack];
//        
//		[self.contentView addSubview:self.backgroundImageView];
//        
//		messageTextView = [[UITextView alloc] init];
//        [self.messageTextView setBackgroundColor:[UIColor clearColor]];
//        [self.messageTextView setEditable:NO];
//        [self.messageTextView setScrollEnabled:NO];
//		[self.messageTextView sizeToFit];
//		[self.contentView addSubview:self.messageTextView];
//        
        

    }
    return self;
}

-(void) createElements
{
    date = [[UILabel alloc] init];
    [self.date setFrame:CGRectMake(10, 5, 300, 20)];
    [self.date setFont:[UIFont systemFontOfSize:11.0]];
    [self.date setTextColor:[UIColor lightGrayColor]];
    [self.contentView addSubview:self.date];
    
    userImageButton = [[UIButton alloc] init];
    //[self.userImageView setBackgroundColor:[UIColor clearColor]];
    //[self.userImageView setFrame:CGRectMake(0.0f, 0.0f, 50.0, 50.0)];
    //[self.userImageButton sizeToFit];
    [userImageButton setUserInteractionEnabled:YES];
    [self.contentView addSubview:self.userImageButton];

    
    timeLabel = [[UILabel alloc] init];
    UIImage* timeImg = [UIImage imageNamed:@"time_label"];
    
    [timeLabel setBackgroundColor:[UIColor colorWithPatternImage:timeImg]];
    //[timeLabel setBackgroundColor: [UIColor whiteColor]];
    timeLabel .contentMode = UIViewContentModeScaleAspectFit;
    //TODO: change location depending on iOS device.
    //TODO: problem: not changing dynamically.
    /**
     http://stackoverflow.com/questions/448162/determine-device-iphone-ipod-touch-with-iphone-sdk
     */
    [self.timeLabel setFrame: CGRectMake(160.0f, 0.0f, timeImg.size.width, timeImg.size.height)];
    //[self.timeLabel.layer setCornerRadius:8.0f];
    self.timeLabel.textColor = [UIColor whiteColor];
    [self.timeLabel setFont:[UIFont fontWithName:@"Helvetica" size:10]];
    
    [self.contentView addSubview:timeLabel];
    
    self.backgroundImageView = [[UIImageView alloc] init];
    [self.backgroundImageView setFrame:CGRectZero];
    [self.contentView addSubview:self.backgroundImageView];
    
    messageTextView = [[UITextView alloc] init];
    [self.messageTextView setBackgroundColor:[UIColor clearColor]];
    [self.messageTextView setEditable:NO];
    [self.messageTextView setScrollEnabled:NO];
    [self.messageTextView sizeToFit];
    [self.messageTextView setFont:[UIFont fontWithName:@"Helvetica Neue" size:6]];
    
    [self.contentView addSubview:self.messageTextView];
    
    
    
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (!(self = [super initWithCoder:aDecoder]))
    {
        NSLog(@"CALLED!!!!");
       return nil;
    }
    
    // Your code goes here!
    
    return self;
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

@end
