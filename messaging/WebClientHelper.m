//
//  WebClientHelper.m
//  NerdNation
//
//  Created by Lukas on 10/9/13.
//  Copyright (c) 2013 NerdNation. All rights reserved.
//

#import "WebClientHelper.h"
#import "MBProgressHUD.h"
#import "GLPThemeManager.h"

@implementation WebClientHelper

+ (void)showStandardLoaderWithTitle:(NSString *)title forView:(UIView *)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = title;
    hud.detailsLabelText = @"Please wait";
}

//Added.
+ (void) showStandardLoaderWithoutSpinningAndWithTitle:(NSString*) title forView:(UIView *)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = title;
    hud.detailsLabelText = @"Please wait";
}

+ (void)hideStandardLoaderForView:(UIView *)view
{
    [MBProgressHUD hideHUDForView:view animated:YES];
}

+ (void)showStandardErrorWithTitle:(NSString *)title andContent:(NSString *)content
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:content
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+(void)showStandardEmailError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please check your email"
                                                    message:@"You must use your college (.edu) email address"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+(void)showStandardLoginErrorWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login failed"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+(void)showStandardPasswordError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                    message:@"Your password must be at least 5 characters long"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+(void)showStandardProfileImageError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                    message:@"You forgot to add a Profile Image"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+(void)showStandardFirstNameError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                    message:@"You forgot to enter your first name"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+(void)showStandardFirstNameTooShortError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                    message:@"Your name is too short"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


+(void)showStandardLastNameError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                    message:@"You forgot your last name"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


+(void)showInternetConnectionErrorWithTitle:(NSString*)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:@"Please check your internet connection"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

//+ (void)showStandardError
//{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network"
//                                                    message:@"Please check your internet connection"
//                                                   delegate:nil
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil];
//    [alert show];
//}

+ (void)showEmptyTextError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                    message:@"It looks like you haven't written anything"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+(void)showOutOfBoundsError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                    message:@"Description needs to be 80 characters max and title 40 characters max."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+(void)showFailedToDeletePostError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Post not deleted"
                                                    message:@"Post was unable to be deleted, please try again later."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+ (void)commentWillUploadedLater
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network!"
                                                    message:@"Your comment is going to be uploaded later"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+ (void)failedToAddUsers
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                    message:@"There was a problem adding friends to the group."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+ (void)failedToSendEmailResettingPassword
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                    message:@"There was a problem sending you a password recovery link."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+ (void)showReportedDone
{
    [WebClientHelper showStandardErrorWithTitle:@"Post Reported" andContent:@"Thanks for helping us keep Gleepost a fun and safe environment. Our team will review this post ASAP."];

}

+ (void)showFailedToReport
{
    [WebClientHelper showStandardErrorWithTitle:@"Error Sending Report" andContent:@"Something went wrong reporting this post, please try again in a few moments."];
}

+ (void)failedToLoadPost
{
    [WebClientHelper showStandardErrorWithTitle:@"Failed to load post" andContent:@"Check your internet connection and try again"];
}

+ (void)accountVerificationError
{
    [WebClientHelper showStandardErrorWithTitle:@"Error" andContent:@"An error occurred while verifying user account"];
}

+ (void)accountLoginError
{
    [WebClientHelper showStandardErrorWithTitle:@"Error" andContent:@"An error occurred while logging in"];
}

+ (void)loadingPostsError
{
    [WebClientHelper showStandardErrorWithTitle:@"Error loading posts" andContent:@"Please ensure that you are connected to the internet"];
}

+ (void)facebookLoginErrorWithStatus:(NSString *)status
{
    [WebClientHelper showStandardErrorWithTitle:@"Facebook Login Error" andContent:status];
}

+ (void)uploadingImageError
{
    [WebClientHelper showStandardErrorWithTitle:@"Error uploading the image" andContent:@"Please check your connection and try again"];
}

+ (void)showRecoveryEmailMessage:(NSString *)email
{
    [WebClientHelper showStandardErrorWithTitle:@"" andContent:[NSString stringWithFormat:@"No problem. We've just sent you a password recovery link at: %@", email]];
}

+ (void)errorRegisteringUserWithResponse:(NSString *)response
{
    [WebClientHelper showStandardErrorWithTitle:@"Oops!" andContent:response];
}

+ (void)errorWrongCredentials
{
    [WebClientHelper showStandardErrorWithTitle:@"Please check your information" andContent:@"Please check your provided information and try again."];
}

+ (void)errorUnverifiedUser
{
    [WebClientHelper showStandardErrorWithTitle:@"Error" andContent:@"You still unverified."];
}

+ (void)errorLoadingData
{
    [WebClientHelper showStandardErrorWithTitle:@"Error" andContent:@"An error occured while loading your data"];
}

+ (void)showPasswordChanged
{
    [WebClientHelper showStandardErrorWithTitle:@"Password changed" andContent:@"Your password has been changed"];
}

+ (void)showNameChangedWithName:(NSString *)fullName andSurname:(NSString *)surname
{
    [WebClientHelper showStandardErrorWithTitle:@"Name changed" andContent:[NSString stringWithFormat:@"Your new name is: %@ %@.",fullName, surname]];
}

