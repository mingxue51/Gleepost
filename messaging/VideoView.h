//
//  VideoView.h
//  Gleepost
//
//  Created by Silouanos on 15/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBJVideoPlayerController.h"

@interface VideoView : UIView <PBJVideoPlayerControllerDelegate>

-(void)setUpPreviewWithUrl:(NSString *)url withRemoteKey:(NSInteger)remoteKey;
//-(void)initialisePreviewWithUrl:(NSString *)url;

@end
