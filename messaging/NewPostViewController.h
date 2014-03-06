//
//  NewPostViewController.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDTakeController.h"
#import "NewPostDelegate.h"

@interface NewPostViewController : UIViewController <UINavigationControllerDelegate, FDTakeDelegate>

//@property (weak, nonatomic) GLPTimelineViewController *delegate;
@property (weak, nonatomic) UIViewController <NewPostDelegate> *delegate;
@property (strong, nonatomic) IBOutlet UINavigationBar *simpleNavBar;

//Used only if the class is call from the groups view controller.
@property (strong, nonatomic) GLPGroup *group;

- (IBAction)addImage:(id)sender;
- (void)doneSelectingDateForEvent:(NSDate *)date andTitle:(NSString *)title;
-(void)cancelSelectingDateForEvent;


@end
