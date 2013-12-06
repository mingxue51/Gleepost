//
//  ProfileViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 20/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ProfileViewController.h"
#import "MBProgressHUD.h"
#import "WebClient.h"
#import "ViewPostViewController.h"
#import "NewPostViewController.h"
#import "ProfileScrollView.h"
#import "ProfileView.h"
#import "NotificationsViewController.h"
#import "PostCell.h"
#import "LoginRegisterViewController.h"
#import "SessionManager.h"
#import "GLPLoginManager.h"
#import "WebClientHelper.h"
#import "ViewPostImageViewController.h"
#import "TransitionDelegateViewImage.h"
#import "ImageFormatterHelper.h"
#import "GLPNotificationManager.h"
#import "UIViewController+GAI.h"
#import "GLPPostManager.h"
#import "UIViewController+Flurry.h"
#import "GLPPostNotificationHelper.h"
#import "GLPThemeManager.h"
#import "AppearanceHelper.h"
#import "PopUpNotificationsViewController.h"
#import "TransitionDelegateViewNotifications.h"
#import "GLPThemeManager.h"


@interface ProfileViewController ()

@property (strong, nonatomic) ProfileScrollView *profileScrollView;
@property (strong, nonatomic) IBOutlet UITableView *postsTableView;

@property (strong, nonatomic) NSMutableArray *posts;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) IBOutlet ProfileView *profileView;

@property (strong, nonatomic) FDTakeController *fdTakeController;
@property (strong, nonatomic) UIImage *uploadedImage;

@property (strong, nonatomic) TransitionDelegateViewImage *transitionViewImageController;

@property (assign, nonatomic) NSInteger unreadNotificationsCount;

@property (strong, nonatomic) TransitionDelegateViewNotifications *transitionViewNotificationsController;

//Notification view.
@property (strong, nonatomic) UIView *notificationView;

@end

static BOOL likePushed;

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //Change the format of the navigation bar.
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar2"] forBarMetrics:UIBarMetricsDefault];
    //[AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"chat_background_default" forBarMetrics:UIBarMetricsDefault];
    
    //Change navigations items' (back arrow, edit etc.) colour.

    UIColor *tabColour = [[GLPThemeManager sharedInstance] colorForTabBar];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, nil]];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    

    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
//    [self.navigationController.navigationBar setShadowImage:[ImageFormatterHelper generateOnePixelHeightImageWithColour:tabColour]];

    
    
    self.transitionViewImageController = [[TransitionDelegateViewImage alloc] init];
    
    self.transitionViewNotificationsController = [[TransitionDelegateViewNotifications alloc] init];
    
    self.profileScrollView = [[ProfileScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 350)];

    [self.profileScrollView setBackgroundColor:[UIColor whiteColor]];

    
    //Fetch the image from the server and add it as a profile background.
    self.profileScrollView.backgroundImageView.image = [UIImage imageNamed:@"background_profile"];
    
    
    [self.tabBarController.tabBar setHidden:NO];
    
    //TODO: Hilight the profile tab.
    
    //Add the profile image.
    
    //self.postsTableView.tableHeaderView = self.profileScrollView;
    
    [self.profileView setBackgroundColor:[UIColor blackColor]];
    
    [self.postsTableView setBackgroundColor:[UIColor whiteColor]];
    
    //If the user is the current user.
    if(self.incomingUser == nil)
    {
        //Add selector to profile image view.
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeProfileImage:)];
        [tap setNumberOfTapsRequired:1];
        [self.profileView.profileImage setUserInteractionEnabled:YES];
        [self.profileView.profileImage addGestureRecognizer:tap];
        
        
        [self.profileView hideAlreadyInContactsImage];

        [self addLogoutNavigationButton];
    }
    else
    {
        //Add the ability of viewing the image.
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFullProfileImage:)];
        [tap setNumberOfTapsRequired:1];
        [self.profileView.profileImage setUserInteractionEnabled:YES];

        [self.profileView.profileImage addGestureRecognizer:tap];
        
        [self setTitle:@"Loading..."];
        
        
    }

    
    [self.postsTableView registerNib:[UINib nibWithNibName:@"PostImageCellView" bundle:nil] forCellReuseIdentifier:@"ImageCell"];
    
    [self.postsTableView registerNib:[UINib nibWithNibName:@"PostTextCellView" bundle:nil] forCellReuseIdentifier:@"TextCell"];
    
    
   
    //Used for change the profile image.
    self.fdTakeController = [[FDTakeController alloc] init];
    self.fdTakeController.viewControllerForPresentingImagePickerController = self;
    self.fdTakeController.delegate = self;
    
    //Initialise profile view.
    
