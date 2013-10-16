//
//  MessageCell.m
//  Gleepost
//
//  Created by Lukas on 10/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "MessageCell.h"
#import "DateFormatterManager.h"

@interface MessageCell()

@property (assign, nonatomic) float messageContentViewInitialY;
@property (assign, nonatomic) float initialHeightOfOtherElementsThanContentMessage;

@end

@implementation MessageCell

@synthesize cellIdentifier;
@synthesize isLeft;


static const float FirstCellOtherElementsTotalHeight = 22;
static const float FollowingCellPadding = 7;
static const float MessageContentViewPadding = 15;
static const float MessageContentLabelMaxWidth = 241;
static const float MessageContentLabelPadding = 40;


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self)
    {
        return nil;
    }
    
    return self;
}

- (void)awakeFromNib
{
    // store initial positioning values
    self.messageContentViewInitialY = self.messageContentView.frame.origin.y;
//    self.messageContentLabelInitialWidth = self.messageContentLabel.frame.size.width;
//    NSLog(@"message init wid %f", self.messageContentLabelInitialWidth);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateWithMessage:(GLPMessage *)message first:(BOOL)isFirst
{
    // configure header (first) message or not
    if(isFirst) {
        self.timeView.hidden = NO;
        self.avatarImageView.hidden = NO;
        self.timeLabel.text = [[DateFormatterManager sharedInstance].timeFormatter stringFromDate:message.date];
        
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
    float labelX, viewX;
    
    if(self.isLeft) {
        labelX = self.messageContentLabel.frame.origin.x;
        viewX = self.messageContentView.frame.origin.x;
    } else {
        labelX = self.messageContentLabel.frame.origin.x + labelWidthDiff;
        viewX = self.messageContentView.frame.origin.x + labelWidthDiff;
    }
    
    self.messageContentView.frame = CGRectMake(viewX, self.messageContentView.frame.origin.y, contentWidth + MessageContentLabelPadding, contentHeight + MessageContentViewPadding);
    self.messageContentLabel.frame = CGRectMake(labelX, self.messageContentLabel.frame.origin.y, contentWidth, contentHeight);
    
    self.messageContentLabel.text = message.content;
    
    switch (message.sendStatusValue) {
        case kSendStatusLocal:
            self.messageContentLabel.textColor = [UIColor orangeColor];
            break;
        case kSendStatusSent:
            self.messageContentLabel.textColor = [UIColor greenColor];
            break;
        case kSendStatusFailure:
            self.messageContentLabel.textColor = [UIColor redColor];
            break;
    }
    
    // round message content background image
    UIGraphicsBeginImageContextWithOptions(self.messageContentImageView.bounds.size, NO, [UIScreen mainScreen].scale);
    [[UIBezierPath bezierPathWithRoundedRect:self.messageContentImageView.bounds cornerRadius:8.0] addClip];
    [self.messageContentImageView.image drawInRect:self.messageContentImageView.bounds];
    self.messageContentImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

//+ (CGFloat)getContentLabelHeightForContent:(NSString *)content
//{
//    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
//    
//    CGFloat contentHeight = [content sizeWithFont: [UIFont systemFontOfSize:14.0] constrainedToSize: maximumLabelSize lineBreakMode: NSLineBreakByCharWrapping].height;
//    
//    return contentHeight;
//}

+ (CGSize)getContentLabelSizeForContent:(NSString *)content
{
    CGSize maximumLabelSize = CGSizeMake(MessageContentLabelMaxWidth, FLT_MAX);
    
    return [content sizeWithFont: [UIFont systemFontOfSize:14.0] constrainedToSize: maximumLabelSize lineBreakMode: NSLineBreakByCharWrapping];
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
