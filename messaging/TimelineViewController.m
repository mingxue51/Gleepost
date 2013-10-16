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

//#import "AppDelegate.h"

@interface TimelineViewController ()

@property (strong, nonatomic) NSMutableArray *posts;
@property (strong, nonatomic) Post *selectedPost;
@property (strong, nonatomic) NSMutableArray *postsHeight;;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSMutableArray *shownCells;

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
    
    

    
    //self.tabBarController.tabBar.backgroundColor = [UIColor whiteColor];*
    
    //self.tabBarController.tabBar.selectedImageTintColor = [UIColor whiteColor];
    
    //Set the white colour to selected tab.
    UIColor *tabColour = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationbar"]];
    self.tabBarController.tabBar.tintColor = tabColour;
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: tabColour, UITextAttributeTextColor, nil] forState:UIControlStateSelected];
    
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
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar2"] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
//    }
    
    
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
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"+"]];
    UIButton *btnBack=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(newPostButtonClick) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = imageView.bounds;
    [imageView addSubview:btnBack];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.navigationItem.rightBarButtonItem = item;
    
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
    
    [self loadPosts];

  
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



- (void)loadPosts
{
    [WebClientHelper showStandardLoaderWithTitle:@"Loading posts" forView:self.view];
    
    
    [[WebClient sharedInstance] getPostsWithCallbackBlock:^(BOOL success, NSArray *posts) {
       [WebClientHelper hideStandardLoaderForView:self.view];
        
        if(success) {
            self.posts = [posts mutableCopy];
            
            
            for(int i=0; i<self.posts.count; ++i)
            {
                NSLog(@"COUNT POSTS: %d",i);
                [self.shownCells addObject:[NSNumber numberWithBool:NO]];
            }
            
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
            
            
            [self.tableView reloadData];
        } else {
            [WebClientHelper showStandardError];
        }
    }];
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
    static NSString *CellIdentifierWithImage = @"CellImage";
    static NSString *CellIdentifierWithoutImage = @"CellText";


    PostCell *postCell;

    
    //TODO: Add to Post datatype a boolean like.
    Post *post = self.posts[indexPath.row];

    if(indexPath.row%3==0)
    {

        postCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithImage forIndexPath:indexPath];
        
       
        postCell.imageAvailable = YES;
        
        //Calculate the new position of the elements.
        
//        float contentHeight = [PostCell getContentLabelHeightForContent:post.content];
        
        
        //Find the difference between current height and new height.
//        float difference = contentHeight - postCell.content.frame.size.height;
        

        //[postCell updateWithPostData:post withImage:YES];
        
        
        //Add the main image to the post.
//        imageCell.mainImage.image = postImage;
        
        //TODO: See again the postImage width. Problem.
//        [imageCell.mainImage setFrame:CGRectMake(10.0f, 80.0f, postImage.size.width-18, postImage.size.height-18)];
        
        
        //Add the social panel over the main image.
//        [imageCell.socialPanel setFrame:CGRectMake(10.0f, postImage.size.width+12, postImage.size.width-18, 50.0f)];
        

    }
    else
    {
        

        postCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithoutImage forIndexPath:indexPath];

        postCell.imageAvailable = NO;
        
        //Find the difference between current height and new height.

        //[postCell updateWithPostData:post withImage:NO];


        
        //Find the size of the text of the current post.
//        float textSize = [PostCell getContentLabelHeightForContent:post.content];
        
        //Add the social panel over the main image.
        //[textCell.socialPanel setFrame:CGRectMake(10.0f, textSize+47, postImage.size.width-18, 50.0f)];
        
//        [self createTheCell:textCell withPost:post andImage:NO];
    }
    
    
    //TODO: For each post take the status of the button like. (Obviously from the server).
    //TODO: In updateWithPostData information take the status of the like button.
    
     [postCell updateWithPostData:post];
    
    //Add selector to the buttons.
    [self buttonWithName:@"Like" andSubviews:[postCell.contentView subviews] withCell:postCell];
    
    [self buttonWithName:@"Comment" andSubviews:[postCell.contentView subviews] withCell:postCell];
    [self buttonWithName:@"Share" andSubviews:[postCell.contentView subviews] withCell:postCell];
    [self buttonWithName:@"" andSubviews:[postCell.contentView subviews] withCell:postCell];
 
    
    
    return postCell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"willDisplayCell");
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
-(UIButton*) buttonWithName: (NSString*)buttonName andSubviews: (NSArray*)subArray withCell: (PostCell*) cell
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
            
            NSLog(@"-> %@", [currentBtn titleLabel].text);
        }
    }
    
    
    return nil;
}

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
    [self performSegueWithIdentifier:@"view profile" sender:self];
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
    //Hide navigation bar.
    [self.navigationItem setTitle:@"New Comment"];
    self.navigationItem.rightBarButtonItem = nil;
    
    NewCommentView *loadingView = [NewCommentView loadingViewInView:[self.view.window.subviews objectAtIndex:0]];
    loadingView.delegate = self;
    
}

/**
 Called by NewCommentView in order to hide view and retrieve the previous ViewController
 */
-(void) removeComment
{
    //Add the right title.
    [self.navigationItem setTitle:@"Campus Wall"];
    
    //Add the add button back.
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"+"]];
    UIButton *btnBack=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(newPostButtonClick) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = imageView.bounds;
    [imageView addSubview:btnBack];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.navigationItem.rightBarButtonItem = item;
    
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
    [self performSegueWithIdentifier:@"view post" sender:self];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //float height = [[self.postsHeight objectAtIndex:indexPath.row] floatValue];
    
    //static float imageSize = 300;
    //static float lowerPostLimit = 115;
    //static float fixedLimitHeight = 70;
    
    Post *currentPost = [self.posts objectAtIndex:indexPath.row];
    
    
    if(indexPath.row%3==0)
    {
        NSLog(@"heightForRowAtIndexPath With Image %f and text: %@",[PostCell getCellHeightWithContent:currentPost.content andImage:YES], currentPost.content);
        //return [PostCell getCellHeightWithContent:[PostCell findTheNeededText:currentPost.content] andImage:YES];
        //return [PostCell getCellHeightWithContent:currentPost.content andImage:YES];
        
        return 415;

    }
    else
    {
        NSLog(@"heightForRowAtIndexPath Without Image %f and text: %@",[PostCell getCellHeightWithContent:currentPost.content andImage:NO], currentPost.content);
        //return [PostCell getCellHeightWithContent:currentPost.content andImage:NO];
        
//        return [PostCell getCellHeightWithContent:[PostCell findTheNeededText:currentPost.content] andImage:NO];
        
        return 156;
    }
}


- (void)newPostButtonClick
{
    [self performSegueWithIdentifier:@"new post" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"view post"])
    {
        
        ViewPostViewController *vc = segue.destinationViewController;
        /**
            Forward data of the post the to the view. Or in future just forward the post id
            in order to fetch it from the server.
         */
        
        vc.post = self.selectedPost;
        
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
}

@end
