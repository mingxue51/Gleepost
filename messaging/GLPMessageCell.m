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
#import "Gleepost-Swift.h"

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
static const CGFloat kProfileImageViewSize = 30;
static const CGFloat kTimeLabelW = 200;
static const CGFloat kTimeLabelH = 20;
static const CGFloat kContentLabelMinimalW = 15;
static const CGFloat kErrorImageW = 13;
static const CGFloat kErrorImageH = 17;

static const CGFloat kProfileImageViewTopMargin = 9;
static const CGFloat kProfileImageViewSideMargin = 4; //6
static const CGFloat kProfileImageViewOppositeSideMargin = 3; //6
static const CGFloat kTimeLabelBottomMargin = 0;
static const CGFloat kContentLabelVerticalPadding = 18; //15
static const CGFloat kContentLabelHorizontalPadding = 24; //20
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
        GLPProfileMessageImageView *imageView = [[GLPProfileMessageImageView alloc] initWithFrame:CGRectMake(0, 0, kProfileImageViewSize, kProfileImageViewSize)];
        [imageView setGesture:self selector:@selector(profileImageClick)];
        [self.contentView addSubview:imageView];
    }

    // timeview
    {
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([GLPiOSSupportHelper screenWidth] / 2 - kTimeLabelW / 2, kTopMargin, kTimeLabelW, kTimeLabelH)];
//        label.textAlignment = NSTextAlignmentCenter;
//        label.textColor = [UIColor lightGrayColor];
//        label.font = [UIFont fontWithName:GLP_TITLE_FONT size:10.0f];
//        label.userInteractionEnabled = NO;
//        [self.contentView addSubview:label];
        
        GLPTimestampMessageLabel *label = [[GLPTimestampMessageLabel alloc] initWithFrame:CGRectMake([GLPiOSSupportHelper screenWidth] / 2 - kTimeLabelW / 2, kTopMargin, kTimeLabelW, kTimeLabelH)];
        [self.contentView addSubview:label];
    }

    // text view
    {
        UIView *view = [UIView new];
        
        [ShapeFormatterHelper setRoundedViewWithNotClipToBounds:view toDiameter:32.0];
        
        GLPBackgroundMessageImageView *backImageView = [[GLPBackgroundMessageImageView alloc] initWithFrame:view.frame];
        [view addSubview:backImageView];
        
        UILabel *label = [UILabel new];
        label.font = [UIFont fontWithName:GLP_MESSAGE_FONT size:kTextSize];
        //label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
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

        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator setHidesWhenStopped:YES];
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageImageClick)];
        [messageImageView addGestureRecognizer:tap];
        messageImageView.clipsToBounds = YES;
        CGRectSetWH(messageImageView, [GLPMessageCell imageMessageWidth], [GLPMessageCell imageMessageHeight]);
        [ShapeFormatterHelper setRoundedViewWithNotClipToBounds:messageImageView toDiameter:32.0];
        messageImageView.userInteractionEnabled = YES;
        messageImageView.hidden = YES;
        
        CGRect imageViewFrame = messageImageView.frame;
        CGRect indicatorFrame = activityIndicator.frame;
        
        [activityIndicator setFrame:CGRectMake((imageViewFrame.size.width / 2) - (indicatorFrame.size.width / 2), imageViewFrame.size.height / 2 + indicatorFrame.size.height / 2, indicatorFrame.size.width, indicatorFrame.size.height)];
        
        [messageImageView addSubview:activityIndicator];
        
        [self.contentView addSubview:messageImageView];
    }
    
    // name label [7] in array
    {
        GLPNameMessageLabel *nameMessageLabel = [[GLPNameMessageLabel alloc] init];
        nameMessageLabel.hidden = YES;
        [self.contentView addSubview:nameMessageLabel];
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
        [self configureNameLabel];
        
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
    GLPProfileMessageImageView *imageView = self.contentView.subviews[0];
    
    if(_message.needsProfileImage || _viewMode) {
        
        if(!_message.hasHeader && !_viewMode)
        {
            _height += 20 + kTimeLabelBottomMargin;
        }
        
        imageView.hidden = NO;
        
        CGRectSetXY(imageView, [self xForCurrentSide:kProfileImageViewSideMargin w:kProfileImageViewSize], kTopMargin + kProfileImageViewTopMargin);
        [imageView setImage:_message.author.profileImageUrl hasProfileImage:[_message.author hasProfilePicture] userName:_message.author.name];
        
    } else {
        imageView.hidden = YES;
    }
}

