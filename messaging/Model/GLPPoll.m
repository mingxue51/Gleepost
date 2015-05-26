//
//  GLPPoll.m
//  Gleepost
//
//  Created by Silouanos on 17/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPPoll.h"
#import "NSDate+Calculations.h"

@implementation GLPPoll

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initialiseObjects];
    }
    return self;
}

- (id)initWithKey:(NSInteger)key
{
    self = [super init];
    if (self)
    {
        [self initialiseObjects];
        self.key = key;
    }
    return self;
}

- (void)initialiseObjects
{
    self.sumVotes = 0;
    self.didUserVote = NO;
    _votes = [[NSMutableDictionary alloc] init];
}

#pragma mark - Accessors

- (CGFloat)voteInPercentageWithOption:(NSString *)option
{
    NSInteger vote = [[self.votes objectForKey:option] integerValue];

    return (CGFloat)vote / self.sumVotes;
}

#pragma mark - Modifiers

- (void)setVotes:(NSDictionary *)votes
{
    _votes = votes.mutableCopy;
    
    //Find the sum of votes.
    for(NSString *optionKey in votes)
    {
        NSInteger vote = [[votes objectForKey:optionKey] integerValue];
        self.sumVotes += vote;
    }
    
    for(NSString *option in self.options)
    {
        if(![_votes objectForKey:option])
        {
            [_votes setObject:@(0) forKey:option];
        }
    }
}

- (void)updateVotesWithWebSocketData:(GLPPoll *)webSocketPoll
{
    self.options = webSocketPoll.options;
    [self setVotes:webSocketPoll.votes.mutableCopy];
}

- (void)userVotedWithOption:(NSString *)option
{
    NSInteger vote = [[self.votes objectForKey:option] integerValue];
    ++vote;
    [self.votes setObject:@(vote) forKey:option];
    self.usersVote = option;
    self.sumVotes += 1;
}

- (void)revertVotingWithOption:(NSString *)option
{
    NSInteger vote = [[self.votes objectForKey:option] integerValue];
    --vote;
    [self.votes setObject:@(vote) forKey:option];
    self.usersVote = nil;
    self.sumVotes -= 1;
}

- (void)setUsersVote:(NSString *)usersVote
{
    _usersVote = usersVote;
    self.didUserVote = (_usersVote) ? YES : NO;
}

- (BOOL)pollEnded
{
    return ([[self.expirationDate substractWithDate:[NSDate date]] isEqualToString:@"ENDED"]);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Options %@, votes %@, expires at %@, your vote %@", self.options, self.votes, self.expirationDate, self.usersVote];
}

@end
