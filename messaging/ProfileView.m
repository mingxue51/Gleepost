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
    [self setBackgroundColor:[UIColor clearColor]];
    [self sendSubviewToBack:self.back];
    
    //Get data from server and complete them in UIView.
    GLPUser* currentUser = [[SessionManager sharedInstance] user];
    
    NSLog(@"Remote Key: %d", currentUser.remoteKey);
    
    
    [ShapeFormatterHelper setRoundedView:self.profileImage toDiameter:self.profileImage.frame.size.height];
    
    //Not need to request. Take all the data from Session Manager.
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