+ (void)showTaglineChangedWithNewTagline:(NSString *)tagline
{
    [WebClientHelper showStandardErrorWithTitle:@"Tagline changed" andContent:[NSString stringWithFormat:@"Your new tagline is: %@.", tagline]];
}

#pragma mark - Location

+ (void)showLocationRestrictionError
{
    [WebClientHelper showStandardErrorWithTitle:@"Location is disabled." andContent:[NSString stringWithFormat:@"To include location with %@, go to your Settings App > Privacy > Location Services.", [[GLPThemeManager sharedInstance] appNameWithString:@"%@"]]];
}

/**
 This method should be called only if the app is running on iOS 8 or later.
 
 @return a UIAlertController with UIAlertControllerStyleAlert that has the ability to navigate to app's privacy settings.
 
 */
+ (UIAlertController *)generateAlertViewForLocationError
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location is disabled."
                                                                   message:[NSString stringWithFormat:@"To include location with %@, go to your Settings App > Privacy > Location Services.", [[GLPThemeManager sharedInstance] appNameWithString:@"%@"]]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Not Now" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {
                                                              
                                                              
                                                          }];
    
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                           }];
    
    [alert addAction:defaultAction];
    [alert addAction:settingsAction];
    
    return alert;
}

#pragma mark - Conversations

+ (void)showFailedToDeleteConversationError
{
    [self showAlertWithTitle:@"Oops!" andMessage:@"There was a problem deleting the conversation. Please check your connection and try again"];
}

#pragma mark - Media

+ (void)showSaveImageMessage
{
    [self showAlertWithTitle:@"Image saved" andMessage:@"The image has been saved to your camera roll!"];
}

+ (void)showErrorSavingImageWithMessage:(NSString *)errorMessage
{
    [self showAlertWithTitle:@"Error saving image" andMessage:errorMessage];
}

#pragma mark - Facebook 

+ (void)showNeedsFacebookAppError
{
    [self showAlertWithTitle:@"Oops!" andMessage:@"To share a post you need to have installed Facebook app on your device"];
}

+ (void)showProblemLoadingFBFriends
{
    [self showAlertWithTitle:@"Error" andMessage:@"There was an error loading your facebook friends"];
}

+ (void)showProblemInvitingFBFriends
{
    [self showAlertWithTitle:@"Error" andMessage:@"There was a problem inviting your selected facebook friends"];
}

+ (void)showSuccessfullyInvitedFriends:(NSString *)friends
{
    [self showAlertWithTitle:@"Invitation completed" andMessage:[NSString stringWithFormat:@"You have successfully invited: %@",friends]];
}

+ (void)showInvitedFriendsToGroupViaFBWithNumberOfFriends:(NSInteger)numberOfFriends
{
    [self showAlertWithTitle:@"Friends invited to group!" andMessage:[NSString stringWithFormat:@"You have invited %ld facebook friends to this group", (long)numberOfFriends]];
}

+ (void)errorInvitingFacebookFriends
{
    [WebClientHelper showStandardErrorWithTitle:@"Oops!" andContent:@"There was a problem inviting your selected facebook friends"];
}

#pragma mark - Groups

+ (void)showFailedToJoinGroupWithName:(NSString *)groupName
{
    [self showAlertWithTitle:@"Oops!" andMessage:[NSString stringWithFormat:@"There was a problem joining %@. Please check your connection and try again", groupName]];
}

+ (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
}

+ (void)showChangedModeServerMessageWithServerMode:(NSString *)mode
{
    [WebClientHelper showAlertWithTitle:@"Success!" andMessage:[NSString stringWithFormat:@"The server mode has been changed to %@. If you come from sign out progress please kill the app and launch again to let this change to be applied.", mode]];
}

+ (void)errorLoadingGroup
{
    [WebClientHelper showStandardErrorWithTitle:@"Error loading group" andContent:@"It seems that you are not belonging to this group anymore"];
}

#pragma mark - Testing

+ (void)showWebSocketReceivedBadEvent:(NSString *)socketEvent
{
    [WebClientHelper showAlertWithTitle:@"Error" andMessage:[NSString stringWithFormat:@"Unexpected event in socket %@", socketEvent]];
}

#pragma mark - Calendar

+ (void)showErrorSavingEventToCalendar
{
    [WebClientHelper showAlertWithTitle:@"Error" andMessage:@"There was a problem saving the event to your calendar."];
}

+ (void)showEventSuccessfullyAddedToCalendar
{
    [WebClientHelper showAlertWithTitle:@"Success!" andMessage:@"This event has been added to your calendar"];
}

+ (void)showErrorPermissionsToCalendar
{
    NSString *message = [[GLPThemeManager sharedInstance] appNameWithString:@"%@ needs permissions to save that event to your Calendar. Please check your settings and try again."];
    
    [WebClientHelper showAlertWithTitle:@"Error" andMessage:message];
}

#pragma mark - Warning

+ (void)showLowMemoryWarningFromClass:(NSString *)className
{
    [WebClientHelper showAlertWithTitle:@"Memory Warning" andMessage:className];
}

@end