//
//  GLPConversationPictureImageView.m
//  Gleepost
//
//  Created by Lukas on 11/27/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPConversationPictureImageView.h"
#import "ShapeFormatterHelper.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "GLPImageHelper.h"
#import "UIImageView+Letters.h"

@implementation GLPConversationPictureImageView

@synthesize conversationRemoteKey=_conversationRemoteKey;

- (void)configureWithImage:(UIImage *)image
{
    _conversationRemoteKey = 0;
    
    self.image = image;
    [ShapeFormatterHelper setRoundedView:self toDiameter:self.frame.size.height];
}

- (void)configureWithConversation:(GLPConversation *)conversation
{
    _conversationRemoteKey = conversation.remoteKey;
    
    if(conversation.isGroup) {
        self.image = [GLPImageHelper placeholderGroupImage];
    } else {
        GLPUser *user = [conversation getUniqueParticipant];
        
        if([user hasProfilePicture]) {
            [self sd_setImageWithURL:[NSURL URLWithString:user.profileImageUrl] placeholderImage:[GLPImageHelper placeholderUserImage] options:SDWebImageRetryFailed];

        } else {
            [self setImageWithString:user.name];
        }
        
    }
    [ShapeFormatterHelper setRoundedView:self toDiameter:self.frame.size.height];

}

@end