//    [self.profileView initialiseView:self.incomingUser];
    
    [self.profileView.notificationsButton addTarget:self action:@selector(showNotifications:) forControlEvents:UIControlEventTouchDown];
    
    self.unreadNotificationsCount = 0;
}

-(void)configureNotificationView
{
    self.notificationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Added.
    [self.profileView hideNotificationsBubble];
    
    [self.profileView initialiseView:self.incomingUser];
    
    if(self.incomingUser != nil)
    {
        //self.incomingUser = [[SessionManager sharedInstance]user];
        [self loadUserDetails];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementNotificationsCount:) name:@"GLPNewNotifications" object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Initialise selected user id with -1 to dinstinguish logged in user from other users' profile.
    self.selectedUserId = -1;
    
    // count unread notifications
    self.unreadNotificationsCount = [GLPNotificationManager getNotificationsCount];
    [self updateNotificationsBubble];
    
    [self loadPosts];

    [self sendViewToGAI:NSStringFromClass([self class])];
    [self sendViewToFlurry:NSStringFromClass([self class])];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPNewNotifications" object:nil];
    
    [super viewWillDisappear:animated];

    
}


//-(void)updatePostInDatabaseWithRemoteKey:(int)remoteKey withNumberOfComments:(int)number
//{
//    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:remoteKey],@"RemoteKey", [NSNumber numberWithInt:number], @"NumberOfComments", nil];
//    
//    
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"GLPPostUpdated" object:self userInfo:dataDict];
//}

- (void)updateNotificationsBubble
{
    if(self.unreadNotificationsCount > 0) {
        [self.profileView showNotificationsBubble:self.unreadNotificationsCount];
    } else {
        [self.profileView hideNotificationsBubble];
    }
}

- (void)incrementNotificationsCount:(NSNotification *)notification
{
    self.unreadNotificationsCount += [notification.userInfo[@"count"] intValue];
    [self updateNotificationsBubble];
    

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

-(void)addLogoutNavigationButton
{
    UIImage *settingsIcon = [UIImage imageNamed:@"settings_icon"];
    
    UIButton *btnBack=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
    [btnBack setBackgroundImage:settingsIcon forState:UIControlStateNormal];
    [btnBack setFrame:CGRectMake(0, 0, 30, 30)];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    
    //self.navigationItem.rightBarButtonItem = item;
    
    UIButton *notView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [notView setBackgroundImage: [UIImage imageNamed:@"bell"]forState:UIControlStateNormal];
    [notView addTarget:self action:@selector(popUpNotifications:) forControlEvents:UIControlEventTouchUpInside];

    ////notifications_button
//    UIBarButtonItem *i = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(popUpNotifications:)];
    UIBarButtonItem *i = [[UIBarButtonItem alloc] initWithCustomView:notView];

    
    [i setTintColor:[[GLPThemeManager sharedInstance] colorForTabBar]];
    
    self.navigationItem.rightBarButtonItem = item;
    
    self.navigationItem.leftBarButtonItem = i;
}

-(void)popUpNotifications:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    PopUpNotificationsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"PopUpNotifications"];
    vc.view.backgroundColor =  self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    vc.delegate = self;
    [vc setTransitioningDelegate:self.transitionViewNotificationsController];
    vc.modalPresentationStyle= UIModalPresentationCustom;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - FDTakeController delegate

-(void)changeProfileImage:(id)sender
{
    [self.fdTakeController takePhotoOrChooseFromLibrary];

}

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)in
{
    self.uploadedImage = photo;
    //[self.profileView.profileImage setImage:photo];
    //[self.profileView updateImage:photo];
    
    //Communicate with server to change the image.
    [self uploadImageAndSetUserImageWithUserRemoteKey];
    
    [self loadPosts];
    
}
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


