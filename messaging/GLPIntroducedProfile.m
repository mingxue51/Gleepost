//
//  GLPIntroducedProfile.m
//  Gleepost
//
//  Created by Silouanos on 24/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPIntroducedProfile.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "ShapeFormatterHelper.h"
#import "WebClient.h"
#import "GLPContact.h"
#import "ContactsManager.h"
#import "WebClientHelper.h"

@interface GLPIntroducedProfile ()

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIButton *profileBtn;
@property (weak, nonatomic) IBOutlet UIButton *addUser;

@property (strong, nonatomic) GLPUser *user;

@end

@implementation GLPIntroducedProfile

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self setFrame:CGRectMake(0, 0, 320.0f, 280.0f)];
    }
    
    return self;
}

-(void)updateContents:(GLPUser*)incomingUser
{
    self.user = incomingUser;
    
    UIImage *userImage;
    
    //Add the default image.
    userImage = [UIImage imageNamed:@"default_user_image2"];
    
    if([incomingUser.profileImageUrl isEqualToString:@""])
    {
        [self.userImage setImage:userImage];
    }
    else
    {
        [self.userImage setImageWithURL:[NSURL URLWithString:incomingUser.profileImageUrl] placeholderImage:nil];
    }
    
    [self.userName setText:incomingUser.name];
    
    [ShapeFormatterHelper setRoundedView:self.userImage toDiameter:self.userImage.frame.size.height];

    
    //Add tags to buttons.
    self.profileBtn.tag = incomingUser.remoteKey;
    self.addUser.tag = incomingUser.remoteKey;
    
}

- (IBAction)navigateToProfile:(id)sender
{
    [self.delegate navigateToProfile:sender];
}

- (IBAction)addUser:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    
    
    [[WebClient sharedInstance] addContact:btn.tag callbackBlock:^(BOOL success) {
        
        if(success)
        {
            //Change the button style.
            NSLog(@"Request has been sent to the user.");
            
//            self.invitationSentView = [InvitationSentView loadingViewInView:[_privateProfileDelegate.view.window.subviews objectAtIndex:0]];
//            self.invitationSentView.delegate = _privateProfileDelegate;
            
            
            GLPContact *contact = [[GLPContact alloc] initWithUserName:self.user.name profileImage:self.user.profileImageUrl youConfirmed:YES andTheyConfirmed:NO];
            contact.remoteKey = btn.tag;
            
            //Save contact to database.
            [[ContactsManager sharedInstance] saveNewContact:contact db:nil];
            
            [self setContactAsRequested];
            
        }
        else
        {
            NSLog(@"Failed to send to the user.");
            //This section of code should never be reached.
            [WebClientHelper showStandardErrorWithTitle:@"Failed to send request" andContent:@"Please check your internet connection and try again"];
        }
    }];
}

-(void)setContactAsRequested
{
    self.addUser.enabled = NO;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
