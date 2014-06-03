//
//  WTSecondScreenView.h
//  Gleepost
//
//  Created by Silouanos on 03/06/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WTSecondScreenViewDelegate <NSObject>

- (void)exitWalkthrough;

@end

@interface WTSecondScreenView : UIView

@property (assign, nonatomic) UIViewController <WTSecondScreenViewDelegate> *delegate;


@end
