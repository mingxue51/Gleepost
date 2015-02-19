//
//  GLPNameTimestampCell.h
//  Gleepost
//
//  Created by Silouanos on 18/02/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLPConversationRead;

@interface GLPNameTimestampCell : UITableViewCell

- (void)setConversationRead:(GLPConversationRead *)conversationRead;
+ (CGFloat)height;

@end
