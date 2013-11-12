//
//  MessageCell.m
//  Gleepost
//
//  Created by Lukas on 10/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "MessageCell.h"
#import "DateFormatterHelper.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "WebClient.h"
#import "ConversationManager.h"
#import "SessionManager.h"
#import "ShapeFormatterHelper.h"

@interface MessageCell()

@property (assign, nonatomic) float messageContentViewInitialY;
@property (assign, nonatomic) float initialMessageContentLabelX;
@property (assign, nonatomic) float initialMessageContentViewX;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (assign, nonatomic) BOOL isBackgroundRounded;

@end

@implementation MessageCell

@synthesize cellIdentifier;
@synthesize isLeft;


static const float FirstCellOtherElementsTotalHeight = 22;
static const float FollowingCellPadding = 7;
static const float MessageContentViewPadding = 10;  //15 before.
static const float MessageContentLabelMaxWidth = 241;
static const float MessageContentLabelPadding = 14; // horizontal padding 12


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self) {
        return nil;
    }
    
    self.isBackgroundRounded = NO;
    self.dateFormatter = [DateFormatterHelper createTimeDateFormatter];
    
    return self;
}

- (void)awakeFromNib
{
    // store initial positioning values
    self.messageContentViewInitialY = self.messageContentView.frame.origin.y;
    self.initialMessageContentLabelX = self.messageContentLabel.frame.origin.x;
    self.initialMessageContentViewX = self.messageContentView.frame.origin.x;
    
//    UIImage *image = [self.messageContentImageView.image resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
//    self.messageContentImageView.image = image;
    

}

