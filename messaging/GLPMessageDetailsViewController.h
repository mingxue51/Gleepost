//
//  GLPMessageDetailsViewController.h
//  Gleepost
//
//  Created by Silouanos on 18/02/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLPMessage;

@interface GLPMessageDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *reads;
@property (strong, nonatomic) GLPMessage *message;

@end
