//
//  GLPLoadingCell.h
//  Gleepost
//
//  Created by Lukas on 10/29/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kGLPLoadingCellStatusInit,
    kGLPLoadingCellStatusLoading,
    kGLPLoadingCellStatusError,
    kGLPLoadingCellStatusSuccess,
    kGLPLoadingCellStatusFinished,
} GLPLoadingCellStatus;

@interface GLPLoadingCell : UITableViewCell



extern float const kGLPLoadingCellHeight;

- (void)show;
- (void)updateWithStatus:(GLPLoadingCellStatus)status;

@end
