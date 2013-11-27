//
//  GLPConversationPictureImageView.h
//  Gleepost
//
//  Created by Lukas on 11/27/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPConversation.h"

@interface GLPConversationPictureImageView : UIImageView

- (void)configureWithImage:(UIImage *)image;
- (void)configureWithConversation:(GLPConversation *)conversation;

@end
