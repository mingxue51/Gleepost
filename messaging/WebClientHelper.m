//
//  WebClientHelper.m
//  Gleepost
//
//  Created by Lukas on 10/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "WebClientHelper.h"
#import "MBProgressHUD.h"

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

+ (void)showStandardError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network"
                                                    message:@"Please check your internet connection"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

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
                                                    message:@"Information needs to be 80 characters max and title 40 characters max."
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

+ (void)failedToSendEmailResettingPassword
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                    message:@"There was a problem sending you a password recovery link."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
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

+ (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
}

@end
