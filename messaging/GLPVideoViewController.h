//
//  GLPVideoViewController.h
//  Gleepost
//
//  Created by Silouanos on 12/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBJVision.h"
#import "PBJVideoPlayerController.h"

@interface GLPVideoViewController : UIViewController<PBJVisionDelegate, UIGestureRecognizerDelegate, PBJVideoPlayerControllerDelegate>

@end
