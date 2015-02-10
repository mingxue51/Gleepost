//
//  WebClientHelper.h
//  Gleepost
//
//  Created by Lukas on 10/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebClientHelper : NSObject

+(void)showStandardLoaderWithTitle:(NSString *)title forView:(UIView *)view;
+ (void)showStandardLoaderWithoutSpinningAndWithTitle:(NSString*) title forView:(UIView *)view;
+(void) hideStandardLoaderForView:(UIView *)view;
+(void)showInternetConnectionErrorWithTitle:(NSString*)title;
+(void)showStandardEmailError;
+(void)showStandardPasswordError;

+(void)showStandardProfileImageError;
+(void)showStandardFirstNameError;

+(void)showStandardLastNameError;
+(void)showStandardFirstNameTooShortError;

+(void)showStandardLoginErrorWithMessage:(NSString *)message;
+ (void)showEmptyTextError;

+ (void)commentWillUploadedLater;
+(void)showOutOfBoundsError;

+(void)showFailedToDeletePostError;

+ (void)failedToLoadPost;

+ (void)showLocationRestrictionError;
+ (UIAlertController *)generateAlertViewForLocationError;

+ (void)accountVerificationError;
+ (void)accountLoginError;
+ (void)loadingPostsError;
+ (void)facebookLoginErrorWithStatus:(NSString *)status;
+ (void)errorRegisteringUserWithResponse:(NSString *)response;
+ (void)errorWrongCredentials;
+ (void)errorUnverifiedUser;
+ (void)errorLoadingData;

+ (void)showNameChangedWithName:(NSString *)fullName andSurname:(NSString *)surname;
+ (void)showTaglineChangedWithNewTagline:(NSString *)tagline;
+ (void)showPasswordChanged;
+ (void)uploadingImageError;
+ (void)failedToAddUsers;
+ (void)failedToSendEmailResettingPassword;
+ (void)showNeedsFacebookAppError;
+ (void)showInvitedFriendsToGroupViaFBWithNumberOfFriends:(NSInteger)numberOfFriends;
+ (void)showProblemLoadingFBFriends;
+ (void)showProblemInvitingFBFriends;
+ (void)showSuccessfullyInvitedFriends:(NSString *)friends;
+ (void)showFailedToJoinGroupWithName:(NSString *)groupName;
+ (void)errorInvitingFacebookFriends;

+ (void)showRecoveryEmailMessage:(NSString *)email;
+ (void)showSaveImageMessage;
+ (void)showErrorSavingImageWithMessage:(NSString *)errorMessage;
+ (void)showWebSocketReceivedBadEvent:(NSString *)socketEvent;
+ (void)errorLoadingGroup;

+ (void)showChangedModeServerMessageWithServerMode:(NSString *)mode;

+ (void)showErrorSavingEventToCalendar;
+ (void)showEventSuccessfullyAddedToCalendar;
+ (void)showErrorPermissionsToCalendar;

+ (void)showReportedDone;
+ (void)showFailedToReport;

+ (void)showFailedToDeleteConversationError;

+ (void)showLowMemoryWarningFromClass:(NSString *)className;

@end
