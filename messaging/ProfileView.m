//
//  ProfileView.m
//  Gleepost
//
//  Created by Σιλουανός on 15/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ProfileView.h"
#import "SessionManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "WebClient.h"
#import "ShapeFormatterHelper.h"


@interface ProfileView ()

@property(strong, nonatomic) GLPUser* currentUser;

@end

@implementation ProfileView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.currentUser = nil;
        
        [self hideNotificationsBubble];
        
    }
    return self;
}

- (void)showNotificationsBubble:(int)count
{
    self.notificationNewBubbleImageView.hidden = NO;
    self.notificationNewBubbleLabel.hidden = NO;
    self.notificationNewBubbleLabel.text = [NSString stringWithFormat:@"%d", count];
}

- (void)hideNotificationsBubble
{
    self.notificationNewBubbleImageView.hidden = YES;
    self.notificationNewBubbleLabel.hidden = YES;
}

-(void) initialiseView:(GLPUser*)incomingUser
{
    [self setBackgroundColor:[UIColor clearColor]];
    [self sendSubviewToBack:self.back];
    
    
    if(incomingUser == nil)
    {
        //Get data from server and complete them in UIView.
        self.currentUser = [[SessionManager sharedInstance] user];
        
        [self setUserDetails];
        
    }
    else
    {
         self.currentUser = incomingUser;
        
        //Remove some elements from the view like notifications etc.
        [self.busyFreeSwitch setHidden:YES];
        [self.notificationsButton setHidden:YES];
        
        [self.busyFreeSwitch setUserInteractionEnabled:NO];
        [self.notificationsButton setUserInteractionEnabled:NO];
        
        [self.busyFreeLabel setHidden:YES];
        
        //Fetch user's details from server.
        [self loadUserDetails:self.currentUser];
        
    }

    
}

-(void)setUserDetails
{    
    
    [ShapeFormatterHelper setRoundedView:self.profileImage toDiameter:self.profileImage.frame.size.height];
    
    //Not need to request. Take all the data from Session Manager.
    [self.profileHeadInformation setText: self.currentUser.networkName];
    
    
    
    if([ self.currentUser.profileImageUrl isEqualToString:@""])
    {
        //Set default image.
        [self.profileImage setImage:[UIImage imageNamed:@"default_user_image"]];
        NSLog(@"Profile User name: %@",  self.currentUser.profileImageUrl);
    }
    else
    {
        
        //Fetch the image from the server and add it to the image view.
        [self.profileImage setImageWithURL:[NSURL URLWithString: self.currentUser.profileImageUrl] placeholderImage:[UIImage imageNamed:nil]];
    }
}

-(void)loadUserDetails:(GLPUser*)inUser
{
    [[WebClient sharedInstance] getUserWithKey:inUser.remoteKey callbackBlock:^(BOOL success, GLPUser *user) {
        
        if(success)
        {
            self.currentUser = user;
            
            [self setUserDetails];
        }
        else
        {
            NSLog(@"Not Success: %d User: %@",success, user);
            
        }
        
        
        
    }];
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
