//
//  GLPFacebookConnect.h
//  Gleepost
//
//  Created by Tanmay Khandelwal on 25/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebClient.h"

@interface GLPFacebookConnect : NSObject

+ (GLPFacebookConnect *)sharedConnection;
- (void)openSessionWithEmailOrNil:(NSString *)email completionHandler:(void (^)(BOOL success, NSString *name, NSString *response))completionHandler;
//- (BOOL)isFacebookSessionValid;
- (void)handleDidBecomeActive;
- (BOOL)handleOpenURL:(NSURL *)url;
- (void)logout;
- (NSString *)facebookLoginToken;
-(void)associateAlreadyRegisteredAccountWithFacebookTokenWithPassword:(NSString *)password andEmail:(NSString *)email withCallbackBlock:(void (^) (BOOL success))callback;
-(void)sharePostWithPost:(GLPPost *)post;
-(void)inviteFriendsViaFBToGroupWithRemoteKey:(GLPGroup* )group completionHandler:(void (^)(BOOL success, NSArray *fbFriends))completionHandler;
-(void)fetchFriends;
-(void)sendRequestToFriendWithFriendsIds:(NSArray *)friendIDs withCompletionCallback:(void (^) (NSString *status))completionCallback;

@end