#pragma mark - Client


- (void)loadPosts
{
    //    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //    hud.labelText = @"Loading posts";
    //    hud.detailsLabelText = @"Please wait few seconds";
    
    int userRemoteKey = 0;
    
    if(self.incomingUser == nil)
    {
        userRemoteKey = [[SessionManager sharedInstance]user].remoteKey;
    }
    else
    {
        userRemoteKey = self.incomingUser.remoteKey;
    }
    
    [GLPPostManager loadRemotePostsForUserRemoteKey:userRemoteKey callback:^(BOOL success, NSArray *posts) {
        
        if(success)
        {
            self.posts = [posts mutableCopy];

            [self.postsTableView reloadData];
        }
        else
        {
            [WebClientHelper showStandardErrorWithTitle:@"Error loading posts" andContent:@"Please ensure that you are connected to the internet"];
        }
        
        
    }];
    
//    [GLPPostManager loadLocalPostsBefore:nil callback:^(NSArray *posts) {
//       
//        NSLog(@"Local Posts Count: %d",posts.count);
//        
//        NSMutableArray *removePosts = [[NSMutableArray alloc] init];
//        self.posts = [posts mutableCopy];
//        
//        for(GLPPost *p in self.posts)
//        {
//            if(self.incomingUser == nil)
//            {
//                if(p.author.remoteKey != [[SessionManager sharedInstance]user].remoteKey)
//                {
//                    [removePosts addObject:p];
//                }
//            }
//            else
//            {
//                if(p.author.remoteKey != self.incomingUser.remoteKey)
//                {
//                    [removePosts addObject:p];
//                }
//            }
//        }
//        
//        for(GLPPost *p in removePosts)
//        {
//            [self.posts removeObject:p];
//        }
//        
//        
//    }];
    
    
    
    
//    WebClient *client = [WebClient sharedInstance];
//    [client getPostsAfter:nil callback:^(BOOL success, NSArray *posts) {
//        
//        if(success) {
//            
//            NSMutableArray *removePosts = [[NSMutableArray alloc] init];
//            self.posts = [posts mutableCopy];
//            
//            for(GLPPost *p in self.posts)
//            {
//                if(self.incomingUser == nil)
//                {
//                    if(p.author.remoteKey != [[SessionManager sharedInstance]user].remoteKey)
//                    {
//                        [removePosts addObject:p];
//                    }
//                }
//                else
//                {
//                    if(p.author.remoteKey != self.incomingUser.remoteKey)
//                    {
//                        [removePosts addObject:p];
//                    }
//                }
//            }
//            
//            for(GLPPost *p in removePosts)
//            {
//                [self.posts removeObject:p];
//            }
//            
//            [self.postsTableView reloadData];
//        } else {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading failed"
//                                                            message:@"Check your id or your internet connection dude."
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//            [alert show];
//        }
//    }];
}

-(void)loadUserDetails
{
    [[WebClient sharedInstance] getUserWithKey:self.incomingUser.remoteKey callbackBlock:^(BOOL success, GLPUser *user) {
        
        if(success)
        {
            [self setTitle:user.name];
            [self.profileView setUserDetails:user];
            
        }
        else
        {
            NSLog(@"Not Success: %d User: %@",success, user);
            
        }

    }];
}

-(void)setImageToUserProfile:(NSString*)url
{
    NSLog(@"READY TO ADD IMAGE TO USER WITH URL: %@",url);
    
    [[WebClient sharedInstance] uploadImageToProfileUser:url callbackBlock:^(BOOL success) {
        
        if(success)
        {
            NSLog(@"NEW PROFILE IMAGE UPLOADED");
            

            
        }
        else
        {
            NSLog(@"ERROR: Not able to register image for profile.");
        }
    }];
}

