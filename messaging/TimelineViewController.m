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
#import "Post.h"
#import "AddCommentViewController.h"
#import "NewCommentView.h"
#import "Social/Social.h"
#import <Twitter/Twitter.h>
#import "PopUpMessage.h"
#import "PostWithImageCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PrivateProfileViewController.h"

//#import "AppDelegate.h"

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
@property int selectedUserId;

//TODO: Remove after the integration of image posts.
@property int selectedIndex;

@end
static BOOL likePushed;

@implementation TimelineViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
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
    UIColor *tabColour = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationbar"]];
    self.tabBarController.tabBar.tintColor = tabColour;
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: tabColour, UITextAttributeTextColor, nil] forState:UIControlStateSelected];
    
    

    
    
    
//    
//    [[UITabBar appearance] setTintColor:[UIColor blackColor]]; // for unselected items that are gray
//    [[UITabBar appearance] setSelectedImageTintColor:[UIColor greenColor]]; // for selected items that are green
    
    //Change navigations items' (back arrow, edit etc.) colour.
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    
    //Access items of tabBarController.
 //   NSArray *items = [self.tabBarController.tabBar items];
    
//    UITabBarItem *item1 = [items objectAtIndex:0];
//    [item1 setTitle:@"TEST"];
    //[item1 ]
    
    
    
     
//    UIImage* tabBarBackground = [UIImage imageNamed:@"navigation_fullblack.png"];
//    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
//    
//    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"navigation_select.png"]];
    
    
    //Change the format of the navigation bar.
    [self.navigationController.navigationBar setTranslucent:YES];
    
    // ios7 only
