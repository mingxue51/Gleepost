//
//  MessagesViewController.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPLoadingCell.h"

@interface MessagesViewController : UITableViewController <GLPLoadingCellDelegate>

extern NSString * const LIVE_CHATS_STR;
extern NSString * const CONTACTS_CHATS_STR;

@end
