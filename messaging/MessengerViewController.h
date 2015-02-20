//
//  MessengerViewController.h
//  Gleepost
//
//  Created by Σιλουανός on 19/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPSearchBar.h"

@interface MessengerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, GLPSearchBarDelegate>

// reload conversations when user comes back from chat view (or from a push notification), in order to update last message and last update
//@property (assign, nonatomic) BOOL needsReloadConversations;

@end
