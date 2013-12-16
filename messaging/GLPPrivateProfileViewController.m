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


@interface GLPPrivateProfileViewController ()


@property (strong, nonatomic) GLPUser *profileUser;

@property (assign, nonatomic) int numberOfRows;


@property (strong, nonatomic) TransitionDelegateViewImage *transitionViewImageController;

@property (strong, nonatomic) NSArray *posts;

@property (assign, nonatomic) GLPSelectedTab selectedTabStatus;

@property (assign, nonatomic) BOOL contact;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self registerTableViewCells];
    
    [self initialiseObjects];
    
    [self configureNavigationBar];
    
    
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
            NSLog(@"PrivateProfileViewController : User already requested by you.");
            //[self setContactAsRequested];
            
        }
        else if ([[ContactsManager sharedInstance]isContactWithIdRequestedYou:self.selectedUserId])
        {
            NSLog(@"PrivateProfileViewController : User requested you.");
            
            //[self setAcceptRequestButton];
            
        }
        else
        {
            //If not show the private profile view as is.
            NSLog(@"PrivateProfileViewController : Private profile as is.");
        }
        
        self.contact = NO;
    }

    
    
    //Initialise rows with 3 because About cell is presented first.
    self.numberOfRows = 2;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Configuration


-(void)initialiseObjects
{
    //Load user's details from server.
    [self loadAndSetUserDetails];
    
    self.transitionViewImageController = [[TransitionDelegateViewImage alloc] init];
    
    [[ContactsManager sharedInstance] loadContactsFromDatabase];
    
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

-(void)configureNavigationBar
{
//    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;

    //Change the format of the navigation bar.
    [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:nil forBarMetrics:UIBarMetricsDefault];
    [AppearanceHelper setNavigationBarColour:self];
    
    //    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, nil]];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [AppearanceHelper setNavigationBarFontFor:self];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
//    self.title = @"Me";
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Client methods

-(void)loadAndSetUserDetails
{
    [[WebClient sharedInstance] getUserWithKey:self.selectedUserId callbackBlock:^(BOOL success, GLPUser *user) {
        
        if(success)
        {
            self.profileUser = user;
            
            self.navigationItem.title = self.profileUser.name;

            [self loadPosts];
            
            //[self.tableView reloadData];
        }
        else
        {
            [WebClientHelper showStandardError];
        }
    }];
}

- (void)loadPosts
{
    [GLPPostManager loadRemotePostsForUserRemoteKey:self.profileUser.remoteKey callback:^(BOOL success, NSArray *posts) {
        
        if(success)
        {
            self.posts = [posts mutableCopy];
            
            [self.tableView reloadData];
        }
        else
        {
            [WebClientHelper showStandardErrorWithTitle:@"Error loading posts" andContent:@"Please ensure that you are connected to the internet"];
        }
        
        
    }];
}

#pragma mark - UI methods

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
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.selectedTabStatus == kGLPMutual)
    {
        return self.numberOfRows + 10; /** + Number of mutual friends. */
    }
    else if(self.selectedTabStatus == kGLPPosts)
    {
        return self.numberOfRows + self.posts.count; /** + Number of user's posts. */
    }
    else
    {
        return self.numberOfRows + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierWithImage = @"ImageCell";
    static NSString *CellIdentifierWithoutImage = @"TextCell";
    static NSString *CellIdentifierProfile = @"ProfileCell";
    static NSString *CellIdentifierButtons = @"ButtonsCell";
    static NSString *CellIdentifierAbout = @"AboutCell";
    static NSString *CellIdentifierMutual = @"MutualCell";
    
    
    PostCell *postViewCell;
    
    ProfileButtonsTableViewCell *buttonsView;
    ProfileTableViewCell *profileView;
    ProfileAboutTableViewCell *profileAboutView;
    ProfileMutualTableViewCell *profileMutualView;
    
    if(indexPath.row == 0)
    {
        profileView = [tableView dequeueReusableCellWithIdentifier:CellIdentifierProfile forIndexPath:indexPath];
        
        [profileView setPrivateProfileDelegate:self];
        
        [profileView initialiseElementsWithUserDetails:self.profileUser];
        profileView.selectionStyle = UITableViewCellSelectionStyleNone;

        return profileView;

    }
    else if (indexPath.row == 1)
    {
        buttonsView = [tableView dequeueReusableCellWithIdentifier:CellIdentifierButtons forIndexPath:indexPath];
        buttonsView.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [buttonsView setDelegate:self];
        
        return buttonsView;
    }
    else if (indexPath.row >= 2)
    {
        if(self.selectedTabStatus == kGLPAbout)
        {
            profileAboutView = [tableView dequeueReusableCellWithIdentifier:CellIdentifierAbout forIndexPath:indexPath];
            
            if(self.contact)
            {
                //Show user's details.
                [profileAboutView updateUserDetails:self.profileUser];
            }

            
            return profileAboutView;
        }
        else if(self.selectedTabStatus == kGLPPosts)
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
                //TODO: Fix that.
                //postViewCell.delegate = self;
                
                [postViewCell updateWithPostData:post withPostIndex:indexPath.row];
                
            }
            
            return postViewCell;
        }
        else if(self.selectedTabStatus == kGLPMutual)
        {
            profileMutualView = [tableView dequeueReusableCellWithIdentifier:CellIdentifierMutual forIndexPath:indexPath];
            
            [profileMutualView updateDataWithName:self.profileUser.name andImageUrl:self.profileUser.profileImageUrl];
            
            return profileMutualView;
        }
        
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        return 245.0f;
    }
    else if(indexPath.row == 1)
    {
        return 50.0f;
    }
    else if(indexPath.row >= 2)
    {
        if(self.selectedTabStatus == kGLPAbout)
        {
            return 150.0f;
        }
        else if (self.selectedTabStatus == kGLPPosts)
        {
            GLPPost *currentPost = [self.posts objectAtIndex:indexPath.row-2];
            
            if([currentPost imagePost])
            {
                return IMAGE_CELL_HEIGHT;
            }
            else
            {
                return TEXT_CELL_HEIGHT;
            }
        }
        else
        {
            return 70.0f;
        }
    }
    
    return 70.0f;
}


#pragma  mark - Buttons view methods

-(void)viewSectionWithId:(GLPSelectedTab) selectedTab
{
    self.selectedTabStatus = selectedTab;
    
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
