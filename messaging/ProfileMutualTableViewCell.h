//
//  ProfileMutualTableViewCell.h
//  Gleepost
//
//  Created by Silouanos on 09/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileMutualTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileUserImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

-(void)updateDataWithName:(NSString*)name andImageUrl:(NSString*)url;

@end
