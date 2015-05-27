//
//  GLPMessageCell.m
//  Gleepost
//
//  Created by Lukas on 2/28/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPMessageCell.h"
#import "GLPMessage+CellLogic.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "ShapeFormatterHelper.h"
#import "GLPDateFormatterHelper.h"
#import "AppearanceHelper.h"
#import "GLPImageHelper.h"
#import "GLPSystemMessage.h"
#import "GLPReadReceiptsManager.h"
#import "GLPiOSSupportHelper.h"

@interface GLPMessageCell()

@property (strong, nonatomic) GLPMessage *message;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) BOOL isOnLeftSide;

/** This variable is true only when the message is going to be viewed in
 GLPMessageDetailViewController*/
@property (assign, nonatomic, setter=setViewMode:) BOOL viewMode;

@end


@implementation GLPMessageCell

static const CGFloat KViewW = 320;
static const CGFloat kProfileImageViewSize = 40;
static const CGFloat kTimeLabelW = 200;
static const CGFloat kTimeLabelH = 20;
static const CGFloat kContentLabelMinimalW = 15;
static const CGFloat kErrorImageW = 13;
static const CGFloat kErrorImageH = 17;

static const CGFloat kProfileImageViewTopMargin = 9;
static const CGFloat kProfileImageViewSideMargin = 6;
static const CGFloat kProfileImageViewOppositeSideMargin = 6;
static const CGFloat kTimeLabelBottomMargin = 0;
static const CGFloat kContentLabelVerticalPadding = 15; //10
static const CGFloat kContentLabelHorizontalPadding = 20; //15
static const CGFloat kContentImageVerticalPadding = 5; //10

static const CGFloat kErrorImageSideMargin = 6;
static const CGFloat kOppositeSideMarginWithoutError = 30;
static const CGFloat kOppositeSideMarginWithError = 10 + kErrorImageW + kErrorImageSideMargin;
static const CGFloat kSideMarginIncludingProfileImage = kProfileImageViewSideMargin + kProfileImageViewSize + kProfileImageViewOppositeSideMargin;
static const CGFloat kTopMargin = 0;
static const CGFloat kBottomMargin = 2; //7

static const CGFloat kViewModeMargin = 10;

static const CGFloat kTextSize = 15;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    [self configureViews];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self) {
        return nil;
    }
    
    [self configureViews];
    
    return self;
}

