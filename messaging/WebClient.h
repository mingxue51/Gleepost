//
//  WebClient.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"
#import "GLPPost.h"
#import "GLPComment.h"
#import "GLPConversation.h"
#import "GLPMessage.h"
#import "GLPLiveConversation.h"
#import "GLPNotification.h"
#import "SRWebSocket.h"
#import "GLPGroup.h"

@class GLPLiveSummary;

@interface WebClient : AFHTTPClient

extern NSString * const kWebserviceBaseUrl;

@property (assign, nonatomic) BOOL isNetworkAvailable;

+ (WebClient *)sharedInstance;

- (void)activate;

// User login
- (void)loginWithName:(NSString *)name password:(NSString *)password andCallbackBlock:(void (^)(BOOL success, GLPUser *user, NSString *token, NSDate *expirationDate, NSString *errorMessage))callbackBlock;
- (void)verifyUserWithToken:(NSString *)token callback:(void (^)(BOOL success))callbackBlock;
/** DEPRECATED **/
- (void)registerWithName:(NSString *)name email:(NSString *)email password:(NSString *)password andCallbackBlock:(void (^)(BOOL success, NSString* responseObject, int userRemoteKey))callbackBlock;
- (void)registerWithName:(NSString *)name surname:(NSString*)surname email:(NSString *)email password:(NSString *)password andCallbackBlock:(void (^)(BOOL success, NSString* responseObject, int userRemoteKey))callbackBlock;

// push
- (void)registerPushToken:(NSString *)pushToken authParams:(NSDictionary *)authParams callback:(void (^)(BOOL success))callback;
-(void)unregisterPushToken:(NSString*)pushToken authParams:(NSDictionary *)authParams callback:(void (^)(BOOL success))callback;

-(void)resendVerificationToEmail:(NSString *)email andCallbackBlock:(void (^) (BOOL success))callbackBlock;
- (void)registerViaFacebookToken:(NSString *)token
                  withEmailOrNil:(NSString *)email
                andCallbackBlock:(void (^)(BOOL success, NSString* responseObject))callbackBlock;

- (void)associateWithFacebookAccountUsingFBToken:(NSString *)fbToken withEMail:(NSString *)email withPassword:(NSString *)password
                                andCallbackBlock:(void (^) (BOOL success))callbackBlock;
- (void)associateWithFacebookAccountUsingFBToken:(NSString *)fbToken withCallbackBlock:(void (^) (BOOL success))callbackBlock;

- (void)requestUsersFacebookIDWithToken:(NSString *)usersToken withCallback:(void (^) (BOOL success, NSInteger usersID))callback;

// fourthsquare api

- (void)findNearbyLocationsWithLatitude:(double)lat andLongitude:(double)lon withCallbackBlock:(void (^) (BOOL success, NSArray *locations))callbackBlock;

- (void)findCurrentLocationWithName:(NSString *)name withCallbackBlock:(void (^) (BOOL success, NSArray *locations))callbackBlock;

- (void)findCurrentLocationWithLatitude:(double)lat andLongitude:(double)lon withCallbackBlock:(void (^) (BOOL success, NSArray *locations))callbackBlock;

- (void)getUserWithKey:(NSInteger)key authParams:(NSDictionary *)authParams callbackBlock:(void (^)(BOOL success, GLPUser *user))callbackBlock;
-(void)getContactsForUser:(GLPUser *)user authParams:(NSDictionary *)authParams callback:(void (^)(BOOL success, NSArray *contacts))callback;

