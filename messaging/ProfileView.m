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



@interface ProfileView ()


@end

@implementation ProfileView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

-(void) initialiseView
{
    NSLog(@"View Called");

    
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self sendSubviewToBack:self.back];
    
    //Get data from server and complete them in UIView.
    __block GLPUser* currentUser = [[SessionManager sharedInstance] user];
    
    NSLog(@"Remote Key: %d", currentUser.remoteKey);
    

    
    self.profileImage.clipsToBounds = YES;
    
    self.profileImage.layer.cornerRadius = 60;
    
    [[WebClient sharedInstance] getUserWithKey:currentUser.remoteKey callbackBlock:^(BOOL success, GLPUser *user) {
        
        if(success)
        {
            NSLog(@"Load User Image URL: %@",user.profileImageUrl);
            currentUser = user;
            
            [self.profileHeadInformation setText:currentUser.networkName];
            
            
            
            if([currentUser.profileImageUrl isEqualToString:@""])
            {
                //Set default image.
                [self.profileImage setImage:[UIImage imageNamed:@"default_user_image"]];
                NSLog(@"Profile User name: %@", currentUser.profileImageUrl);
            }
            else
            {

                //Fetch the image from the server and add it to the image view.
                [self.profileImage setImageWithURL:[NSURL URLWithString:currentUser.profileImageUrl] placeholderImage:[UIImage imageNamed:nil]];
            }
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