-(void)uploadImageAndSetUserImageWithUserRemoteKey
{
    // UIImage* imageToUpload = [Image resizeImage:self.uploadedImage WithSize:CGSizeMake(124, 124)];
    
    UIImage* imageToUpload = [ImageFormatterHelper imageWithImage:self.uploadedImage scaledToHeight:320];
    
    NSData *imageData = UIImagePNGRepresentation(imageToUpload);
    
    NSLog(@"Image register image size: %d",imageData.length);
    
    
    //[WebClientHelper showStandardLoaderWithTitle:@"Uploading image" forView:self.view];
    
    
    [[WebClient sharedInstance] uploadImage:imageData ForUserRemoteKey:[[SessionManager sharedInstance]user].remoteKey callbackBlock:^(BOOL success, NSString* response) {
        
        //[WebClientHelper hideStandardLoaderForView:self.view];
        
        
        if(success)
        {
            NSLog(@"IMAGE UPLOADED. URL: %@",response);
            
            [self updateViewWithNewImage:response];
            
            //Change profile image in Session Manager.
            [[SessionManager sharedInstance] registerUserImage:response];
            
            //Set image to user's profile.
            [self setImageToUserProfile:response];
            
            //            [[SessionManager sharedInstance]user].profileImageUrl = response;
            
            //TODO: This is wrong
            //[[SessionManager sharedInstance] updateUserWithUrl:response];
            
        }
        else
        {
            NSLog(@"ERROR");
            [WebClientHelper showStandardErrorWithTitle:@"Error uploading the image" andContent:@"Please check your connection and try again"];
            
        }
    }];
}



#pragma mark - Other methods


-(void)updateViewWithNewImage:(NSString*)imageUrl
{
    //Set new url to current view.
    [self.profileView updateImageWithUrl: imageUrl];
    
    //Update posts in current view.
    [self refreshPostsWithNewImage:imageUrl];
    
}

-(void)refreshPostsWithNewImage:(NSString*)imageUrl
{
    for(GLPPost *post in self.posts)
    {
        post.author.profileImageUrl = imageUrl;
    }
    
    [self.postsTableView reloadData];
}

-(void)logout:(id)sender
{
    //Pop up a bottom menu.
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Are you sure you want to logout?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Logout", nil];

    [actionSheet showInView:[self.view window]];

}

#pragma mark - Action Sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [GLPLoginManager logout];
        [self.navigationController popViewControllerAnimated:YES];
        [self performSegueWithIdentifier:@"start" sender:self];
    }
    else
    {
        NSLog(@"Cancel");
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subview in actionSheet.subviews)
    {
        if ([subview isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton*)subview;
            
            if([btn.titleLabel.text isEqualToString:@"Cancel"])
            {
                //btn.titleLabel.textColor = [UIColor colorWithRed:75.0/255.0 green:204.0/255.0 blue:210.0/255.0 alpha:0.8];
                btn.titleLabel.textColor = [[GLPThemeManager sharedInstance]colorForTabBar];
            }
            else
            {
                btn.titleLabel.textColor = [UIColor lightGrayColor];
            }
        }
    }
}

-(void) showNotifications: (id)sender
{
    [self performSegueWithIdentifier:@"view notifications" sender:self];
}




//TODO: Create delegates and datasource for table view.

//-(void) setBackgroundToNavigationBar
//{
//    UIImage *img = [UIImage imageNamed:@"navigationbar_4"];
//    UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.f, -20.f, 320.f, 65.f)];
//    
//    
//    
//    [bar setBackgroundColor:[UIColor clearColor]];
//    [bar setBackgroundImage:[UIImage imageNamed:@"navigationbar_4"] forBarMetrics:UIBarMetricsDefault];
//    [bar setTranslucent:YES];
//    
//    
//    //Change the format of the navigation bar.
//    [self.navigationController.navigationBar setTranslucent:YES];
//    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar_trans"] forBarMetrics:UIBarMetricsDefault];
//    
//    [self.navigationController.navigationBar insertSubview:bar atIndex:1];
//}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ImageCellIdentifier = @"ImageCell";
    static NSString *TextCellIdentifier = @"TextCell";
    
    PostCell *cell;
    
    GLPPost *post = self.posts[indexPath.row];
    
    if([post imagePost])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:ImageCellIdentifier forIndexPath:indexPath];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:TextCellIdentifier forIndexPath:indexPath];
    }
    
    //Set this class as delegate.
    cell.delegate = self;
    
    [cell updateWithPostData:post withPostIndex:indexPath.row];
   // [cell updateWithPostData:post];

