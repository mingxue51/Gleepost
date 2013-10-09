//
//  KeyboardHelper.h
//  score echo rhumatologie
//
//  Created by Lukas on 6/3/13.
//  Copyright (c) 2013 Siu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyboardHelper : NSObject

+ (float)keyboardAnimationDuration:(NSNotification *)notification;
+ (float)keyboardHeight:(NSNotification *)notification;
+ (UIViewAnimationOptions)keyboardAnimationOptions:(NSNotification *)notification;
+ (UIViewAnimationOptions)animationOptionsWithCurve:(UIViewAnimationCurve) curve;

@end
