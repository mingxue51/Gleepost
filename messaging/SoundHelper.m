//
//  SoundHelper.m
//  Gleepost
//
//  Created by Silouanos on 13/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "SoundHelper.h"

@interface SoundHelper ()

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;



@end

@implementation SoundHelper


static SoundHelper *instance = nil;

+ (SoundHelper *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SoundHelper alloc] init];
    });
    
    return instance;
}

-(id)init
{
    self = [super init];
    
    if(self)
    {
//        _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:clickURL error:nil];

        _audioPlayer = [[AVAudioPlayer alloc] init];
    }
    
    return self;
}

-(void)messageSent
{
    if(ON_DEVICE)
    {

        NSURL *clickURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/b.wav", [[NSBundle mainBundle] resourcePath]]];
        
//        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/b.mp3", [[NSBundle mainBundle] resourcePath]]]];
        
        @try {
            _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:clickURL error:nil];

            [_audioPlayer setVolume:0.1];
            
        }
        @catch (NSException *exception) {
            DDLogDebug(@"EXCEPTION");
        }
        @finally {
            DDLogDebug(@"EXCEPTION");

        }
        
        [_audioPlayer play];
    }
}

-(void)userFound
{
    
    
    if(ON_DEVICE)
    {
        NSURL *clickURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/mario.mp3", [[NSBundle mainBundle] resourcePath]]];
        _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:clickURL error:nil];
        
        [_audioPlayer play];
    }
    
    
    
    //start a background sound
//    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"Soothing_Music2_Long" ofType: @"mp3"];
//    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath ];
//    myAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
//    myAudioPlayer.numberOfLoops = -1; //infinite loop
//    [myAudioPlayer play];
    
    

    
//    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
//    [audioSession setActive:YES error:nil];
}

@end
