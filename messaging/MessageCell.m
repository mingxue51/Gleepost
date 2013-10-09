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


float const FirstCellOtherElementsTotalHeight = 22;
float const FollowingCellPadding = 7;
float const MessageContentViewPadding = 15;


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self) {
        return nil;
    }
    
    return self;
}

- (void)awakeFromNib
{
    // store initial positioning values
    self.messageContentViewInitialY = self.messageContentView.frame.origin.y;
    
    // round message content background image
    UIGraphicsBeginImageContextWithOptions(self.messageContentImageView.bounds.size, NO, [UIScreen mainScreen].scale);
    [[UIBezierPath bezierPathWithRoundedRect:self.messageContentImageView.bounds cornerRadius:8.0] addClip];
    [self.messageContentImageView.image drawInRect:self.messageContentImageView.bounds];
    self.messageContentImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateWithMessage:(Message *)message first:(BOOL)isFirst
{
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
    
    float contentHeight = [MessageCell getContentLabelHeightForContent:message.content];
    self.messageContentView.frame = CGRectMake(self.messageContentView.frame.origin.x, self.messageContentView.frame.origin.y, self.messageContentView.frame.size.width, contentHeight + MessageContentViewPadding);
    self.messageContentLabel.frame = CGRectMake(self.messageContentLabel.frame.origin.x, self.messageContentLabel.frame.origin.y, self.messageContentLabel.frame.size.width, contentHeight);
    self.messageContentLabel.text = message.content;
}

+ (CGFloat)getContentLabelHeightForContent:(NSString *)content
{
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    
    CGFloat contentHeight = [content sizeWithFont: [UIFont systemFontOfSize:14.0] constrainedToSize: maximumLabelSize lineBreakMode: NSLineBreakByCharWrapping].height;
    NSLog(@"content height %f", contentHeight);
    
    return contentHeight;
}

+ (CGFloat)getCellHeightWithContent:(NSString *)content first:(BOOL)isFirst
{
    // initial height
    float height = (isFirst) ? FirstCellOtherElementsTotalHeight : 0;
    
    // add content label height + message content view padding
    height += [MessageCell getContentLabelHeightForContent:content] + MessageContentViewPadding;
    
    return height + FollowingCellPadding;
    
    
//    CGSize expectedLabelSize = [yourString sizeWithFont:yourLabel.font constrainedToSize:maximumLabelSize lineBreakMode:yourLabel.lineBreakMode];
//    
//    //adjust the label the the new height.
//    CGRect newFrame = yourLabel.frame;
//    newFrame.size.height = expectedLabelSize.height;
//    yourLabel.frame = newFrame;
    

    
//    float restHeight =
//    
//    return contentHeight + PaddingBottom;
    
//    return 0;
}

@end