- (void)getPostsAfter:(GLPPost *)post withCategoryTag:(NSString*)tag callback:(void (^)(BOOL success, NSArray *posts))callbackBlock;
-(void)getEventPostsAfterDate:(NSDate*)date withCallbackBlock:(void (^) (BOOL success, NSArray *posts))callbackBlock;
- (void)getAttendingEventsForUserWithRemoteKey:(NSInteger)userRemoteKey callback:(void (^) (BOOL success, NSArray *posts))callback;
- (void)getAttendingEventsAfter:(GLPPost *)post withUserRemoteKey:(NSInteger)userRemoteKey callback:(void (^)(BOOL success, NSArray *posts))callbackBlock;
- (void)createPost:(GLPPost *)post callbackBlock:(void (^)(BOOL success, int remoteKey))callbackBlock;
- (void)editPost:(GLPPost *)editedPost callbackBlock:(void (^)(BOOL success, GLPPost *updatedPost))callbackBlock;
-(void)getPostWithRemoteKey:(NSInteger)remoteKey withCallbackBlock:(void (^) (BOOL success, GLPPost *post))callbackBlock;
-(void)loadUserPostsAfter:(GLPPost *)post withRemoteKey:(int)remoteKey callbackBlock:(void (^) (BOOL success, NSArray *posts))callbackBlock;
- (void)deletePostWithRemoteKey:(NSInteger)postRemoteKey callbackBlock:(void (^) (BOOL success))callbackBlock;
- (void)reportPostWithRemoteKey:(NSInteger)postRemoteKey callbackBlock:(void (^) (BOOL success))callbackBlock;
- (void)loadAttendeesWithPostRemoteKey:(NSInteger)postRemoteKey callback:(void (^)(NSArray *users, BOOL success))callback;

// polling

- (void)voteWithPostRemoteKey:(NSInteger)postRemoteKey andOption:(NSInteger)option callbackBlock:(void (^) (BOOL success, NSString *statusMsg))callbackBlock;

- (void)getCommentsForPost:(GLPPost *)post withCallbackBlock:(void (^)(BOOL success, NSArray *comments))callbackBlock;
- (void)createComment:(GLPComment *)comment callbackBlock:(void (^)(BOOL success))callbackBlock;

-(void)attendEvent:(BOOL)attend withPostRemoteKey:(NSInteger)postRemoteKey callbackBlock:(void (^) (BOOL success, NSInteger popularity))callbackBlock;

- (void)getConversationsFilterByLive:(BOOL)live withCallbackBlock:(void (^)(BOOL success, NSArray *conversations))callbackBlock;
- (void)getConversationForRemoteKey:(NSInteger)remoteKey withCallback:(void (^)(BOOL success, GLPConversation *conversation))callback;
- (void)synchronousGetConversationForRemoteKey:(NSInteger)remoteKey withCallback:(void (^)(BOOL success, GLPConversation *conversation))callback;
- (void)synchronousGetConversationsFilterByLive:(BOOL)live withCallback:(void (^)(BOOL success, NSArray *conversations))callback;
-(void)createRegularConversationWithUserRemoteKey:(int)remoteKey andCallback:(void (^) (BOOL sucess, GLPConversation *conversation ))callbackBlock;
- (GLPConversation *)synchronousCreateConversationWithUser:(GLPUser *)user;
- (GLPConversation *)synchronousCreateConversationWithUsers:(NSArray *)users;
- (void)createConversation:(void (^)(GLPConversation *conversation))callback;


// groups
-(void)getGroupDescriptionWithId:(NSInteger)groupId withCallbackBlock:(void (^) (BOOL success, GLPGroup *group, NSString *errorMessage))callbackBlock;
-(void)getPostsAfter:(GLPPost *)post withGroupId:(NSInteger)groupId callback:(void (^)(BOOL success, NSArray *posts))callbackBlock;
-(void)getGroupswithCallbackBlock:(void (^) (BOOL success, NSArray *groups))callbackBlock;
-(void)getMembersWithGroupRemoteKey:(int)remoteKey withCallbackBlock:(void (^) (BOOL success, NSArray *members))callbackBlock;
- (void)makeMemberAsAdmin:(GLPMember *)member withCallbackBlock:(void (^) (BOOL success))callbackBlock;
- (void)removeMemberFromAdmin:(GLPMember *)member withCallbackBlock:(void (^) (BOOL success))callbackBlock;
-(void)createGroupWithGroup:(GLPGroup *)group callback:(void (^) (BOOL success, GLPGroup *group))callbackBlock;
-(void)quitFromAGroupWithRemoteKey:(int)groupRemoteKey callback:(void (^) (BOOL success))callbackBlock;
-(void)getPostsGroupsFeedWithTag:(NSString *)tag callback:(void (^) (BOOL success, NSArray *posts))callbackBlock;
-(void)inviteUsersViaFacebookWithGroupRemoteKey:(int)groupRemoteKey andUsersFacebookIds:(NSArray *)fbIds withCallbackBlock:(void (^) (BOOL success))callback;

