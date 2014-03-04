//
//  GroupViewController.m
//  Gleepost
//
//  Created by Silouanos on 04/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GroupViewController.h"
#import "GLPPost.h"
#import "AppearanceHelper.h"
#import "GLPGroupManager.h"
#import "PostCell.h"
#import "ProfileTableViewCell.h"
#import "GLPPostManager.h"
#import "GLPPostImageLoader.h"
#import "GLPPostNotificationHelper.h"
#import "ViewPostViewController.h"
#import "ViewPostImageViewController.h"
#import "TransitionDelegateViewImage.h"
#import "ProfileTwoButtonsTableViewCell.h"
#import "ContactUserCell.h"
#import "GLPPrivateProfileViewController.h"
#import "WebClient.h"

@interface GroupViewController ()

@property (strong, nonatomic) NSArray *posts;
@property (strong, nonatomic) NSArray *members;
@property (assign, nonatomic) BOOL commentCreated;
@property (strong, nonatomic) GLPPost *selectedPost;
@property (assign, nonatomic) int currentNumberOfRows;
@property (strong, nonatomic) TransitionDelegateViewImage *transitionViewImageController;
@property (assign, nonatomic) int selectedUserId;
@property (assign, nonatomic) GLPSelectedTab selectedTabStatus;

@end

@implementation GroupViewController

const int NUMBER_OF_ROWS = 2;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    [self registerTableViewCells];
    
    [self initialiseObjects];
    
    [self loadPosts];
    
    [self loadMembers];
    
    [self.tableView setTableFooterView:[[UIView alloc] init]];

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureNotifications];

    
    [self configureNavigationBar];
}

- (void)viewDidDisappear:(BOOL)animated
{
    
    [super viewDidDisappear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self removeNotifications];
    
    [super viewWillDisappear:animated];
}

#pragma mark - Configuration methods

-(void)registerTableViewCells
{
    //Register nib files in table view.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileViewTableViewCell" bundle:nil] forCellReuseIdentifier:@"ProfileCell"];

    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileViewTwoButtonsTableViewCell" bundle:nil] forCellReuseIdentifier:@"TwoButtonsCell"];
    
    //Register posts.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostImageCellView" bundle:nil] forCellReuseIdentifier:@"ImageCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTextCellView" bundle:nil] forCellReuseIdentifier:@"TextCell"];
    
    //Register contacts' cells.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];

}

-(void)initialiseObjects
{
    [self.view setBackgroundColor:[AppearanceHelper defaultGleepostColour]];
    self.selectedTabStatus = kGLPPosts;
    
}

-(void)configureNavigationBar
{
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;

    [self.navigationController setNavigationBarHidden:NO
                                             animated:YES];
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    
    //Change the format of the navigation bar.
    [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:nil forBarMetrics:UIBarMetricsDefault];
    [AppearanceHelper setNavigationBarColour:self];

    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [AppearanceHelper setNavigationBarFontFor:self];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
}

-(void)configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRealImage:) name:@"GLPPostImageUploaded" object:nil];
}

