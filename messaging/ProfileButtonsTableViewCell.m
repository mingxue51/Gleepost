//
//  ProfileButtonsTableViewCell.m
//  Gleepost
//
//  Created by Silouanos on 09/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ProfileButtonsTableViewCell.h"
#import "ConversationManager.h"
#import "WebClient.h"
#import "SessionManager.h"
#import "GLPContact.h"
#import "WebClientHelper.h"
#import "ContactsManager.h"


@interface ProfileButtonsTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *aboutLine;
@property (weak, nonatomic) IBOutlet UIImageView *postsLine;
@property (weak, nonatomic) IBOutlet UIImageView *mutualLine;


@end

@implementation ProfileButtonsTableViewCell

const float BUTTONS_CELL_HEIGHT = 45.0f;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
    }
    
    return self;
}

-(void)setDelegate:(GLPPrivateProfileViewController *)delegate
{
    _delegate = delegate;
}

- (IBAction)viewAbout:(id)sender
{
    [self setGrayToNavigators];

    [self setGreenToNavigator:self.aboutLine];
    
    [_delegate viewSectionWithId:kGLPAbout];
}

- (IBAction)viewPosts:(id)sender
{
    [self setGrayToNavigators];

    [self setGreenToNavigator:self.postsLine];


    [_delegate viewSectionWithId:kGLPPosts];

}

- (IBAction)viewMutual:(id)sender
{
    [self setGrayToNavigators];

    [self setGreenToNavigator:self.mutualLine];

    [_delegate viewSectionWithId:kGLPMutual];
}


-(void)setGreenToNavigator:(UIImageView*)navigator
{
    [navigator setImage:[UIImage imageNamed:@"active_tab"]];
}

-(void)setGrayToNavigators
{
    [self.aboutLine setImage:[UIImage imageNamed:@"idle_tab"]];
    
    [self.postsLine setImage:[UIImage imageNamed:@"idle_tab"]];
    [self.mutualLine setImage:[UIImage imageNamed:@"idle_tab"]];
}

-(void)showAllLines
{
    [self.aboutLine setHidden:NO];
    [self.postsLine setHidden:NO];
    [self.mutualLine setHidden:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (IBAction)sendMessage:(id)sender
{
    //If conversation with user already exist, don't create a new one.
    [ConversationManager loadConversationWithParticipant:self.currentUser.remoteKey withCallback:^(BOOL sucess, GLPConversation *conversation) {
        
        if(sucess)
        {
            //Conversation exist.
            [self.delegate viewConversation:conversation];
            DDLogInfo(@"Conversation already exist: %@", conversation.title);
        }
        else
        {
            //Conversation not exist, create new fake conversation.
            
            NSArray *part = [[NSArray alloc] initWithObjects:self.currentUser, [SessionManager sharedInstance].user, nil];
            
            [self.delegate viewConversation:[ConversationManager createFakeConversationWithParticipants:part]];
            
            DDLogInfo(@"Fake conversation just created.");
            
        }
        
    }];

}

//- (IBAction)sendMessage:(id)sender
//{
//    
//    //If conversation with user already exist, don't create a new one.
//    [ConversationManager loadConversationWithParticipant:self.currentUser.remoteKey withCallback:^(BOOL sucess, GLPConversation *conversation) {
//        
//        if(sucess)
//        {
//            //Conversation exist.
//            [_privateProfileDelegate viewConversation:conversation];
//            DDLogInfo(@"Conversation already exist: %@", conversation.title);
//        }
//        else
//        {
//            //Conversation not exist, create new fake conversation.
//            
//            NSArray *part = [[NSArray alloc] initWithObjects:self.currentUser, [SessionManager sharedInstance].user, nil];
//            
//            [_privateProfileDelegate viewConversation:[ConversationManager createFakeConversationWithParticipants:part]];
//            
//            DDLogInfo(@"Fake conversation just created.");
//            
//        }
//        
//    }];
//    
//    
//    
//}

- (void)addUser:(id)sender
{
    [[WebClient sharedInstance] addContact:self.currentUser.remoteKey callbackBlock:^(BOOL success) {
        
        if(success)
        {
            //Change the button style.
            NSLog(@"Request has been sent to the user.");
            
            self.invitationSentView = [InvitationSentView loadingViewInView:[self.delegate.view.window.subviews objectAtIndex:0]];
            self.invitationSentView.delegate = self.delegate;
            
            
            GLPContact *contact = [[GLPContact alloc] initWithUserName:self.currentUser.name profileImage:self.currentUser.profileImageUrl youConfirmed:YES andTheyConfirmed:NO];
            contact.remoteKey = self.currentUser.remoteKey;
            
            //Save contact to database.
            [[ContactsManager sharedInstance] saveNewContact:contact db:nil];
            
            //[self setContactAsRequested];
            
        }
        else
        {
            NSLog(@"Failed to send to the user.");
            //This section of code should never be reached.
            [WebClientHelper showStandardErrorWithTitle:@"Failed to send request" andContent:@"Please check your internet connection and try again"];
        }
    }];
}




@end
