//
//  KeyboardHelper.m
//  score echo rhumatologie
//
//  Created by Lukas on 6/3/13.
//  Copyright (c) 2013 Siu. All rights reserved.
//

#import "KeyboardHelper.h"

@implementation KeyboardHelper

+ (float)keyboardAnimationDuration:(NSNotification *)notification
{
    return [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
}

+ (float)keyboardHeight:(NSNotification *)notification
{
    CGRect keyboardFrame;
    [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    
    return keyboardFrame.size.height;
}

+ (UIViewAnimationOptions)keyboardAnimationOptions:(NSNotification *)notification
{
    UIViewAnimationCurve animationCurve;
    [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    return [KeyboardHelper animationOptionsWithCurve:animationCurve];
}

+ (UIViewAnimationOptions)animationOptionsWithCurve:(UIViewAnimationCurve)curve
{
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            NSLog(@"easy in out");
            return UIViewAnimationOptionCurveEaseInOut;
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
    }
}

@end