-(void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPPostImageUploaded" object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notifications methods

-(void)updateRealImage:(NSNotification *)notification
{
    GLPPost *currentPost = nil;
    
    int index = [GLPPostNotificationHelper parsePost:&currentPost imageNotification:notification withPostsArray:self.posts];
    
    
    if(currentPost)
    {
        [self refreshCellViewWithIndex:index+2];
    }
}

#pragma mark - Table view refresh methods

-(void)refreshCellViewWithIndex:(const NSUInteger)index
{
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.selectedTabStatus == kGLPPosts)
    {
        self.currentNumberOfRows = NUMBER_OF_ROWS + self.posts.count;
    }
    else
    {
        self.currentNumberOfRows = NUMBER_OF_ROWS + self.members.count;
    }
        
    
    
    return self.currentNumberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifierWithImage = @"ImageCell";
    static NSString *CellIdentifierWithoutImage = @"TextCell";
    static NSString *CellIdentifierProfile = @"ProfileCell";
    static NSString *CellIdentifierTwoButtons = @"TwoButtonsCell";
    static NSString *CellIdentifierContact = @"ContactCell";
    
    PostCell *postViewCell;
    ProfileTableViewCell *profileView;
    ProfileTwoButtonsTableViewCell *buttonsView;
    ContactUserCell *contactCell;
    
    if(indexPath.row == 0)
    {
        profileView = [tableView dequeueReusableCellWithIdentifier:CellIdentifierProfile forIndexPath:indexPath];
        
//        [profileView setPrivateProfileDelegate:self];
        
//        if(self.profileImage && self.profileUser)
//        {
//            [profileView initialiseElementsWithUserDetails:self.profileUser withImage:self.profileImage];
//        }
//        else if(self.profileImage && !self.profileUser)
//        {
//            [profileView initialiseProfileImage:self.profileImage];
//        }
//        else
//        {
//            [profileView initialiseElementsWithUserDetails:self.profileUser];
//        }
        
        [profileView initialiseElementsWithGroupInformation:self.group];
        
        profileView.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return profileView;
        
    }
    else if(indexPath.row == 1)
    {
        buttonsView = [tableView dequeueReusableCellWithIdentifier:CellIdentifierTwoButtons forIndexPath:indexPath];
        buttonsView.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [buttonsView setDelegate:self];
        
        return buttonsView;
        
    }
    else if (indexPath.row >= 2)
    {
        
        if(self.selectedTabStatus == kGLPSettings)
        {
            //Imeplement members cell.
            contactCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierContact forIndexPath:indexPath];
            
            GLPUser *currentMember = self.members[indexPath.row - 2];
            
            [contactCell setName:currentMember.name withImageUrl:currentMember.profileImageUrl];
            
            return contactCell;
        }
        else
        {
            if(self.posts.count != 0)
            {
                GLPPost *post = self.posts[indexPath.row-2];
                
                if([post imagePost])
                {
                    postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithImage forIndexPath:indexPath];
                }
                else
                {
                    postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithoutImage forIndexPath:indexPath];
                }
                
                //Set this class as delegate.
                postViewCell.delegate = self;
                
                [postViewCell updateWithPostData:post withPostIndex:indexPath.row];
                
                
                if(indexPath.row - 2  != self.posts.count)
                {
                    //Add separator line to posts' cells.
                    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, postViewCell.frame.size.height-0.5f, 320, 0.5)];
                    line.backgroundColor = [UIColor colorWithRed:217.0f/255.0f green:228.0f/255.0f blue:234.0f/255.0f alpha:1.0f];
                    [postViewCell addSubview:line];
                }
            }
        }

        
        return postViewCell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if(indexPath.row < 2)
    {
        return;
    }
    
    if(self.selectedTabStatus == kGLPPosts)
    {
        if(indexPath.row-2 == self.posts.count) {
            return;
        }
        
        self.selectedPost = self.posts[indexPath.row-2];
        //    self.postIndexToReload = indexPath.row-2;
        self.commentCreated = NO;
        [self performSegueWithIdentifier:@"view post" sender:self];
    }
    else
    {
        GLPUser *member = self.members[indexPath.row - 2];
        
        self.selectedUserId = member.remoteKey;
        
        [self performSegueWithIdentifier:@"view private profile" sender:self];

    }
    

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        return PROFILE_CELL_HEIGHT;
    }
    else if(indexPath.row == 1)
    {
        return TWO_BUTTONS_CELL_HEIGHT;
    }
    else if(indexPath.row >= 2)
    {
        
        if(self.selectedTabStatus == kGLPPosts)
        {
            if(self.posts.count != 0 && self.posts)
            {
                GLPPost *currentPost = [self.posts objectAtIndex:indexPath.row-2];
                
                if([currentPost imagePost])
                {
                    return [PostCell getCellHeightWithContent:currentPost.content image:YES isViewPost:NO];
                }
                else
                {
                    return [PostCell getCellHeightWithContent:currentPost.content image:NO isViewPost:NO];
                }
            }
        }
        else
        {
            return CONTACT_CELL_HEIGHT;
        }
        

    }
    
    return 70.0f;
}

