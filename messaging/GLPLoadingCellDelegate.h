//
//  GLPLoadingCellDelegate.h
//  Gleepost
//
//  Created by Lukas on 1/28/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPLoadingCell.h"

typedef enum {
    kGLPLoadingStateReady,
    kGLPLoadingStateLoading,
    kGLPLoadingStateStopped,
} GLPLoadingCellState;

typedef enum {
    kGLPLoadingCellPositionTop,
    kGLPLoadingCellPositionBottom,
} GLPLoadingCellPosition;

@interface GLPLoadingCellDelegate : NSObject

@property (assign, nonatomic) BOOL isVisible;
@property (assign, nonatomic) GLPLoadingCellState cellState;

- (void)activate;
- (void)show;
- (void)hide;
- (void)configureCell:(GLPLoadingCell *)cell;
- (NSInteger)numberOfRows;
- (GLPLoadingCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
