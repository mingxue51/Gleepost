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
#import "InvitationSentView.h"
#import "WebClientHelper.h"
#import "ContactsManager.h"

@interface PrivateProfileViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *networkName;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *personalMessage;
@property (weak, nonatomic) IBOutlet UIButton *addUserButton;

@property (strong, nonatomic) GLPUser *profileUser;
@property (strong, nonatomic) InvitationSentView *invitationSentView;
@end


@implementation PrivateProfileViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    //Check if the user is already in contacts.
    //If yes show the regular profie view (unlocked).
    if([[ContactsManager sharedInstance] isUserContactWithId:self.selectedUserId])
    {
        NSLog(@"PrivateProfileViewController : Unlock Profile.");
    }
    else
    {
        //If no, check in database if the user is already requested.
        
        //If yes change the button of add user to user already requested.
        
        if([[ContactsManager sharedInstance] isContactWithIdRequested:self.selectedUserId])
        {
            NSLog(@"PrivateProfileViewController : User already requested by you.");
            UIImage *img = [UIImage imageNamed:@"invitesent"];
            [self.addUserButton setImage:img forState:UIControlStateNormal];
            [self.addUserButton setEnabled:NO];

            
        }
        else
        {
            //If not show the private profile view as is.
            NSLog(@"PrivateProfileViewController : Private profile as is.");
        }
    }
    
    
    
    
    
    [self loadAndSetUserDetails];
    
//    if([self isUserRequested])
//    {
//        //Add the image that is requested and remove add contact button.
//        
//    }
    
}

- (IBAction)addContact:(id)sender
{
    [[WebClient sharedInstance] addContact:self.selectedUserId callbackBlock:^(BOOL success) {
        
        NSLog(@"Profile User: %d", self.selectedUserId);
        
        if(success)
        {
            //Change the button style.
            NSLog(@"Request has been sent to the user.");
            
            self.invitationSentView = [InvitationSentView loadingViewInView:[self.view.window.subviews objectAtIndex:0]];
            self.invitationSentView.delegate = self;
        }
        else
        {
            NSLog(@"Failed to send to the user.");
            //This section of code should never be reached.
        }
    }];
}

-(BOOL)isUserRequested
{
    [[WebClient sharedInstance ] getContactsWithCallbackBlock:^(BOOL success, NSArray *contacts) {
        
        
        if(success)
        {
            //Store contacts into an array.
            NSLog(@"Contacts loaded successfully.");
            
            for(GLPContact *c in contacts)
            {
                if(c.youConfirmed)
                {
                    if([c.user.name isEqualToString:self.profileUser.name])
                    {
                        
                    }
                        
                }
            }

            
            //            self.users = contacts.mutableCopy;
            
        }
        else
        {
            [WebClientHelper showStandardError];
        }
        
        
    }];
    return NO;
}

-(void)loadAndSetUserDetails
{
    [[WebClient sharedInstance] getUserWithKey:self.selectedUserId callbackBlock:^(BOOL success, GLPUser *user) {
        
        if(success)
        {
            NSLog(@"Private Profile Load User Image URL: %@",user.profileImageUrl);
       
            self.profileUser = user;
            
            [self.userName setText:user.name];
            
            [self.networkName setText:user.networkName];
            
            [self.personalMessage setText:user.personalMessage];
            
            [self setRoundedView:self.profileImage toDiameter:self.profileImage.frame.size.height];
            
            
            
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

-(void)setRoundedView:(UIImageView *)roundedView toDiameter:(float)newSize;
{
    roundedView.clipsToBounds = YES;
    
    CGPoint saveCenter = roundedView.center;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = newSize / 2.0;
    roundedView.center = saveCenter;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
