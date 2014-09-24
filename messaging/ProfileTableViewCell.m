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
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import <QuartzCore/QuartzCore.h>
#import "ContactsManager.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "SessionManager.h"
#import "InvitationSentView.h"
#import "AppearanceHelper.h"
#import "ContactsManager.h"
#import "ConversationManager.h"
#import "GLPLiveConversationsManager.h"
#import "BusyFreeSwitch.h"

@interface ProfileTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
//@property (weak, nonatomic) IBOutlet UIImageView *coverProfileImage;

@property (weak, nonatomic) IBOutlet UILabel *universityLabel;
@property (weak, nonatomic) IBOutlet UIButton *addContactButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;

@property (weak, nonatomic) IBOutlet UIImageView *inContacts;
@property (weak, nonatomic) IBOutlet BusyFreeSwitch *busySwitch;
@property (weak, nonatomic) IBOutlet UILabel *busyLabel;

@property (weak, nonatomic) IBOutlet UILabel *groupDescriptionLbl;

@property (strong, nonatomic) GLPUser *currentUser;
@property (readonly, nonatomic) UIViewController <ProfileTableViewCellDelegate> *delegate;
//@property (readonly, nonatomic) GLPPrivateProfileViewController *privateProfileDelegate;
@property (strong, nonatomic) InvitationSentView *invitationSentView;

@property (strong, nonatomic) GLPGroup *currentGroup;

@property (weak, nonatomic) IBOutlet UIImageView *profileBackImage;

@end

@implementation ProfileTableViewCell

const float PROFILE_CELL_HEIGHT = 220.0f;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {

    }
    
    return self;
}

#pragma mark - Group methods

-(void)initialiseElementsWithGroupInformation:(GLPGroup *)group withGroupImage:(UIImage *)image
{
    if(!group)
    {
        
        //Hide all the elements and put loading in university label.
        [self initialiseLoadingElements];
        
        return;
    }

    
    self.currentGroup = group;
    
    [self.universityLabel setHidden:YES];
    
    [self.groupDescriptionLbl setHidden:NO];
    
//    [self.universityLabel setNumberOfLines:3];
    

    
    if(group.groupDescription)
    {
        [self.groupDescriptionLbl setText:group.groupDescription];
    }
    else
    {
        [self.groupDescriptionLbl setText:@""];
    }
    
    
    [self formatProfileImage];
    
    //        [self.postImage setImageWithURL:nil placeholderImage:[UIImage imageNamed:nil] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    
    if(image)
    {
        [self.profileImage setImage:image];
        [_profileBackImage setHidden:NO];

        //Add gesture to show menu.
        [self addGestureToGroupImageWithImage:YES];
    }
    else if(group.groupImageUrl)
    {
        
//        [self.profileImage setImageWithURL:[NSURL URLWithString:group.groupImageUrl] placeholderImage:nil options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//            
//            [_profileBackImage setHidden:NO];
//            
//        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        
        


        
        //Add gesture to show menu.
        [self addGestureToGroupImageWithImage:YES];
    }
    else
    {
//        [_profileBackImage setHidden:YES];
        [self.profileImage setImage:nil];
        
        //Add gesture to show menu.
        [self addGestureToGroupImageWithImage:NO];
    }
    


}

-(void)initialiseGroupImage:(UIImage *)image
{
//    [self initialiseLoadingElements];
    
    [self formatProfileImage];
    
    [self.profileImage setImage:image];
}

-(void)addGestureToGroupImageWithImage:(BOOL)imageAvailable
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:_delegate action:@selector(showInformationMenu:)];
    [tap setNumberOfTapsRequired:1];
    [self.profileImage addGestureRecognizer:tap];
    
    self.profileImage.tag = (imageAvailable) ?  1 : 0;
}



-(void)initialiseProfileImage:(UIImage*)image
{
    [self initialiseLoadingElements];

    [self formatProfileImage];
    
    [self.profileImage setImage:image];
    
//    [self.coverProfileImage setImage:image];
}


#pragma mark - User methods


/**
 
 TODO: Call that method from Profile VC when after refactoring image prefetching.
 
 */
