//
//  GLPStretchedImageView.m
//  Gleepost
//
//  Created by Σιλουανός on 28/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPStretchedImageView.h"
#import "ShapeFormatterHelper.h"
#import "NSString+Utils.h"
#import "GLPiOSSupportHelper.h"

@interface GLPStretchedImageView ()

@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UIFont *font;
@property (strong, nonatomic) UIImageView *transImageView;
//@property (strong, nonatomic) UIButton *joinButton;
@end

@implementation GLPStretchedImageView

const float kStretchedImageHeight = 250;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self configureFont];

        [self configureLabel];
        
//        [self configureJoinButton];
        
        [self configureTransparentImageView];
    }
    
    return self;
}

#pragma mark - Configuration
//
//- (void)configureJoinButton
//{
//    _joinButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0f, self.frame.size.height - 45, 40.0f, 40.0f)];
//    
//    [_joinButton setBackgroundImage:[UIImage imageNamed:@"temp_request_to_join"] forState:UIControlStateNormal];
//    
//    [_joinButton addTarget:self action:@selector(joinOrRequestToJoin) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self addSubview:_joinButton];
//}

- (void)configureLabel
{
    CGFloat screenWidth = [GLPiOSSupportHelper screenWidth];
    
    _title = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 130.0, screenWidth - 40, 80.0)];
    
    [_title setCenter:CGPointMake(screenWidth / 2, _title.center.y)];
    
    [_title setFont:_font];
    
    [_title setTextColor:[UIColor whiteColor]];
    
    [_title setTextAlignment:NSTextAlignmentCenter];
    
    [_title setNumberOfLines:0];
    
//    [ShapeFormatterHelper setBorderToView:_title withColour:[UIColor redColor] andWidth:1.0];
    
    [self addSubview:_title];
}

- (void)configureFont
{
    _font = [UIFont fontWithName:@"HelveticaNeue" size:22.0];
}

- (void)configureTransparentImageView
{
    _transImageView = [[UIImageView alloc] initWithFrame:self.frame];
    
    CGRectSetW(_transImageView, [GLPiOSSupportHelper screenWidth]);
    
    [_transImageView setBackgroundColor:[UIColor blackColor]];
    
    [_transImageView setAlpha:0.5 ];
    
    [_transImageView setClipsToBounds:YES];
    
    [self addSubview:_transImageView];
    
    [self sendSubviewToBack:_transImageView];
}

#pragma mark - Modifiers

- (void)setTextInTitle:(NSString *)text
{
    [_title setText:text];
    
    CGRectSetH(_title, [self getContentLabelSizeForContent:text]);
}

- (void)setHeightOfTransImage:(float)height
{
    CGRectSetH(_transImageView, height);
}

- (void)setImageUrl:(NSString *)imageUrl
{
    [super setImageUrl:imageUrl withPlaceholderImage:@"default_thumbnail"];
    
    if([imageUrl isEmpty] || !imageUrl)
    {
        [_transImageView setHidden:YES];
    }
}

#pragma mark - Helpers

- (float)getContentLabelSizeForContent:(NSString *)content
{
    int maxWidth = _title.frame.size.width;
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName: _font}];
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){maxWidth, CGFLOAT_MAX}
                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               context:nil];
    
    return rect.size.height;
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
