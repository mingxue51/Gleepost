//
//  ChatViewController.h
//  messaging
//
//  Created by Lukas on 8/29/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController


@property BOOL newChat;

- (void)searchForConversationForGroup:(BOOL)group;
-(void)navigateToLiveChatWithIndex: (int)index;

@end