// live conversations
- (void)getConversationsWithCallback:(void (^)(BOOL success, NSArray *conversations))callbackBlock;
- (void)getLiveConversationsWithCallbackBlock:(void (^)(BOOL success, NSArray *conversations))callbackBlock;

- (void)getLastMessagesForConversation:(GLPConversation *)conversation withLastMessage:(GLPMessage *)lastMessage callbackBlock:(void (^)(BOOL success, NSArray *messages))callbackBlock;
- (void)getPreviousMessagesBefore:(GLPMessage *)message callbackBlock:(void (^)(BOOL success, NSArray *messages))callbackBlock;
- (void)deleteConversationWithRemoteKey:(NSInteger)remoteKey callbackBlock:(void (^) (BOOL success))callbackBlock;

- (void)synchronousLongPollWithCallback:(void (^)(BOOL success, GLPMessage *message))callback;

- (void)createMessageSynchronously:(GLPMessage *)message callback:(void (^)(BOOL success, NSInteger remoteKey))callback;

- (NSArray *)synchronousGetMessagesForConversation:(GLPConversation *)conversation after:(GLPMessage *)afterMessage before:(GLPMessage *)beforeMessage;
- (void)getMessagesForConversation:(GLPConversation *)conversation after:(GLPMessage *)afterMessage before:(GLPMessage *)beforeMessage callbackBlock:(void (^)(BOOL success, NSArray *messages))callbackBlock;
- (void)getMessagesForConversation:(GLPConversation *)conversation afterRemoteKey:(NSInteger)afterRemoteKey beforeRemoteKey:(NSInteger)beforeRemoteKey callbackBlock:(void (^)(BOOL success, NSArray *messages))callbackBlock;


// User

- (void)getUserWithKey:(NSInteger)key callbackBlock:(void (^)(BOOL success, GLPUser *user))callbackBlock;
-(void)acceptContact:(int)contactRemoteKey callbackBlock:(void (^)(BOOL success))callbackBlock;
-(void)resetPasswordWithEmail:(NSString *)email callbackBlock:(void (^) (BOOL success))callbackBlock;
- (void)searchUserByName:(NSString *)name callback:(void (^)(NSArray *users))callback;


-(void)setBusyStatus:(BOOL)busy callbackBlock:(void (^)(BOOL success))callbackBlock;
-(void)getBusyStatus:(void (^) (BOOL success, BOOL status))callbackBlock;
-(void)getContactsWithCallback:(void (^)(BOOL success, NSArray *contacts))callback;
-(void)addContact:(int)contactRemoteKey callbackBlock:(void (^)(BOOL success))callbackBlock;

-(void)changePasswordWithOld:(NSString*)oldPass andNew:(NSString*)newPass callbackBlock:(void (^) (BOOL success))callbackBlock;
-(void)changeNameWithName:(NSString*)name andSurname:(NSString*)surname callbackBlock:(void (^) (BOOL success))callbackBlock;
- (void)changeTagLine:(NSString *)tagline callback:(void (^) (BOOL success))callback;

- (void)getLastMessagesForLiveConversation:(GLPLiveConversation *)conversation withLastMessage:(GLPMessage *)lastMessage callbackBlock:(void (^)(BOOL success, NSArray *messages))callbackBlock;

