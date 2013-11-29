//
//  ViewTopicViewController.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPConversation.h"
#import "HPGrowingTextView.h"
#import "GLPLiveConversation.h"
#import "GLPLoadingCell.h"


@interface ViewTopicViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, HPGrowingTextViewDelegate, UIGestureRecognizerDelegate, GLPLoadingCellDelegate>
{
    int previousTextViewSize;
    CGRect        keyboardSuperFrame; // frame of keyboard when initially displayed
    UIView      * keyboardSuperView;  // reference to keyboard view
}


@property (strong, nonatomic) GLPConversation *conversation;

- (void)reloadElements;

@end
