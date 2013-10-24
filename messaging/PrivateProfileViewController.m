//
//  PrivateProfileViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 16/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "PrivateProfileViewController.h"
#import "GLPUser.h"
#import "WebClient.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface PrivateProfileViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *networkName;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *personalMessage;

@property (strong, nonatomic) GLPUser *profileUser;
@end


@implementation PrivateProfileViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadAndSetUserDetails];
    
    
}



-(void)loadAndSetUserDetails
{
    [[WebClient sharedInstance] getUserWithKey:self.selectedUserId callbackBlock:^(BOOL success, GLPUser *user) {
        
        if(success)
        {
            NSLog(@"Private Profile Load User Image URL: %@",user.profileImageUrl);
       
            
            
            
            [self.userName setText:user.name];
            
            [self.networkName setText:user.networkName];
            
            [self.personalMessage setText:user.personalMessage];
            
            self.profileImage.clipsToBounds = YES;
            
            self.profileImage.layer.cornerRadius = 60;
            
            
            
            if([user.profileImageUrl isEqualToString:@""])
            {
                //Set default image.
                [self.profileImage setImage:[UIImage imageNamed:@"default_user_image"]];
            }
            else
            {
                
                //Fetch the image from the server and add it to the image view.
                [self.profileImage setImageWithURL:[NSURL URLWithString:user.profileImageUrl] placeholderImage:[UIImage imageNamed:@"default_user_image"]];
            }
        }
        else
        {
            NSLog(@"Not Success: %d User: %@",success, user);
            
        }
        
        
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
