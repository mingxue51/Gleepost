//
//  RemoteMessage+CellLogic.h
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPMessage.h"

@interface GLPMessage (CellLogic)

@property (retain, nonatomic) NSString *cellIdentifier;
@property (assign, nonatomic) BOOL hasHeader;

extern NSString * const kMessageLeftCell;
extern NSString * const kMessageRightCell;

- (void)configureAsFirstMessage;
- (void)configureAsFollowingMessage:(GLPMessage *)message;
+ (NSString *)getOppositeCellIdentifierOf:(NSString *)cellIdentifier;

@end
