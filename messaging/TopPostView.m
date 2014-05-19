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

@interface TopPostView ()

@property (weak, nonatomic) IBOutlet UILabel *eventTitleLbl;

@property (weak, nonatomic) IBOutlet UILabel *eventTimeLbl;


@end

@implementation TopPostView

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
    [_eventTitleLbl setText:post.eventTitle];
    
    [self setEventTimeWithTime:post.dateEventStarts];
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


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
