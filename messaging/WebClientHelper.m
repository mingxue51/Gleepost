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

+ (void)showStandardError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Operation failed"
                                                    message:@"Check your internet connection, dude"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
