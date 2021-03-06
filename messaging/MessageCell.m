////
////  MessageCell.m
////  Gleepost
////
////  Created by Lukas on 10/9/13.
////  Copyright (c) 2013 Gleepost. All rights reserved.
////
//
//#import "MessageCell.h"
//#import "DateFormatterHelper.h"
//#import <QuartzCore/QuartzCore.h>
//#import <SDWebImage/UIImageView+WebCache.h>
//#import "WebClient.h"
//#import "ConversationManager.h"
//#import "SessionManager.h"
//#import "ShapeFormatterHelper.h"
//
//@interface MessageCell()
//
//@property (assign, nonatomic) float messageContentViewInitialY;
//@property (assign, nonatomic) float initialMessageContentLabelX;
//@property (assign, nonatomic) float initialMessageContentViewX;
//
//@property (strong, nonatomic) NSDateFormatter *dateFormatter;
//
//@property (assign, nonatomic) BOOL isBackgroundRounded;
//
//@property (strong, nonatomic) NSDate *lastTimestampDate;
//
//@end
//
//@implementation MessageCell
//
//@synthesize cellIdentifier;
//@synthesize isLeft;
//
//
//static const float FirstCellOtherElementsTotalHeight = 22;
//static const float FollowingCellPadding = 7;
//static const float MessageContentViewPadding = 10;  //15 before.
//static const float MessageContentLabelMaxWidth = 241;
//static const float MessageContentLabelMaxWidthWithError = MessageContentLabelMaxWidth - 20;
//static const float MessageContentLabelPadding = 14; // horizontal padding 12
//
//
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if(!self) {
//        return nil;
//    }
//    
//    self.isBackgroundRounded = NO;
//    //self.dateFormatter = [DateFormatterHelper createTimeDateFormatter];
//    self.dateFormatter = [DateFormatterHelper createMessageDateFormatter];
//    
//    
//    return self;
//}
//
//- (void)awakeFromNib
//{
//    // store initial positioning values
//    self.messageContentViewInitialY = self.messageContentView.frame.origin.y;
//    self.initialMessageContentLabelX = self.messageContentLabel.frame.origin.x;
//    self.initialMessageContentViewX = self.messageContentView.frame.origin.x;
//    
////    UIImage *image = [self.messageContentImageView.image resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
////    self.messageContentImageView.image = image;
//    
//
//}
//
//- (void)updateWithMessage:(GLPMessage *)message first:(BOOL)isFirst
//{
//    // configure header (first) message or not
//    if(isFirst) {
//        self.timeView.hidden = NO;
//        self.avatarImageView.hidden = NO;
//        self.timeLabel.text = [self.dateFormatter stringFromDate:message.date];
//        self.timeLabel.textColor = [UIColor lightGrayColor];
//        self.timeLabel.font = [UIFont fontWithName:GLP_APP_FONT_BOLD size:10.0f];
//        
//        
//        // move the content view at its initial position
//        self.messageContentView.frame = CGRectMake(self.messageContentView.frame.origin.x, self.messageContentViewInitialY, self.messageContentView.frame.size.width, self.messageContentView.frame.size.height);
//        
//        //ARROW REMOVED.
//        
////        if (self.isLeft) {
////            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-left"]];
////            imageView.frame = CGRectMake(self.avatarImageView.frame.origin.x + self.avatarImageView.frame.size.width, self.messageContentViewInitialY +7, 5, 10);
////            [self.contentView addSubview:imageView];
////        }else {
////            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arraow-right"]];
////            imageView.frame = CGRectMake(self.avatarImageView.frame.origin.x -5, self.messageContentViewInitialY +7, 5, 10);
////            [self.contentView addSubview:imageView];
////            
////        }
//        
//    } else {
//        self.timeView.hidden = YES;
//        self.avatarImageView.hidden = YES;
//        
//        // move the content view at the top of the cell
//        self.messageContentView.frame = CGRectMake(self.messageContentView.frame.origin.x, 0, self.messageContentView.frame.size.width, self.messageContentView.frame.size.height);
//    }
//    
//    // configure width and height based on dynamic label size
//    CGSize contentSize = [MessageCell getContentLabelSizeForMessage:message];
//    float contentHeight = contentSize.height;
//    float contentWidth = contentSize.width;
//    
//    float labelWidthDiff = MessageContentLabelMaxWidth - contentWidth;
//    float labelX = self.initialMessageContentLabelX;
//    float viewX = self.initialMessageContentViewX;
//    
//    if(!self.isLeft) {
//        labelX += labelWidthDiff;
//        viewX += labelWidthDiff;
//    }
//    
//    if(message.sendStatus == kSendStatusLocal) {
//        self.messageContentView.alpha = 0.15;
//    } else {
//        self.messageContentView.alpha = 1;
//    }
//    
//    self.messageContentView.frame = CGRectMake(viewX, self.messageContentView.frame.origin.y, contentWidth + MessageContentLabelPadding, contentHeight + MessageContentViewPadding);
//    self.messageContentLabel.frame = CGRectMake(self.messageContentLabel.frame.origin.x, self.messageContentLabel.frame.origin.y, contentWidth, contentHeight);
//    
//    
//    self.messageContentLabel.text = message.content;
//    
//    self.messageContentImageView.layer.masksToBounds = YES;
//    self.messageContentImageView.layer.cornerRadius = 12.0;
//    self.messageContentView.layer.cornerRadius = 12.0;
//    self.messageContentLabel.font = [UIFont fontWithName:GLP_MESSAGE_FONT size:16];
//
//    if(!self.isLeft) {
//        [self.messageContentImageView.layer setBorderColor: [[UIColor colorWithRed:3.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0] CGColor]];
//        [self.messageContentImageView.layer setBorderWidth:2];
//                self.messageContentLabel.textColor = [UIColor colorWithRed:70.0f/255.0f green:70.0f/255.0f blue:70.0f/255.0f alpha:1.0f];
//    }else {
//        self.messageContentLabel.textColor = [UIColor whiteColor];
//        self.messageContentView.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:234.0/255.0 blue:176.0/255.0 alpha:1.0];
//        
//    }
//    
//    UIImage *defaultProfilePicture = [UIImage imageNamed:@"default_user_image3.png"];
//    if([message.author hasProfilePicture]) {
//            [self.avatarImageView setImageWithURL:[NSURL URLWithString:message.author.profileImageUrl] placeholderImage:defaultProfilePicture];
//    } else {
//        self.avatarImageView.image = defaultProfilePicture;
//    }
//    
//    self.avatarImageView.tag = message.author.remoteKey;
//    
//    [ShapeFormatterHelper setRoundedView:self.avatarImageView toDiameter:self.avatarImageView.frame.size.height];
//
//    if(message.sendStatus == kSendStatusFailure) {
//        DDLogInfo(@"Show failure for message: %@", message.content);
//        self.errorImageView.hidden = NO;
//        
//        float y = self.messageContentView.frame.origin.y + ((self.messageContentView.frame.size.height - self.errorImageView.frame.size.height) / 2);
//        
//        if(self.isLeft) {
//            float x = CGRectGetMaxX(self.messageContentView.frame) + 10;
//            CGRectSetXY(self.errorImageView, x, y);
//        } else {
//            float x = self.messageContentView.frame.origin.x - self.errorImageView.frame.size.width - 15;
//            CGRectSetXY(self.errorImageView, x, y);
//        }
//    } else {
//        self.errorImageView.hidden = YES;
//    }
//    
////    switch (message.sendStatusValue) {
////        case kSendStatusLocal:
////            self.messageContentLabel.textColor = [UIColor orangeColor];
////            break;
////        case kSendStatusSent:
////            self.messageContentLabel.textColor = [UIColor greenColor];
////            break;
////        case kSendStatusFailure:
////            self.messageContentLabel.textColor = [UIColor redColor];
////            break;
////    }
//}
//
//
//+ (CGSize)getContentLabelSizeForMessage:(GLPMessage *)message
//{
//
//        //DELETED.
////    CGSize maximumLabelSize = CGSizeMake(MessageContentLabelMaxWidth, FLT_MAX);
////    
////    return [content sizeWithFont: [UIFont systemFontOfSize:14.0] constrainedToSize: maximumLabelSize lineBreakMode: NSLineBreakByWordWrapping];
//     //DELETED.
//    
//    UIFont *font = [UIFont fontWithName:GLP_MESSAGE_FONT size:16];
//    
//    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:message.content attributes:@{NSFontAttributeName: font}];
//    
//    float maxWidth = message.sendStatus == kSendStatusFailure ? MessageContentLabelMaxWidthWithError : MessageContentLabelMaxWidth;
//    
//    CGRect rect = [attributedText boundingRectWithSize:(CGSize){maxWidth, CGFLOAT_MAX}
//                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
//                                               context:nil];
//    
////    CGSize size = rect.size;
//    
//    return rect.size;
//}
//
//+ (CGFloat)getCellHeightWithMessage:(GLPMessage *)message first:(BOOL)isFirst
//{
//    // initial height
//    float height = (isFirst) ? FirstCellOtherElementsTotalHeight : 0;
//    
//    // add content label height + message content view padding
//    height += [MessageCell getContentLabelSizeForMessage:message].height + MessageContentViewPadding;
//    
//    return height + FollowingCellPadding;
//}
//
//@end
