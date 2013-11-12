 //
//  TimelineViewController.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "TimelineViewController.h"
#import "ViewPostViewController.h"
#import "NewPostViewController.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "MBProgressHUD.h"
#import "AddCommentViewController.h"
#import "NewCommentView.h"
#import "Social/Social.h"
#import <Twitter/Twitter.h>
#import "PopUpMessage.h"
#import "PostWithImageCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PrivateProfileViewController.h"
#import "NewPostView.h"
#import "TransitionDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "AppearanceHelper.h"
#import "ViewPostImageViewController.h"
#import "TransitionDelegateViewImage.h"
#import "ContactsManager.h"
#import "ProfileViewController.h"
#import "SessionManager.h"

@interface TimelineViewController ()

@property (strong, nonatomic) NSMutableArray *posts;
@property (strong, nonatomic) NSMutableArray *usersImages;
@property (strong, nonatomic) NSMutableArray *postsImages;
@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic) GLPPost *selectedPost;
@property (strong, nonatomic) GLPUser *selectedUser;
@property (strong, nonatomic) NSMutableArray *postsHeight;;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSMutableArray *shownCells;
@property (strong, nonatomic) NewPostView *postView;
@property (strong, nonatomic) TransitionDelegate *transitionController;
@property (strong, nonatomic) TransitionDelegateViewImage *transitionViewImageController;

@property int selectedUserId;

//TODO: Remove after the integration of image posts.
@property int selectedIndex;

@end
static BOOL likePushed;

@implementation TimelineViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //[AppearanceHelper setNavigationBarBlurBackgroundFor:self WithImage:@"navigationbar2"];
    
    [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar2" forBarMetrics:UIBarMetricsDefault];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    [self.navigationController.navigationBar setTranslucent:YES];

    
    
    //UIColor *barColour = [UIColor colorWithRed:75.0/255.0 green:204.0/255.0 blue:210.0/255.0 alpha:0.8];
//    UIColor *barColour = [UIColor colorWithRed:75.0/255.0 green:204.0/255.0 blue:210.0/255.0 alpha:1.0];
//    
////    
//    UIView *colourView = [[UIView alloc] initWithFrame:CGRectMake(0.f, -20.f, 320.f, 64.f)];
//    colourView.opaque = YES;
//    colourView.alpha = 1.0f;
//
//    colourView.backgroundColor = [UIColor colorWithPatternImage:image];
//    
//    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
//    
//    
//    [self.navigationController.navigationBar.layer insertSublayer:colourView.layer atIndex:1];
    
    

    
    
    // NOT WORKING.
    //Change the format of the tab bar.
//    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    
//    //Access the root view controller.
//    UIViewController *root = appDelegate.window.rootViewController;
//    
//    //Access the navigation controller.
//    UINavigationController *controller = [root navigationController];
//    
//    //Get all the view controllers included in the application.
//    NSArray* viewControllers = [controller viewControllers];
//    
//    //Take the first view controller lauched in tab view controller.
//    UIViewController *first = [viewControllers objectAtIndex:2];
    
    //Get the tab bar controller.
//    UITabBarController *tabBarController = (UITabBarController *)first;
    
    //Set the image to the tab bar.
//    UIImage *tabBackground = [[UIImage imageNamed:@"tabbar"]
//                              resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//    
//    
//    [[tabBarController tabBar] setBackgroundImage:tabBackground];
    
    // NOT WORKING. // END.

   
    
    //Change the format of the tab bar.
    self.tabBarController.tabBar.hidden = NO;
    
    
    
    //Register nib files in table view.
    [self.tableView registerNib:[UINib nibWithNibName:@"PostImageCellView" bundle:nil] forCellReuseIdentifier:@"ImageCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTextCellView" bundle:nil] forCellReuseIdentifier:@"TextCell"];

    
    //self.tabBarController.tabBar.backgroundColor = [UIColor whiteColor];*
    
    //self.tabBarController.tabBar.selectedImageTintColor = [UIColor whiteColor];
    
    //Set the white colour to selected tab.
    //UIColor *tabColour = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationbar"]];
    UIColor *tabColour = [UIColor colorWithRed:75.0/255.0 green:208.0/255.0 blue:210.0/255.0 alpha:1.0];
    
    self.tabBarController.tabBar.tintColor = tabColour;
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: tabColour, UITextAttributeTextColor, nil] forState:UIControlStateSelected];
    
    

    
    
    
//    
//    [[UITabBar appearance] setTintColor:[UIColor blackColor]]; // for unselected items that are gray
//    [[UITabBar appearance] setSelectedImageTintColor:[UIColor greenColor]]; // for selected items that are green
    
    //Change navigations items' (back arrow, edit etc.) colour.
   // self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    

    
    
     
