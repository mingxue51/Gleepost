//
//  GLPConversationViewController.h
//  Gleepost
//
//  Created by Lukas on 1/30/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPTableViewController.h"
#import "GLPConversation.h"
#import "HPGrowingTextView.h"

@interface GLPConversationViewController : GLPTableViewController <UITextViewDelegate, HPGrowingTextViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) GLPConversation *conversation;

-(void)navigateToProfile:(id)sender;


@end
