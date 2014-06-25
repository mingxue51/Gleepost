//
//  GroupCollectionViewCell.h
//  Gleepost
//
//  Created by Σιλουανός on 24/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLPGroup;

@protocol GroupDeletedDelegate <NSObject>

@required
-(void)groupDeletedWithData:(GLPGroup *)group;

@end

extern const CGSize GROUP_COLLECTION_CELL_DIMENSIONS;

@interface GroupCollectionViewCell : UICollectionViewCell <UIAlertViewDelegate>

-(void)setGroupData:(GLPGroup *)groupData;
-(void)setDelegate:(UIViewController <GroupDeletedDelegate> *)delegate;

@end
