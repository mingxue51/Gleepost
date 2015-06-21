//
//  GLPConversationViewController.h
//  Gleepost
//
//  Created by Lukas on 1/30/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPTableViewController.h"
#import "GLPConversation.h"
#import "GLPUser.h"
#import "HPGrowingTextView.h"
#import "GLPMessageCell.h"

@interface GLPConversationViewController : GLPTableViewController <UITextViewDelegate, HPGrowingTextViewDelegate, UIGestureRecognizerDelegate, GLPMessageCellDelegate>

@property (strong, nonatomic) GLPConversation *conversation;
@property (assign, nonatomic) BOOL comesFromPN;

- (void)disableAddUserButton;

@end
