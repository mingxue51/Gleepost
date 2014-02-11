//
//  NewPostViewController.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPTimelineViewController.h"
#import "FDTakeController.h"

@interface NewPostViewController : UIViewController <UINavigationControllerDelegate, FDTakeDelegate>

@property (weak, nonatomic) GLPTimelineViewController *delegate;
@property (strong, nonatomic) IBOutlet UINavigationBar *simpleNavBar;

- (IBAction)addImage:(id)sender;
- (void)doneSelectingDateForEvent:(NSDate *)date andTitle:(NSString *)title;
-(void)cancelSelectingDateForEvent;


@end
