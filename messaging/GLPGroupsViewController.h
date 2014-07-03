//
//  GLPGroupsViewController.h
//  Gleepost
//
//  Created by Σιλουανός on 24/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewGroupViewController.h"
#import "GroupCollectionViewCell.h"
#import "GLPSearchBar.h"

@interface GLPGroupsViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GroupCreatedDelegate, GroupDeletedDelegate, GLPSearchBarDelegate>

@end
