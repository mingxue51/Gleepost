//
//  GLPPrivateProfileViewController.h
//  Gleepost
//
//  Created by Silouanos on 09/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GLPPrivateProfileViewController : UITableViewController

typedef enum {
    kGLPAbout,
    kGLPPosts,
    kGLPMutual
    
}GLPSelectedTab;


@property (assign, nonatomic) int selectedUserId;


-(void)viewSectionWithId:(GLPSelectedTab) selectedTab;

@end
