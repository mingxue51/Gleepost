//
//  ChatViewAnimationController.h
//  Gleepost
//
//  Created by Silouanos on 29/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>


@interface ChatViewAnimationController : UIViewController<AVAudioPlayerDelegate>

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
