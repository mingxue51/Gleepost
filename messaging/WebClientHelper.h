//
//  WebClientHelper.h
//  Gleepost
//
//  Created by Lukas on 10/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebClientHelper : NSObject

+(void) showStandardLoaderWithTitle:(NSString *)title forView:(UIView *)view;
+ (void) showStandardLoaderWithoutSpinningAndWithTitle:(NSString*) title forView:(UIView *)view;
+(void) hideStandardLoaderForView:(UIView *)view;
+(void) showStandardErrorWithTitle:(NSString *)title andContent:(NSString *)content;
//+(void) showStandardError;
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

+ (void)failedToSendEmailResettingPassword;
+ (void)showNeedsFacebookAppError;
+ (void)showInvitedFriendsToGroupViaFBWithNumberOfFriends:(NSInteger)numberOfFriends;
+ (void)showProblemLoadingFBFriends;
+ (void)showProblemInvitingFBFriends;
+ (void)showSuccessfullyInvitedFriends:(NSString *)friends;
+ (void)showFailedToJoinGroupWithName:(NSString *)groupName;

+ (void)showSaveImageMessage;
+ (void)showErrorSavingImageWithMessage:(NSString *)errorMessage;
+ (void)showWebSocketReceivedBadEvent:(NSString *)socketEvent;

+ (void)showChangedModeServerMessageWithServerMode:(NSString *)mode;

+ (void)showErrorSavingEventToCalendar;
+ (void)showEventSuccessfullyAddedToCalendar;
+ (void)showErrorPermissionsToCalendar;

@end