- (void)updateWithMessage:(GLPMessage *)message first:(BOOL)isFirst withIdentifier:(NSString*) identifier andParticipants:(NSArray*)participants
{
    

    // configure header (first) message or not
    if(isFirst) {
        self.timeView.hidden = NO;
        self.avatarImageView.hidden = NO;
        self.timeLabel.text = [self.dateFormatter stringFromDate:message.date];
        // move the content view at its initial position
        self.messageContentView.frame = CGRectMake(self.messageContentView.frame.origin.x, self.messageContentViewInitialY, self.messageContentView.frame.size.width, self.messageContentView.frame.size.height);
    } else {
        self.timeView.hidden = YES;
        self.avatarImageView.hidden = YES;
        
        // move the content view at the top of the cell
        self.messageContentView.frame = CGRectMake(self.messageContentView.frame.origin.x, 0, self.messageContentView.frame.size.width, self.messageContentView.frame.size.height);
    }
    
    // configure width and height based on dynamic label size
    CGSize contentSize = [MessageCell getContentLabelSizeForContent:message.content];
    float contentHeight = contentSize.height;
    float contentWidth = contentSize.width;
    
    float labelWidthDiff = MessageContentLabelMaxWidth - contentWidth;
    float labelX = self.initialMessageContentLabelX;
    float viewX = self.initialMessageContentViewX;
    
    if(!self.isLeft) {
        labelX += labelWidthDiff;
        viewX += labelWidthDiff;
    }
    
    self.messageContentView.frame = CGRectMake(viewX, self.messageContentView.frame.origin.y, contentWidth + MessageContentLabelPadding, contentHeight + MessageContentViewPadding);
    self.messageContentLabel.frame = CGRectMake(self.messageContentLabel.frame.origin.x, self.messageContentLabel.frame.origin.y, contentWidth, contentHeight);
    
    self.messageContentLabel.text = message.content;
    
    
    self.messageContentImageView.layer.masksToBounds = YES;
    self.messageContentImageView.layer.cornerRadius = 12.5;
    
    GLPUser* user = nil;
    
    if([identifier isEqualToString:@"LeftCell"])
    {
        [self.messageContentImageView.layer setBorderColor: [[UIColor colorWithRed:76.0/255.0 green:183.0/255.0 blue:197.0/255.0 alpha:1.0] CGColor]];
        [self.messageContentImageView.layer setBorderWidth: 1.25];
        
        user = [[SessionManager sharedInstance]user];
        
        //Add tag to the avatar image view the user's remote key.
        self.avatarImageView.tag = user.remoteKey;

    }
    else
    {
        //At the moment just take the image of the first participant.
        user = [participants objectAtIndex:0];
        
        //Add tag to the avatar image view the user's remote key.
        self.avatarImageView.tag = user.remoteKey;
    }
    

    
    //Fetch user's details from database.
    // This is wrong, never call any heavy operation in drawing methods
   // [ConversationManager loadUserWithMessageId:message.key];
    

    
    [ShapeFormatterHelper setRoundedView:self.avatarImageView toDiameter:self.avatarImageView.frame.size.height];

    if(self.avatarImageView.image == nil)
    {
        if([user.profileImageUrl isEqualToString:@""])
        {
            //Set default image.
            [self.avatarImageView setImage:[UIImage imageNamed:@"default_user_image"]];
        }
        else
        {
            
            //Fetch the image from the server and add it to the image view.
            [self.avatarImageView setImageWithURL:[NSURL URLWithString:user.profileImageUrl] placeholderImage:[UIImage imageNamed:@"default_user_image"]];
        }
    }
    else
    {
        
    }

    
    
    //Fetch user's details from server.
//    [[WebClient sharedInstance] getUserWithKey:message.author.remoteKey callbackBlock:^(BOOL success, GLPUser *user) {
//        
//        if(success)
//        {
//            NSLog(@"Private Profile Load User Image URL: %@",user.profileImageUrl);
//            
//
//            
//            self.avatarImageView.clipsToBounds = YES;
//            
//            self.avatarImageView.layer.cornerRadius = 20;
//            
//            
//            
//            if([user.profileImageUrl isEqualToString:@""])
//            {
//                //Set default image.
//                [self.avatarImageView setImage:[UIImage imageNamed:@"default_user_image"]];
//            }
//            else
//            {
//                
//                //Fetch the image from the server and add it to the image view.
//                [self.avatarImageView setImageWithURL:[NSURL URLWithString:user.profileImageUrl] placeholderImage:[UIImage imageNamed:@"default_user_image"]];
//            }
//        }
//        else
//        {
//            NSLog(@"Not Success: %d User: %@",success, user);
//            
//        }
//        
//        
//        
//    }];
    
    
    //Add user's image.
    

    
    
//    switch (message.sendStatusValue) {
//        case kSendStatusLocal:
//            self.messageContentLabel.textColor = [UIColor orangeColor];
//            break;
//        case kSendStatusSent:
//            self.messageContentLabel.textColor = [UIColor greenColor];
//            break;
//        case kSendStatusFailure:
//            self.messageContentLabel.textColor = [UIColor redColor];
//            break;
//    }
    
    // round message content background image
//    if(!self.isBackgroundRounded)
//    {
//        self.isBackgroundRounded = YES;
//    UIGraphicsBeginImageContextWithOptions(self.messageContentImageView.bounds.size, NO, [UIScreen mainScreen].scale);
//    [[UIBezierPath bezierPathWithRoundedRect:self.messageContentImageView.bounds cornerRadius:10.0] addClip];
//    [self.messageContentImageView.image drawInRect:self.messageContentImageView.bounds];
//    self.messageContentImageView.image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    }
}

+ (CGSize)getContentLabelSizeForContent:(NSString *)content
{
    CGSize maximumLabelSize = CGSizeMake(MessageContentLabelMaxWidth, FLT_MAX);
    
    return [content sizeWithFont: [UIFont systemFontOfSize:14.0] constrainedToSize: maximumLabelSize lineBreakMode: NSLineBreakByWordWrapping];
}

+ (CGFloat)getCellHeightWithContent:(NSString *)content first:(BOOL)isFirst
{
    // initial height
    float height = (isFirst) ? FirstCellOtherElementsTotalHeight : 0;
    
    // add content label height + message content view padding
    height += [MessageCell getContentLabelSizeForContent:content].height + MessageContentViewPadding;
    
    return height + FollowingCellPadding;
}

@end
