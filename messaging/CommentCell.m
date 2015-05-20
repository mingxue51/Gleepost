//
//  CommentCell.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "CommentCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSDate+TimeAgo.h"
#import <QuartzCore/QuartzCore.h>
#import "SessionManager.h"
#import "ContactsManager.h"
#import "ShapeFormatterHelper.h"
#import "AppearanceHelper.h"
#import "UIView+RoudedCorners.h"
#import "UIView+Borders.h"
#import "GLPImageHelper.h"
#import "GLPiOSSupportHelper.h"

@interface CommentCell()

@property (assign, nonatomic) float heightOfCell;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceFromBottom;
@property (weak, nonatomic) IBOutlet UIImageView *backgoundImageView;
@property (assign, nonatomic) CommentCellType cellType;

@property (assign, nonatomic) NSInteger commentIndex;
@property (assign, nonatomic) NSInteger commentsNumber;

@end


static const float FixedSizeOfTextCell = 53.0; //Before was 90. 75
static const float FollowingCellPadding = 0.0;
static const float CommentContentViewPadding = 0.0;  //15 before.
static const float CommentContentLabelMargin = 20 + 36 + 5 + 20;


@implementation CommentCell


/**
 Sets comment's data with comment's index in the array of comments.
 The index is used in order to decide what kind of comment is being created.
 There are three different kind of comment views: top, middle and bottom.
 For more information see the design in mockup.
 
 @param comment data of comment.
 @param index comment's index in the array is used to make UI decisions.
 @param commentsNumber comments' number is used to make UI decisions.
 
 */

-(void)setComment:(GLPComment*)comment withIndex:(NSInteger)index andNumberOfComments:(NSInteger)commentsNumber
{
    _commentIndex = index;
    _commentsNumber = commentsNumber;
    
    [self findCommentCellType];
    
    //Add user's remote key as an image tag.
    self.userImageView.tag = comment.author.remoteKey;
    
    //Set comment's content.
    [self.contentLabel setText:comment.content];
    
    [_userImageView setImageUrl:comment.author.profileImageUrl withPlaceholderImage:[GLPImageHelper placeholderUserImagePath]];
    [_userImageView setTag:comment.author.remoteKey];
    _userImageView.delegate = _delegate;
    [_userImageView setGesture:YES];

    
    //Meke the user's image circle.
    [ShapeFormatterHelper setRoundedView:self.userImageView toDiameter:self.userImageView.frame.size.height];
    
    
    
    //Set user's name.
    [self.userNameLabel setText:comment.author.name];
    _userNameLabel.tag = comment.author.remoteKey;
    [_userNameLabel setDelegate:_delegate];
    
    NSDate *currentDate = comment.date;
    
    //Set post's time.
    [self.postDateLabel setText:[[currentDate timeAgo] uppercaseString]];
    
//    [ShapeFormatterHelper setBorderToView:self withColour:[UIColor redColor] andWidth:0.5];
//    [ShapeFormatterHelper setBorderToView:self.postDateLabel withColour:[UIColor blackColor] andWidth:1.0];
    
    //Add touch gesture to profile image.
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigateToProfile:)];
//    [tap setNumberOfTapsRequired:1];
//    [self.userImageView addGestureRecognizer:tap];
    
    
//    [self formatCommentElements];
}

- (void)findCommentCellType
{
    if(_commentIndex == 0 && _commentsNumber == 1)
    {
        _cellType = kTopBottomCommentCell;
        
        return;
    }
    
    if(_commentIndex == 0)
    {
        _cellType = kTopCommentCell;
    }
    else if (_commentIndex == _commentsNumber - 1)
    {
        _cellType = kBottomCommentCell;
    }
    else
    {
        _cellType = kMiddleCommentCell;
    }
}

- (void)configureCommentCell
{
    self.distanceFromBottom.constant = -1.0;
    
    switch (_cellType) {
        case kTopCommentCell:
            [self configureTopCell];
            break;
            
        case kBottomCommentCell:
            self.distanceFromBottom.constant = 0.0;
            [self configureBottomCell];
            break;
            
        case kTopBottomCommentCell:
            [self configureTopBottomCommentCell];
            break;
            
        case kMiddleCommentCell:
            [self configureMiddleCell];
            break;
            
        default:
            DDLogDebug(@"Default");
            break;
    }
}

