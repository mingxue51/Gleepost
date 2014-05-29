//
//  SetEventInformationCell.h
//  Gleepost
//
//  Created by Silouanos on 28/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PendingPost;

@protocol SetEventInformationCellDelegate <NSObject>

@required
-(void)showDatePickerWithPendingPost:(PendingPost *)pendingPost withHiddenDatePicker:(BOOL)hidden;
-(void)datePickerUpdatedWithPendingPost:(PendingPost *)pendingPost;
-(void)eventTextViewUpdatedWithPendingPost:(PendingPost *)pendingPost;

@end

@interface SetEventInformationCell : UITableViewCell

extern NSString * const kGLPSetInformationCell;
extern float const INFORMATION_CELL_HEIGHT;
extern float const INFORMATION_DATE_PICKER_HEIGHT;


-(void)initialiseElementsWithDelegate:(UIViewController<SetEventInformationCellDelegate> *)delegate withPendingPost:(PendingPost *)pendingPost;
-(void)setHiddenToDatePicker:(BOOL)hidden;

@end
