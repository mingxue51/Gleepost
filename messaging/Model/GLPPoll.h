//
//  GLPPoll.h
//  Gleepost
//
//  Created by Silouanos on 17/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPEntity.h"
#import "GLPEntity.h"

@interface GLPPoll : GLPEntity

@property (strong, nonatomic) NSDate *expirationDate;
@property (strong, nonatomic) NSArray *options;

/** <Option (NSString), Vote Count (NSInteger)> as key value. */
@property (strong, nonatomic, readonly) NSMutableDictionary *votes;
@property (strong, nonatomic) NSString *usersVote;
@property (assign, nonatomic) NSInteger sumVotes;
@property (assign, nonatomic) BOOL didUserVote;

- (id)initWithKey:(NSInteger)key;
- (void)setVotes:(NSMutableDictionary *)votes;
- (void)userVotedWithOption:(NSString *)option;
- (void)revertVotingWithOption:(NSString *)option;
- (CGFloat)voteInPercentageWithOption:(NSString *)option;
- (BOOL)pollEnded;

@end