-(void)initialiseElementsWithUserDetails:(GLPUser *)user withImage:(UIImage*)image
{
    if(user == nil)
    {
        [self initialiseLoadingElements];
        
        return;
    }
    
    self.currentUser = user;

    
    [self.universityLabel setText:user.networkName];
    
    [self formatProfileImage];


    
    if([user.profileImageUrl isEqualToString:@""])
    {
        //Set default image.
        [self.profileImage setImage:[UIImage imageNamed:@"default_user_image2"]];
    }
    else
    {
//        [self.profileImage setImageWithURL:[NSURL URLWithString:user.profileImageUrl] placeholderImage:nil options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

        
        [self.profileImage setImage:image];
        
//        [self.coverProfileImage setImage:image];
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
    
    
    [self.universityLabel setText:user.networkName];

    [self formatProfileImage];


    
    if([user.profileImageUrl isEqualToString:@""])
    {
        //Set default image.
        [self.profileImage setImage:[UIImage imageNamed:@"default_user_image2"]];
    }
    else
    {
        
        //Fetch the image from the server and add it to the image view.
//        [self.profileImage setImageWithURL:[NSURL URLWithString:user.profileImageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//            
//            [_profileBackImage setHidden:NO];
//            
//        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        
        [self.profileImage setImageWithURL:[NSURL URLWithString:user.profileImageUrl] placeholderImage:nil options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
//        [self.profileImage setImageWithURL:[NSURL URLWithString:user.profileImageUrl] placeholderImage:[UIImage imageNamed:@"default_user_image2"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//            
////            [self.coverProfileImage setImage:image];
//            
//        }];
        
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


-(void)setDelegate:(UIViewController <ProfileTableViewCellDelegate> *)delegate
{
    _delegate = delegate;
}

//-(void)setPrivateProfileDelegate:(GLPPrivateProfileViewController*)delegate
//{
//    _privateProfileDelegate = delegate;
//}

-(void)setCurrentUserStatusWithUser:(GLPUser *)user
{

//    CGRect universityLabelFrame = self.universityLabel.frame;
    
    if(user.remoteKey == 0)
    {
        return;
    }
    
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
//        if([[ContactsManager sharedInstance] isUserContactWithId:user.remoteKey])
//        {
//            //TODO: Set in table view contact as in contacts.
//            [self.inContacts setHidden:NO];
//            [self.addContactButton setHidden:YES];
//        }
//        else
//        {
//            if([[ContactsManager sharedInstance] isContactWithIdRequested:user.remoteKey])
//            {
//                [self setContactAsRequested];
//            }
//            else if ([[ContactsManager sharedInstance]isContactWithIdRequestedYou:user.remoteKey])
//            {
//                [self setAcceptRequestButton];
//            }
//            else
//            {
//                //If not show the private profile view as is.
//            }
//        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFullProfileImage:)];
        [tap setNumberOfTapsRequired:1];
        [self.profileImage addGestureRecognizer:tap];
        
        
        //TODO: Issue by moving the information label.
        //Change the position of the university label.
       // [self.universityLabel setFrame:CGRectMake(universityLabelFrame.origin.x, 160.0f, universityLabelFrame.size.width, universityLabelFrame.size.height)];
    }
    
    [self.universityLabel setHidden:NO];
}

-(void)formatProfileImage
{
    [ShapeFormatterHelper setRoundedView:self.profileImage toDiameter:self.profileImage.frame.size.height];
    
    self.profileImage.layer.borderWidth = 5.0;
    self.profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
    
    // drop shadow
//    [self.profileImage.layer setShadowColor:[UIColor blackColor].CGColor];
//    [self.profileImage.layer setShadowOpacity:0.5];
//    [self.profileImage.layer setShadowRadius:3.0];
//    [self.profileImage.layer setShadowOffset:CGSizeMake(0.0, 10.0)];
//    self.profileImage.layer.masksToBounds = YES;
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

#pragma mark - UI methods

-(void)hideElements
{
    
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
            [_delegate unlockProfile];
        }
        else
        {
            //Error message.
            [WebClientHelper showInternetConnectionErrorWithTitle:@"Failed to accept contact"];
            
        }
    }];
}

- (IBAction)sendMessage:(id)sender
{
    GLPConversation *conversation = [[GLPLiveConversationsManager sharedInstance] findRegularByParticipant:self.currentUser];
    DDLogInfo(@"Regular conversation for participant, conversation remote key: %d", conversation.remoteKey);
    
    if(!conversation) {
        DDLogInfo(@"Create empty conversation");
        
        NSArray *part = [[NSArray alloc] initWithObjects:self.currentUser, [SessionManager sharedInstance].user, nil];
        conversation = [[GLPConversation alloc] initWithParticipants:part];
    }
    
    [_delegate viewConversation:conversation];
}

-(void)showFullProfileImage:(id)sender
{
    [_delegate showFullProfileImage:sender];
}

#pragma mark - Client

- (IBAction)addUser:(id)sender
{
    [[WebClient sharedInstance] addContact:self.currentUser.remoteKey callbackBlock:^(BOOL success) {
        
        if(success)
        {
            //Change the button style.
            NSLog(@"Request has been sent to the user.");
            
            self.invitationSentView = [InvitationSentView loadingViewInView:[_delegate.view.window.subviews objectAtIndex:0]];
            self.invitationSentView.delegate = _delegate;
            
            
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