-(void)setCellHeight:(NSString*)content
{
    CGRect cellFrame = self.contentLabel.frame;
    
    float heightSize = [CommentCell getContentLabelSizeForContent:content].height;
    
    //[self.contentView setFrame:CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.heightOfCell+heightSize)];
    
    self.contentLabel.numberOfLines = 0;
    
    
//    [self.contentLabelHeight setConstant:heightSize];
    
    [self.contentLabel setFrame:CGRectMake(cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.width, heightSize)];
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
//    CGRect cellFrame = self.contentLabel.frame;
    
    CGSize heightSize = [CommentCell getContentLabelSizeForContent:self.contentLabel.text];
    
//    [self.contentView setFrame:CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.heightOfCell+heightSize)];
    
    self.contentLabel.numberOfLines = 0;
//    self.lineView.frame = CGRectMake(0, self.contentView.frame.size.height-1, self.contentView.frame.size.width, 1);

    
//    [self setElement:self.contentLabel size:heightSize];
    
    [self.contentLabelHeight setConstant:heightSize.height];
    
    [ShapeFormatterHelper resetAnyFormatOnView:_backgoundImageView];

    
    [self configureCommentCell];

    
//    [self.contentLabel setFrame:CGRectMake(cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.width, heightSize)];
}

-(void)setElement:(UIView*)element size:(CGSize)size
{
    [element setFrame:CGRectMake(element.frame.origin.x, element.frame.origin.y, [CommentCell getMaxLabelContentWidth], size.height)];
}

#pragma mark - UI methods

- (void)configureTopCell
{
    [ShapeFormatterHelper formatTopCellWithBackgroundView:_backgoundImageView andSuperView:self.contentView];
}

- (void)configureMiddleCell
{
    [self.backgoundImageView layoutIfNeeded];
    
    [ShapeFormatterHelper removeTopCellBottomLine:self.contentView];
    [_backgoundImageView addRightBorderWithWidth:1.0 andColor:[AppearanceHelper mediumGrayGleepostColour]];
    [_backgoundImageView addLeftBorderWithWidth:1.0 andColor:[AppearanceHelper mediumGrayGleepostColour]];
}

- (void)configureTopBottomCommentCell
{
    [ShapeFormatterHelper setCornerRadiusWithView:_backgoundImageView andValue:4];
    [ShapeFormatterHelper setBorderToView:_backgoundImageView withColour:[AppearanceHelper mediumGrayGleepostColour] andWidth:1.0];
}

- (void)configureBottomCell
{
    /**
     We are adding these 2 image views to the view because there was a problem
     with the 2 sides borders.
     */
//    UIImageView *im = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 0.0, 1.0, 2.0)];
//    [im setBackgroundColor:[AppearanceHelper mediumGrayGleepostColour]];
//    
//    [self.contentView addSubview:im];
//
//    im = [[UIImageView alloc] initWithFrame:CGRectMake([GLPiOSSupportHelper screenWidth] - 11, 0.0, 1.0, 2.0)];
//    [im setBackgroundColor:[AppearanceHelper mediumGrayGleepostColour]];
//    
//    [self.contentView addSubview:im];
//
//    [_backgoundImageView setRoundedCorners:UIRectCornerBottomRight | UIRectCornerBottomLeft radius:4.0];
//    
//    [_backgoundImageView addTopBorderWithHeight:2.0 andColor:[UIColor whiteColor]];
    
    [ShapeFormatterHelper removeTopCellBottomLine:self.contentView];

    [ShapeFormatterHelper formatBottomCellWithBackgroundView:_backgoundImageView andSuperView:self.contentView];
}

- (void)formatBackgroundView
{
    [ShapeFormatterHelper setBorderToView:_backgoundImageView withColour:[AppearanceHelper mediumGrayGleepostColour] andWidth:1.0f];
}

+ (CGSize)getContentLabelSizeForContent:(NSString *)content
{
    
    UIFont *font = [UIFont fontWithName:GLP_HELV_NEUE_LIGHT size:15.0];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName: font}];
        
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){[CommentCell getMaxLabelContentWidth], CGFLOAT_MAX}
                                               options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                               context:nil];
    
    CGSize size = rect.size;
    
    return size;

}

+ (CGFloat)getCellHeightWithContent:(NSString *)content image:(BOOL)isImage
{
    // initial height
    float height = (isImage) ? 0 : FixedSizeOfTextCell;
    
    // add content label height + message content view padding
    height += [CommentCell getContentLabelSizeForContent:content].height + CommentContentViewPadding;
    
    return height + FollowingCellPadding;
}

+ (CGFloat)getMaxLabelContentWidth
{
    return [GLPiOSSupportHelper screenWidth] - CommentContentLabelMargin;
}

@end