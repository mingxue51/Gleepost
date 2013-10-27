//
//  ContactCell.h
//  Gleepost
//
//  Created by Σιλουανός on 30/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactUserCell : UITableViewCell

/** User's profile image. */
@property (retain, nonatomic) IBOutlet UIImageView *profileImageUser;

/** User's name. */
@property (retain, nonatomic) IBOutlet UILabel *nameUser;


/** Creates the elements of the cell. */
-(void) createElements;


@end
