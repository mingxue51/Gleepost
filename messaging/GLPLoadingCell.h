//
//  GLPLoadingCell.h
//  Gleepost
//
//  Created by Lukas on 10/29/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kGLPLoadingCellStatusInit, // deprecated
    kGLPLoadingCellStatusSuccess, // deprecated
    kGLPLoadingCellStatusFinished, // deprecated
    
    kGLPLoadingCellStatusDisabled,
    kGLPLoadingCellStatusReady,
    kGLPLoadingCellStatusLoading,
    kGLPLoadingCellStatusError
} GLPLoadingCellStatus;


@protocol GLPLoadingCellDelegate

- (void)loadingCellDidReload;

@end


@interface GLPLoadingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *loadMoreButton;
@property (weak, nonatomic) id<GLPLoadingCellDelegate> delegate;
@property (assign, nonatomic) BOOL shouldShowError;

extern float const kGLPLoadingCellHeight;
extern NSString * const kGLPLoadingCellIdentifier;
extern NSString * const kGLPLoadingCellNibName;

- (void)updateWithStatus:(GLPLoadingCellStatus)status;

// new API
- (void)startAnimating;

@end