- (void)configureViews
{
    // profile image
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kProfileImageViewSize, kProfileImageViewSize)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileImageClick)];
        [imageView addGestureRecognizer:tap];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        [self.contentView addSubview:imageView];
    }

    // timeview
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([GLPiOSSupportHelper screenWidth] / 2 - kTimeLabelW / 2, kTopMargin, kTimeLabelW, kTimeLabelH)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont fontWithName:GLP_TITLE_FONT size:10.0f];
        label.userInteractionEnabled = NO;
        [self.contentView addSubview:label];
    }

    // text view
    {
        UIView *view = [UIView new];
        
        [ShapeFormatterHelper setRoundedViewWithNotClipToBounds:view toDiameter:32.0];
        
        UILabel *label = [UILabel new];
        label.font = [UIFont fontWithName:GLP_MESSAGE_FONT size:kTextSize];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        
        view.userInteractionEnabled = YES;
        [view addSubview:label];
        
        UITapGestureRecognizer *tapGestrureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainViewClick)];
        [view addGestureRecognizer:tapGestrureRecognizer];
        
        [self.contentView addSubview:view];
    }
    
    // error image
    {
        UIImage *image = [UIImage imageNamed:@"message_cell_error"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, kErrorImageW, kErrorImageH);
        [button setImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(errorButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:button];
    }
    
    // system message
    {
        UILabel *labelSystem = [[UILabel alloc] initWithFrame:CGRectMake([GLPiOSSupportHelper screenWidth] / 2 - kTimeLabelW / 2, kTopMargin, kTimeLabelW, kTimeLabelH)];
        labelSystem.textAlignment = NSTextAlignmentCenter;
        labelSystem.textColor = [UIColor lightGrayColor];
        labelSystem.font = [UIFont fontWithName:GLP_TITLE_FONT size:10.0f];
        labelSystem.userInteractionEnabled = NO;
        [self.contentView addSubview:labelSystem];
    }
    
    // read receipt message
    {
        //The Y position is changing depending on the bubble height.
        UILabel *readReceiptMessage = [[UILabel alloc] initWithFrame:CGRectMake([GLPiOSSupportHelper screenWidth] / 2 - kTimeLabelW / 2, kTopMargin, kTimeLabelW, kTimeLabelH)];
        readReceiptMessage.textAlignment = NSTextAlignmentCenter;
        readReceiptMessage.textColor = [UIColor lightGrayColor];
        readReceiptMessage.font = [UIFont fontWithName:GLP_TITLE_FONT size:10.0f];
        readReceiptMessage.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGestrureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(readReceiptLabelClick)];
        [readReceiptMessage addGestureRecognizer:tapGestrureRecognizer];
        [self.contentView addSubview:readReceiptMessage];
    }
    
    // image view
    {
        UIImageView *messageImageView = [UIImageView new];
        messageImageView.contentMode = UIViewContentModeScaleAspectFill;
        messageImageView.backgroundColor = [AppearanceHelper grayGleepostColour];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageImageClick)];
        [messageImageView addGestureRecognizer:tap];
        messageImageView.clipsToBounds = YES;
        CGRectSetWH(messageImageView, [GLPMessageCell imageMessageWidth], [GLPMessageCell imageMessageHeight]);
        [ShapeFormatterHelper setRoundedViewWithNotClipToBounds:messageImageView toDiameter:32.0];
        messageImageView.userInteractionEnabled = YES;
        messageImageView.hidden = YES;
        [self.contentView addSubview:messageImageView];
    }
    
    self.selectedBackgroundView = [UIView new];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)configureWithMessage:(GLPMessage *)message
{
    _message = message;
    _isOnLeftSide = [message.cellIdentifier isEqualToString:kMessageLeftCell];
    
    _height = kTopMargin;
    
    if([_message isKindOfClass:[GLPSystemMessage class]])
    {
        [self setHiddedElementsOnSystemMessage:YES];
        [self configureSystemMessage];
    }
    else
    {
        [self setHiddedElementsOnSystemMessage:NO];
        [self configureProfileImage];
        [self configureTimeLabel];
        
        if([self.message isImageMessage])
        {
            [self configureMessageImage];
        }
        else
        {
            [self configureMessageText];
        }
        
        [self configureReadReceiptLabel];
    }
    
    _height += kBottomMargin;
    
    if(_height < kProfileImageViewSize && ![_message isKindOfClass:[GLPSystemMessage class]]) {
        _height = kProfileImageViewSize;
    }
    
    CGRectSetH(self.contentView, _height);
}

- (void)configureSystemMessage
{
    UILabel *label = self.contentView.subviews[4];
    GLPSystemMessage *sMessage = (GLPSystemMessage *)_message;
    [label setText:[sMessage systemMessage]];
}

- (void)configureProfileImage
{
    UIImageView *imageView = self.contentView.subviews[0];
    
//    if(_message.hasHeader) {
    
    if(_message.needsProfileImage || _viewMode) {
        
        if(!_message.hasHeader && !_viewMode)
        {
            _height += 20 + kTimeLabelBottomMargin;
        }
        
        imageView.hidden = NO;
        
        CGRectSetXY(imageView, [self xForCurrentSide:kProfileImageViewSideMargin w:kProfileImageViewSize], kTopMargin + kProfileImageViewTopMargin);
        
        UIImage *defaultProfilePicture = [GLPImageHelper placeholderUserImage];
        
        if([_message.author hasProfilePicture])
        {
            [imageView sd_setImageWithURL:[NSURL URLWithString:_message.author.profileImageUrl] placeholderImage:[GLPImageHelper placeholderUserImage] options:SDWebImageRetryFailed];
        } else
        {
            imageView.image = defaultProfilePicture;
        }
        
        [ShapeFormatterHelper setRoundedView:imageView toDiameter:imageView.frame.size.height];
        
    } else {
        imageView.hidden = YES;
    }
}

