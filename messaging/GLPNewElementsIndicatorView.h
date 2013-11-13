//
//  GLPNewElementsIndicatorView.h
//  Gleepost
//
//  Created by Lukas on 11/13/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GLPNewElementsIndicatorViewDelegate <NSObject>

- (void)newElementsIndicatorViewPushed;

@end


@interface GLPNewElementsIndicatorView : UIView

@property (weak, nonatomic) id<GLPNewElementsIndicatorViewDelegate> delegate;

- (id)initWithDelegate:(id<GLPNewElementsIndicatorViewDelegate>) delegate;

@end