//    NSLog(@"Username: %@",post.author.name);
//    
//    
//    //Add the user's name.
//    [cell.userName setText: post.author.name];
//    
//    
//    //Add the post's time.
//    [cell.postTime setText:post.date.description];
//    
//    
//    
//    //Add the user's image to the corresponding cell.
//    UIImage *img = [UIImage imageNamed:@"avatar_big"];
//    
//    
//    [cell.userImage setBackgroundImage:img forState:UIControlStateNormal];
//    
//    
////
////    cell.userImage.contentMode = UIViewContentModeScaleAspectFit;
////    [cell.userImage setFrame:CGRectMake(10.0f, 0.0f+10.0f, img.size.width-15, img.size.height-15)];
////
////    
//
//    
//    //Add the post's text content.
//    [cell.contentLbl setText:post.content];
//
//    //Add the main image to the post.
//    UIImage *postImage = [UIImage imageNamed:@"post_image"];
//    
//    cell.postImage.image = postImage;
//
//    //TODO: See again the postImage width. Problem.
//  //  [cell.mainImage setFrame:CGRectMake(10.0f, 80.0f, postImage.size.width-20, postImage.size.height)];

    
    //Add selector to the buttons.
    [self buttonWithName:@"Like" andSubviews:[cell.contentView subviews] withCell:cell];
    //[self buttonWithName:@"Comment" andSubviews:[cell.contentView subviews] withCell:cell];
    [self buttonWithName:@"Share" andSubviews:[cell.contentView subviews] withCell:cell];
//
//    cell.userInteractionEnabled = YES;
//    
//    [self getInformationAndSetFormatButtons];
//    
//    //    cell.contentLabel.text = post.content;
//    //    cell.dateLabel.text = [self.dateFormatter stringFromDate:post.date];
//    //    cell.userLabel.text = post.user.name;
//    
//    cell.backgroundColor = [UIColor whiteColor];
    
//    NSLog(@"POST CONTENTS: %@ - %@ - %@",post.content,[self.dateFormatter stringFromDate:post.date], post.user.name);
    
    //    cell.textLabel.text = post.content;
    //    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", post.user.name, [self.dateFormatter stringFromDate:post.date]];
    
    return cell;
}

/**
 
 Gets information from the server and sets the current state
 of the buttons: Like, Comment and maybe Share.
 
 */
-(void) getInformationAndSetFormatButtons
{
    //Like button.
    /**
     If the current post is liked by the user then change the
     default colour of the like image.
     */
    
    
    //Set the current status of like button to status variable.
    likePushed = NO;
    
}

