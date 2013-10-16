//
//  ViewPostTableView.h
//  Gleepost
//
//  Created by Σιλουανός on 3/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostView.h"
#import "TypeTextView.h"
#import "Post.h"

@interface ViewPostTableView : UITableView

@property (strong, nonatomic) IBOutlet PostView *headerView;
@property (strong, nonatomic) TypeTextView *typeTextView;

-(void) initTableView;

@end