- (void)configureTimeLabel
{
//    UILabel *label = self.contentView.subviews[1];
    
    GLPTimestampMessageLabel *label = self.contentView.subviews[1];
    
//    DDLogDebug(@"configureTimeLabel: %@", _message.content);
    
    if(_message.hasHeader || _viewMode) {
        label.hidden = NO;
        
//        label.text = [[[GLPDateFormatterHelper messageDateFormatter] stringFromDate:_message.date] uppercaseString];
//        label.text = [[[GLPDateFormatterHelper messageDateFormatterWithDate:_message.date] stringFromDate:_message.date] uppercaseString];
        
        [label setDate:self.message.date];
        
        _height += label.frame.size.height + kTimeLabelBottomMargin;
        
    } else {
        label.hidden = YES;
    }
}

/**
 This method should be executed only when the message belongs to 
 group messenger chat and when belongs to logged in user's.
 */
- (void)configureNameLabel
{    
    GLPNameMessageLabel *nameMessageLabel = self.contentView.subviews[7];
    
    if([self.message needsNameLabel])
    {
        [nameMessageLabel setUserNameWithUserName:_message.author.name];
        _height += nameMessageLabel.frame.size.height + [GLPNameMessageLabel labelBottomPadding];
        nameMessageLabel.hidden = NO;
    }
    else
    {
        nameMessageLabel.hidden = YES;
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
    UIImageView *imageView = self.contentView.subviews[6];
    UIView *view = self.contentView.subviews[2];
    view.hidden = YES;
    imageView.hidden = NO;
    
    imageView.alpha = _message.sendStatus == kSendStatusLocal ? 0.15 : 1;
    
    //Configure positioning.
    
    CGFloat x = [self xForCurrentSide:kSideMarginIncludingProfileImage w:[GLPMessageCell imageMessageWidth]];

    _height += kContentImageVerticalPadding;
    
    imageView.frame = CGRectMake(x, _height, [GLPMessageCell imageMessageWidth], [GLPMessageCell imageMessageHeight]);
    
    NSString *contentFromMediaContent = [_message getContentFromMediaContent];
    
    [imageView setImageWithURL:[NSURL URLWithString:contentFromMediaContent] placeholderImage:nil options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    //If the image is pending show indicator.
    if([_message doesStringContainTimestamp:contentFromMediaContent])
    {
        UIActivityIndicatorView *indicator = imageView.subviews[0];
        indicator.hidden = NO;
        [indicator startAnimating];
        
        CGRect imageViewFrame = imageView.frame;
        CGRect indicatorFrame = indicator.frame;
        
        [indicator setFrame:CGRectMake((imageViewFrame.size.width / 2) - (indicatorFrame.size.width / 2), imageViewFrame.size.height / 2 - indicatorFrame.size.height / 2, indicatorFrame.size.width, indicatorFrame.size.height)];
    }
    else
    {
        UIActivityIndicatorView *indicator = imageView.subviews[0];
        [indicator stopAnimating];
    }
    
    
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
    UILabel *label = view.subviews[1];
    UIButton *errorButton = self.contentView.subviews[3];
    GLPBackgroundMessageImageView *backImageView = view.subviews[0];

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
    
    label.frame = CGRectMake(kContentLabelHorizontalPadding / 2 + 1.0, kContentLabelVerticalPadding / 2 - 0.5, labelSize.width, labelSize.height);
    label.text = _message.content;
        
    if(_isOnLeftSide) {
        view.backgroundColor = [UIColor clearColor];

        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
//        [ShapeFormatterHelper setBorderToView:view withColour:[AppearanceHelper borderMessengerGleepostColour] andWidth:0.5];
        [ShapeFormatterHelper setBorderToView:view withColour:[UIColor clearColor] andWidth:0.5];
        [backImageView changeImageView:BubbleTypeIncomingTailless size:view.frame];

    } else {
        view.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
//        [ShapeFormatterHelper setBorderToView:view withColour:[AppearanceHelper borderGreenMessengerGleepostColour] andWidth:0.5];
        
        [backImageView changeImageView:BubbleTypeOutgoingTailless size:view.frame];
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
    //UIFont *font = [UIFont fontWithName:GLP_MESSAGE_FONT size:kTextSize];
    UIFont *font = [UIFont systemFontOfSize:kTextSize];

    
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
    
    if([message needsNameLabel] && ![message isKindOfClass:[GLPSystemMessage class]])
    {
        height += [GLPNameMessageLabel labelHeight] + [GLPNameMessageLabel labelBottomPadding];
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
    
    if([message needsNameLabel])
    {
        height += [GLPNameMessageLabel labelHeight] + [GLPNameMessageLabel labelBottomPadding];
    }
    
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
