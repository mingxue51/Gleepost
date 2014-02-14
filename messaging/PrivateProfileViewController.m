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
#import "UIViewController+Flurry.h"
#import "GLPThemeManager.h"
#import "ReflectedImageView.h"
#import "QuartzCore/CALayer.h"
#import "ShapeFormatterHelper.h"

@interface PrivateProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet ReflectedImageView *reflectedProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *networkName;
@property (weak, nonatomic) IBOutlet UILabel *personalMessage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *course;
@property (weak, nonatomic) IBOutlet UIButton *addUserButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptUserButton;
@property (weak, nonatomic) IBOutlet UILabel *numberOfFriends;

//Image view to create borders around information.
@property (weak, nonatomic) IBOutlet UIImageView *borderImageViews;
@property (weak, nonatomic) IBOutlet UIImageView *borderImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *borderImageView3;

//TabViews.
@property (weak, nonatomic) IBOutlet UIView *tabView;

@property (weak, nonatomic) UIView *aboutTabView;
@property (weak, nonatomic) UITableView *postsTabView;
@property (weak, nonatomic) UITableView *mutualTabView;



@property (strong, nonatomic) GLPUser *profileUser;
@property (strong, nonatomic) InvitationSentView *invitationSentView;
@property (strong, nonatomic) TransitionDelegateViewImage *transitionViewImageController;

@end


@implementation PrivateProfileViewController


- (void)backButtonTapped {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [AppDelegate customBackButtonWithTarget:self];

    
    
    //[AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar2" forBarMetrics:UIBarMetricsDefault];
    //[AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:[[GLPThemeManager sharedInstance] imageForNavBar] forBarMetrics:UIBarMetricsDefault];

//    [self configureInformationBorders];
    
    [self configureViews];
    
    self.transitionViewImageController = [[TransitionDelegateViewImage alloc] init];

    
    [[ContactsManager sharedInstance] loadContactsFromDatabase];
    
    
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
        NSLog(@"PrivateProfileViewController : Private profile as is.");
    }
    
//    [self formatProfileView];
    
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
    [self sendViewToFlurry:NSStringFromClass([self class])];
}

-(void)awakeFromNib
{

}

#pragma mark - UI changes

-(void)setContactAsRequested
{
    UIImage *img = [UIImage imageNamed:@"pending"];
    [self.addUserButton setImage:img forState:UIControlStateNormal];
    [self.addUserButton setEnabled:NO];
}

