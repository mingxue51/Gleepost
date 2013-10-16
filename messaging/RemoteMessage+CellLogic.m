//
//  RemoteMessage+CellLogic.m
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "RemoteMessage+CellLogic.h"
#import <objc/runtime.h>
#import "RemoteMessage+Additions.h"
#import "SessionManager.h"
#import "User.h"

@implementation Message (CellLogic)

NSString * const kMessageCellIdentifier = @"kMessageCellIdentifier";
NSString * const kMessageHasHeader = @"kMessageHasHeader";

// Cell recycling identifiers, equals to IB values
NSString * const kMessageLeftCell = @"LeftCell";
NSString * const kMessageRightCell = @"RightCell";

- (void)setCellIdentifier:(NSString *)cellIdentifier
{
	objc_setAssociatedObject(self, &kMessageCellIdentifier, cellIdentifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)cellIdentifier
{
	return objc_getAssociatedObject(self, &kMessageCellIdentifier);
}

- (void)setHasHeader:(BOOL)hasHeader
{
    NSString *value = hasHeader ? @"YES" : @"NO";
    objc_setAssociatedObject(self, &kMessageHasHeader, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hasHeader
{
    NSString *value = objc_getAssociatedObject(self, &kMessageHasHeader);
    
    if(!value) {
        return NO;
    }
    
    return [value isEqualToString:@"YES"] ? YES : NO;
}

- (void)configureAsFirstMessage
{
    self.cellIdentifier = kMessageLeftCell;
    self.hasHeader = YES;
}

- (void)configureAsFollowingMessage:(Message *)message
{
    if([self followsPreviousMessage:message]) {
        self.cellIdentifier = message.cellIdentifier;
        self.hasHeader = NO;
    } else {
        self.cellIdentifier = [Message getCellIdentifierForMessage:self];
        self.hasHeader = YES;
    }
    
}

+ (NSString *)getCellIdentifierForMessage:(Message *)message
{
    BOOL currentUser = [message.author.remoteKey isEqualToNumber:[NSNumber numberWithInteger:[SessionManager sharedInstance].key]];
    
    return currentUser ? kMessageLeftCell : kMessageRightCell;
}

+ (NSString *)getOppositeCellIdentifierOf:(NSString *)cellIdentifier
{
    return ([cellIdentifier isEqualToString:kMessageLeftCell]) ? kMessageRightCell : kMessageLeftCell;
}

@end