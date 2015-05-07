//
//  CLPostTimeLocationView.m
//  Gleepost
//
//  Created by Silouanos on 06/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  Location time view (the one with the black transparent background) on the post image view (or cell).
//  We are using a custom class to resize the view depending on the Location and time number of characters.

#import "CLPostTimeLocationView.h"
#import "GLPiOSSupportHelper.h"
#import "GLPLocation.h"
#import "DateFormatterHelper.h"
#import "CLPostView.h"

@interface CLPostTimeLocationView ()

@property (assign, nonatomic) CGFloat viewMaxWidth;
@property (assign, nonatomic) CGFloat locationLabelMaxWidth;
@property (assign, nonatomic, readonly) CGFloat viewWidthPadding;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeWidthConstraint;


@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIImageView *locationImageView;

@property (strong, nonatomic) GLPLocation *location;
@property (strong, nonatomic) NSDate *dateEventStarts;

@end

@implementation CLPostTimeLocationView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self intialiseConstants];
}

- (void)setLocation:(GLPLocation *)location andTime:(NSDate *)time
{

    self.location = location;
    self.dateEventStarts = time;
    

    [self configureTimeLabel];
    
    [self configureMaxWidths];
    
    [self configureLocationButton];
    
    



    
    [self configureViewWidth];
}



#pragma mark - Configuration

- (void)intialiseConstants
{
    _viewWidthPadding = 5.0;
}

- (void)configureLocationButton
{
    [self setHiddenLocationElements:(!self.location)];
    
    CGFloat locationButtonWidth = [self getContentLabelWidthForContent:self.location.name] + 0.5;
    
    if(locationButtonWidth > self.locationLabelMaxWidth)
    {
        locationButtonWidth = self.locationLabelMaxWidth;
    }
    
    [self.locationButton setTitle:self.location.name forState:UIControlStateNormal];
    self.locationWidthConstraint.constant = locationButtonWidth;
}

- (void)configureTimeLabel
{
    NSString *stringTime = [DateFormatterHelper generateStringTimeForPostEventWithTime:self.dateEventStarts];
    self.timeLabel.text = stringTime;
    self.timeWidthConstraint.constant = [self getContentLabelWidthForContent:stringTime] + 0.5;
}

- (void)setHiddenLocationElements:(BOOL)hidden
{
    [self.locationButton setHidden:hidden];
    [self.locationImageView setHidden:hidden];
}

- (void)configureViewWidth
{
    if(self.location)
    {
        [self.locationButton layoutIfNeeded];
        
        CGFloat finalViewWidth = self.locationButton.frame.origin.x + self.locationWidthConstraint.constant + self.viewWidthPadding;
        
        DDLogDebug(@"configureViewWidth %f - max %f", finalViewWidth, self.viewMaxWidth);

        
        if(finalViewWidth > self.viewMaxWidth)
        {
            finalViewWidth = self.viewMaxWidth;
        }
        
        self.widthConstraint.constant = finalViewWidth;
    }
    else
    {
        [self.timeLabel layoutIfNeeded];
        self.widthConstraint.constant = self.timeLabel.frame.origin.x + self.timeWidthConstraint.constant + self.viewWidthPadding;
    }
}

- (void)configureMaxWidths
{
    [self.locationImageView layoutIfNeeded];
    
    CGFloat locationImageViewX = self.locationImageView.frame.origin.x;
    CGFloat locationImageViewWidth = self.locationImageView.frame.size.width;
    
    self.viewMaxWidth = [CLPostView width] - 16.0 * 2;
    
    self.locationLabelMaxWidth = ([CLPostView width] - 16.0 * 2) - (locationImageViewX + locationImageViewWidth);
}


#pragma mark - Label width

- (CGFloat)getContentLabelWidthForContent:(NSString *)content
{
    if(!content)
    {
        return 0.0;
    }
    
    UIFont *font = [UIFont fontWithName:GLP_TITLE_FONT size:12.0];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName: font}];
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){CGFLOAT_MAX, CGFLOAT_MAX}
                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               context:nil];
    CGSize size = rect.size;
    
    return size.width;
}

//- (CGFloat)maxLocationLabelWidth

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