//    UIImage* tabBarBackground = [UIImage imageNamed:@"navigation_fullblack.png"];
//    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
//    
//    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"navigation_select.png"]];
    
    

    
    // ios7 only
//    if([self respondsToSelector:@selector(setBackButtonBackgroundImage:forState:barMetrics:)])
//    {


    
    
    //Possible way to change the size of the navigation bar.
    /*
     [[tabbarController.view.subviews objectAtIndex:0] setFrame:CGRectMake(0, 0, 320, 440)];
     [tabbarController.tabBar setFrame:CGRectMake(0, 440, 320, 50)];
     */
    

    
  
    //[self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar"] forBarMetrics:UIBarMetricsDefault];
    
    
    //TODO: Format the text of the navigation bar.
    
    
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new_post.png"]]];
//    [item.target addTarget:self action:@selector(newPostButtonClick) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = item;
    
    [self setPlusButtonToNavigationBar];
    
    //self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
//    UIButton *btnBack=[UIButton buttonWithType:UIButtonTypeCustom];
//
//    [btnBack setImage:[UIImage imageNamed:@"new_post.png"] forState:UIControlStateNormal];
//    [btnBack setFrame:CGRectMake(0, 0, 79, 30)];
//    UIView *backModifiedView=[[UIView alloc] initWithFrame:btnBack.frame];
//    [btnBack setFrame:CGRectMake(btnBack.frame.origin.x, btnBack.frame.origin.y+7, btnBack.frame.size.width, btnBack.frame.size.height)];
//    [backModifiedView addSubview:btnBack];
//    UIBarButtonItem *bbiLeft=[[UIBarButtonItem alloc] initWithCustomView:backModifiedView];
//    self.navigationItem.rightBarButtonItem=bbiLeft;
    
    

    
    
    self.postsHeight = [[NSMutableArray alloc] init];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    

    self.users = [[NSMutableArray alloc] init];
    
    
    self.usersImages = [[NSMutableArray alloc] init];
    self.postsImages = [[NSMutableArray alloc] init];
    

  
    //TODO: Here may there is a problem.
    //UIView *viewTitle = self.navigationItem.titleView;
    
    //[self setTheNavigationTextWhiteWithText:@"Campus Wall"];
    

    
    //[viewTitle setBackgroundColor:[UIColor whiteColor]];
    //[viewTitle setTintColor:[UIColor whiteColor]];
   // [viewTitle set]
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    //Create the array and initialise.
    self.shownCells = [[NSMutableArray alloc] init];
    
    self.transitionController = [[TransitionDelegate alloc] init];
    
    self.transitionViewImageController = [[TransitionDelegateViewImage alloc] init];

    //Initialise.
    self.readyToReloadPosts = YES;

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(self.readyToReloadPosts)
    {
        [self loadPosts];
    }

}

- (UIImage*) blur:(UIImage*)theImage
{
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:15.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    return [UIImage imageWithCGImage:cgImage];
    
    // if you need scaling
    // return [[self class] scaleIfNeeded:cgImage];
}




#pragma mark - Initialise navigation bar

-(void) setPlusButtonToNavigationBar
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"+"]];
    imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, 30.0, 30.0);
    
    
    UIButton *btnBack=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(newPostButtonClick) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = imageView.bounds;
    [imageView addSubview:btnBack];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    
    
    
    self.navigationItem.rightBarButtonItem = item;
}

-(void)setNavigationBarName
{
    [self.navigationItem setTitle:@"Campus Wall"];
}


-(void)hideNavigationBarAndButtonWithNewTitle:(NSString*)newTitle
{
    [self.navigationItem setTitle:newTitle];
    self.navigationItem.rightBarButtonItem = nil;
}

/**
 Not used.
 */
