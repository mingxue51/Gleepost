//
//  GLPPrivateProfileViewController.m
//  Gleepost
//
//  Created by Silouanos on 09/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPPrivateProfileViewController.h"
#import "TransitionDelegateViewImage.h"
#import "ContactsManager.h"
#import "PostCell.h"
#import "ProfileAboutTableViewCell.h"
#import "ProfileTableViewCell.h"
#import "ProfileButtonsTableViewCell.h"
#import "ProfileMutualTableViewCell.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "GLPPostManager.h"
#import "ViewPostImageViewController.h"
#import "AppearanceHelper.h"
#import "GLPPostNotificationHelper.h"
#import "GLPPostImageLoader.h"
#import "ViewPostViewController.h"
#import "GLPPostNotificationHelper.h"
#import "GLPConversationViewController.h"




@interface GLPPrivateProfileViewController ()


@property (strong, nonatomic) GLPUser *profileUser;
@property (strong, nonatomic) UIImage *profileImage;

@property (assign, nonatomic) int numberOfRows;
@property (assign, nonatomic) int currentNumberOfRows;


@property (strong, nonatomic) TransitionDelegateViewImage *transitionViewImageController;

@property (strong, nonatomic) NSArray *posts;

@property (assign, nonatomic) GLPSelectedTab selectedTabStatus;

@property (assign, nonatomic) BOOL contact;

//Used when there is new comment.
@property (assign, nonatomic) BOOL commentCreated;

@property (strong, nonatomic) GLPPost *selectedPost;

@property (assign, nonatomic) int postIndexToReload;

@property (strong, nonatomic) GLPConversation *conversation;
@property (strong, nonatomic) GLPUser *emptyConversationUser;

@end

@implementation GLPPrivateProfileViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
    }
    
    return self;
}

- (void)backButtonTapped {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureView];

    
    self.tableView.allowsSelectionDuringEditing=YES;
    
    
//    self.navigationItem.leftBarButtonItem = [AppDelegate customBackButtonWithTarget:self];
    // [self loadPosts];
    
    //If no, check in database if the user is already requested.
    
    //If yes change the button of add user to user already requested.
    
    //Check if the user is already in contacts.
    
    if([[ContactsManager sharedInstance] isUserContactWithId:self.selectedUserId])
    {
        //TODO: Set in table view contact as in contacts.
        
        self.contact = YES;
    }
    else
    {
        if([[ContactsManager sharedInstance] isContactWithIdRequested:self.selectedUserId])
        {
            //            NSLog(@"PrivateProfileViewController : User already requested by you.");
            //[self setContactAsRequested];
            
        }
        else if ([[ContactsManager sharedInstance]isContactWithIdRequestedYou:self.selectedUserId])
        {
            //            NSLog(@"PrivateProfileViewController : User requested you.");
            
            //[self setAcceptRequestButton];
            
        }
        else
        {
            //If not show the private profile view as is.
            //            NSLog(@"PrivateProfileViewController : Private profile as is.");
        }
        
        self.contact = NO;
    }
    
    
    [self registerTableViewCells];
    
    [self initialiseObjects];
    
    [self configureNavigationBar];
    

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO
                                             animated:YES];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRealImage:) name:@"GLPPostImageUploaded" object:nil];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPPostImageUploaded" object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Configuration


-(void)initialiseObjects
{
    //Initialise rows with 3 because About cell is presented first.
    self.numberOfRows = 2;
    
    
    self.profileImage = nil;
    
    if(self.contact)
    {
        //If the user is contact then load data from ContactsManager.
        [self loadAndSetContactDetails];

    }
    else
    {
        //Load user's details from server.
        [self loadAndSetUserDetails];
    }
    

    
    self.transitionViewImageController = [[TransitionDelegateViewImage alloc] init];
    
    //[[ContactsManager sharedInstance] loadContactsFromDatabase];
    
    self.selectedTabStatus = kGLPAbout;
    
    self.posts = [[NSArray alloc] init];


}


-(void)registerTableViewCells
{
    //Register nib files in table view.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileViewTableViewCell" bundle:nil] forCellReuseIdentifier:@"ProfileCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileViewButtonsTableViewCell" bundle:nil] forCellReuseIdentifier:@"ButtonsCell"];
    
    //Register posts.
    [self.tableView registerNib:[UINib nibWithNibName:@"PostImageCellView" bundle:nil] forCellReuseIdentifier:@"ImageCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTextCellView" bundle:nil] forCellReuseIdentifier:@"TextCell"];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileViewAboutTableViewCell" bundle:nil] forCellReuseIdentifier:@"AboutCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileViewMutualTableViewCell" bundle:nil] forCellReuseIdentifier:@"MutualCell"];
}

