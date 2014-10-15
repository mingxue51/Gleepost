//
//  GLPSettingsViewController.h
//  Gleepost
//
//  Created by Σιλουανός on 12/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SettingsItem) {
    kNameSetting = 0,
    kPasswordSetting,
    kTaglineSetting,
    kInviteFriendsSetting,
};

@interface GLPSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@end
