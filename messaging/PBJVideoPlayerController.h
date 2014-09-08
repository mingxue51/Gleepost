//
//  PBJVideoPlayerController.h
//
//  Created by Patrick Piemonte on 5/27/13.
//
//  Copyright (c) 2013-2014 Patrick Piemonte (http://patrickpiemonte.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <UIKit/UIKit.h>

@class AVURLAsset;
@class AVPlayerItem;
@class AVAsset;
typedef NS_ENUM(NSInteger, PBJVideoPlayerPlaybackState) {
    PBJVideoPlayerPlaybackStateStopped = 0,
    PBJVideoPlayerPlaybackStatePlaying,
    PBJVideoPlayerPlaybackStatePaused,
    PBJVideoPlayerPlaybackStateFailed,
};

typedef NS_ENUM(NSInteger, PBJVideoPlayerBufferingState) {
    PBJVideoPlayerBufferingStateUnknown = 0,
    PBJVideoPlayerBufferingStateReady,
    PBJVideoPlayerBufferingStateDelayed,
};

// PBJVideoPlayerController.view provides us with an interface for playing/streaming videos
@protocol PBJVideoPlayerControllerDelegate;
@interface PBJVideoPlayerController : UIViewController

@property (nonatomic, weak) id<PBJVideoPlayerControllerDelegate> delegate;

@property (nonatomic) NSString *videoPath;
@property (nonatomic) AVAsset *asset;
@property (nonatomic) BOOL playbackLoops;
@property (nonatomic, readonly) NSTimeInterval maxDuration;

@property (nonatomic, readonly) PBJVideoPlayerPlaybackState playbackState;
@property (nonatomic, readonly) PBJVideoPlayerBufferingState bufferingState;

- (void)playFromBeginning;
- (void)playFromCurrentTime;
- (void)pause;
- (void)stop;
- (BOOL)isVideoLoaded;
- (void)setMute:(BOOL)mute;
- (void)resetVideo;
/** New methods. */
- (void)setVideoAsset:(AVURLAsset *)asset;
- (void)setVideoPlayerItem:(AVPlayerItem *)playerItem;

@end

@protocol PBJVideoPlayerControllerDelegate <NSObject>
@optional
- (void)readyToPlay:(BOOL)ready withPlayerController:(PBJVideoPlayerController *)videoPlayer;

@required
- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer;
- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer;

- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer;
- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer;
@end
