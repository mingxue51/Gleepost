//
//  PollingDataView.m
//  Gleepost
//
//  Created by Silouanos on 20/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  This class has the responsibility to manage the poll timing labels and make calculations
//  have to do with presenting the time left.

#import "PollingDataView.h"
#import "GLPPoll.h"
#import "NSDate+Calculations.h"

@interface PollingDataView ()

@property (weak, nonatomic) IBOutlet UILabel *timeLeftLabel;
@property (weak, nonatomic) IBOutlet UILabel *votesLabel;
@property (weak, nonatomic) IBOutlet UILabel *smallTimeLeftLabel;

@end

@implementation PollingDataView

- (void)setPollData:(GLPPoll *)pollData
{
    [self configureElementsDependingOnUsersVote:pollData];
    [self setDataToElementsWithPollData:pollData];
}

- (void)configureElementsDependingOnUsersVote:(GLPPoll *)pollData
{
    self.timeLeftLabel.hidden = [pollData didUserVote];
    self.votesLabel.hidden = ![pollData didUserVote];
    self.smallTimeLeftLabel.hidden = ![pollData didUserVote];
}

- (void)setDataToElementsWithPollData:(GLPPoll *)pollData
{
    NSString *formattedDate = [pollData.expirationDate substractWithDate:[NSDate date]];
    self.timeLeftLabel.text = formattedDate;
    self.smallTimeLeftLabel.text = formattedDate;
    self.votesLabel.text =  [NSString stringWithFormat:@"%ld %@", (long)pollData.sumVotes, (pollData.sumVotes == 1) ? @"VOTE" : @"VOTES"];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