- (void)configureTimeLabel
{
    UILabel *label = self.contentView.subviews[1];
    
//    DDLogDebug(@"configureTimeLabel: %@", _message.content);
    
    if(_message.hasHeader || _viewMode) {
        label.hidden = NO;
        
//        label.text = [[[GLPDateFormatterHelper messageDateFormatter] stringFromDate:_message.date] uppercaseString];
        label.text = [[[GLPDateFormatterHelper messageDateFormatterWithDate:_message.date] stringFromDate:_message.date] uppercaseString];
        
        _height += label.frame.size.height + kTimeLabelBottomMargin;
        
    } else {
        label.hidden = YES;
    }
}

- (void)configureReadReceiptLabel
{
    UILabel *readReceiptLabel = self.contentView.subviews[5];
    
    NSString *readReceiptMessage = [[GLPReadReceiptsManager sharedInstance] getReadReceiptMessageWithMessage:_message];
    
    if(readReceiptMessage && !_viewMode) {
        readReceiptLabel.hidden = NO;
        readReceiptLabel.text = readReceiptMessage;
        CGRectSetY(readReceiptLabel, _height + kTimeLabelBottomMargin);
        _height += readReceiptLabel.frame.size.height + kTimeLabelBottomMargin;
        
    } else {
        readReceiptLabel.hidden = YES;
    }
}

