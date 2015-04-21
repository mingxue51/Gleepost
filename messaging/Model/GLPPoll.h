//
//  GLPPoll.h
//  Gleepost
//
//  Created by Silouanos on 17/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPEntity.h"

@interface GLPPoll : NSObject

@property (strong, nonatomic) NSDate *expirationDate;
@property (strong, nonatomic) NSArray *options;

/** <Option (NSString), Vote (CGFloat)> as key value. */
@property (strong, nonatomic, readonly) NSMutableDictionary *votes;
@property (strong, nonatomic) NSString *usersVote;
@property (assign, nonatomic) NSInteger sumVotes;
@property (assign, nonatomic) BOOL didUserVote;


- (void)setAndCalculateVotes:(NSMutableDictionary *)votes;
- (void)userVotedWithOption:(NSString *)option;
- (void)revertVotingWithOption:(NSString *)option;

@end
