//
//  ProfileViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 20/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ProfileViewController.h"
#import "Post.h"
#import "MBProgressHUD.h"
#import "WebClient.h"
#import "ViewPostViewController.h"
#import "NewPostViewController.h"
#import "ProfileScrollView.h"
#import "ProfileView.h"
#import "NotificationsViewController.h"
#import "PostCell.h"

@interface ProfileViewController ()

@property (strong, nonatomic) ProfileScrollView *profileScrollView;
@property (strong, nonatomic) IBOutlet UITableView *postsTableView;

@property (strong, nonatomic) NSMutableArray *posts;
@property (strong, nonatomic) Post *selectedPost;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) IBOutlet ProfileView *profileView;


@end

static BOOL likePushed;

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    
    
    //Change the format of the navigation bar.
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar2"] forBarMetrics:UIBarMetricsDefault];

    //Change navigations items' (back arrow, edit etc.) colour.
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    
    
    
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
    
    [self.postsTableView registerNib:[UINib nibWithNibName:@"PostImageCellView" bundle:nil] forCellReuseIdentifier:@"ImageCell"];
    
    [self.postsTableView registerNib:[UINib nibWithNibName:@"PostTextCellView" bundle:nil] forCellReuseIdentifier:@"TextCell"];
    
    
    
    //Initialise profile view.
    
    [self.profileView initialiseView];
    
    [self.profileView.notificationsButton addTarget:self action:@selector(showNotifications:) forControlEvents:UIControlEventTouchDown];
    

    [self loadPosts];
    
    NSLog(@"Profile View Controller");
}

-(void) showNotifications: (id)sender
{
    [self performSegueWithIdentifier:@"view profile" sender:self];
}

- (void)viewDidLayoutSubviews
{
    NSLog(@"viewDidLayoutSubviews");
    
    [super viewDidLayoutSubviews];
}

- (void)loadPosts
{
    NSLog(@"load posts");
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading posts";
    hud.detailsLabelText = @"Please wait few seconds";
    
    WebClient *client = [WebClient sharedInstance];
    [client getPostsWithCallbackBlock:^(BOOL success, NSArray *posts) {
        [hud hide:YES];
        
        if(success) {
            self.posts = [posts mutableCopy];
            
            NSLog(@"POSTS in TimeLineViewController");
            
            for(Post *p in self.posts)
            {
                NSLog(@"%@",p.content);
            }
            
            [self.postsTableView reloadData];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading failed"
                                                            message:@"Check your id or your internet connection dude."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
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
    
    Post *post = self.posts[indexPath.row];
    
    if(indexPath.row%3==0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:ImageCellIdentifier forIndexPath:indexPath];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:TextCellIdentifier forIndexPath:indexPath];
    }
    
    
    [cell updateWithPostData:post];

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
    [self buttonWithName:@"Comment" andSubviews:[cell.contentView subviews] withCell:cell];
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
    NSLog(@"IN ButtonWithName");
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
        NotificationsViewController *nv = segue.destinationViewController;
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
