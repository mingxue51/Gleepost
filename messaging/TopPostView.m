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

@interface TopPostView ()

@property (weak, nonatomic) IBOutlet UILabel *eventTitleLbl;

@property (weak, nonatomic) IBOutlet UILabel *eventTimeLbl;

@property (weak, nonatomic) IBOutlet UIButton *moreOptionsBtn;

@property (weak, nonatomic) IBOutlet UIButton *locationBtn;

@property (weak, nonatomic) IBOutlet UIImageView *locationImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eventTitleLblHeight;

@property (strong, nonatomic) GLPPost *post;

@end

@implementation TopPostView

const float TITLE_MAX_WIDTH = 260.0;
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
//    [ShapeFormatterHelper setBorderToView:self withColour:[UIColor blueColor] andWidth:1.0f];
    
    _post = post;
    
    float height = [TopPostView getContentLabelSizeForContent:post.eventTitle];
    
    [_eventTitleLblHeight setConstant:height];
    
    [_eventTitleLbl setText:post.eventTitle];
    
    [self setEventTimeWithTime:post.dateEventStarts];
    
    [self configureLocationElementsWithPost:post];
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
    if ([[NSDate date] compare:date] == NSOrderedDescending)
    {
        [_eventTimeLbl setText:[date timeAgo]];
        
    } else if ([[NSDate date] compare:date] == NSOrderedAscending)
    {
        
        [_eventTimeLbl setText:[date stringWithHumanizedTimeDifference:NSDateHumanizedSuffixLeft withFullString:YES]];
        
    } else
    {
        [_eventTimeLbl setText:[date timeAgo]];
        
    }
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
    NSString *notificationName = [NSString stringWithFormat:@"%@_%ld", GLPNOTIFICATION_SHOW_MORE_OPTIONS, (long)_post.remoteKey];

    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self];
}

-(BOOL)isCurrentPostBelongsToCurrentUser
{
    return ([SessionManager sharedInstance].user.remoteKey == self.post.author.remoteKey);
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
    
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){TITLE_MAX_WIDTH, TITLE_MAX_HEIGHT}
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
