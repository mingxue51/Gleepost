//
//  ContactCell.h
//  Gleepost
//
//  Created by Σιλουανός on 30/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPGroup.h"

@class GLPMember;

@protocol MemberCellDelegate <NSObject>

- (void)moreOptionsSelectedForMember:(GLPMember *)member;

@end

@interface MemberCell : UITableViewCell

extern const float CONTACT_CELL_HEIGHT;

@property (weak, nonatomic) UIViewController<MemberCellDelegate> *delegate;

/** Creates the elements of the cell. */
-(void)setName:(NSString *)name withImageUrl:(NSString *)imageUrl;

-(void)setMember:(GLPMember *)member withGroup:(GLPGroup *)group loggedInMemberRole:(GLPMember *)loggedInMember;

@end
