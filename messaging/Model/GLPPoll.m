//
//  GLPPoll.m
//  Gleepost
//
//  Created by Silouanos on 17/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPPoll.h"

@implementation GLPPoll

- (void)setAndCalculateVotes:(NSMutableDictionary *)votes
{
    //TODO: Implement that so we can calculate the sum of votes
    //and for each individual vote we can calculate the percentage.
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Options %@, votes %@, expires at %@, your vote %@", self.options, self.votes, self.expirationDate, self.usersVote];
}

@end