-(void)configureView
{
    [self.view setBackgroundColor:[AppearanceHelper defaultGleepostColour]];
    
    //Add new colour in the bottom of the table view.
//    UIImageView *bottomImageView = [[UIImageView alloc] init];
//    bottomImageView.backgroundColor = [UIColor whiteColor];
    
//    [bottomImageView setFrame:CGRectMake(0.0f, 400.0f, 320.0f, 300.0f)];
//    [self.tableView addSubview:bottomImageView];
//    [bottomImageView sendSubviewToBack:self.tableView];
    
    
    [self setBottomView];

}

-(void)setBottomView
{
    //Clear bottom view.
//    [self clearBottomView];
    
    CGRect frame = self.tableView.bounds;
    frame.origin.y = frame.size.height;
    
    CGRect viewFrame = self.view.bounds;
    viewFrame.origin.y = viewFrame.size.height;
    
    UIImageView* grayView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 300.f, 320.0f, 250.0f)];
    grayView.tag = 100;
    grayView.backgroundColor = [UIColor whiteColor];
//    [self.tableView addSubview:grayView];
//    [grayView sendSubviewToBack:self.tableView];
    
    self.tableView.tableFooterView = grayView;
//    [self.view addSubview:grayView];
}

-(void)clearBottomView
{
//    for(UIView *v in self.tableView.subviews)
//    {
//        if(v.tag == 100)
//        {
//            [v removeFromSuperview];
//        }
//    }
    
//    [self.tableView.tableFooterView setFrame:CGRectMake(0.0f, 300.0f, 320.0f, 0.0f)];
    
    self.tableView.tableFooterView = nil;
}