#pragma mark - Client

-(void)loadPosts
{
    [GLPGroupManager loadInitialPostsWithGroupId:_group.remoteKey remoteCallback:^(BOOL success, NSArray *remotePosts) {
       
        if(success)
        {
            DDLogDebug(@"Posts from network: %@ - %@", _group.name, remotePosts);
            
            _posts = remotePosts;
            
            [GLPPostManager setFakeKeysToPrivateProfilePosts:self.posts];
            
            [[GLPPostImageLoader sharedInstance] addPostsImages:self.posts];
            
            [self.tableView reloadData];
        }
        
    }];
}

-(void)loadMembers
{
    [[WebClient sharedInstance] getMembersWithGroupRemoteKey:self.group.remoteKey withCallbackBlock:^(BOOL success, NSArray *members) {
       
        if(success)
        {
            self.members = members;
            
            if(self.selectedTabStatus == kGLPSettings)
            {
                [self.tableView reloadData];
            }
        }
        
    }];
    
//    GLPUser *user = [[GLPUser alloc] init];
//    
//    user.name = @"Test Guy";
//    user.remoteKey = [SessionManager sharedInstance].user.remoteKey;
//    
//    self.members = [[NSArray alloc] initWithObjects:user, nil];
//    
//    [self.tableView reloadData];
    
}

#pragma mark - View image delegate


-(void)viewPostImage:(UIImage*)postImage
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    ViewPostImageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ViewPostImage"];
    vc.image = postImage;
    vc.view.backgroundColor = self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.67];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    
    [vc setTransitioningDelegate:self.transitionViewImageController];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - New comment delegate

-(void)setPreviousViewToNavigationBar
{
    self.navigationItem.hidesBackButton = NO;
    
}

-(void)setPreviousNavigationBarName
{
    [self.navigationItem setTitle:self.group.name];
}

-(void)hideNavigationBarAndButtonWithNewTitle:(NSString*)newTitle
{
    [self.navigationItem setTitle:newTitle];
    self.navigationItem.hidesBackButton = YES;
}

-(void)navigateToViewPostFromCommentWithIndex:(int)postIndex
{
    self.selectedPost = self.posts[postIndex-1];
    
    //    self.postIndexToReload = postIndex;
    
    ++self.selectedPost.commentsCount;
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:postIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    self.commentCreated = YES;
    
    //Notify GLPProfileViewController about changes.
    [GLPPostNotificationHelper updatePostWithNotifiationName:@"GLPPostUpdated" withObject:self remoteKey:self.selectedPost.remoteKey numberOfLikes:self.selectedPost.likes andNumberOfComments:self.selectedPost.commentsCount];
    
    [self performSegueWithIdentifier:@"view post" sender:self];
}

#pragma  mark - Button Navigation Delegate

-(void)viewSectionWithId:(GLPSelectedTab) selectedTab
{
    
    self.selectedTabStatus = selectedTab;
    
    if(selectedTab == kGLPSettings)
    {
        
    }
    
    [self.tableView reloadData];
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


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"view post"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];

        ViewPostViewController *vpvc = segue.destinationViewController;
        
        vpvc.post = self.selectedPost;
        
        vpvc.commentJustCreated = self.commentCreated;
    }
    else if([segue.identifier isEqualToString:@"view private profile"])
    {
        GLPPrivateProfileViewController *profileViewController = segue.destinationViewController;
        
        profileViewController.selectedUserId = self.selectedUserId;
    }
}

@end
