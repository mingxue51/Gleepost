//
//  ContactCell.h
//  Gleepost
//
//  Created by Σιλουανός on 30/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPGroup.h"

@interface ContactUserCell : UITableViewCell

extern const float CONTACT_CELL_HEIGHT;

/** User's profile image. */
@property (retain, nonatomic) IBOutlet UIImageView *profileImageUser;

/** User's name. */
@property (retain, nonatomic) IBOutlet UILabel *nameUser;

@property (weak, nonatomic) IBOutlet UILabel *creatorLbl;


/** Creates the elements of the cell. */
-(void)setName:(NSString *)name withImageUrl:(NSString *)imageUrl;

-(void)setMember:(GLPUser *)member withGroup:(GLPGroup *)group;

@end
