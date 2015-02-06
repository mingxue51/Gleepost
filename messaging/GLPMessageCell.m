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

@interface GLPMessageCell()

@property (strong, nonatomic) GLPMessage *message;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) BOOL isOnLeftSide;

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
static const CGFloat kErrorImageSideMargin = 6;
static const CGFloat kOppositeSideMarginWithoutError = 30;
static const CGFloat kOppositeSideMarginWithError = 10 + kErrorImageW + kErrorImageSideMargin;
static const CGFloat kSideMarginIncludingProfileImage = kProfileImageViewSideMargin + kProfileImageViewSize + kProfileImageViewOppositeSideMargin;
static const CGFloat kTopMargin = 0;
static const CGFloat kBottomMargin = 2; //7


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
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width / 2 - kTimeLabelW / 2, kTopMargin, kTimeLabelW, kTimeLabelH)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont fontWithName:GLP_TITLE_FONT size:10.0f];
        label.userInteractionEnabled = NO;
        [self.contentView addSubview:label];
    }

    // text view
    {
        UIView *view = [UIView new];
//        view.layer.cornerRadius = 12.0;
        [ShapeFormatterHelper setCornerRadiusWithView:view andValue:3];
        
        UIImageView *imageView = [UIImageView new];
        imageView.image = [UIImage imageNamed:@"yourchatbubble4"];
        imageView.layer.masksToBounds = YES;
//        imageView.layer.cornerRadius = 12.0;
        [ShapeFormatterHelper setCornerRadiusWithView:imageView andValue:4];
        
        
//        imageView.layer.borderColor = [[UIColor colorWithRed:3.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0] CGColor];
//        imageView.layer.borderWidth = 2;
        
        UILabel *label = [UILabel new];
        label.font = [UIFont fontWithName:GLP_MESSAGE_FONT size:17]; //16
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        
        view.userInteractionEnabled = NO;
        
        [view addSubview:imageView];
        [view addSubview:label];
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
    self.selectedBackgroundView = [UIView new];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)configureWithMessage:(GLPMessage *)message
{
    _message = message;
    _isOnLeftSide = [message.cellIdentifier isEqualToString:kMessageLeftCell];
    
    _height = kTopMargin;
    
    [self configureProfileImage];
    [self configureTimeLabel];
    [self configureMessageText];
    
    _height += kBottomMargin;
    
    if(_height < kProfileImageViewSize) {
        _height = kProfileImageViewSize;
    }
    
    CGRectSetH(self.contentView, _height);
}

- (void)configureProfileImage
{
    UIImageView *imageView = self.contentView.subviews[0];
    
//    if(_message.hasHeader) {
    if(_message.needsProfileImage) {
        
        if(!_message.hasHeader)
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
    
    if(_message.hasHeader) {
        label.hidden = NO;
        
//        label.text = [[[GLPDateFormatterHelper messageDateFormatter] stringFromDate:_message.date] uppercaseString];
        label.text = [[[GLPDateFormatterHelper messageDateFormatterWithDate:_message.date] stringFromDate:_message.date] uppercaseString];
        
        _height += label.frame.size.height + kTimeLabelBottomMargin;
        
    } else {
        label.hidden = YES;
    }
}

- (void)configureMessageText
{
    UIView *view = self.contentView.subviews[2];
    UIImageView *imageView = view.subviews[0];
    UILabel *label = view.subviews[1];
    
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
    

    imageView.frame = CGRectMake(0, 0, w, h);

    label.frame = CGRectMake(kContentLabelHorizontalPadding / 2, kContentLabelVerticalPadding / 2, labelSize.width, labelSize.height);
    label.text = _message.content;
        
    if(_isOnLeftSide) {
//        view.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:234.0/255.0 blue:176.0/255.0 alpha:1.0];
        view.backgroundColor = [AppearanceHelper lightGrayGleepostColour];
        imageView.hidden = YES;
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        [ShapeFormatterHelper setBorderToView:view withColour:[AppearanceHelper borderMessengerGleepostColour] andWidth:0.5];

    } else {
//        view.backgroundColor = [UIColor clearColor];
        imageView.hidden = YES;
        view.backgroundColor = [AppearanceHelper blueGleepostColour];
//        label.textColor = [UIColor colorWithRed:70.0f/255.0f green:70.0f/255.0f blue:70.0f/255.0f alpha:1.0f];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        
        UIColor *c = [AppearanceHelper borderBlueMessengerGleepostColour];
        
        [ShapeFormatterHelper setBorderToView:view withColour:[AppearanceHelper borderBlueMessengerGleepostColour] andWidth:0.5];

    }
    
    
    
    UIButton *errorButton = self.contentView.subviews[3];
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

# pragma mark - Helpers

+ (CGSize)contentLabelSizeForMessage:(GLPMessage *)message
{
    UIFont *font = [UIFont fontWithName:GLP_MESSAGE_FONT size:17];
    
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
    
    if(message.hasHeader || message.needsProfileImage) {
        height = kTimeLabelH + kTimeLabelBottomMargin;
    }
    
    height += [GLPMessageCell contentLabelSizeForMessage:message].height + kContentLabelVerticalPadding;
    height += kBottomMargin;
    
    return height;
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
