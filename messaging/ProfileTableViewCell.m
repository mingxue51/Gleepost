//
//  ProfileTableViewCell.m
//  Gleepost
//
//  Created by Silouanos on 09/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ProfileTableViewCell.h"
#import "ShapeFormatterHelper.h"
#import "GLPThemeManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ContactsManager.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "SessionManager.h"
#import "InvitationSentView.h"
#import "AppearanceHelper.h"
#import "ContactsManager.h"

@interface ProfileTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *universityLabel;
@property (weak, nonatomic) IBOutlet UIButton *addContactButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;

@property (weak, nonatomic) IBOutlet UIImageView *inContacts;
@property (weak, nonatomic) IBOutlet UISwitch *busySwitch;
@property (weak, nonatomic) IBOutlet UILabel *busyLabel;


@property (strong, nonatomic) GLPUser *currentUser;

@property (readonly, nonatomic) GLPProfileViewController *delegate;
@property (readonly, nonatomic) GLPPrivateProfileViewController *privateProfileDelegate;

@property (strong, nonatomic) InvitationSentView *invitationSentView;


@end

@implementation ProfileTableViewCell

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
    }
    
    return self;
}

-(void)initialiseProfileImage:(UIImage*)image
{
    [self initialiseLoadingElements];

    
    [ShapeFormatterHelper setRoundedView:self.profileImage toDiameter:self.profileImage.frame.size.height];
    
    self.profileImage.layer.borderWidth = 4.0;
    self.profileImage.layer.borderColor = [AppearanceHelper colourForNotFocusedItems].CGColor;
    
    [self.profileImage setImage:image];
}

-(void)initialiseElementsWithUserDetails:(GLPUser *)user withImage:(UIImage*)image
{
    if(user == nil)
    {
        [self initialiseLoadingElements];
        
        return;
    }
    
    self.currentUser = user;
    
    [self.busySwitch setOn:!self.isBusy];

    

    
    [self.universityLabel setText:user.networkName];
    
    [ShapeFormatterHelper setRoundedView:self.profileImage toDiameter:self.profileImage.frame.size.height];
    
    self.profileImage.layer.borderWidth = 4.0;
    self.profileImage.layer.borderColor = [AppearanceHelper colourForNotFocusedItems].CGColor;
    
    
    
    
    if([user.profileImageUrl isEqualToString:@""])
    {
        //Set default image.
        [self.profileImage setImage:[UIImage imageNamed:@"default_user_image"]];
    }
    else
    {
        [self.profileImage setImage:image];
    }
    
    //Decide which elements to present.
    [self setCurrentUserStatusWithUser:user];

}