-(void)configureNavigationBar
{
//    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;

    //Change the format of the navigation bar.
//    [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:nil forBarMetrics:UIBarMetricsDefault];
    [AppearanceHelper setNavigationBarColour:self];
    
    //    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, nil]];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [AppearanceHelper setNavigationBarFontFor:self];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    

    
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Client methods


//TODO: Load first user from local database and the from server.

-(void)loadAndSetUserDetails
{
    [[ContactsManager sharedInstance] loadUserWithRemoteKey:self.selectedUserId localCallback:^(BOOL exist, GLPUser *user) {
        
        if(exist)
        {
            self.profileUser = user;
            self.navigationItem.title = self.profileUser.name;
            [self.tableView reloadData];
        }
        
    } remoteCallback:^(BOOL success, GLPUser *user) {
        
        if(success)
        {
            self.profileUser = user;
            self.navigationItem.title = self.profileUser.name;
            [self.tableView reloadData];
        }
        else
        {
            [WebClientHelper showStandardError];
        }

    }];
    
    [self loadPosts];
    
//    [[WebClient sharedInstance] getUserWithKey:self.selectedUserId callbackBlock:^(BOOL success, GLPUser *user) {
//        
//        if(success)
//        {
//            self.profileUser = user;
//            
//            self.navigationItem.title = self.profileUser.name;
//
////            if(!self.contact)
////            {
////
////                [self loadPosts];
////            }
//            
//            [self loadPosts];
//
//            
//            [self refreshFirstCell];
//
//        }
//        else
//        {
//            [WebClientHelper showStandardError];
//        }
//    }];
}

-(void)loadAndSetContactDetails
{
    //Try to load image.
    self.profileImage = [[ContactsManager sharedInstance] contactImageWithRemoteKey:self.selectedUserId];
    
    //If image is nil then load directly from the server.
    if(self.profileImage == nil)
    {
        [self loadAndSetUserDetails];
    }
    else
    {
        GLPUser *notCompletedUser = [[ContactsManager sharedInstance] contactWithRemoteKey:self.selectedUserId].user;
        
        self.navigationItem.title = notCompletedUser.name;
        
        [self refreshFirstCell];
        
        [self loadAndSetUserDetails];
    }
}

- (void)loadPosts
{
//    [GLPPostManager loadRemotePostsForUserRemoteKey:self.profileUser.remoteKey callback:^(BOOL success, NSArray *posts) {
//        
//        if(success)
//        {
//            self.posts = [posts mutableCopy];
//            
//            [[GLPPostImageLoader sharedInstance] addPostsImages:self.posts];
//
//            //TODO: Removed.
//            [self.tableView reloadData];
//        }
//        else
//        {
//            [WebClientHelper showStandardErrorWithTitle:@"Error loading posts" andContent:@"Please ensure that you are connected to the internet"];
//        }
//
//        
//    }];
    
    [[WebClient sharedInstance] userPostsWithRemoteKey:self.profileUser.remoteKey callbackBlock:^(BOOL success, NSArray *posts) {
        
        if(success)
        {
            self.posts = [posts mutableCopy];
            
            [[GLPPostImageLoader sharedInstance] addPostsImages:self.posts];
            
            //TODO: Removed.
            [self.tableView reloadData];
        }
        else
        {
            [WebClientHelper showStandardErrorWithTitle:@"Error loading posts" andContent:@"Please ensure that you are connected to the internet"];
        }

        
    }];
}

#pragma mark - UI methods


-(void)updateRealImage:(NSNotification*)notification
{
    if([GLPPostNotificationHelper parsePostImageNotification:notification withPostsArray:self.posts])
    {
        //TODO: Removed.
//        [self.tableView reloadData];
    }
    
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

-(void)unlockProfile
{
    self.contact = YES;
//    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if(self.selectedTabStatus == kGLPMutual)
//    {
//        self.currentNumberOfRows = self.numberOfRows + 10;
//        return self.currentNumberOfRows; /** + Number of mutual friends. */
//    }
//    else if(self.selectedTabStatus == kGLPPosts)
//    {
        self.currentNumberOfRows = self.numberOfRows + self.posts.count;
        return self.currentNumberOfRows; /** + Number of user's posts. */
//    }
//    else
//    {
//        self.currentNumberOfRows = self.numberOfRows + 1;
//        return self.currentNumberOfRows;
//    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierWithImage = @"ImageCell";
    static NSString *CellIdentifierWithoutImage = @"TextCell";
    static NSString *CellIdentifierProfile = @"ProfileCell";
    static NSString *CellIdentifierButtons = @"ButtonsCell";
//    static NSString *CellIdentifierAbout = @"AboutCell";
//    static NSString *CellIdentifierMutual = @"MutualCell";
    
    
    PostCell *postViewCell;
    
    ProfileButtonsTableViewCell *buttonsView;
    ProfileTableViewCell *profileView;
//    ProfileAboutTableViewCell *profileAboutView;
//    ProfileMutualTableViewCell *profileMutualView;
    
    if(indexPath.row == 0)
    {
        profileView = [tableView dequeueReusableCellWithIdentifier:CellIdentifierProfile forIndexPath:indexPath];
        
        [profileView setPrivateProfileDelegate:self];
        
        if(self.profileImage && self.profileUser)
        {
            [profileView initialiseElementsWithUserDetails:self.profileUser withImage:self.profileImage];
        }
        else if(self.profileImage && !self.profileUser)
        {
            [profileView initialiseProfileImage:self.profileImage];
        }
        else
        {
            [profileView initialiseElementsWithUserDetails:self.profileUser];
        }
        
        profileView.selectionStyle = UITableViewCellSelectionStyleNone;

        return profileView;

    }
    else if (indexPath.row == 1)
    {
        buttonsView = [tableView dequeueReusableCellWithIdentifier:CellIdentifierButtons forIndexPath:indexPath];
        buttonsView.currentUser = self.profileUser;
        buttonsView.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [buttonsView setDelegate:self];
        
        return buttonsView;
    }
    else if (indexPath.row >= 2)
    {
//        if(self.selectedTabStatus == kGLPAbout)
//        {
//            profileAboutView = [tableView dequeueReusableCellWithIdentifier:CellIdentifierAbout forIndexPath:indexPath];
//            
//            if(self.contact)
//            {
//                //Show user's details.
//                [profileAboutView updateUserDetails:self.profileUser];
//            }
//
//            
//            return profileAboutView;
//        }
//        else if(self.selectedTabStatus == kGLPPosts)
//        {
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
                
                if(indexPath.row > 5)
                {
                    [self clearBottomView];
                }
                
                if(indexPath.row -1 != self.posts.count)
                {
                    //Add separator line to posts' cells.
                    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, postViewCell.frame.size.height-0.5f, 320, 0.5)];
                    line.backgroundColor = [UIColor colorWithRed:217.0f/255.0f green:228.0f/255.0f blue:234.0f/255.0f alpha:1.0f];
                    [postViewCell addSubview:line];
                }
                

                
                
            }
            
            return postViewCell;
//        }
//        else if(self.selectedTabStatus == kGLPMutual)
//        {
//            profileMutualView = [tableView dequeueReusableCellWithIdentifier:CellIdentifierMutual forIndexPath:indexPath];
//            
//            [profileMutualView updateDataWithName:self.profileUser.name andImageUrl:self.profileUser.profileImageUrl];
//            
//            return profileMutualView;
//        }
        
    }
    
    //TODO: See if this is right.
    return nil;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //TODO: implement manual reloading
    if(indexPath.row-2 == self.posts.count) {
        return;
    }
    else if(indexPath.row < 2)
    {
        return;
    }
    
    self.selectedPost = self.posts[indexPath.row-2];