- (void)configureMessageImage
{
    DDLogDebug(@"GLPMessageCell configureMessageImage %@", self.message.content);
    UIImageView *imageView = self.contentView.subviews[6];
    UIView *view = self.contentView.subviews[2];
    view.hidden = YES;
    imageView.hidden = NO;
    
    
    imageView.alpha = _message.sendStatus == kSendStatusLocal ? 0.15 : 1;
    
    //Configure positioning.
    
    CGFloat x = [self xForCurrentSide:kSideMarginIncludingProfileImage w:[GLPMessageCell imageMessageWidth]];

    _height += kContentImageVerticalPadding;
    
    imageView.frame = CGRectMake(x, _height, [GLPMessageCell imageMessageWidth], [GLPMessageCell imageMessageHeight]);
    
    [imageView setImageWithURL:[NSURL URLWithString:_message.content] placeholderImage:nil options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    UIButton *errorButton = self.contentView.subviews[3];
    
    //For now hide it.
    errorButton.hidden = YES;
    
    _height += [GLPMessageCell imageMessageHeight];
}

- (void)configureMessageText
{
    UIImageView *imageView = self.contentView.subviews[6];
    imageView.hidden = YES;
    
    UIView *view = self.contentView.subviews[2];
    UILabel *label = view.subviews[0];
    UIButton *errorButton = self.contentView.subviews[3];

    CGSize labelSize = [GLPMessageCell contentLabelSizeForMessage:_message];
    
    if(labelSize.width < kContentLabelMinimalW) {
        labelSize.width = kContentLabelMinimalW;
        label.textAlignment = NSTextAlignmentCenter;
    } else {
        label.textAlignment = NSTextAlignmentLeft;
    }
    
    CGFloat w = labelSize.width + kContentLabelHorizontalPadding;
    CGFloat h = labelSize.height + kContentLabelVerticalPadding;
    CGFloat x = [self xForCurrentSide:kSideMarginIncludingProfileImage w:w];
    view.frame = CGRectMake(x, _height, w, h);

    view.alpha = _message.sendStatus == kSendStatusLocal ? 0.15 : 1;
    
    label.frame = CGRectMake(kContentLabelHorizontalPadding / 2, kContentLabelVerticalPadding / 2, labelSize.width, labelSize.height);
    label.text = _message.content;
        
    if(_isOnLeftSide) {
//        view.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:234.0/255.0 blue:176.0/255.0 alpha:1.0];
        view.backgroundColor = [AppearanceHelper lightGrayGleepostColour];
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        [ShapeFormatterHelper setBorderToView:view withColour:[AppearanceHelper borderMessengerGleepostColour] andWidth:0.5];

    } else {
//        view.backgroundColor = [UIColor clearColor];
        view.backgroundColor = [AppearanceHelper greenGleepostColour];
//        label.textColor = [UIColor colorWithRed:70.0f/255.0f green:70.0f/255.0f blue:70.0f/255.0f alpha:1.0f];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        [ShapeFormatterHelper setBorderToView:view withColour:[AppearanceHelper borderGreenMessengerGleepostColour] andWidth:0.5];
    }
    
    
    
    if(_message.sendStatus == kSendStatusFailure) {
        errorButton.hidden = NO;
        CGFloat errorX = _isOnLeftSide ? CGRectGetMaxX(view.frame) + kErrorImageSideMargin : view.frame.origin.x - kErrorImageSideMargin - kErrorImageW;
        CGFloat errorY = CGRectGetMidY(view.frame) - errorButton.frame.size.height / 2;
        CGRectSetXY(errorButton, errorX, errorY);
    } else {
        errorButton.hidden = YES;
    }

    _height += h;
}

- (void)setHiddedElementsOnSystemMessage:(BOOL)hidden
{
    for(NSUInteger index = 0; index < self.contentView.subviews.count; ++index)
    {
        UIView *v = self.contentView.subviews[index];
        
        if(index != 4)
        {
            [v setHidden:hidden];
        }
        else
        {
            [v setHidden:!hidden];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{

}

# pragma mark - Actions

- (void)errorButtonClick
{
    [_delegate errorButtonClickForMessage:_message];
}

- (void)profileImageClick
{
    [_delegate profileImageClickForMessage:_message];
}

- (void)readReceiptLabelClick
{
    [_delegate readReceitClickForMessage:_message];
}

- (void)mainViewClick
{
    [_delegate mainViewClickForMessage:_message];
}

- (void)messageImageClick
{
    UIImageView *imageView = self.contentView.subviews[6];
    [_delegate messageImageClickedForMessage:_message withImageView:imageView];
}

# pragma mark - Helpers

+ (CGSize)contentLabelSizeForMessage:(GLPMessage *)message
{
    UIFont *font = [UIFont fontWithName:GLP_MESSAGE_FONT size:kTextSize];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:message.content attributes:@{NSFontAttributeName: font}];
    
    CGFloat maxWidth = KViewW - (kSideMarginIncludingProfileImage + kContentLabelHorizontalPadding);
    if(message.sendStatus == kSendStatusFailure) {
        maxWidth -= kOppositeSideMarginWithError;
    } else {
        maxWidth -= kOppositeSideMarginWithoutError;
    }
    
    CGSize size = [attributedText boundingRectWithSize:(CGSize){maxWidth, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size;
    
    //    CGRect rect = [attributedText boundingRectWithSize:(CGSize){maxWidth, CGFLOAT_MAX}
    //                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
    //                                               context:nil];
    
    return (CGSize){ceilf(size.width), ceilf(size.height)};
}

+ (CGFloat)viewHeightForMessage:(GLPMessage *)message
{
    CGFloat height = kTopMargin;
    
    
    if((message.hasHeader || message.needsProfileImage) && ![message isKindOfClass:[GLPSystemMessage class]]) {
        height = kTimeLabelH + kTimeLabelBottomMargin;
    }
    
    if([message isImageMessage])
    {
        height += [GLPMessageCell imageMessageHeight];
    }
    else
    {
        height += [GLPMessageCell contentLabelSizeForMessage:message].height;
    }
    
    if(![message isKindOfClass:[GLPSystemMessage class]])
    {
        height += kContentLabelVerticalPadding;
    
        if([[GLPReadReceiptsManager sharedInstance] doesMessageNeedSeenMessage:message])
        {
            height += kTimeLabelH;
        }
    }
    
    height += kBottomMargin;
    
    return height;
}

/**
 This method should be used only by GLPMessageDetailViewController.
 
 @param message the actual message (non system one).
 @return the height of the message.
 */
+ (CGFloat)viewHeightForMessageInViewMode:(GLPMessage *)message
{
    CGFloat height = kTopMargin;
    
    height = kTimeLabelH + kTimeLabelBottomMargin;
    
    
    height += [GLPMessageCell contentLabelSizeForMessage:message].height;
    
    height += kContentLabelVerticalPadding;
    
    if([[GLPReadReceiptsManager sharedInstance] doesMessageNeedSeenMessage:message])
    {
        height += kTimeLabelH;
    }
    
    height += kBottomMargin;
    
    return height + kViewModeMargin;
}

+ (CGFloat)imageMessageHeight
{
    return 200;
}

+ (CGFloat)imageMessageWidth
{
    return [GLPiOSSupportHelper screenWidth] * 0.43;
}

- (CGFloat)xForCurrentSide:(CGFloat)x w:(CGFloat)w
{
    if(_isOnLeftSide) {
        return x;
    } else {
        return self.contentView.frame.size.width - w - x;
    }
}

@end
