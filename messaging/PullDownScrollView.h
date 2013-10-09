//
//  PullDownScrollView.h
//  Gleepost
//
//  Created by Σιλουανός on 8/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#define REFHEIGHT   60

@interface PullDownScrollView : UIScrollView<UIScrollViewDelegate>
{
    BOOL isLoading;
    BOOL isDraging;
}
@property (strong, nonatomic) UIImageView *pullDownImageView;

@end
