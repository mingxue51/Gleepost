//
//  VideoCaptureView.h
//  Gleepost
//
//  Created by Silouanos on 13/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBJVision.h"

@interface VideoCaptureView : UIView<PBJVisionDelegate, UIGestureRecognizerDelegate>

@end