-(void) setBackgroundToNavigationBar
{
    UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.f, -20.f, 320.f, 65.f)];
    
    
    [bar setBackgroundColor:[UIColor clearColor]];
    [bar setBackgroundImage:[UIImage imageNamed:@"navigationbar_4"] forBarMetrics:UIBarMetricsDefault];
    [bar setTranslucent:YES];
    
    
    //Change the format of the navigation bar.
    [self.navigationController.navigationBar setTranslucent:YES];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar_trans"] forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController.navigationBar insertSubview:bar atIndex:0];
    
}

/*
 
 Not used.
 This method can be used in order to customise the title of the navigation bar.
 
 */
-(void) setTheNavigationTextWhiteWithText:(NSString*)title
{
    //Set white colour to the title of the navigation bar.
    CGRect frame = CGRectMake(0, 0, 200, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Helvetica" size:18.0];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = NSLocalizedString(title, @"Example");
    
    self.navigationItem.titleView = label;
    
    self.navigationItem.titleView = label;
}

/**
 Fetches the post's user from the server and set to the corresponding cell its contents.
 
 @param post the corresponding post.
 @param postCell the instance of the cell.
 
 */
//-(void) userWithPost:(GLPPost*) post andPostCell:(PostCell*)postCell
//{
//    [[WebClient sharedInstance] getUserWithKey:post.author.remoteKey callbackBlock:^(BOOL success, GLPUser *user) {
//        
//        if(success)
//        {
//            NSLog(@"User Image URL: %@",user.profileImageUrl);
//            [postCell updateWithPostData:post andUserData:user];
//            
//            [self.users addObject:user];
//        }
//        else
//        {
//            NSLog(@"Not Success: %d",success);
//            [postCell updateWithPostData:post andUserData:nil];
//            
//        }
//        
//        
//    }];
//}

#pragma mark - Client methods

- (void)loadPosts
{
    //[WebClientHelper showStandardLoaderWithTitle:@"Loading posts" forView:self.view];
    
    
    [[WebClient sharedInstance] getPostsAfter:nil callback:^(BOOL success, NSArray *posts) {
      // [WebClientHelper hideStandardLoaderForView:self.view];
        
        if(success) {
            self.posts = [posts mutableCopy];
            
            
//            for(GLPPost *p in self.posts)
//            {
//                UIImageView *imgView = [[UIImageView alloc] init];
//                
//                [imgView setImageWithURL:[NSURL URLWithString:[p.imagesUrls objectAtIndex:0] placeholderImage:[UIImage imageNamed:nil]];
//            }
            


            

            
            //TODO: Change this when image is available.
            //TODO: Add new attribute containsImage in Post class.
            
            //TODO: Fix the dynamic calculation of the size.
//            for(int i=0; i<posts.count; ++i)
//            {
//                Post *currentPost = [posts objectAtIndex:i];
//                float sizeOfText = [PostCell getContentLabelHeightForContent: currentPost.content];
//                if(i%3 == 0)
//                {
//                    //Add height for image.
//                    
//                    NSNumber *height = [NSNumber numberWithFloat:(imageSize+fixedLimitHeight+sizeOfText)];
//                    NSLog(@"Image height: %f",[height floatValue]);
//                    [self.postsHeight addObject:height];
//                }
//                else
//                {
//                    NSNumber *height = [NSNumber numberWithFloat:(fixedLimitHeight+sizeOfText)];
//                    
//                    if(height.floatValue < lowerPostLimit)
//                    {
//                        height = [NSNumber numberWithFloat:(lowerPostLimit+sizeOfText)];
//                         
//                    }
// 
//                    
//                    NSLog(@"Text height: %f",[height floatValue]);
//                    [self.postsHeight addObject:height];
//
//                }
//            }
            //[self loadUsersImagesAndReloadTable];
            
            
            [self.tableView reloadData];
            
        } else {
            [WebClientHelper showStandardError];
        }
    }];
}

-(void) loadPostsImages
{
    for(GLPPost* currentPost in self.posts)
    {
        UIImageView* userImage = [[UIImageView alloc] init];

        NSURL * url = [NSURL URLWithString:[currentPost.imagesUrls objectAtIndex:0]];

        //Fetch post image from the server.
        [userImage setImageWithURL:url placeholderImage:nil options:SDWebImageProgressiveDownload progress:^(NSUInteger receivedSize, long long expectedSize)
         {
             //NSLog(@"Downloading...");
         }
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
         {
             [self.postsImages addObject:image];
         }];
    }
}

-(void) loadUsersImagesAndReloadTable
{
    
    for(GLPPost* currentPost in self.posts)
    {
        [[WebClient sharedInstance] getUserWithKey:currentPost.author.remoteKey callbackBlock:^(BOOL success, GLPUser *user) {
            
            if(success)
            {
                //[self.users addObject:user];
                
                UIImageView* userImage = [[UIImageView alloc] init];
                
                NSURL * url = [NSURL URLWithString:user.profileImageUrl];
                
                //Fetch post image from the server.
                [userImage setImageWithURL:url placeholderImage:nil options:SDWebImageProgressiveDownload progress:^(NSUInteger receivedSize, long long expectedSize)
                 {
                     //NSLog(@"Downloading...");
                 }
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
                 {
                     [self.usersImages addObject:image];
                     

                 }];
                
               
            }
            else
            {
                NSLog(@"Not Success: %d User: %@",success, user);
                
            }
            
            
            
        }];
        

    }
    
    [self.tableView reloadData];
   
}

-(void)postLike:(BOOL)like withPostRemoteKey:(int)postRemoteKey
{
    [[WebClient sharedInstance] postLike:like forPostRemoteKey:postRemoteKey callbackBlock:^(BOOL success) {
       
        if(success)
        {
            NSLog(@"Like for post %d succeed.",postRemoteKey);
        }
        else
        {
            NSLog(@"Like for post %d not succeed.",postRemoteKey);
        }
        
        
    }];
}

#pragma mark - New post methods

-(void)addNewPost:(GLPPost*)post
{
    post.imagesUrls = [NSArray arrayWithObjects:@"uploading...", nil];
    
    //[self.posts addObject:post];
    [self.posts insertObject:post atIndex:0];
    [self.tableView reloadData];
    
}

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
    static NSString *CellIdentifierWithImage = @"ImageCell";
    static NSString *CellIdentifierWithoutImage = @"TextCell";


    PostCell *postCell;

    
    //TODO: Add to Post datatype a boolean like.
    GLPPost *post = self.posts[indexPath.row];
    

//    GLPUser *user = self.users[indexPath.row];

    
    if([post imagePost])
    {

        postCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithImage forIndexPath:indexPath];
        
        postCell.imageAvailable = YES;
        
//        if(post.tempImage != nil)
//        {
//
//        }

    }
    else
    {
        

        postCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithoutImage forIndexPath:indexPath];

        postCell.imageAvailable = NO;
        
    }
    
    
    //TODO: For each post take the status of the button like. (Obviously from the server).
    //TODO: In updateWithPostData information take the status of the like button.
    
    
    //Add selector to the buttons.
    [self buttonWithName:@"Like" andSubviews:[postCell.socialPanel subviews] withCell:postCell andPostIndex:indexPath.row];
    
    [self buttonWithName:@"Comment" andSubviews:[postCell.socialPanel subviews] withCell:postCell andPostIndex:indexPath.row];
    [self buttonWithName:@"Share" andSubviews:[postCell.socialPanel subviews] withCell:postCell andPostIndex:indexPath.row];
    [self buttonWithName:@"" andSubviews:[postCell.socialPanel subviews] withCell:postCell andPostIndex:indexPath.row];
    

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigateToProfile:)];
    [tap setNumberOfTapsRequired:1];
    [postCell.userImageView addGestureRecognizer:tap];
    
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFullPostImage:)];
    [tap setNumberOfTapsRequired:1];
    [postCell.postImage addGestureRecognizer:tap];
    


    
    
    [postCell updateWithPostData:post];


    
    return postCell;
    
}

