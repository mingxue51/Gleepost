//
//  SoundHelper.h
//  Gleepost
//
//  Created by Silouanos on 13/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface SoundHelper : NSObject

+ (SoundHelper *)sharedInstance;

-(void)messageSent;
-(void)userFound;


@end
