//
//  TopPostView.m
//  Gleepost
//
//  Created by Silouanos on 16/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "TopPostView.h"
#import "NSDate+TimeAgo.h"
#import "NSDate+HumanizedTime.h"
#import "ShapeFormatterHelper.h"
#import "GLPLocation.h"
#import "SessionManager.h"
#import "DateFormatterHelper.h"

@interface TopPostView ()

@property (weak, nonatomic) IBOutlet UILabel *eventTitleLbl;

@property (weak, nonatomic) IBOutlet UILabel *eventTimeLbl;

@property (weak, nonatomic) IBOutlet UIButton *moreOptionsBtn;

@property (weak, nonatomic) IBOutlet UIButton *locationBtn;

@property (weak, nonatomic) IBOutlet UIImageView *locationImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eventTitleLblHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationImageDistanceFromEdge;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationButtonWidth;


@end

@implementation TopPostView

const float TITLE_MAX_HEIGHT = 50.0;
const float TWO_LINES_HEIGHT = 40.0;
const float ONE_LINE_HEIGHT = 20;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        // Initialization code
    }
    return self;
}

-(void)setElementsWithPost:(GLPPost *)post
{
//    [ShapeFormatterHelper setBorderToView:self.eventTitleLbl withColour:[UIColor blueColor] andWidth:1.0f];
    
    //TODO: Fix that by creating specific queue. There is a problem here where an
    //      empty post is viewed without data in and then the actual data appeared.
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    
        float height = [TopPostView getContentLabelSizeForContent:post.eventTitle];

//        dispatch_async(dispatch_get_main_queue(), ^{
    
            [_eventTitleLblHeight setConstant:height];
            
            [_eventTitleLbl setText:post.eventTitle];
            
            [self setEventTimeWithTime:post.dateEventStarts];
            
            [self configureLocationElementsWithPost:post];
    
//        });
        
//    });

}

- (void)configureLocationElementsWithPost:(GLPPost *)post
{
    if(post.location)
    {
        [_locationImageView setHidden:NO];
        [_locationBtn setHidden:NO];
        
        [_locationBtn setTitle:post.location.name forState:UIControlStateNormal];
    }
    else
    {
        [_locationImageView setHidden:YES];
        [_locationBtn setHidden:YES];
    }
}

-(void)setEventTimeWithTime:(NSDate *)date
{
//    if ([[NSDate date] compare:date] == NSOrderedDescending)
//    {
//        [_eventTimeLbl setText:[date timeAgo]];
//        
//    } else if ([[NSDate date] compare:date] == NSOrderedAscending)
//    {
//        
//        [_eventTimeLbl setText:[date stringWithHumanizedTimeDifference:NSDateHumanizedSuffixLeft withFullString:YES]];
//        
//    } else
//    {
//        [_eventTimeLbl setText:[date timeAgo]];
//        
//    }
    
    _eventTimeLbl.text = [DateFormatterHelper generateStringTimeForPostEventWithTime:date];
}

#pragma mark - Modifiers

-(void)setEventTime:(NSString *)eventTime
{
    [_eventTimeLbl setText:eventTime];
}

-(void)setEventTitle:(NSString *)eventTitle
{
    [_eventTitleLbl setText:eventTitle];
}


#pragma mark - Selectors

- (IBAction)showLocation:(id)sender
{
    if(![_delegate respondsToSelector:@selector(locationPushed)])
    {
        return;
    }
    
    [_delegate locationPushed];
}

- (IBAction)moreOptions:(id)sender
{
    //TODO: For now call the same method from a MainPostView instance.
    //Check if that is ok in terms of the efficiency of the table view.
    
    [_mainPostView moreOptions:sender];
    
    
//    NSString *notificationName = [NSString stringWithFormat:@"%@_%ld", GLPNOTIFICATION_SHOW_MORE_OPTIONS, (long)_post.remoteKey];
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self];
}

//-(BOOL)isCurrentPostBelongsToCurrentUser
//{
//    return ([SessionManager sharedInstance].user.remoteKey == self.post.author.remoteKey);
//}

#pragma mark - Location button calculations

- (CGFloat)getLocationWidth:(NSString *)location
{
    if(!location)
    {
        return 0.0;
    }
    
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:14.0];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:location attributes:@{NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){[self getMaxLengthOfLocationButton], 18.0}
                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               context:nil];
    CGSize size = rect.size;
    return size.width;
}

- (CGFloat)getMaxLengthOfLocationButton
{
    return ([[UIScreen mainScreen] bounds].size.width / 2) - 18 - 10 - 2 - 8;
}

#pragma mark - Label size

+ (float)getContentLabelSizeForContent:(NSString *)content
{
    if(!content)
    {
        return 0.0;
    }
    
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:18.0];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName: font}];
    
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){[TopPostView getMaxTitleLabelHeight], TITLE_MAX_HEIGHT}
                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               context:nil];
    
    CGSize size = rect.size;
    
    
    return size.height;
}

+ (BOOL)isTitleTextOneLineOfCodeWithContent:(NSString *)content
{
    float currentTitleHeight = [TopPostView getContentLabelSizeForContent:content];
    
    if(currentTitleHeight < TWO_LINES_HEIGHT)
    {
        return YES;
    }
    
    return NO;
}

+ (CGFloat)getMaxTitleLabelHeight
{
    return [[UIScreen mainScreen] bounds].size.width -20 - 40;
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