//    self.selectedIndex = indexPath.row;
    self.postIndexToReload = indexPath.row-2;
    self.commentCreated = NO;
    [self performSegueWithIdentifier:@"view post" sender:self];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        return PROFILE_CELL_HEIGHT;
    }
    else if(indexPath.row == 1)
    {
        return BUTTONS_CELL_HEIGHT;
    }
    else if(indexPath.row >= 2)
    {
//        if(self.selectedTabStatus == kGLPAbout)
//        {
//            return 150.0f;
//        }
//        else if (self.selectedTabStatus == kGLPPosts)
//        {
        
        if(self.posts.count != 0 && self.posts)
        {
            GLPPost *currentPost = [self.posts objectAtIndex:indexPath.row-2];
            
            DDLogDebug(@"Current Post content: %@ : %d", currentPost.content, indexPath.row);
            
            if([currentPost imagePost])
            {
                return [PostCell getCellHeightWithContent:currentPost.content image:YES isViewPost:NO];
            }
            else
            {
                return [PostCell getCellHeightWithContent:currentPost.content image:NO isViewPost:NO];
            }
        }

//        }
//        else
//        {
//            return 70.0f;
//        }
    }
    
    return 70.0f;
}

#pragma mark - Table view refresh methods


-(void)refreshFirstCell
{
    [self.tableView reloadData];
//    [self.tableView beginUpdates];
//    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//    [self.tableView endUpdates];
}

#pragma  mark - Buttons view methods

-(void)viewSectionWithId:(GLPSelectedTab) selectedTab
{
    self.selectedTabStatus = selectedTab;
    
    
//    if (self.selectedTabStatus == kGLPMutual) { // overridden to add friend
//        NSLog(@"Add friend");
//        ProfileButtonsTableViewCell *buttonsView = [self.tableView dequeueReusableCellWithIdentifier:@"ButtonsCell" forIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
//        [buttonsView addUser:nil];
//
//        
//    }else if (self.selectedTabStatus == kGLPAbout) { // overridden to message
//        NSLog(@"About");
//
//        ProfileButtonsTableViewCell *buttonsView =     (ProfileButtonsTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
//        [buttonsView sendMessage:nil];
//        
//    }else {
        [self.tableView reloadData];
//    }
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
    [self.navigationItem setTitle:self.profileUser.name];
}

-(void)hideNavigationBarAndButtonWithNewTitle:(NSString*)newTitle
{
    [self.navigationItem setTitle:newTitle];
    self.navigationItem.hidesBackButton = YES;
}

-(void)navigateToViewPostFromCommentWithIndex:(int)postIndex
{
    self.selectedPost = self.posts[postIndex-2];
    
//    self.postIndexToReload = postIndex;
    
    ++self.selectedPost.commentsCount;
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:postIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    self.commentCreated = YES;
    
    //Notify GLPProfileViewController about changes.
    [GLPPostNotificationHelper updatePostWithNotifiationName:@"GLPPostUpdated" withObject:self remoteKey:self.selectedPost.remoteKey numberOfLikes:self.selectedPost.likes andNumberOfComments:self.selectedPost.commentsCount];
    
    [self performSegueWithIdentifier:@"view post" sender:self];
}

#pragma mark - Navigation methods

-(void)viewConversation:(GLPConversation*)conversation
{
    _conversation = conversation;
    
    [self performSegueWithIdentifier:@"view topic" sender:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"view post"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
        ViewPostViewController *vc = segue.destinationViewController;
        /**
         Forward data of the post the to the view. Or in future just forward the post id
         in order to fetch it from the server.
         */
        
        vc.commentJustCreated = self.commentCreated;
        
        vc.post = self.selectedPost;
        
    }
    else if ([segue.identifier isEqualToString:@"view topic"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
        GLPConversationViewController *vt = segue.destinationViewController;
        vt.conversation = _conversation;
    }
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
