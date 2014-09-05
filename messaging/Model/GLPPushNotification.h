//
//  GLPPushNotification.h
//  Gleepost
//
//  Created by Σιλουανός on 4/9/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PNKind) {
    kPNKindNewGroupPost,
    kPNKindAddedYouToGroup, //Is going to be deleted.
    kPNKindLikedYourPost,
    kPNKindCommentedYourPost,
    kPNKindSendYouMessage,
    kPNKindNewAppVersion,
    kPNKindUnknown
};

@interface GLPPushNotification : NSObject

@property (assign, nonatomic) PNKind kindOfPN;
@property (strong, nonatomic) NSNumber *groupId;
@property (strong, nonatomic) NSNumber *postId;
@property (strong, nonatomic) NSNumber *commenterId;
@property (strong, nonatomic) NSNumber *likerId;
@property (strong, nonatomic) NSNumber *conversationId;
@property (strong, nonatomic) NSString *version;

- (id)initWithJson:(NSDictionary *)json;

@end
