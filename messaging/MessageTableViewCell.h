//
//  MessageTableViewCell.h
//  Gleepost
//
//  Created by Σιλουανός on 9/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPConversationPictureImageView.h"

extern float const CONVERSATION_CELL_HEIGHT;

@interface MessageTableViewCell : UITableViewCell

- (void)initialiseWithConversation:(GLPConversation *)conversation;

@end
