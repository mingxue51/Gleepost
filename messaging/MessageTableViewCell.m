//
//  MessageTableViewCell.m
//  Gleepost
//
//  Created by Σιλουανός on 9/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "AppearanceHelper.h"
#import "UIColor+GLPAdditions.h"

float const CONVERSATION_CELL_HEIGHT = 65.0;

@interface MessageTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet GLPConversationPictureImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIImageView *unreadImageView;

@end

@implementation MessageTableViewCell

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self formatElements];
    }
    
    return self;
}

- (void)formatElements
{
    
}

- (void)initialiseWithConversation:(GLPConversation *)conversation
{
    //If the message is new then do all bold and change the colour of the name to gleepost green colour.
    //cell.conversation = conversation;
    _userName.text = conversation.title;
//    _userName.font = [UIFont fontWithName:GLP_TITLE_FONT size:14.0f];
    
    _content.text = [conversation getLastMessageOrDefault];
    _content.textColor = [UIColor colorWithR:185.0 withG:185.0 andB:185.0];
//    _content.font = [UIFont fontWithName:GLP_MESSAGE_FONT size:12.0f];
    _content.numberOfLines = 1;
    
    
    _time.text = [conversation getLastUpdateOrDefault];
//    cell.time.textColor = [UIColor grayColor];
//    cell.time.font = [UIFont fontWithName:GLP_APP_FONT size:12.0f];
    
    _unreadImageView.hidden = !conversation.hasUnreadMessages;
    
    if(conversation.hasUnreadMessages)
    {
        [self formatReceivedNewMessage];
    }
    else
    {
        [self formatRegularMessage];
    }
    
    [_userImage configureWithConversation:conversation];
}

- (void)formatReceivedNewMessage
{
    [_time setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0]];
    [_userName setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0]];
    [_userName setTextColor:[AppearanceHelper blueGleepostColour]];
    [_content setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0]];
}

- (void)formatRegularMessage
{
    [_time setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0]];
    [_userName setFont:[UIFont fontWithName:@"HelveticaNeue" size:17.0]];
    [_userName setTextColor:[UIColor blackColor]];
    [_content setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0]];
}

@end
