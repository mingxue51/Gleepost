//
//  GLPPoll.m
//  Gleepost
//
//  Created by Silouanos on 17/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPPoll.h"

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

- (void)initialiseObjects
{
    self.sumVotes = 0;
    self.didUserVote = NO;
    _votes = [[NSMutableDictionary alloc] init];
}

- (void)setAndCalculateVotes:(NSMutableDictionary *)votes
{
    //Find the sum of votes.
    for(NSString *optionKey in votes)
    {
        NSInteger vote = [[votes objectForKey:optionKey] integerValue];
        self.sumVotes += vote;
    }
    
    //Calculate the percentage for each option.
    for(NSString *optionKey in votes)
    {
        NSInteger vote = [[votes objectForKey:optionKey] integerValue];
        [self.votes setObject:@((CGFloat)vote/self.sumVotes) forKey:optionKey];
    }
    
    
    for(NSString *option in self.options)
    {
        if(![self.votes objectForKey:option])
        {
            [self.votes setObject:@(0.0) forKey:option];
        }
    }
}

- (void)userVotedWithOption:(NSString *)option
{
    [self.votes setObject:@(1.0) forKey:option];
    self.usersVote = option;
    self.sumVotes = 0;
}

- (void)revertVotingWithOption:(NSString *)option
{
    [self.votes setObject:@(0.0) forKey:option];
    self.usersVote = nil;
    self.sumVotes = 0;
}

- (void)setUsersVote:(NSString *)usersVote
{
    _usersVote = usersVote;
    self.didUserVote = (_usersVote) ? YES : NO;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Options %@, votes %@, expires at %@, your vote %@", self.options, self.votes, self.expirationDate, self.usersVote];
}

@end