-(void)initialiseElementsWithUserDetails:(GLPUser *)user
{
    
//    [self.course setText: user.course];
    
//    [self.personalMessage setText:user.personalMessage];
    
    if(user == nil)
    {
        [self initialiseLoadingElements];
        
        return;
    }
    
    self.currentUser = user;
    
    [self.busySwitch setOn:!self.isBusy];

    
    [self.universityLabel setText:user.networkName];

    [ShapeFormatterHelper setRoundedView:self.profileImage toDiameter:self.profileImage.frame.size.height];
    
    self.profileImage.layer.borderWidth = 4.0;
    self.profileImage.layer.borderColor = [AppearanceHelper colourForNotFocusedItems].CGColor;
    
    

    
    if([user.profileImageUrl isEqualToString:@""])
    {
        //Set default image.
        [self.profileImage setImage:[UIImage imageNamed:@"default_user_image2"]];
    }
    else
    {
        
        //Fetch the image from the server and add it to the image view.
        //[self.profileImage setImageWithURL:[NSURL URLWithString:user.profileImageUrl] placeholderImage:[UIImage imageNamed:@"default_user_image"]];
        
        [self.profileImage setImageWithURL:[NSURL URLWithString:user.profileImageUrl] placeholderImage:[UIImage imageNamed:@"default_user_image"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {

            
        }];
        
        //TODO: Create shadow to the image.
        
        //                self.profileImage.layer.shadowColor = [UIColor blackColor].CGColor;
        //                self.profileImage.layer.shadowOffset = CGSizeMake(-1, 1);
        //                self.profileImage.layer.shadowOpacity = 1;
        //                self.profileImage.layer.shadowRadius = 3.0;
        //                self.profileImage.clipsToBounds = NO;
        
        
        
        
        
        //                UIBezierPath *maskPath;
        //                maskPath = [UIBezierPath bezierPathWithRoundedRect:self.profileImage.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(10.0, 10.0)];
        //
        //                CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        //                maskLayer.frame = self.view.bounds;
        //                maskLayer.path = maskPath.CGPath;
        //                self.profileImage.layer.mask = maskLayer;
        
        
        
        
        

    }
    
    //Decide which elements to present.
    [self setCurrentUserStatusWithUser:user];
}

-(void)initialiseLoadingElements
{
    [self.universityLabel setText:@"Loading..."];
    
    [ShapeFormatterHelper setRoundedView:self.profileImage toDiameter:self.profileImage.frame.size.height];
    
    self.profileImage.layer.borderWidth = 4.0;
    self.profileImage.layer.borderColor = [AppearanceHelper colourForNotFocusedItems].CGColor;
    
    
    //Set default image.
   [self.profileImage setImage:[UIImage imageNamed:@"default_user_image2"]];
    
    
    //Hide all the elements.
    [self.addContactButton setHidden:YES];
    [self.acceptButton setHidden:YES];
    [self.inContacts setHidden:YES];
    [self.messageButton setHidden:YES];
    [self.busyLabel setHidden:YES];
    [self.busySwitch setHidden:YES];
}

-(void)updateImageWithUrl:(NSString*)url
{
    [self.profileImage setImageWithURL:[NSURL URLWithString:url]];
}

-(void)setDelegate:(GLPProfileViewController *)delegate
{
    _delegate = delegate;
}

-(void)setPrivateProfileDelegate:(GLPPrivateProfileViewController*)delegate
{
    _privateProfileDelegate = delegate;
}

-(void)setCurrentUserStatusWithUser:(GLPUser *)user
{

    CGRect universityLabelFrame = self.universityLabel.frame;
    
    if(self.currentUser.remoteKey == [[SessionManager sharedInstance].user remoteKey])
    {
        //Set only current user's elements.
        
        [self.addContactButton setHidden:YES];
        [self.acceptButton setHidden:YES];
        [self.inContacts setHidden:YES];
        [self.messageButton setHidden:YES];
        
        //Show busy free toggle.
        [self.busyLabel setHidden:NO];
        [self.busySwitch setHidden:NO];
        
        //Load data for busy switch.
//        [self getBusyStatus];
        
        //Add selector to profile image view.
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeProfileImage:)];
        [tap setNumberOfTapsRequired:1];
//        [self.profileImage setUserInteractionEnabled:YES];
        [self.profileImage addGestureRecognizer:tap];
        
        //Change the position of the university label.
       // [self.universityLabel setFrame:CGRectMake(universityLabelFrame.origin.x, 180.0f, universityLabelFrame.size.width, universityLabelFrame.size.height)];
        
        
    }
    else
    {
        if([[ContactsManager sharedInstance] isUserContactWithId:user.remoteKey])
        {
            //TODO: Set in table view contact as in contacts.
            [self.inContacts setHidden:NO];
            [self.addContactButton setHidden:YES];
        }
        else
        {
            if([[ContactsManager sharedInstance] isContactWithIdRequested:user.remoteKey])
            {
                [self setContactAsRequested];
            }
            else if ([[ContactsManager sharedInstance]isContactWithIdRequestedYou:user.remoteKey])
            {
                [self setAcceptRequestButton];
            }
            else
            {
                //If not show the private profile view as is.
            }
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:_privateProfileDelegate action:@selector(showFullProfileImage:)];
        [tap setNumberOfTapsRequired:1];
        [self.profileImage addGestureRecognizer:tap];
        
        
        //TODO: Issue by moving the information label.
        //Change the position of the university label.
       // [self.universityLabel setFrame:CGRectMake(universityLabelFrame.origin.x, 160.0f, universityLabelFrame.size.width, universityLabelFrame.size.height)];
    }
    
    [self.universityLabel setHidden:NO];
}

-(void)changeProfileImage:(id)sender
{
    [_delegate changeProfileImage:sender];
}

-(void)setContactAsRequested
{
    UIImage *img = [UIImage imageNamed:@"pending"];
    [self.addContactButton setImage:img forState:UIControlStateNormal];
    [self.addContactButton setEnabled:NO];
}

-(void)setAcceptRequestButton
{
    [self.addContactButton setHidden:YES];
    [self.addContactButton setEnabled:NO];
    [self.acceptButton setHidden:NO];
}

#pragma mark - Selectors

- (IBAction)acceptUser:(id)sender
{
    //Accept contact in the local database and in server.
    [[ContactsManager sharedInstance] acceptContact:self.currentUser.remoteKey callbackBlock:^(BOOL success) {
        
        if(success)
        {
            //Hide accept button and show contact button.
            [self.acceptButton setHidden:YES];
            
            [self.inContacts setHidden:NO];
            
            //Call method in Controller to unlock profile.
            [_privateProfileDelegate unlockProfile];
        }
        else
        {
            //Error message.
            [WebClientHelper showStandardErrorWithTitle:@"Failed to accept contact" andContent:@"Please check your internet connection and try again"];
            
        }
    }];
}

- (IBAction)sendMessage:(id)sender {
}

#pragma mark - Client

//-(void)getBusyStatus
//{
//    [[WebClient sharedInstance] getBusyStatus:^(BOOL success, BOOL status) {
//        
//        if(success)
//        {
//            [self.busySwitch setOn:!status];
//        }
//    }];
//}

- (IBAction)setBusyStatus:(id)sender
{
    UISwitch *s = (UISwitch*)sender;
    
    
    [[WebClient sharedInstance] setBusyStatus:!s.isOn callbackBlock:^(BOOL success) {
        
        if(success)
        {
            //Do something.
        }
    }];
}

- (IBAction)addUser:(id)sender
{
    [[WebClient sharedInstance] addContact:self.currentUser.remoteKey callbackBlock:^(BOOL success) {
        
        if(success)
        {
            //Change the button style.
            NSLog(@"Request has been sent to the user.");
            
            self.invitationSentView = [InvitationSentView loadingViewInView:[_privateProfileDelegate.view.window.subviews objectAtIndex:0]];
            self.invitationSentView.delegate = _privateProfileDelegate;
            
            
            GLPContact *contact = [[GLPContact alloc] initWithUserName:self.currentUser.name profileImage:self.currentUser.profileImageUrl youConfirmed:YES andTheyConfirmed:NO];
            contact.remoteKey = self.currentUser.remoteKey;
            
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