-(void)setAcceptRequestButton
{
    [self.addUserButton setHidden:YES];
    [self.addUserButton setEnabled:NO];
    [self.acceptUserButton setHidden:NO];
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

-(void)configureViews
{
    self.aboutTabView = [[[NSBundle mainBundle] loadNibNamed:@"AboutProfileTabView" owner:self options:nil] objectAtIndex:0];
    self.aboutTabView.tag = 1;
    
    self.postsTabView = [[[NSBundle mainBundle] loadNibNamed:@"PostsProfileTabView" owner:self options:nil] objectAtIndex:0];
    self.postsTabView.tag = 2;
    
    self.mutualTabView = [[[NSBundle mainBundle] loadNibNamed:@"MutualProfileTabView" owner:self options:nil] objectAtIndex:0];
    self.mutualTabView.tag = 3;
    
    [self.tabView addSubview:self.aboutTabView];
    [self.tabView addSubview:self.postsTabView];
    [self.tabView addSubview:self.mutualTabView];
    
    self.postsTabView.hidden = YES;
    self.mutualTabView.hidden = YES;
}

-(void)configureInformationBorders
{
    
    CGColorRef colour = [[GLPThemeManager sharedInstance]colorForTabBar].CGColor;
    
    [self.borderImageViews.layer setBorderWidth:1.0];
    [self.borderImageViews.layer setBorderColor:colour];
    
    [self.borderImageView2.layer setBorderWidth:1.0];
    [self.borderImageView2.layer setBorderColor:colour];
    
    [self.borderImageView3.layer setBorderWidth:1.0];
    [self.borderImageView3.layer setBorderColor:colour];
}

/**
 
 Convert current image view to circle shape.
 
 @param roundedView the incoming image view.
 @param newSize the diameter of the new shape.
 
 */
-(void)setRoundedView:(UIImageView *)roundedView toDiameter:(float)newSize;
{
    roundedView.clipsToBounds = YES;
    
    CGPoint saveCenter = roundedView.center;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = newSize / 2.0;
    roundedView.center = saveCenter;
}




-(void)formatProfileView
{
    [[self.profileImage layer] setBorderWidth:6.0f];
    [[self.profileImage layer] setBorderColor:[UIColor colorWithRed:243.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0].CGColor];
}

#pragma mark - Tab views

- (IBAction)showAboutView:(id)sender
{
    [self showTabViewWithTag:1];

}

- (IBAction)showPostsView:(id)sender
{

    [self showTabViewWithTag:2];
    
//    [self.tabView addSubview:self.postsTabView];
}

- (IBAction)showMutualView:(id)sender
{
    [self showTabViewWithTag:3];
}

-(void)showTabViewWithTag:(int)tag
{
    //Clear all views and add posts view.
    NSArray *subViews = self.tabView.subviews;
    
    
    
    for(UIView *v in subViews)
    {
        if(v.tag != tag)
        {
            [v setHidden:YES];
        }
        else
        {
            [v setHidden:NO];
        }
    }
}

#pragma mark - Buttons selectors

//Accept contact.
- (IBAction)acceptContact:(id)sender
{
    
    //Accept contact in the local database and in server.
    [[ContactsManager sharedInstance] acceptContact:self.selectedUserId callbackBlock:^(BOOL success) {
       
        if(success)
        {
            //Navigate to unlock profile.
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
            ProfileViewController *pvc = [storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
            
            GLPUser *incomingUser = [[GLPUser alloc] init];
            
            incomingUser.remoteKey = self.selectedUserId;
            
            pvc.incomingUser = incomingUser;
            
            //Navigate to profile view controller.
            NSMutableArray *array = [[self.navigationController viewControllers] mutableCopy];
            
            NSArray *a = [[NSArray alloc] initWithObjects:[array objectAtIndex:0], pvc, nil];
            
            [self.navigationController setViewControllers:a animated:YES];
            
            
            //Change the status of contact in local database.
//            [[ContactsManager sharedInstance] contactWithRemoteKeyAccepted:self.selectedUserId];
        }
        else
        {
            //Error message.
            [WebClientHelper showStandardErrorWithTitle:@"Failed to accept contact" andContent:@"Please check your internet connection and try again"];
            
        }
    }];
    
    
    
//    //If success from server then navigate to unlocked profile.
//    [[WebClient sharedInstance]acceptContact:self.selectedUserId callbackBlock:^(BOOL success) {
//       
//        if(success)
//        {
//            //Navigate to unlock profile.
//            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
//            ProfileViewController *pvc = [storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
//            
//            GLPUser *incomingUser = [[GLPUser alloc] init];
//            
//            incomingUser.remoteKey = self.selectedUserId;
//            
//            pvc.incomingUser = incomingUser;
//            //Navigate to profile view controller.
//            NSMutableArray *array = [[self.navigationController viewControllers] mutableCopy];
//            
//            NSArray *a = [[NSArray alloc] initWithObjects:[array objectAtIndex:0], pvc, nil];
//            
//            [self.navigationController setViewControllers:a animated:YES];
//            
//            
//            //Change the status of contact in local database.
//            [[ContactsManager sharedInstance] contactWithRemoteKeyAccepted:self.selectedUserId];
//        }
//        else
//        {
//            //Error message.
//            [WebClientHelper showStandardErrorWithTitle:@"Failed to accept contact" andContent:@"Please check your internet connection and try again"];
//
//        }
//        
//    }];
}


- (IBAction)addContact:(id)sender
{
    [[WebClient sharedInstance] addContact:self.selectedUserId callbackBlock:^(BOOL success) {
        
        if(success)
        {
            //Change the button style.
            NSLog(@"Request has been sent to the user.");
            
            self.invitationSentView = [InvitationSentView loadingViewInView:[self.view.window.subviews objectAtIndex:0]];
            //self.invitationSentView.delegate = self;
            
            
            GLPContact *contact = [[GLPContact alloc] initWithUserName:self.profileUser.name profileImage:self.profileUser.profileImageUrl youConfirmed:YES andTheyConfirmed:NO];
            contact.remoteKey = self.selectedUserId;
            
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

#pragma mark - Client methods

-(void)loadAndSetUserDetails
{
    [[WebClient sharedInstance] getUserWithKey:self.selectedUserId callbackBlock:^(BOOL success, GLPUser *user) {
        
        if(success)
        {
            self.profileUser = user;
            
            self.title = user.name;
            self.userName.text = user.name;
            
            [self.networkName setText:user.networkName];
            
            [self.course setText: user.course];
            
            [self.personalMessage setText:user.personalMessage];
            
            [self setRoundedView:self.profileImage toDiameter:self.profileImage.frame.size.height];
            
            self.profileImage.layer.borderWidth = 2.0;
            self.profileImage.layer.borderColor = [[GLPThemeManager sharedInstance]colorForTabBar].CGColor;
            
            [self setRoundedView:self.reflectedProfileImage toDiameter:self.reflectedProfileImage.frame.size.height];
            
            
            if([user.profileImageUrl isEqualToString:@""])
            {
                //Set default image.
                [self.profileImage setImage:[UIImage imageNamed:@"default_user_image"]];
            }
            else
            {
                
                //Fetch the image from the server and add it to the image view.
                //[self.profileImage setImageWithURL:[NSURL URLWithString:user.profileImageUrl] placeholderImage:[UIImage imageNamed:@"default_user_image"]];
                
                [self.profileImage setImageWithURL:[NSURL URLWithString:user.profileImageUrl] placeholderImage:[UIImage imageNamed:@"default_user_image"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                    
                    //Create the reflection effect.
                    //TODO: Fix that, only add image when the image is loaded.
                    [self.reflectedProfileImage reflectionImageWithImage:self.profileImage.image];
                    
                }];
                
                //TODO: Create shadow to the image.
                
//                self.profileImage.layer.shadowColor = [UIColor blackColor].CGColor;
//                self.profileImage.layer.shadowOffset = CGSizeMake(-1, 1);
//                self.profileImage.layer.shadowOpacity = 1;
//                self.profileImage.layer.shadowRadius = 3.0;
//                self.profileImage.clipsToBounds = NO;
                
                

                
                [ShapeFormatterHelper createTwoTopCornerRadius:self.profileImage withViewBounts:self.view.bounds andSizeOfCorners:CGSizeMake(5.0, 5.0)];
                
                
//                UIBezierPath *maskPath;
//                maskPath = [UIBezierPath bezierPathWithRoundedRect:self.profileImage.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(10.0, 10.0)];
//                
//                CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//                maskLayer.frame = self.view.bounds;
//                maskLayer.path = maskPath.CGPath;
//                self.profileImage.layer.mask = maskLayer;
                

                

                
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
            
        GLPUser *incomingUser = [[GLPUser alloc] init];
        
        incomingUser.remoteKey = self.selectedUserId;
        
        profileViewController.incomingUser = incomingUser;
    }
}


@end
