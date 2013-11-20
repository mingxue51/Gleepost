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
#import "AppearanceHelper.h"
#import "ViewPostImageViewController.h"
#import "TransitionDelegateViewImage.h"
#import "ContactsManager.h"
#import "UIViewController+GAI.h"
#import "ProfileViewController.h"

@interface PrivateProfileViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *networkName;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *personalMessage;
@property (weak, nonatomic) IBOutlet UIButton *addUserButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptUserButton;

@property (strong, nonatomic) GLPUser *profileUser;
@property (strong, nonatomic) InvitationSentView *invitationSentView;
@property (strong, nonatomic) TransitionDelegateViewImage *transitionViewImageController;

@end


@implementation PrivateProfileViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar2" forBarMetrics:UIBarMetricsDefault];

    self.transitionViewImageController = [[TransitionDelegateViewImage alloc] init];


    //For test purposes.
    //Remove the previous view controller.
    //TODO: Not tested.
    NSMutableArray *controllers = self.navigationController.viewControllers.mutableCopy;
    
    [controllers removeObjectAtIndex:controllers.count-2];
    
    [self.navigationController setViewControllers:controllers];
    
    //Override back navigation button.
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back1"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(goBackToCampusWall:)];
    
    self.navigationItem.backBarButtonItem = backButton;
    
    
//    self.navigationItem.leftBarButtonItem = backButton;
    
    ////////
    
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
            [self setContactAsRequested];
            
        }
        else if ([[ContactsManager sharedInstance]isContactWithIdRequestedYou:self.selectedUserId])
        {
            NSLog(@"PrivateProfileViewController : User requested you.");
            
            [self setAcceptRequestButton];

        }
        else
        {
            //If not show the private profile view as is.
            NSLog(@"PrivateProfileViewController : Private profile as is2.");
        }
    }
    
    
    
    [self formatProfileView];
    
    [self loadAndSetUserDetails];
    
//    if([self isUserRequested])
//    {
//        //Add the image that is requested and remove add contact button.
//        
//    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self sendViewToGAI:NSStringFromClass([self class])];
}

-(void)goBackToCampusWall:(id)sender
{
    NSLog(@"GO BACK TO CAMPUS WALL.");
    
    UIViewController *campusWallController = [[self.navigationController viewControllers] objectAtIndex:self.navigationController.viewControllers.count-1];
    
    NSLog(@"Back class: %@",[campusWallController class]);
    
    [self.navigationController popToViewController:campusWallController animated:YES];
}

-(void)setContactAsRequested
{
    UIImage *img = [UIImage imageNamed:@"invitesent"];
    [self.addUserButton setImage:img forState:UIControlStateNormal];
    [self.addUserButton setEnabled:NO];
}

-(void)setAcceptRequestButton
{
    [self.addUserButton setHidden:YES];
    [self.addUserButton setEnabled:NO];
    [self.acceptUserButton setHidden:NO];
}

-(void)formatProfileView
{
    [[self.profileImage layer] setBorderWidth:6.0f];
    [[self.profileImage layer] setBorderColor:[UIColor colorWithRed:243.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0].CGColor];
}

//Accept contact.
- (IBAction)acceptContact:(id)sender
{
    
    //If success from server then navigate to unlocked profile.
    [[WebClient sharedInstance]acceptContact:self.selectedUserId callbackBlock:^(BOOL success) {
       
        if(success)
        {
            

            
            //Navigate to unlock profile.
            [self performSegueWithIdentifier:@"view profile" sender:self];
            
            //Change the status of contact in local database.
            [[ContactsManager sharedInstance] contactWithRemoteKeyAccepted:self.selectedUserId];
        }
        else
        {
            //Error message.
            [WebClientHelper showStandardErrorWithTitle:@"Failed to accept contact" andContent:@"Please check your internet connection and try again"];

        }
        
    }];
}


- (IBAction)addContact:(id)sender
{
    [[WebClient sharedInstance] addContact:self.selectedUserId callbackBlock:^(BOOL success) {
        
        if(success)
        {
            //Change the button style.
            NSLog(@"Request has been sent to the user.");
            
            self.invitationSentView = [InvitationSentView loadingViewInView:[self.view.window.subviews objectAtIndex:0]];
            self.invitationSentView.delegate = self;
            
            
            GLPContact *contact = [[GLPContact alloc] initWithUserName:self.profileUser.name profileImage:self.profileUser.profileImageUrl youConfirmed:YES andTheyConfirmed:NO];
            
            //Save contact to database.
            [[ContactsManager sharedInstance] saveNewContact:contact];
            
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

//-(BOOL)isUserRequested
//{
//    [[WebClient sharedInstance ] getContactsWithCallbackBlock:^(BOOL success, NSArray *contacts) {
//        
//        
//        if(success)
//        {
//            //Store contacts into an array.
//            NSLog(@"Contacts loaded successfully.");
//            
//            for(GLPContact *c in contacts)
//            {
//                if(c.youConfirmed)
//                {
//                    if([c.user.name isEqualToString:self.profileUser.name])
//                    {
//                        
//                    }
//                        
//                }
//            }
//
//            
//            //            self.users = contacts.mutableCopy;
//            
//        }
//        else
//        {
//            [WebClientHelper showStandardError];
//        }
//        
//        
//    }];
//    return NO;
//}

-(void)loadAndSetUserDetails
{
    [[WebClient sharedInstance] getUserWithKey:self.selectedUserId callbackBlock:^(BOOL success, GLPUser *user) {
        
        if(success)
        {
            NSLog(@"Private Profile Load User Image URL: %@",user.profileImageUrl);
       
            
            self.profileUser = user;
            
            self.title = user.name;
            
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
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFullProfileImage:)];
                [tap setNumberOfTapsRequired:1];
                [self.profileImage addGestureRecognizer:tap];
            }
        }
        else
        {
            NSLog(@"Not Success: %d User: %@",success, user);
            
        }
        
        
        
    }];
}

-(void)showFullProfileImage:(id)sender
{
    UITapGestureRecognizer *incomingImage = (UITapGestureRecognizer*) sender;
    
    UIImageView *clickedImageView = (UIImageView*)incomingImage.view;
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    ViewPostImageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ViewPostImage"];
    vc.image = clickedImageView.image;
    vc.view.backgroundColor =  self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.67];
    
    [vc setTransitioningDelegate:self.transitionViewImageController];
    vc.modalPresentationStyle= UIModalPresentationCustom;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self presentViewController:vc animated:YES completion:nil];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"view profile"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
        ProfileViewController *profileViewController = segue.destinationViewController;
        
        profileViewController.isUserJustAccepted = YES;
        
        GLPUser *incomingUser = [[GLPUser alloc] init];
        
        incomingUser.remoteKey = self.selectedUserId;
        
        profileViewController.incomingUser = incomingUser;
    }
}


@end