//    if([self respondsToSelector:@selector(setBackButtonBackgroundImage:forState:barMetrics:)])
//    {

    UIImage *image = [UIImage imageNamed:@"navigationbar2"];
    if(SYSTEM_VERSION_EQUAL_TO(@"7")) {
        [self.navigationController.navigationBar setBackgroundImage:image forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    } else {
        [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    
    
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

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadPosts];

    
}

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
    
    NSArray *arrayView = [self.navigationController.navigationBar subviews];
    
    NSLog(@"Views: %@", arrayView);
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

- (void)loadPosts
{
    [WebClientHelper showStandardLoaderWithTitle:@"Loading posts" forView:self.view];
    
    
    [[WebClient sharedInstance] getPostsWithCallbackBlock:^(BOOL success, NSArray *posts) {
       [WebClientHelper hideStandardLoaderForView:self.view];
        
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
                NSLog(@"Load User Image URL: %@",user.profileImageUrl);
                
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
        
        NSLog(@"Users Images: %@",self.usersImages);

    }
    
    [self.tableView reloadData];
   
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Post Size: %d", self.posts.count);
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

    }
    else
    {
        

        postCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithoutImage forIndexPath:indexPath];

        postCell.imageAvailable = NO;
        
    }
    
    
    //TODO: For each post take the status of the button like. (Obviously from the server).
    //TODO: In updateWithPostData information take the status of the like button.
    
    //NSLog(@"Image URL: %@", user.profileImageUrl);
    
    //Add selector to the buttons.
    [self buttonWithName:@"Like" andSubviews:[postCell.socialPanel subviews] withCell:postCell andPostIndex:indexPath.row];
    
    [self buttonWithName:@"Comment" andSubviews:[postCell.socialPanel subviews] withCell:postCell andPostIndex:indexPath.row];
    [self buttonWithName:@"Share" andSubviews:[postCell.socialPanel subviews] withCell:postCell andPostIndex:indexPath.row];
    [self buttonWithName:@"" andSubviews:[postCell.socialPanel subviews] withCell:postCell andPostIndex:indexPath.row];
    
    
    //For each post try to fetch users' details.
    NSLog(@"User Remote Key: %d",post.author.remoteKey);
    
    
    /**
     UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
     [tap setNumberOfTapsRequired:1];
     [yourImageView addGestureRecognizer: tap];
     */
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigateToProfile:)];
    [tap setNumberOfTapsRequired:1];
    [postCell.userImageView addGestureRecognizer:tap];
    
    [postCell updateWithPostData:post];

    
    //[self userWithPost:post andPostCell:postCell];
    
    
    return postCell;
    
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
    NSLog(@"IN ButtonWithName");
    for(UIView* view in subArray)
    {
        if([view isKindOfClass:[UIButton class]])
        {
            UIButton *currentBtn = (UIButton*)view;
            currentBtn.userInteractionEnabled = YES;
            if([currentBtn.titleLabel.text isEqualToString:@"Like"])
            {
                if(cell.imageAvailable)
                {
                    [currentBtn addTarget:self action:@selector(likeButtonPushedWithImage:) forControlEvents:UIControlEventTouchUpInside];
                }
                else
                {
                    [currentBtn addTarget:self action:@selector(likeButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
                }
                //[currentBtn addTarget:self action:@selector(likeButtonPushed:) forControlEvents:UIControlEventTouchDown];
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
    if(likePushed)
    {
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
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
    
}

-(void)navigateToProfile:(id)sender
{
    UITapGestureRecognizer *incomingUser = (UITapGestureRecognizer*) sender;

    UIImageView *incomingView = (UIImageView*)incomingUser.view;
        
    self.selectedUserId = incomingView.tag;
    
    [self performSegueWithIdentifier:@"view private profile" sender:self];
}

-(void) likeButtonPushedWithImage:(id)sender
{
    NSLog(@"Like Pushed: %d",likePushed);
    UIButton *btn = (UIButton*) sender;
    
    //If like button is pushed then set the pushed variable to NO and change the
    //colour of the image.
    if(likePushed)
    {
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //Add the thumbs up selected version of image.
        [btn setImage:[UIImage imageNamed:@"thumbs-up_image"] forState:UIControlStateNormal];
        
        
        likePushed = NO;
    }
    else
    {
        [btn setTitleColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationbar"]] forState:UIControlStateNormal];
        //Add the thumbs up selected version of image.
        [btn setImage:[UIImage imageNamed:@"thumbs-up_pushed"] forState:UIControlStateNormal];
        
        likePushed = YES;
    }
    
}

/**
 Navigates to a modal view to let user to add a comment.
 */
-(void)commentButtonPushed: (id)sender
{
    UIButton *btn = (UIButton*)sender;
    
    NSLog(@"Button Title: %@ With tag: %d",btn.titleLabel.text, btn.tag);
    
    //Hide navigation bar.
    [self.navigationItem setTitle:@"New Comment"];
    self.navigationItem.rightBarButtonItem = nil;
    
    NewCommentView *loadingView = [NewCommentView loadingViewInView:[self.view.window.subviews objectAtIndex:0]];
    loadingView.post = self.posts[btn.tag];
    loadingView.delegate = self;
    
}

-(void)shareButtonPushed: (id)sender
{
    NSLog(@"Share Pushed");
 
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
        NSLog(@"heightForRowAtIndexPath With Image %f and text: %@",[PostCell getCellHeightWithContent:currentPost.content image:YES], currentPost.content);
        //return [PostCell getCellHeightWithContent:[PostCell findTheNeededText:currentPost.content] andImage:YES];
        //return [PostCell getCellHeightWithContent:currentPost.content andImage:YES];
        
        //return [PostCell getCellHeightWithContent:currentPost.content image:YES];
        return 415;


    }
    else
    {
        NSLog(@"heightForRowAtIndexPath Without Image %f and text: %@",[PostCell getCellHeightWithContent:currentPost.content image:NO], currentPost.content);
        //return [PostCell getCellHeightWithContent:currentPost.content andImage:NO];
        
//        return [PostCell getCellHeightWithContent:[PostCell findTheNeededText:currentPost.content] andImage:NO];
        
        //return [PostCell getCellHeightWithContent:currentPost.content image:NO];
        return 156;
    }
}


- (void)newPostButtonClick
{
    [self performSegueWithIdentifier:@"new post" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    
    //        if([view isKindOfClass:[UIButton class]])

    if([sender isKindOfClass:[PostCell class]])
    {
        NSLog(@"THIS CLASS!");
    }
    
    if([segue.identifier isEqualToString:@"view post"])
    {
        
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

        NewPostViewController *vc = segue.destinationViewController;
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

}

@end