-(void)uploadImage:(NSData*)image ForUserRemoteKey:(int)userRemoteKey callbackBlock: (void (^)(BOOL success, NSString *response)) callbackBlock;
-(void)uploadImage:(NSData *)imageData callback:(void (^)(BOOL success, NSString *imageUrl))callback;
-(void)uploadImage:(NSData *)imageData callback:(void (^)(BOOL success, NSString *imageUrl))callback progressCallBack:(void (^) (CGFloat progress))progressCallback;
-(void)uploadGroupImage:(NSData *)imageData withTimestamp:(NSDate *)timestamp callback:(void (^)(BOOL success, NSString *imageUrl))callback;

- (void)uploadImage:(NSData *)imageData forGroupWithRemoteKey:(NSInteger)groupRemoteKey callback:(void (^)(BOOL success, NSString *imageUrl))callback;

-(void)uploadImageToProfileUser:(NSString *)url callbackBlock:(void (^)(BOOL))callbackBlock;

-(void)uploadImageUrl:(NSString *)imageUrl withGroupRemoteKey:(int)remoteKey callbackBlock:(void (^) (BOOL success))callbackBlock;


-(void)postLike:(BOOL)like forPostRemoteKey:(NSInteger)postRemoteKey callbackBlock:(void (^) (BOOL success))callbackBlock;

// pending posts

- (void)getPostsWaitingForApprovalCallbackBlock:(void (^) (BOOL success, NSArray *pendingPosts))callbackBlock;

// campus live
- (void)campusLiveSummaryUntil:(NSDate *)until callbackBlock:(void (^) (BOOL success, GLPLiveSummary *liveSummary))callbackBlock;

// approval
- (void)getApprovalStatusCallbackBlock:(void (^) (BOOL success, NSInteger level))callbackBlock;

// notifications
-(void)getUnreadNotificationsWithCallback:(void (^)(BOOL success, NSArray *notifications))callback;
- (void)getAllNotificationsWithCallback:(void (^)(BOOL success, NSArray *notifications))callback;
-(void)synchronousGetNotificationsWithCallback:(void (^)(BOOL success, NSArray *notifications))callback;

- (void)markNotificationsRead:(void (^)(BOOL success))callback;
- (void)markConversationsRead:(void (^)(BOOL success))callback;
- (void)markConversationWithRemoteKeyAsRead:(NSInteger)convRemoteKey upToMessageWithRemoteKey:(NSInteger)msgRemoteKey callback:(void (^)(BOOL success))callback;

- (void)markNotificationRead:(GLPNotification *)notification callback:(void (^)(BOOL success, NSArray *notifications))callback;

// invite
- (void)getInviteMessageWithCallback:(void (^)(BOOL success, NSString *inviteMessage))callback;

- (void)markNotificationsReadWithLastNotificationRemoteKey:(int)remoteKey withCallbackBlock:(void (^)(BOOL success))callback;

// video
-(void)uploadVideo:(NSData *)videoData callback:(void (^)(BOOL success, NSString *videoUrl))callback;
- (void)uploadVideoWithData:(NSData *)videoData withTimestamp:(NSDate *)timestamp callback:(void (^)(BOOL success, NSNumber *videoId))callback;
- (void)checkForReadyVideoWithPendingVideoKey:(NSNumber *)videoKey callback:(void (^) (BOOL success, GLPVideo *result))callback;

// groups

- (void)addUsers:(NSArray *)users toGroup:(GLPGroup *)group callback:(void (^)(BOOL success, GLPGroup *updatedGroup))callback;
- (void)joinPublicGroup:(GLPGroup *)group callback:(void (^) (BOOL success, GLPGroup *updatedGroup))callback;
- (void)searchGroupsWithName:(NSString *)groupName callback:(void (^) (BOOL success, NSArray *groups))callback;
- (void)searchGroupsWithUsersRemoteKey:(NSInteger)usersRemoteKey callback:(void (^) (BOOL success, NSArray *groups))callback;

@end
