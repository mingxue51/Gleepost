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
        self.image = [UIImage imageNamed:@"default_group_image"];
    } else {
        GLPUser *user = [conversation getUniqueParticipant];
        UIImage *defaultProfilePicture = [UIImage imageNamed:@"default_user_image2"];
        
        if([user hasProfilePicture]) {
            [self setImageWithURL:[NSURL URLWithString:user.profileImageUrl] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        } else {
            self.image = defaultProfilePicture;
        }
        
        [ShapeFormatterHelper setRoundedView:self toDiameter:self.frame.size.height];
    }

}

@end