-(void)showFullPostImage:(id)sender
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

-(void) imageViewTabbed: (id) sender
{
    NSLog(@"imageViewTabbed");
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
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

/**
 
 Add selectors to the social panel buttons.
 
 @param buttonName title of the button.
 @param subviews of the social panel.
 @param cell current cell.
 
 */
-(UIButton*) buttonWithName: (NSString*)buttonName andSubviews: (NSArray*)subArray withCell: (PostCell*) cell andPostIndex:(int)postIndex
{
    for(UIView* view in subArray)
    {
        if([view isKindOfClass:[UIButton class]])
        {
            UIButton *currentBtn = (UIButton*)view;
            currentBtn.userInteractionEnabled = YES;
            if([currentBtn.titleLabel.text isEqualToString:@"Like"])
            {
                currentBtn.tag = postIndex;

                    //[currentBtn addTarget:self action:@selector(likeButtonPushedWithImage:) forControlEvents:UIControlEventTouchUpInside];

                    [currentBtn addTarget:self action:@selector(likeButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
                
            }
            else if ([currentBtn.titleLabel.text isEqualToString:@"Comment"])
            {
                currentBtn.tag = postIndex;
                [currentBtn addTarget:self action:@selector(commentButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
            }
            else if([currentBtn.titleLabel.text isEqualToString:@"Share"])
            {
               [currentBtn addTarget:self action:@selector(shareButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                [currentBtn addTarget:self action:@selector(navigateToProfile:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    
    
    return nil;
}

/*
 When like button is pushed turn it to our application's custom colour.
 */
-(void)likeButtonPushed: (id) sender
{
    UIButton *btn = (UIButton*) sender;

    //If like button is pushed then set the pushed variable to NO and change the
    //colour of the image.
    if([[self.posts objectAtIndex:btn.tag] liked])
    {
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        //Add the thumbs up selected version of image.
        [btn setImage:[UIImage imageNamed:@"thumbs-up"] forState:UIControlStateNormal];
        
        [[self.posts objectAtIndex:btn.tag] setLiked:NO];
        
        //Change the like status and send to server the change.
        [self postLike:NO withPostRemoteKey:[[self.posts objectAtIndex:btn.tag] remoteKey]];
    }
    else
    {
        [btn setTitleColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationbar"]] forState:UIControlStateNormal];
        //Add the thumbs up selected version of image.
        [btn setImage:[UIImage imageNamed:@"thumbs-up_pushed"] forState:UIControlStateNormal];
        
        
       [[self.posts objectAtIndex:btn.tag] setLiked:YES];
        
        //Change the like status and send to server the change.
        [self postLike:YES withPostRemoteKey:[[self.posts objectAtIndex:btn.tag] remoteKey]];

    }
    
}

-(void)navigateToProfile:(id)sender
{
    UITapGestureRecognizer *incomingUser = (UITapGestureRecognizer*) sender;

    UIImageView *incomingView = (UIImageView*)incomingUser.view;
    
    //Decide where to navigate. Private or open.
    
    
    self.selectedUserId = incomingView.tag;
    
    if((self.selectedUserId == [[SessionManager sharedInstance]user].remoteKey))
    {
        self.selectedUserId = -1;
        //Navigate to profile view controller.
        
        [self performSegueWithIdentifier:@"view profile" sender:self];
    }
    else if([self navigateToUnlockedProfile])
    {
        //Navigate to profile view controller.

        [self performSegueWithIdentifier:@"view profile" sender:self];
    }
    else
    {
        //Navigate to private view controller.
        
        [self performSegueWithIdentifier:@"view private profile" sender:self];
    }
    
}

/**
 If YES navigate to real profile, if no to private profile.
 */
-(BOOL)navigateToUnlockedProfile
{
    //Check if the user is already in contacts.
    //If yes show the regular profie view (unlocked).
    if([[ContactsManager sharedInstance] isUserContactWithId:self.selectedUserId])
    {
        NSLog(@"PrivateProfileViewController : Unlock Profile.");
        
        return YES;
    }
    else
    {
        //If no, check in database if the user is already requested.
        
        //If yes change the button of add user to user already requested.
        
        if([[ContactsManager sharedInstance] isContactWithIdRequested:self.selectedUserId])
        {
            NSLog(@"PrivateProfileViewController : User already requested by you.");
            //            UIImage *img = [UIImage imageNamed:@"invitesent"];
            //            [self.addUserButton setImage:img forState:UIControlStateNormal];
            //            [self.addUserButton setEnabled:NO];
            //
            //For now just navigate to the unlocked profile.
            
            return YES;
            
        }
        else
        {
            //If not show the private profile view as is.
            NSLog(@"PrivateProfileViewController : Private profile as is.");
            
            return NO;
        }
    }
}

//-(void) likeButtonPushedWithImage:(id)sender
//{
//    NSLog(@"Like Pushed: %d",likePushed);
//    UIButton *btn = (UIButton*) sender;
//    
//    //If like button is pushed then set the pushed variable to NO and change the
//    //colour of the image.
//    if(likePushed)
//    {
//        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        //Add the thumbs up selected version of image.
//        [btn setImage:[UIImage imageNamed:@"thumbs-up_image"] forState:UIControlStateNormal];
//        
//        
//        likePushed = NO;
//    }
//    else
//    {
//        [btn setTitleColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationbar"]] forState:UIControlStateNormal];
//        //Add the thumbs up selected version of image.
//        [btn setImage:[UIImage imageNamed:@"thumbs-up_pushed"] forState:UIControlStateNormal];
//        
//        likePushed = YES;
//    }
//    
//}

/**
 Navigates to a modal view to let user to add a comment.
 */
-(void)commentButtonPushed: (id)sender
{
    UIButton *btn = (UIButton*)sender;
    
    //Hide navigation bar.
    [self hideNavigationBarAndButtonWithNewTitle:@"New Comment"];
    
    NewCommentView *loadingView = [NewCommentView loadingViewInView:[self.view.window.subviews objectAtIndex:0]];
    loadingView.post = self.posts[btn.tag];
    loadingView.delegate = self;
    
}

-(void)shareButtonPushed: (id)sender
{
    NSArray *items = @[[NSString stringWithFormat:@"%@",@"Share1"],[NSURL URLWithString:@"http://www.google.com"]];

    UIActivityViewController *shareItems = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];

    NSArray * excludeActivities = @[UIActivityTypeAssignToContact, UIActivityTypePostToWeibo, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeSaveToCameraRoll, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    
    /**
     NSString *const UIActivityTypePostToFacebook;
     NSString *const UIActivityTypePostToTwitter;
     NSString *const UIActivityTypePostToWeibo;
     NSString *const UIActivityTypeMessage;
     NSString *const UIActivityTypeMail;
     NSString *const UIActivityTypePrint;
     NSString *const UIActivityTypeCopyToPasteboard;
     NSString *const UIActivityTypeAssignToContact;
     NSString *const UIActivityTypeSaveToCameraRoll;
     NSString *const UIActivityTypeAddToReadingList;
     NSString *const UIActivityTypePostToFlickr;
     NSString *const UIActivityTypePostToVimeo;
     NSString *const UIActivityTypePostToTencentWeibo;
     NSString *const UIActivityTypeAirDrop;
     */
    /**
     NSArray * activityItems = @[[NSString stringWithFormat:@"Some initial text."], [NSURL URLWithString:@"http://www.google.com"]];
     NSArray * applicationActivities = nil;
     NSArray * excludeActivities = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeMessage];
     
     UIActivityViewController * activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
     activityController.excludedActivityTypes = excludeActivities;
     
     */
    
 //   SLComposeViewController *t;
    
    //SLComposeViewController *fbController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];

//    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
//    {
//        // Device is able to send a Twitter message
//        NSLog(@"Able to use twitter.");
//        
//    }
    
//    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
//    {
//        // Device is able to send a Twitter message
//        NSLog(@"Able to use facebook.");
//        
//    }
    
    shareItems.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:shareItems animated:YES completion:nil];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedPost = self.posts[indexPath.row];
    self.selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"view post" sender:self];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //float height = [[self.postsHeight objectAtIndex:indexPath.row] floatValue];
    
    //static float imageSize = 300;
    //static float lowerPostLimit = 115;
    //static float fixedLimitHeight = 70;
    
    GLPPost *currentPost = [self.posts objectAtIndex:indexPath.row];
    
    
    if([currentPost imagePost])
    {
        //NSLog(@"heightForRowAtIndexPath With Image %f and text: %@",[PostCell getCellHeightWithContent:currentPost.content image:YES], currentPost.content);
        //return [PostCell getCellHeightWithContent:[PostCell findTheNeededText:currentPost.content] andImage:YES];
        //return [PostCell getCellHeightWithContent:currentPost.content andImage:YES];
        
        //return [PostCell getCellHeightWithContent:currentPost.content image:YES];
        return 415;


    }
    else
    {
        //NSLog(@"heightForRowAtIndexPath Without Image %f and text: %@",[PostCell getCellHeightWithContent:currentPost.content image:NO], currentPost.content);
        //return [PostCell getCellHeightWithContent:currentPost.content andImage:NO];
        
//        return [PostCell getCellHeightWithContent:[PostCell findTheNeededText:currentPost.content] andImage:NO];
        
        //return [PostCell getCellHeightWithContent:currentPost.content image:NO];
        return 156;
    }
}

- (void)newPostButtonClick
{
    
//    if(![NewPostView visible])
//    {
//        self.postView = [NewPostView loadingViewInView:[self.view.window.subviews objectAtIndex:0]];
//        self.postView.delegate = self;
//    }
//    else
//    {
//        [self.postView cancelPushed:nil];
//    }


    
    
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7"))
    {
        //If iOS7
        
        //Hide navigation items and add NewPostViewController's items.
        [self hideNavigationBarAndButtonWithNewTitle:@"New Post"];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
        NewPostViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"NewPostViewController"];
        vc.view.backgroundColor =  self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.67];
        vc.delegate = self;
        [vc setTransitioningDelegate:self.transitionController];
        vc.modalPresentationStyle= UIModalPresentationCustom;
        [self.view setBackgroundColor:[UIColor whiteColor]];
        [self presentViewController:vc animated:YES completion:nil];
    }
    else
    {
        
        //If iOS6
        
        NSLog(@"Modal View iOS 6");
        
        /**
            Takes screenshot from the current view controller to bring the sense of the transparency after the load
            of the NewPostViewController.
         */
        UIGraphicsBeginImageContext(self.view.window.bounds.size);
        [self.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"NewPostViewController"];
        
       // vc.view.backgroundColor = [UIColor clearColor];
        vc.view.backgroundColor = [UIColor colorWithPatternImage:image];
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:vc animated:YES completion:nil];
        
        /**
         UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
         UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SecondViewController"];
         vc.view.backgroundColor = [UIColor clearColor];
         self.modalPresentationStyle = UIModalPresentationCurrentContext;
         [self presentViewController:vc animated:NO completion:nil];
         
         */
        
//        self.modalPresentationStyle = UIModalPresentationFullScreen;
//
        
//        presenterViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
//        [presenterViewController presentViewController:loginViewController animated:YES completion:NULL];
        
        //[self performSegueWithIdentifier:@"new post" sender:self];

    }

    
    

}

- (UIImage *)screenshot:(CGRect)cropRect
{
    UIGraphicsBeginImageContext(cropRect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, -cropRect.origin.x, -cropRect.origin.y - [[UIApplication sharedApplication] statusBarFrame].size.height);
    [self.view.window.layer renderInContext:ctx];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    
    //        if([view isKindOfClass:[UIButton class]])

    if([sender isKindOfClass:[PostCell class]])
    {
    }
    
    if([segue.identifier isEqualToString:@"view post"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];

        ViewPostViewController *vc = segue.destinationViewController;
        /**
            Forward data of the post the to the view. Or in future just forward the post id
            in order to fetch it from the server.
         */
        
        vc.post = self.selectedPost;
        vc.selectedIndex = self.selectedIndex;
    
        
        self.selectedPost = nil;
        
    } else if([segue.identifier isEqualToString:@"new post"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];

        //TODO: See how to present from view controller.

        
        NewPostViewController *vc = segue.destinationViewController;

        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        
        
        
//        self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        //[self presentViewController:vc animated:NO completion:nil];
        
        
        //UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
        
        //[self.navigationController presentModalViewController:navController animated:YES];
        
        //[self presentViewController:navController animated:YES completion:nil];

        vc.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"new comment"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
        AddCommentViewController *addComment = segue.destinationViewController;
        
        addComment.delegate = self;
        
    }
    else if([segue.identifier isEqualToString:@"view private profile"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:NO];
        
        PrivateProfileViewController *privateProfileViewController = segue.destinationViewController;
        
        privateProfileViewController.selectedUserId = self.selectedUserId;
    }
    else if([segue.identifier isEqualToString:@"view profile"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
        ProfileViewController *profileViewController = segue.destinationViewController;
        
        GLPUser *incomingUser = [[GLPUser alloc] init];
        
        incomingUser.remoteKey = self.selectedUserId;

        if(self.selectedUserId == -1)
        {
            incomingUser = nil;
        }
    
        profileViewController.incomingUser = incomingUser;
    }

}

@end