-(UIButton*) buttonWithName: (NSString*)buttonName andSubviews: (NSArray*)subArray withCell: (PostCell*) cell
{
    for(UIView* view in subArray)
    {
        if([view isKindOfClass:[UIButton class]])
        {
            UIButton *currentBtn = (UIButton*)view;
            currentBtn.userInteractionEnabled = YES;
            if([currentBtn.titleLabel.text isEqualToString:@"Like"])
            {
                [currentBtn addTarget:self action:@selector(likeButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
                //[currentBtn addTarget:self action:@selector(likeButtonPushed:) forControlEvents:UIControlEventTouchDown];
            }
            else if ([currentBtn.titleLabel.text isEqualToString:@"Comment"])
            {
                [currentBtn addTarget:self action:@selector(commentButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                [currentBtn addTarget:self action:@selector(shareButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            NSLog(@"-> %@", [currentBtn titleLabel].text);
        }
    }
    
    
    return nil;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedPost = self.posts[indexPath.row];
    [self performSegueWithIdentifier:@"view post" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    GLPPost *currentPost = [self.posts objectAtIndex:indexPath.row];
    
    
    if([currentPost imagePost])
    {
//        NSLog(@"heightForRowAtIndexPath With Image %f and text: %@",[PostCell getCellHeightWithContent:currentPost.content image:YES], currentPost.content);
        //return [PostCell getCellHeightWithContent:[PostCell findTheNeededText:currentPost.content] andImage:YES];
        //return [PostCell getCellHeightWithContent:currentPost.content andImage:YES];
        
        return 415;
        
    }
    else
    {
//        NSLog(@"heightForRowAtIndexPath Without Image %f and text: %@",[PostCell getCellHeightWithContent:currentPost.content image:NO], currentPost.content);
        //return [PostCell getCellHeightWithContent:currentPost.content andImage:NO];
        
        //        return [PostCell getCellHeightWithContent:[PostCell findTheNeededText:currentPost.content] andImage:NO];
        
        return 156;
    }
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Modal View Controller");

    
    if([segue.identifier isEqualToString:@"view post"])
    {
        //Hide tabbar.
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
        ViewPostViewController *vc = segue.destinationViewController;
        vc.post = self.selectedPost;
        self.selectedPost = nil;
        
    }
    else if([segue.identifier isEqualToString:@"view profile"])
    {
//        NotificationsViewController *nv = segue.destinationViewController;
        ProfileViewController *profileViewController = segue.destinationViewController;
        
        GLPUser *incomingUser = [[GLPUser alloc] init];
        
        incomingUser.remoteKey = self.selectedUserId;
        
        if(self.selectedUserId == -1)
        {
            incomingUser = nil;
        }
        
        profileViewController.incomingUser = incomingUser;
    }
    else if([segue.identifier isEqualToString:@"start"])
    {
        //Hide tabbar.
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
        LoginRegisterViewController *loginRegisterViewController = segue.destinationViewController;
        
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View image delegate

-(void)viewPostImage:(UIImage*)postImage
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    ViewPostImageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ViewPostImage"];
    vc.image = postImage;
    vc.view.backgroundColor =  self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.67];
    
    [vc setTransitioningDelegate:self.transitionViewImageController];
    vc.modalPresentationStyle= UIModalPresentationCustom;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self presentViewController:vc animated:YES completion:nil];
}


#pragma mark - New comment delegate

-(void)setPreviousViewToNavigationBar
{
    [self addLogoutNavigationButton];
}

-(void)setPreviousNavigationBarName
{
    [self.navigationItem setTitle:@"Profile"];
}

-(void)hideNavigationBarAndButtonWithNewTitle:(NSString*)newTitle
{
    [self.navigationItem setTitle:newTitle];
    self.navigationItem.rightBarButtonItem = nil;
}

-(void)navigateToViewPostFromCommentWithIndex:(int)postIndex
{
    self.selectedPost = self.posts[postIndex];
    ++self.selectedPost.commentsCount;
    
    //Send push notification to GLPTimelineViewController.
//    [self updatePostInDatabaseWithRemoteKey:self.selectedPost.remoteKey withNumberOfComments:self.selectedPost.commentsCount];
    
    [GLPPostNotificationHelper updatePostWithNotifiationName:@"GLPPostUpdated"
                                                  withObject:self
                                                   remoteKey:self.selectedPost.remoteKey
                                               numberOfLikes:self.selectedPost.likes
                                         andNumberOfComments:self.selectedPost.commentsCount];
    
    [self performSegueWithIdentifier:@"view post" sender:self];
}

#pragma mark - Social panel buttons' selectors

/*
 
 When like button is pushed turn it to our application's custom colour.
 
 */
-(void)likeButtonPushed: (id) sender
{
    NSLog(@"Like Pushed: %d",likePushed);
    UIButton *btn = (UIButton*) sender;
    
    //If like button is pushed then set the pushed variable to NO and change the
    //colour of the image.
    if(likePushed)
    {
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //Add the thumbs up selected version of image.
        [btn setImage:[UIImage imageNamed:@"thumbs-up"] forState:UIControlStateNormal];
        
        
        likePushed = NO;
    }
    else
    {
        [btn setTitleColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationbar"]] forState:UIControlStateNormal];
        //Add the thumbs up selected version of image.
        [btn setImage:[UIImage imageNamed:@"thumbs-up_pushed"] forState:UIControlStateNormal];
        
        likePushed = YES;
    }
    
    
    
    // [btn setBackgroundImage:[UIImage imageNamed:@"navigationbar"] forState:UIControlStateNormal];
    //
    //    //TODO: See if the button is already liked.
    //    [[btn titleLabel] setTintColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationbar"]]];
}

-(void)commentButtonPushed: (id) sender
{
    NSLog(@"commentButtonPushed");
}

-(void)shareButtonPushed: (id) sender
{
    NSLog(@"shareButtonPushed");
}

@end
