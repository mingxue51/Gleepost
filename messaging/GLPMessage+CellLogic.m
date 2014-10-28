//
//  RemoteMessage+CellLogic.m
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//


#import <objc/runtime.h>
#import "GLPMessage+CellLogic.h"
#import "SessionManager.h"
#import "GLPUser.h"

@implementation GLPMessage (CellLogic)

NSString * const kMessageCellIdentifier = @"kMessageCellIdentifier";
NSString * const kMessageHasHeader = @"kMessageHasHeader";
NSString * const kMessageNeedsProfileImage = @"kMessageNeedsProfileImage";
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

- (void)setNeedsProfileImage:(BOOL)needsProfileImage
{
    NSString *value = needsProfileImage ? @"YES" : @"NO";
    objc_setAssociatedObject(self, &kMessageNeedsProfileImage, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)needsProfileImage
{
    NSString *value = objc_getAssociatedObject(self, &kMessageNeedsProfileImage);
    
    if(!value) {
        return NO;
    }
    
    return [value isEqualToString:@"YES"] ? YES : NO;
}

- (void)configureAsFirstMessage
{
    self.cellIdentifier = [GLPMessage getCellIdentifierForMessage:self];
    self.hasHeader = YES;
    self.needsProfileImage = YES;
    //TODO: if a message doesn't has previous message should have header. (is the first message).
//    self.hasHeader = [self followsPreviousMessage:self] ? NO : YES;
    
    DDLogDebug(@"configureAsFirstMessage %@", self.content);
}

- (void)configureAsOtherUsersFollowingMessage:(GLPMessage *)message
{
    self.cellIdentifier = [GLPMessage getCellIdentifierForMessage:self];
    self.needsProfileImage = YES;
    self.hasHeader = [self followsPreviousMessage:message] ? NO : YES;
}

- (void)configureAsFollowingMessage:(GLPMessage *)message
{
    
    self.cellIdentifier = [GLPMessage getCellIdentifierForMessage:self];
    self.hasHeader = [self followsPreviousMessage:message] ? NO : YES;
    self.needsProfileImage = NO;
    
    DDLogDebug(@"configureAsFollowingMessage following %@, current %@", message.content, self.content);

}

+ (NSString *)getCellIdentifierForMessage:(GLPMessage *)message
{
    BOOL currentUser = [message.author isEqualToEntity:[SessionManager sharedInstance].user];
    return currentUser ? kMessageRightCell : kMessageLeftCell;
}

@end
