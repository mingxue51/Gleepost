//
//  GLPTimelineViewController.m
//  Gleepost
//
//  Created by Lukas on 11/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.

#import "GLPTimelineViewController.h"
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
#import "GLPPostManager.h"
#import "GLPLoadingCell.h"
#import "SessionManager.h"
#import "ContactsManager.h"
#import "GLPProfileViewController.h"
#import "TSMessage.h"
#import "GLPNewElementsIndicatorView.h"
#import "UIViewController+GAI.h"
#import "UIViewController+Flurry.h"
#import "GLPPostNotificationHelper.h"
#import "GLPThemeManager.h"
#import "ImageFormatterHelper.h"
#import "GLPPrivateProfileViewController.h"
#import "GLPPostImageLoader.h"
#import "GLPMessagesLoader.h"
#import "GLPProfileLoader.h"
#import "GLPCategoriesViewController.h"
#import "TransitionDelegateViewCategories.h"
#import "CampusWallHeader.h"
#import "CampusWallHeaderSimpleView.h"
#import "FakeNavigationBar.h"
#import "UIImage+StackBlur.h"
#import "ConversationManager.h"
#import "WalkThroughHelper.h"
#import "AnimationDayController.h"
#import "GLPGroupManager.h"
#import "CampusWallGroupsPostsManager.h"
#import "GLPiOS6Helper.h"

@interface GLPTimelineViewController ()

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
@property (strong, nonatomic) TransitionDelegateViewCategories *transitionCategoriesViewController;
@property (strong, nonatomic) UIImage *imageToBeView;

// cron controls
@property (assign, nonatomic) BOOL isReloadingCronRunning;
@property (assign, nonatomic) BOOL shouldReloadingCronRun;

//  table view controls
@property (assign, nonatomic) GLPLoadingCellStatus loadingCellStatus;
@property (assign, nonatomic) BOOL isLoading;
@property (assign, nonatomic) BOOL firstLoadSuccessful;
@property (assign, nonatomic) BOOL tableViewInScrolling;
@property (assign, nonatomic) int insertedNewRowsCount; // count of new rows inserted
@property (assign, nonatomic) int postIndexToReload;

// Not need because we use performselector which areis deprioritized during scrolling
@property (assign, nonatomic) BOOL shouldLoadNewPostsAfterScrolling;
@property (assign, nonatomic) int postsNewRowsCountToInsertAfterScrolling;

@property (strong, nonatomic) GLPNewElementsIndicatorView *elementsIndicatorView;

@property int selectedUserId;

//Used when there is new comment.
@property (assign, nonatomic) BOOL commentCreated;

//TODO: Remove after the integration of image posts.
@property int selectedIndex;

@property (strong, nonatomic) UITabBarItem *homeTabbarItem;


//Hidden navigation bar.
@property (assign, nonatomic) CGFloat startContentOffset;
@property (assign, nonatomic) CGFloat lastContentOffset;
@property (assign, nonatomic) BOOL hidden;

//Header.
@property (weak, nonatomic) CampusWallHeaderSimpleView *campusWallHeader;
@property (strong, nonatomic) FakeNavigationBar *reNavBar;

//Groups.
@property (strong, nonatomic) CampusWallGroupsPostsManager *groupsPostsManager;
@property (assign, nonatomic) BOOL groupsMode;

//Extra view will present to hide the change of background during the viewing of new post.
@property (strong, nonatomic) UIImageView *topImageView;

@end


@implementation GLPTimelineViewController

//Constants.
const float TOP_OFFSET = 280.0f;


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self configNotifications];
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     
    [self configTableView];

    [self configHeader];
    

    [self configTabbarFormat];
    
    [self configNewElementsIndicatorView];
    
    [self initialiseObjects];
    
    //TODO: Remove this later.
    [[ContactsManager sharedInstance] refreshContacts];
    
    
    [NSThread detachNewThreadSelector:@selector(startLoadingContents:) toTarget:self withObject:nil];
    
    [self loadInitialPosts];
    
    [WalkThroughHelper showCampusWallMessage];
    
    //Find the sunset sunrise for preparation of the new chat.
    [AnimationDayController sharedInstance];
    
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configAppearance];
    
    [self configNavigationBar];
    
    
   // [self configStatusbarBackground];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if(self.firstLoadSuccessful) {
        [self startReloadingCronImmediately:YES];
    }
    

    //TODO: Delete that.
    if(self.postIndexToReload!=-1)
    {
        //Refresh post cell in the table view with index.
//        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.postIndexToReload inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        
    }
    
    [self sendViewToGAI:NSStringFromClass([self class])];
    [self sendViewToFlurry:NSStringFromClass([self class])];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [self.homeTabbarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor blackColor], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
    
    [AppearanceHelper setUnselectedColourForTabbarItem:self.homeTabbarItem];
    
    //Hide temporary top image view.
    [_topImageView setHidden:YES];
    
    // hide new element visual indicator if needed
    [self hideNewElementsIndicatorView];
    
    //Show navigation bar.
//    [self contract];

    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self stopReloadingCron];
//    [self.navigationController setNavigationBarHidden:NO
//                                             animated:YES];
}

//- (BOOL)prefersStatusBarHidden
//{
//    return NO;
//}

-(void)initialiseObjects
{
    self.postsHeight = [[NSMutableArray alloc] init];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    
    self.users = [[NSMutableArray alloc] init];
    
    
    self.usersImages = [[NSMutableArray alloc] init];
    self.postsImages = [[NSMutableArray alloc] init];
    
    //Create the array and initialise.
    self.shownCells = [[NSMutableArray alloc] init];
    
    self.transitionController = [[TransitionDelegate alloc] init];
    self.transitionViewImageController = [[TransitionDelegateViewImage alloc] init];
    
    self.transitionCategoriesViewController = [[TransitionDelegateViewCategories alloc] init];
    
    //Initialise.
    self.readyToReloadPosts = YES;
    
    // loading related controls
    self.loadingCellStatus = kGLPLoadingCellStatusLoading;
    self.isLoading = NO;
    self.firstLoadSuccessful = NO;
    self.tableViewInScrolling = NO;
    self.insertedNewRowsCount = 0;
    self.shouldLoadNewPostsAfterScrolling = NO;
    self.postsNewRowsCountToInsertAfterScrolling = 0;
    
    self.isReloadingCronRunning = NO;
    self.shouldReloadingCronRun = NO;
    
    self.commentCreated = NO;
    
    self.postIndexToReload = -1;
    
    self.groupsMode = NO;
    
    //Initialize temporary top image view.
    _topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -20.0, 320.0, 20.0)];
    [_topImageView setBackgroundColor:[AppearanceHelper defaultGleepostColour]];
    
    [self.view addSubview:_topImageView];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPPostUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPPostUploaded" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPPostImageUploaded" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPLikedPostUdated" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPShowEvent" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPProfileImageChanged" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POST_DELETED object:nil];

}


#pragma mark - Notifications

/**
 Updates the number of comments. Called only if number of comments changed in profile view controller or in view post view controller.
 
 @param noticiation the post notification coming from profile view controller.
 
 */
-(void)updatePostWithRemoteKey:(NSNotification*)notification
{
    int index = [GLPPostNotificationHelper parseNotification:notification withPostsArray:self.posts];
    
    if([GLPPostNotificationHelper parseNotification:notification withPostsArray:self.posts] != -1)
    {
        //Reload again only this post.
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(void)updatePostRemoteKeyAndImage:(NSNotification*)notification
{
    if(_groupsMode)
    {
        return;
    }
    
    NSDictionary *dict = [notification userInfo];
    
    int key = [(NSNumber*)[dict objectForKey:@"key"] integerValue];
    int remoteKey = [(NSNumber*)[dict objectForKey:@"remoteKey"] integerValue];
    NSString * urlImage = [dict objectForKey:@"imageUrl"];
    
    int index = 0;
    
    GLPPost *uploadedPost = nil;
    
    for(GLPPost* p in self.posts)
    {
        if(key == p.key)
        {
            p.imagesUrls = [[NSArray alloc] initWithObjects:urlImage, nil];
            p.remoteKey = remoteKey;
            uploadedPost = p;
//            p.tempImage = nil;
            break;
        }
        ++index;
    }

    
    if(uploadedPost.author.remoteKey == [SessionManager sharedInstance].user.remoteKey)
    {
        //If the post belongs to logged in user then inform his/her profile's posts.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GLPNewPostByUser" object:nil userInfo:nil];
    }
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];

//    [self.tableView reloadData];
    

}

-(void)updateRealImage:(NSNotification*)notification
{
    
    GLPPost *currentPost = nil;
    int index = -1;
    if(_groupsMode)
    {
        NSArray *posts = [[CampusWallGroupsPostsManager sharedInstance] allPosts];

        index = [GLPPostNotificationHelper parsePost:&currentPost imageNotification:notification withPostsArray:posts];
    }
    else
    {
        index = [GLPPostNotificationHelper parsePost:&currentPost imageNotification:notification withPostsArray:self.posts];
    }
    
    
    if(_groupsMode && [currentPost isGroupPost])
    {
        if(currentPost)
        {
            [self refreshCellViewWithIndex:index];
        }
    }
    else if(!_groupsMode && ![currentPost isGroupPost])
    {
        if(currentPost)
        {
            [self refreshCellViewWithIndex:index];
        }
    }
    
//    if([GLPPostNotificationHelper parsePostImageNotification:notification withPostsArray:self.posts])
//    {
//        [self.tableView reloadData];
//    }

}

-(void)updateLikedPost:(NSNotification*)notification
{
    [GLPPostNotificationHelper parseLikedPostNotification:notification withPostsArray:self.posts];
    [self.tableView reloadData];
}

-(void)refreshPostsWithNewProfileImage:(NSNotification *)notification
{
    NSArray *postsIndexes = [GLPPostNotificationHelper parseNotification:notification withPostsArrayForNewProfileImage:self.posts];
    
    //Update all the user's posts in campus wall.
    
    for(NSNumber *number in postsIndexes)
    {
        [self refreshCellViewWithIndex:number.integerValue];
    }
}

-(void)deletePost:(NSNotification *)notification
{
    int index = -1;
    
    if(_groupsMode)
    {
        
        index = [GLPPostNotificationHelper parseNotificationAndFindIndexWithNotification:notification withPostsArray:[[CampusWallGroupsPostsManager sharedInstance] allPosts].mutableCopy];
        
    }
    else
    {
        index = [GLPPostNotificationHelper parseNotificationAndFindIndexWithNotification:notification withPostsArray:self.posts];
    }
    
    
    if(index != -1)
    {
        [self removeTableViewPostWithIndex:index];
    }
    
}

#pragma mark - Init config

/**
 Starts loading in the background some basic contents of the app like messages, profiles etc.
 */

-(void)startLoadingContents:(id)sender
{
    
    //[[GLPMessagesLoader sharedInstance] loadLiveConversations];
    //[[GLPMessagesLoader sharedInstance] loadConversations];
    [[GLPProfileLoader sharedInstance] loadUserData];

}

-(void)configNavigationBar
{
    
    //Hide for now the navigation bar.
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    UIColor *tabColour = [[GLPThemeManager sharedInstance] colorForTabBar];

//    [self.navigationController.navigationBar setTranslucent:NO];
    
    //Sets colour to navigation items.
    self.navigationController.navigationBar.tintColor = tabColour;
    
    //[AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"chat_background_default" forBarMetrics:UIBarMetricsDefault];

    
    //Set the  colour of navigation bar's title.
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: tabColour, UITextAttributeTextColor,[UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f], UITextAttributeFont, nil]];
    
    [self.navigationController.navigationBar setShadowImage:[ImageFormatterHelper generateOnePixelHeightImageWithColour:[AppearanceHelper colourForNotFocusedItems]]];
    
    
    //Set to all the application the status bar text white.

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

}

- (void)configAppearance
{
    //[AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar2" forBarMetrics:UIBarMetricsDefault];

    //[AppearanceHelper setNavigationBarBlurBackgroundFor:self WithImage:nil];
    
    
    UIColor *tabColour = [[GLPThemeManager sharedInstance] colorForTabBar];

    
    //    [[UINavigationBar appearance] setTitleTextAttributes: @{UITextAttributeFont: [UIFont fontWithName:@"Helvetica Neue" size:20.0f]}];

    
//    self.tabBarController.tabBar.hidden = NO;
    [AppearanceHelper showTabBar:self];
    
    //[[CustomTabBarButtonManager sharedInstance] showItemHidden];
    
    
    //Set colour of the border navigation bar image. TODO: Set one line image.
//    [[UINavigationBar appearance] setShadowImage:[ImageFormatterHelper generateOnePixelHeightImageWithColour:tabColour]];
    


    
    
//    UIColor *tabColour = [UIColor colorWithRed:75.0/255.0 green:208.0/255.0 blue:210.0/255.0 alpha:1.0];
    self.tabBarController.tabBar.tintColor = tabColour;
    

//    NSArray *items = self.tabBarController.tabBar.items;
//    UITabBarItem *i = [items objectAtIndex:0];
//    
//    [self.homeTabbarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: tabColour, UITextAttributeTextColor, nil] forState:UIControlStateHighlighted];
    
    [AppearanceHelper setSelectedColourForTabbarItem:self.homeTabbarItem withColour:tabColour];
    
    
//    [self configTabbarFormat];

    
    [self setCustomBackgroundToTableView];
    
    [self setButtonsToNavigationBar];
    
    //Show temporary top image view.
    [_topImageView setHidden:NO];
}

-(void)setCustomBackgroundToTableView
{
    if([GLPiOS6Helper isIOS6])
    {
        [GLPiOS6Helper setBackgroundImageToTableView:self.tableView];
        
        return;
    }
    
    UIImageView *backImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"campus_wall_background_main"]];
    
    [backImgView setFrame:CGRectMake(0.0f, 0.0f, backImgView.frame.size.width, backImgView.frame.size.height)];
    
    [self.tableView setBackgroundColor:[AppearanceHelper defaultGleepostColour]];
    [self.tableView setBackgroundView:backImgView];
}

-(void)configTabbarFormat
{
    
    if([GLPiOS6Helper isIOS6])
    {
        [GLPiOS6Helper configureTabbarController:self.tabBarController];
        
        NSArray *items = self.tabBarController.tabBar.items;
        
        
        UITabBarItem *item = [items objectAtIndex:0];
                
        item.image = [UIImage imageNamed:@"bird-house-7"];
        
        item.selectedImage = [UIImage imageNamed:@"bird-house-7"];
        
//        item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        
        
        self.homeTabbarItem = item;
        
        
        
        item = [items objectAtIndex:1];
        
        item.image = [UIImage imageNamed:@"message-7"];
        
        item.selectedImage = [UIImage imageNamed:@"message-7"];
        
//        item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        
        
        [AppearanceHelper setUnselectedColourForTabbarItem:item];
        
        
        item = [items objectAtIndex:2];
        
        item.image = [UIImage imageNamed:@"proximity-7"];
        
        item.selectedImage = [UIImage imageNamed:@"proximity-7"];
        
//        item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        
        
        [AppearanceHelper setUnselectedColourForTabbarItem:item];
        
        
        item = [items objectAtIndex:3];
        
        item.image = [UIImage imageNamed:@"man-7"];
        
        item.selectedImage = [UIImage imageNamed:@"man-7"];
        
//        item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        
        [AppearanceHelper setUnselectedColourForTabbarItem:item];
        
        
        item = [items objectAtIndex:4];
        
        item.image = [UIImage imageNamed:@"id-card-7"];
        
        item.selectedImage = [UIImage imageNamed:@"id-card-7"];
        
//        item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        
        
        [AppearanceHelper setUnselectedColourForTabbarItem:item];
        
        return;
    }
    
    // set selected and unselected icons
    NSArray *items = self.tabBarController.tabBar.items;
    
    
    UITabBarItem *item = [items objectAtIndex:0];
    
    item.image = [[UIImage imageNamed:@"bird-house-7"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    item.selectedImage = [UIImage imageNamed:@"bird-house-7"];
    
    item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    
    self.homeTabbarItem = item;
    
    
    
    item = [items objectAtIndex:1];
    
    item.image = [[UIImage imageNamed:@"message-7"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    item.selectedImage = [UIImage imageNamed:@"message-7"];
    
    item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);

    
    [AppearanceHelper setUnselectedColourForTabbarItem:item];
    
    
    item = [items objectAtIndex:2];
    
    item.image = [[UIImage imageNamed:@"proximity-7"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    item.selectedImage = [UIImage imageNamed:@"proximity-7"];
    
    item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);

    
    [AppearanceHelper setUnselectedColourForTabbarItem:item];

    
    item = [items objectAtIndex:3];
    
    item.image = [[UIImage imageNamed:@"man-7"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    item.selectedImage = [UIImage imageNamed:@"man-7"];
    
    item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);

    [AppearanceHelper setUnselectedColourForTabbarItem:item];

    
    item = [items objectAtIndex:4];
    
    item.image = [[UIImage imageNamed:@"id-card-7"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    item.selectedImage = [UIImage imageNamed:@"id-card-7"];
    
    item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);

    
    [AppearanceHelper setUnselectedColourForTabbarItem:item];

   
    
    // this way, the icon gets rendered as it is (thus, it needs to be green in this example)
//    item0.image = [[UIImage imageNamed:@"contacts.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    
//    // this icon is used for selected tab and it will get tinted as defined in self.tabBar.tintColor
//    item0.selectedImage = [UIImage imageNamed:@"contacts.png"];
}

-(void)configNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePostWithRemoteKey:) name:@"GLPPostUpdated" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePostRemoteKeyAndImage:) name:@"GLPPostUploaded" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRealImage:) name:@"GLPPostImageUploaded" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLikedPost:) name:@"GLPLikedPostUdated" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showEventPost:) name:@"GLPShowEvent" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPostsWithNewProfileImage:) name:@"GLPProfileImageChanged" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePost:) name:GLPNOTIFICATION_POST_DELETED object:nil];


}

- (void)configTableView
{
    //Register nib files in table view.
    [self.tableView registerNib:[UINib nibWithNibName:@"PostImageCellView" bundle:nil] forCellReuseIdentifier:@"ImageCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTextCellView" bundle:nil] forCellReuseIdentifier:@"TextCell"];
    
//    [self.tableView registerNib:[UINib nibWithNibName:@"CampusWallHeaderScrollView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"CampusWallHeaderSimple"];

    // refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadEarlierPostsFromPullToRefresh) forControlEvents:UIControlEventValueChanged];
}

-(void)configHeader
{
    //Load the header of the table view.
    
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"CampusWallHeaderScrollView" owner:self options:nil];
    
    //Set delegate.
    self.campusWallHeader = [array objectAtIndex:0];
    [self.campusWallHeader formatElements];
    [self.campusWallHeader setDelegate:self];
    
    self.tableView.tableHeaderView = self.campusWallHeader;
    
    //Add fake navigation bar to view.
    array = [[NSBundle mainBundle] loadNibNamed:@"FakeNavigationBar" owner:self options:nil];
    
    self.reNavBar = [array objectAtIndex:0];
    [self.reNavBar formatElements];
    [self.reNavBar setDelegate:self];
    [self.tableView addSubview:self.reNavBar];
    [self.tableView bringSubviewToFront:self.reNavBar];
    
    [self.reNavBar setHidden:YES];
}

- (void)configNewElementsIndicatorView
{
    self.elementsIndicatorView = [[GLPNewElementsIndicatorView alloc] initWithDelegate:self];
    self.elementsIndicatorView.hidden = YES;
    self.elementsIndicatorView.center = self.navigationController.view.center;
    CGRectSetY(self.elementsIndicatorView, 80); //TODO: something better than arbitrary value
    
    [self.navigationController.view addSubview:self.elementsIndicatorView];
}


#pragma mark - Navigation bar

-(void) setButtonsToNavigationBar
{
    //UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"+"]];
    //imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, 32.0, 32.0);
    
    
//    UIButton *btnBack=[UIButton buttonWithType:UIButtonTypeContactAdd];
//    [btnBack addTarget:self action:@selector(newPostButtonClick) forControlEvents:UIControlEventTouchUpInside];
//    [btnBack setTintColor:[[GLPThemeManager sharedInstance] colorForTabBar]];
//    
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btnBack];


    UIBarButtonItem *tagsButton = [[UIBarButtonItem alloc] initWithTitle:@"Tags" style:UIBarButtonItemStyleBordered target:self action:@selector(showCategories:)];
    
    
    
    UIBarButtonItem *i = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newPostButtonClick)];
    [i setTintColor:[[GLPThemeManager sharedInstance] colorForTabBar]];
    
    self.navigationItem.leftBarButtonItem = tagsButton;
    self.navigationItem.rightBarButtonItem = i;
}

-(void)setNavigationBarName
{
    [self.navigationItem setTitle:@"Campus Wall"];
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

#pragma mark - Conversations

//- (void)loadConversations
//{
//    [ConversationManager loadConversationsWithLocalCallback:^(NSArray *conversations) {
//
//    } remoteCallback:^(BOOL success, NSArray *conversations) {
//      
//    }];
//}

#pragma mark - Table view refresh methods

-(void)refreshCellViewWithIndex:(const NSUInteger)index
{
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

#pragma mark - Posts

- (void)loadInitialPosts
{
    if(self.isLoading) {
        return;
    }
    
    [self startLoading];
    
    [GLPPostManager loadInitialPostsWithLocalCallback:^(NSArray *localPosts) {
        // show temp local results
        self.posts = [localPosts mutableCopy];
        
        //[[GLPPostImageLoader sharedInstance] addPostsImages:self.posts];
        
        [self.tableView reloadData];
        
    } remoteCallback:^(BOOL success, BOOL remain, NSArray *remotePosts) {
        if(success) {
            self.posts = [remotePosts mutableCopy];
            
            [[GLPPostImageLoader sharedInstance] addPostsImages:self.posts];

            self.loadingCellStatus = (remain) ? kGLPLoadingCellStatusInit : kGLPLoadingCellStatusFinished;
            [self.tableView reloadData];
            
            self.firstLoadSuccessful = YES;
            [self startReloadingCronImmediately:NO];
            
            
            //If there are less than 5 posts then add the white footer.
//            if(remotePosts.count < 5)
//            {
//                [self setBottomView];
//            }
//            else
//            {
//                [self clearBottomView];
//            }
            
        } else {
            self.loadingCellStatus = kGLPLoadingCellStatusError;
            [self.tableView reloadData];
        }
        
        [self stopLoading];
    }];
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
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
}

- (void)loadEarlierPostsFromPullToRefresh
{
    
    //Added to support groups' feed.
    
    if(_groupsMode)
    {
//        [self loadEarlierGroupsPostsAndSaveScrollingState:NO];
        
        [self loadEarlierGroupsPostsAndSaveScrollingState:NO];
    }
    else
    {
        [self loadEarlierPostsAndSaveScrollingState:NO];
    }
}

- (void)loadEarlierPostsFromCron
{
    //Added to support groups' feed.
    
    if(_groupsMode)
    {
//        [self loadEarlierGroupsPostsAndSaveScrollingState:YES];
        [self loadInitialGroupsPosts];

    }
    else
    {
        [self loadEarlierPostsAndSaveScrollingState:YES];
    }
    
}

- (void)loadEarlierPostsAndSaveScrollingState:(BOOL)saveScrollingState
{
    if(self.isLoading) {
        return;
    }
    
    // take the last remote post
    GLPPost *remotePost = nil;
    
    NSMutableArray *notUploadedPosts = [[NSMutableArray alloc] init];
    
    if(self.posts.count > 0) {
        // first is the most recent
        for(GLPPost *p in self.posts) {
            
            if(p.remoteKey == 0)
            {
                [notUploadedPosts addObject:p];
            }
            
            if(p.remoteKey != 0) {
                remotePost = p;
                break;
            }
        }
    }
    
    [self startLoading];
    
    [GLPPostManager loadRemotePostsBefore:remotePost withNotUploadedPosts:notUploadedPosts andCurrentPosts:self.posts callback:^(BOOL success, BOOL remain, NSArray *posts) {
        [self stopLoading];
        
        if(!success) {
            [self showLoadingError:@"Failed to load new posts"];
            return;
        }
        
        if(posts.count > 0) {
            [self.posts insertObjects:posts atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, posts.count)]];
            
            //New methodology of loading images.
            [[GLPPostImageLoader sharedInstance] addPostsImages:posts];

            
            // update table view and keep the scrolling state
            if(saveScrollingState) {
                // delay the update if user is in scrolling state
                // Not need because we use performselector which areis deprioritized during scrolling
//                if(self.tableViewInScrolling) {
//                    self.shouldLoadNewPostsAfterScrolling = YES;
//                    self.postsNewRowsCountToInsertAfterScrolling += posts.count; // add new posts count to possibly non 0 count, if scrolling is still enabled after two reloads for instance
//                } else {
//                    [self updateTableViewWithNewPosts:posts.count];
//                }
                
                // do not care about the user is in scrolling state, see commented code below
                [self updateTableViewWithNewPosts:posts.count];
                
                // save the new rows count in order to know when (at what scroll position) to hide the new elements indicator
                self.insertedNewRowsCount += posts.count;
            }
            
            // or scroll to the top
            else {
                [self updateTableViewWithNewPostsAndScrollToTop:posts.count];
            }
        }
    }];
}

- (void)loadPreviousPosts
{
    if(self.isLoading) {
        return;
    }
    
    if(self.posts.count == 0) {
        self.loadingCellStatus = kGLPLoadingCellStatusFinished;
        return;
    }
    
    if(self.loadingCellStatus == kGLPLoadingCellStatusLoading) {
        return;
    }
    
    [self startLoading];
    self.loadingCellStatus = kGLPLoadingCellStatusLoading;
    
    [GLPPostManager loadPreviousPostsAfter:[self.posts lastObject] callback:^(BOOL success, BOOL remain, NSArray *posts) {
        [self stopLoading];
        
        if(!success) {
            self.loadingCellStatus = kGLPLoadingCellStatusError;
            [self reloadLoadingCell];
            return;
        }
        
        self.loadingCellStatus = remain ? kGLPLoadingCellStatusInit : kGLPLoadingCellStatusFinished;
        
        if(posts.count > 0) {
            int firstInsertRow = self.posts.count;
            
            [[GLPPostImageLoader sharedInstance] addPostsImages:posts];

            [self.posts insertObjects:posts atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.posts.count, posts.count)]];
            
            NSMutableArray *rowsInsertIndexPath = [[NSMutableArray alloc] init];
            for(int i = firstInsertRow; i < self.posts.count; i++) {
                [rowsInsertIndexPath addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            
            // update table view with showing new rows and updating the loading row
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:firstInsertRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView insertRowsAtIndexPaths:rowsInsertIndexPath withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView endUpdates];
            
        } else {
            [self reloadLoadingCell];
        }
    }];
}

- (void)reloadNewLocalPosts
{
    if(self.isLoading) {
        return;
    }
    
    self.isLoading = YES;
    
    // get the last post if exists
    GLPPost *post = (self.posts.count > 0) ? self.posts[0] : nil;
    
    [GLPPostManager loadLocalPostsBefore:post callback:^(NSArray *posts) {
        if(!posts || posts.count == 0) {
            return;
        }
        
        [self.posts insertObjects:posts atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, posts.count)]];
        
        [self updateTableViewWithNewPostsAndScrollToTop:posts.count];
        
        self.isLoading = NO;
    }];
    
}


#pragma mark - Groups' Posts

- (void)loadInitialGroupsPosts
{
    if(self.isLoading) {
        return;
    }
    
    [self startLoading];
    
//    if(![[CampusWallGroupsPostsManager sharedInstance] arePostsEmpty])
//    {
//        DDLogDebug(@"Post are not empty.");
//        
//        [self.tableView reloadData];
//    }
    
    [self.tableView reloadData];

    
    
    [GLPGroupManager loadGroupsFeedWithCallback:^(BOOL success, NSArray *posts) {
       
        
        if(!success)
        {
            [WebClientHelper showInternetConnectionErrorWithTitle:@"Failed to load groups feed posts"];
            [self stopLoading];
            return;
        }
        
        [[CampusWallGroupsPostsManager sharedInstance] setPosts:posts.mutableCopy];
        
//        self.posts = posts.mutableCopy;
        
        [[GLPPostImageLoader sharedInstance] addPostsImages:[[CampusWallGroupsPostsManager sharedInstance] allPosts]];
        
        [self.tableView reloadData];
        
        self.firstLoadSuccessful = YES;
//        [self startReloadingCronImmediately:NO];

        
        [self stopLoading];

        
    }];
    
    
//    [GLPGroupManager loadInitialPostsWithGroupId:[SessionManager sharedInstance].user.networkId remoteCallback:^(BOOL success, BOOL remain, NSArray *remotePosts) {
//       
//        if(success)
//        {
//            [[CampusWallGroupsPostsManager sharedInstance] setPosts:remotePosts.mutableCopy];
//            
//            self.posts = remotePosts.mutableCopy;
//            
//            [[GLPPostImageLoader sharedInstance] addPostsImages:self.posts];
//
//            [self.tableView reloadData];
//            
//            self.firstLoadSuccessful = YES;
//            [self startReloadingCronImmediately:NO];
//        }
//        
//        [self stopLoading];
//    }];
}

-(void)loadEarlierGroupsPostsAndSaveScrollingState:(BOOL)scrollingState
{
    if(self.isLoading) {
        return;
    }
    
//    // take the last remote post
//    GLPPost *remotePost = nil;
//    
//    NSMutableArray *notUploadedPosts = [[NSMutableArray alloc] init];
//    
//    if(self.posts.count > 0) {
//        // first is the most recent
//        for(GLPPost *p in self.posts) {
//            
//            if(p.remoteKey == 0)
//            {
//                [notUploadedPosts addObject:p];
//            }
//            
//            if(p.remoteKey != 0) {
//                remotePost = p;
//                break;
//            }
//        }
//    }
    
    [self startLoading];
    
    
    
    [GLPGroupManager loadGroupsFeedWithCallback:^(BOOL success, NSArray *posts) {
        
        if(!success)
        {
            [WebClientHelper showInternetConnectionErrorWithTitle:@"Failed to load groups feed posts"];
            [self stopLoading];
            return;
        }
        
        NSArray *recentPosts = [[CampusWallGroupsPostsManager sharedInstance] addNewPosts:posts.mutableCopy];
        
        //        self.posts = posts.mutableCopy;
        
        
        DDLogDebug(@"Recent posts: %d", recentPosts.count);

        [[GLPPostImageLoader sharedInstance] addPostsImages:recentPosts];

        if(recentPosts.count > 0)
        {
            [self updateTableViewWithNewPosts:recentPosts.count];
        }
        
        
        self.firstLoadSuccessful = YES;
        //        [self startReloadingCronImmediately:NO];
        
        
        [self stopLoading];
        
//        [self updateTableViewWithNewPostsAndScrollToTop:[[CampusWallGroupsPostsManager sharedInstance] numberOfPosts]];

        
        
    }];
    
    //TODO change that when it will be supported from server.
    
//    [GLPPostManager loadRemotePostsBefore:remotePost withNotUploadedPosts:notUploadedPosts andCurrentPosts:self.posts callback:^(BOOL success, BOOL remain, NSArray *posts) {
//        [self stopLoading];
//        
//        if(!success) {
//            [self showLoadingError:@"Failed to load new posts"];
//            return;
//        }
//        
//        if(posts.count > 0) {
//            [self.posts insertObjects:posts atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, posts.count)]];
//            
//            //New methodology of loading images.
//            [[GLPPostImageLoader sharedInstance] addPostsImages:posts];
//            
//            
//            // update table view and keep the scrolling state
//            if(scrollingState) {
//                // delay the update if user is in scrolling state
//                // Not need because we use performselector which areis deprioritized during scrolling
//                //                if(self.tableViewInScrolling) {
//                //                    self.shouldLoadNewPostsAfterScrolling = YES;
//                //                    self.postsNewRowsCountToInsertAfterScrolling += posts.count; // add new posts count to possibly non 0 count, if scrolling is still enabled after two reloads for instance
//                //                } else {
//                //                    [self updateTableViewWithNewPosts:posts.count];
//                //                }
//                
//                // do not care about the user is in scrolling state, see commented code below
//                [self updateTableViewWithNewPosts:posts.count];
//                
//                // save the new rows count in order to know when (at what scroll position) to hide the new elements indicator
//                self.insertedNewRowsCount += posts.count;
//            }
//            
//            // or scroll to the top
//            else {
//                [self updateTableViewWithNewPostsAndScrollToTop:posts.count];
//            }
//        }
//    }];
}

-(void)reloadNewImagePostWithPost:(GLPPost*)inPost
{
    DDLogDebug(@"Is loading: %d", self.isLoading);
    
    //TODO: REMOVED! IT'S IMPORTANT!
    
//    if(self.isLoading) {
//        return;
//    }
    
    self.isLoading = YES;
    
//    GLPPost *post = (self.posts.count > 0) ? self.posts[0] : nil;
    
    NSArray *posts = [[NSArray alloc] initWithObjects:inPost, nil];
    
    [self.posts insertObjects:posts atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, posts.count)]];
    
    [self updateTableViewWithNewPostsAndScrollToTop:posts.count];
    
    
    self.isLoading = NO;
    
    //Bring the fake navigation bar to from because is hidden by new cell.
//    [self.tableView bringSubviewToFront:self.reNavBar];

}

-(void)postLike:(BOOL)like withPostRemoteKey:(int)postRemoteKey
{
    [[WebClient sharedInstance] postLike:like forPostRemoteKey:postRemoteKey callbackBlock:^(BOOL success) {
        
        if(success)
        {
            NSLog(@"Timeline Like for post %d succeed.",postRemoteKey);
        }
        else
        {
            NSLog(@"Timeline for post %d not succeed.",postRemoteKey);
        }
        
        
    }];
}


#pragma mark - Request management

- (void)startReloadingCronImmediately:(BOOL)immediately
{
    if(self.isReloadingCronRunning) {
        NSLog(@"Reloading cron already running");
        return;
    }
    
    NSLog(@"Start reloading cron, immediately: %d", immediately);
    
    self.isReloadingCronRunning = YES;
    self.shouldReloadingCronRun = YES;
    
    [self executeReloadingCron:[NSNumber numberWithBool:immediately]];
}

- (void)stopReloadingCron
{
//    // try to stop it if it runs
//    self.shouldReloadingCronRun = NO;
    
    // or cancel performSelector:afterDelay: call
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(executeReloadingCron:) object:[NSNumber numberWithBool:YES]];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(executeReloadingCron:) object:[NSNumber numberWithBool:NO]];
    
    self.isReloadingCronRunning = NO;
    
    NSLog(@"Stop reloading cron");
}

- (void)executeReloadingCron:(id)immediatelyObject
{
    NSLog(@"Execute reloading cron, immediately: %@", immediatelyObject);
    
    BOOL immediately = [immediatelyObject boolValue];
    
    // sometimes we may want to pass one time interval because reloading
    // when we start the reloading cron after a successful initial loading for instance
    if(immediately) {
        [self loadEarlierPostsAndSaveScrollingState:YES];
    }
    
    [self performSelector:@selector(executeReloadingCron:) withObject:[NSNumber numberWithBool:YES] afterDelay:RELOAD_POSTS_INTERVAL_S];
}

- (void)startLoading
{
    self.isLoading = YES;
    
    [self.refreshControl beginRefreshing];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)stopLoading
{
    self.isLoading = NO;
    
    [self.refreshControl endRefreshing];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)showLoadingError:(NSString *)message
{
    [TSMessage showNotificationInViewController:self title:@"Loading failed" subtitle:message type:TSMessageNotificationTypeError];
}


#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.startContentOffset = self.lastContentOffset = scrollView.contentOffset.y;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat differenceFromStart = self.startContentOffset - currentOffset;
    CGFloat differenceFromLast =  self.lastContentOffset - currentOffset;
    self.lastContentOffset = currentOffset;
    
    
    [self.reNavBar setFrame:CGRectMake(0.0f, scrollView.contentOffset.y, 320.0f, 50.0f)];
    
    
//    [self.campusWallHeader setPositionToNavBar:CGPointMake(0.0f, scrollView.contentOffset.y)];
    
    if(scrollView.contentOffset.y >= TOP_OFFSET)
    {
        //[self contract];
    
        [UIView animateWithDuration:0.1f animations:^{
            
            [self.reNavBar setAlpha:1.0f];
            
            //Bring reNavBar to front to avoid problems of hiding the view.
            [self.tableView bringSubviewToFront:self.reNavBar];

            
        } completion:^(BOOL finished) {
            
            [self.reNavBar setHidden:NO];

        }];
        
        //[self.campusWallHeader showFakeNavigationBar];
            
    }
    else
    {
        //[self expand];
        
        [UIView animateWithDuration:0.1f animations:^{
            
            [self.reNavBar setAlpha:0.0f];
            
        } completion:^(BOOL finished) {
            
            [self.reNavBar setHidden:YES];

        }];
        
        
       // [self.campusWallHeader hideFakeNavigationBar];

    }

    
    if(scrollView.contentOffset.y >= 180.0f)
    {
        if ([scrollView.panGestureRecognizer translationInView:scrollView].y > 0)
        {
//            DDLogDebug(@"down");

            
        } else
        {
//            DDLogDebug(@"up");
        }
        
    }
    else
    {
    }
    
    if((differenceFromStart) < 0)
    {
        // scroll up
        if(scrollView.isTracking && (abs(differenceFromLast)>1))
        {
            
        }
            //[self expand];
    }
    else {
        if(scrollView.isTracking && (abs(differenceFromLast)>1))
        {
            
        }
            //[self contract];
    }
    
}


- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    //[self contract];
    return YES;
}

#pragma mark - Hidden navigation bar

-(void)expand
{
    if(self.hidden)
    {
        return;
    }
    
    self.hidden = YES;

    
    [self.navigationController setNavigationBarHidden:YES
                                             animated:NO];
}

-(void)contract
{
    if(!self.hidden)
    {
        return;
    }
    
    self.hidden = NO;
    
//    [self.tabBarController setTabBarHidden:NO
//                                  animated:YES];
    
    
    [self.navigationController setNavigationBarHidden:NO
                                             animated:NO];
}



-(void)hideNavigationbarElements
{
    [self.navigationController.navigationBar setBackgroundColor: [UIColor clearColor]];
}

-(void)showNavigationbarElements
{
    [self configAppearance];
}

#pragma mark - Table view


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_groupsMode)
    {
        return [[CampusWallGroupsPostsManager sharedInstance] numberOfPosts];
    }
    else
    {
        return self.posts.count + 1;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //For group posts we want to disable the loading previous posts.
    if(!_groupsMode)
    {
        if(indexPath.row == self.posts.count) {
            GLPLoadingCell *loadingCell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell" forIndexPath:indexPath];
            [loadingCell updateWithStatus:self.loadingCellStatus];
            return loadingCell;
        }
    }

    
    static NSString *CellIdentifierWithImage = @"ImageCell";
    static NSString *CellIdentifierWithoutImage = @"TextCell";
//    static NSString *CellIdentifierHeader = @"CampusWallHeader";
    
    //Header cell.
//    CampusWallHeader *campusWallHeader;
    
    PostCell *postCell;

//    if(indexPath.row == 0)
//    {
//        campusWallHeader = [tableView dequeueReusableCellWithIdentifier:CellIdentifierHeader forIndexPath:indexPath];
//        
//        return campusWallHeader;
//    }
//    else
//    {

//    }
    
    //    GLPUser *user = self.users[indexPath.row];

    
    GLPPost *post = [self currentPostWithIndexPath:indexPath];
    
//    if(_groupsMode)
//    {
//        post = [[CampusWallGroupsPostsManager sharedInstance] postAtIndex:indexPath.row];
//    }
//    else
//    {
//        post = self.posts[indexPath.row];
//    }
    
    
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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigateToProfile:)];
    [tap setNumberOfTapsRequired:1];
    [postCell.userImageView addGestureRecognizer:tap];
    
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFullPostImage:)];
    [tap setNumberOfTapsRequired:1];
    [postCell.postImage addGestureRecognizer:tap];
    
    postCell.delegate = self;
    
    [postCell updateWithPostData:post withPostIndex:indexPath.row];
    
    [self.tableView bringSubviewToFront:self.reNavBar];
    
    
    return postCell;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //TODO: implement manual reloading
    if(indexPath.row == self.posts.count) {
        return;
    }
    
    
    self.selectedPost = [self currentPostWithIndexPath:indexPath];
    
//    if(_groupsMode)
//    {
//        self.selectedPost = [[CampusWallGroupsPostsManager sharedInstance] postAtIndex:indexPath.row];
//    }
//    else
//    {
//        self.selectedPost = self.posts[indexPath.row];
//    }
    
    self.selectedIndex = indexPath.row;
    self.postIndexToReload = indexPath.row;
    self.commentCreated = NO;
    [self performSegueWithIdentifier:@"view post" sender:self];
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == self.posts.count) {
        return (self.loadingCellStatus != kGLPLoadingCellStatusFinished) ? kGLPLoadingCellHeight : 0;
    }
    
    //float height = [[self.postsHeight objectAtIndex:indexPath.row] floatValue];
    
    //static float imageSize = 300;
    //static float lowerPostLimit = 115;
    //static float fixedLimitHeight = 70;
    
    
//    if(indexPath.row == 0)
//    {
//        return 200;
//    }
//    else
//    {
//        GLPPost *currentPost = [self.posts objectAtIndex:indexPath.row];
    GLPPost *currentPost = [self currentPostWithIndexPath:indexPath];
    
    if([currentPost imagePost])
    {
        //NSLog(@"heightForRowAtIndexPath With Image %f and text: %@",[PostCell getCellHeightWithContent:currentPost.content image:YES], currentPost.content);

        return [PostCell getCellHeightWithContent:currentPost image:YES isViewPost:NO];
    }
    else
    {
        //NSLog(@"heightForRowAtIndexPath Without Image %f and text: %@",[PostCell getCellHeightWithContent:currentPost.content image:NO], currentPost.content);
        
        return [PostCell getCellHeightWithContent:currentPost image:NO isViewPost:NO];
    }
    

//    }

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // hide the new elements indicator if needed when we are on top
    if(!self.elementsIndicatorView.hidden && (indexPath.row == 0 || indexPath.row < self.insertedNewRowsCount)) {
        NSLog(@"HIDE %d - %d", indexPath.row, self.insertedNewRowsCount);
        
        self.insertedNewRowsCount = 0; // reset the count
        [self hideNewElementsIndicatorView];
    }
    
    if(!_groupsMode)
    {
        if(indexPath.row == self.posts.count && self.loadingCellStatus == kGLPLoadingCellStatusInit) {
            NSLog(@"Load previous posts cell activated");
            [self loadPreviousPosts];
        }
    }
    

}



#pragma mark - Table view manager methods

/**
 
 Gives the current post depending on the mode.
 
 @param indexPath.
 
 @return the current post.
 
 */
-(GLPPost *)currentPostWithIndexPath:(NSIndexPath *)indexPath
{
    if(_groupsMode)
    {
        return [[CampusWallGroupsPostsManager sharedInstance] postAtIndex:indexPath.row];
    }
    else
    {
        return [self.posts objectAtIndex:indexPath.row];
    }
    
}

-(void) updateTableWithNewRowCount:(int)rowCount
{
    CGPoint tableViewOffset = [self.tableView contentOffset];
    
    [UIView setAnimationsEnabled:NO];
    
    NSMutableArray *rowsInsertIndexPath = [[NSMutableArray alloc] init];
    
    int heightForNewRows = 0;
    
    for (NSInteger i = 0; i < rowCount; i++) {
        NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [rowsInsertIndexPath addObject:tempIndexPath];
        
        heightForNewRows = heightForNewRows + [self tableView:self.tableView heightForRowAtIndexPath:tempIndexPath];
    }
    
    tableViewOffset.y += heightForNewRows;
    
    [self.tableView reloadData];
    [self.tableView setContentOffset:tableViewOffset animated:NO];
    
    [UIView setAnimationsEnabled:YES];
}

- (void)reloadLoadingCell
{
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.posts.count inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)scrollToTheTop
{
    // we never know, that would be a stupid crash
    if(self.posts.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

-(void)scrollToTheNavigationBar
{
    
    [UIView animateWithDuration:0.5f animations:^{
        
        [self.tableView setContentOffset:CGPointMake(0,TOP_OFFSET)];
        
        
    } completion:^(BOOL finished) {
        
        
    }];
    
}


- (void)updateTableViewWithNewPostsAndScrollToTop:(int)count
{
    NSMutableArray *rowsInsertIndexPath = [[NSMutableArray alloc] init];
    for(int i = 0; i < count; i++) {
        [rowsInsertIndexPath addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    //The condition is added to prevent error when there are no posts in the table view.
    
    if(self.posts.count == 1 || !self.posts)
    {
        [self.tableView reloadData];
    }
    else
    {
        [self.tableView insertRowsAtIndexPaths:rowsInsertIndexPath withRowAnimation:UITableViewRowAnimationFade];
    }
    
    
    
    //    [self scrollToTheTop];
    [self scrollToTheNavigationBar];
    
    //Bring the fake navigation bar to from because is hidden by new cell.
    //    [self.tableView bringSubviewToFront:self.reNavBar];
}

- (void)updateTableViewWithNewPosts:(int)count
{
    CGPoint tableViewOffset = [self.tableView contentOffset];
    [UIView setAnimationsEnabled:NO];
    
    int heightForNewRows = 0;
    NSMutableArray *rowsInsertIndexPath = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < count; i++) {
        NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [rowsInsertIndexPath addObject:tempIndexPath];
        
        heightForNewRows = heightForNewRows + [self tableView:self.tableView heightForRowAtIndexPath:tempIndexPath];
    }
    
    tableViewOffset.y += heightForNewRows;
    
    [self.tableView setContentOffset:tableViewOffset animated:NO];
    [self.tableView insertRowsAtIndexPaths:rowsInsertIndexPath withRowAnimation:UITableViewRowAnimationFade];
    
    [UIView setAnimationsEnabled:YES];
    
    // display the new elements indicator if we are not on top
    NSIndexPath *firstVisibleIndexPath = [[self.tableView indexPathsForVisibleRows] objectAtIndex:0];
    if(firstVisibleIndexPath.row != 0) {
        [self showNewElementsIndicatorView];
    }
}


-(void)removeTableViewPostWithIndex:(int)index
{
    NSMutableArray *rowsDeleteIndexPath = [[NSMutableArray alloc] init];
    
    [rowsDeleteIndexPath addObject:[NSIndexPath indexPathForRow:index inSection:0]];

    [self.tableView deleteRowsAtIndexPaths:rowsDeleteIndexPath withRowAnimation:UITableViewRowAnimationRight];
}

#pragma mark - RemovePostCellDelegate

-(void)removePostWithPost:(GLPPost *)post
{
//    int index;
    
    self.isLoading = YES;
    
    [GLPPostNotificationHelper deletePostNotificationWithPostRemoteKey:post.remoteKey];
    
    self.isLoading = NO;

    
//    for(index = 0; index < self.posts.count; ++index)
//    {
//        GLPPost *p = [self.posts objectAtIndex:index];
//        
//        if(p.remoteKey == post.remoteKey)
//        {
//            [self.posts removeObject:p];
//            
//            [self removeTableViewPostWithIndex:index];
//            
//
//            return;
//        }
//    }
    
}



#pragma mark - Change category

-(void)refreshPostsWithNewCategory
{
    if(_groupsMode)
    {
        [self loadGroupsFeed];
    }
    else
    {
        [self loadInitialPosts];
    }
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
    [self setButtonsToNavigationBar];
    
    [self configAppearance];
}

-(void)setPreviousNavigationBarName
{
    [self.navigationItem setTitle:@"Campus Wall"];
}

-(void)hideNavigationBarAndButtonWithNewTitle:(NSString*)newTitle
{
    [self.navigationItem setTitle:newTitle];
    self.navigationItem.rightBarButtonItem = nil;
}

-(void)navigateToViewPostFromCommentWithIndex:(int)postIndex
{
    self.selectedPost = self.posts[postIndex];
    self.postIndexToReload = postIndex;
   
    ++self.selectedPost.commentsCount;

    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:postIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    self.commentCreated = YES;
    
    //Notify GLPProfileViewController about changes.
    [GLPPostNotificationHelper updatePostWithNotifiationName:@"GLPPostUpdated" withObject:self remoteKey:self.selectedPost.remoteKey numberOfLikes:self.selectedPost.likes andNumberOfComments:self.selectedPost.commentsCount];
    
    [self performSegueWithIdentifier:@"view post" sender:self];
}


// Not need because we use performselector which areis deprioritized during scrolling

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    self.tableViewInScrolling = YES;
//}
//
//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
//{
//    self.tableViewInScrolling = NO;
//    
//    // rows waiting to be inserted
//    if(self.shouldLoadNewPostsAfterScrolling) {
//        [self updateTableViewWithNewPosts:self.postsNewRowsCountToInsertAfterScrolling];
//        
//        // reset the control values
//        self.shouldLoadNewPostsAfterScrolling = NO;
//        self.postsNewRowsCountToInsertAfterScrolling = 0;
//    }
//}


#pragma mark - GLPNewElementsIndicatorView

- (void)showNewElementsIndicatorView
{
    if(!self.elementsIndicatorView.hidden) {
        return;
    }
    
    self.elementsIndicatorView.alpha = 0;
    self.elementsIndicatorView.hidden = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.elementsIndicatorView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideNewElementsIndicatorView
{
    if(self.elementsIndicatorView.hidden) {
        return;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.elementsIndicatorView.alpha = 0;
    } completion:^(BOOL finished) {
        self.elementsIndicatorView.hidden = YES;
    }];
}

// from GLPNewElementsIndicatorViewDelegate
- (void)newElementsIndicatorViewPushed
{
    [self hideNewElementsIndicatorView];
    
    [self scrollToTheTop];
}



#pragma mark - Other stuff

//-(void)showFullPostImage:(id)sender
//{
//    
//    UITapGestureRecognizer *incomingImage = (UITapGestureRecognizer*) sender;
//    
//    UIImageView *clickedImageView = (UIImageView*)incomingImage.view;
//    
//    
//    self.imageToBeView = clickedImageView.image;
//    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
//    ViewPostImageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ViewPostImage"];
//    vc.image = clickedImageView.image;
//    vc.view.backgroundColor = self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.67];
//    vc.modalPresentationStyle= UIModalPresentationCustom;
//
//    [vc setTransitioningDelegate:self.transitionViewImageController];
//    
//    [self.view setBackgroundColor:[UIColor whiteColor]];
//    [self presentViewController:vc animated:YES completion:nil];
//    
//}



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
    
    //Decide where to navigate. Private or open profile.
    
    self.selectedUserId = incomingView.tag;
    
    if((self.selectedUserId == [[SessionManager sharedInstance]user].remoteKey))
    {
        self.selectedUserId = -1;
        
        //Navigate to profile view controller.
        
        [self performSegueWithIdentifier:@"view profile" sender:self];
    }
    else if([[ContactsManager sharedInstance] navigateToUnlockedProfileWithSelectedUserId:self.selectedUserId])
    {
        //Navigate to private profile view controller.
        
        [self performSegueWithIdentifier:@"view new private profile" sender:self];
    }
    else
    {
        //Navigate to private view controller.
        
        [self performSegueWithIdentifier:@"view new private profile" sender:self];
    }
    
}

/**
 If YES navigate to real profile, if no to private profile.
 */
//-(BOOL)navigateToUnlockedProfile
//{
//    //Check if the user is already in contacts.
//    //If yes show the regular profie view (unlocked).
//    if([[ContactsManager sharedInstance] isUserContactWithId:self.selectedUserId])
//    {
//        NSLog(@"PrivateProfileViewController : Unlock Profile.");
//        
//        return YES;
//    }
//    else
//    {
//        //If no, check in database if the user is already requested.
//        
//        //If yes change the button of add user to user already requested.
//        
//        if([[ContactsManager sharedInstance] isContactWithIdRequested:self.selectedUserId])
//        {
//            NSLog(@"PrivateProfileViewController : User already requested by you.");
//            //            UIImage *img = [UIImage imageNamed:@"invitesent"];
//            //            [self.addUserButton setImage:img forState:UIControlStateNormal];
//            //            [self.addUserButton setEnabled:NO];
//            //
//            //For now just navigate to the unlocked profile.
//            
//            return YES;
//            
//        }
//        else
//        {
//            //If not show the private profile view as is.
//            NSLog(@"PrivateProfileViewController : Private profile as is.");
//            
//            return NO;
//        }
//    }
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
    loadingView.postIndex = btn.tag;
    //loadingView.delegate = self;
    
}

//-(void)navigateToViewPostFromCommentWithIndex:(int)postIndex
//{
//    self.selectedPost = self.posts[postIndex];
//    [self performSegueWithIdentifier:@"view post" sender:self];
//}

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
    
    
    
    
    
    if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
    {
        //If iOS7
        
        //Hide navigation items and add NewPostViewController's items.
        [self hideNavigationBarAndButtonWithNewTitle:@"New Post"];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
        NewPostViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"NewPostViewController"];
        vc.view.backgroundColor =  self.view.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
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

-(void)loadGroupsFeed
{
    _groupsMode = YES;
    [self updateTitleView];
    [self loadInitialGroupsPosts];
}

-(void)loadRegularPosts
{
    _groupsMode = NO;
    
    [self updateTitleView];

    
    [self loadInitialPosts];
}

-(void)showCategories:(id)sender
{
//    [self scrollToTheTop];
    
    
    if([self.reNavBar isHidden])
    {
        [self scrollToTheNavigationBar];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    GLPCategoriesViewController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"Categories"];

    /**
     Takes screenshot from the current view controller to bring the sense of the transparency after the load
     of the NewPostViewController.
     */
    UIGraphicsBeginImageContext(self.view.window.bounds.size);
    [self.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    cvc.view.backgroundColor = self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    cvc.modalPresentationStyle = UIModalPresentationCustom;
    cvc.delegate = self;
//    [cvc.view setBackgroundColor:[UIColor colorWithPatternImage:[image stackBlur:10.0f]]];
    
    image = [ImageFormatterHelper cropImage:image withRect:CGRectMake(0, 63, 320, 302)];
    
    [cvc.blurBack setImage:[image stackBlur:10.0f]];
    
    [cvc setTransitioningDelegate:self.transitionCategoriesViewController];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self presentViewController:cvc animated:YES completion:nil];
    
}

-(void)showEventPost:(NSNotification*)notification
{
    NSDictionary *dict = [notification userInfo];
    GLPPost *post = [dict objectForKey:@"Post"];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    ViewPostViewController *vpvc = [storyboard instantiateViewControllerWithIdentifier:@"ViewPostViewController"];
    vpvc.post = post;
    vpvc.isFromCampusLive = YES;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vpvc];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}

-(void)updateTitleView
{
    if(_groupsMode)
    {
        [self.reNavBar groupFeedEnabled];
        [self.campusWallHeader groupFeedEnabled];
    }
    else
    {
        [self.reNavBar groupFeedDisabled];
        [self.campusWallHeader groupFeedDisabled];

    }
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
        
//        self.postIndexToReload = 
        
        vc.commentJustCreated = self.commentCreated;
        vc.isFromCampusLive = NO;
        vc.post = self.selectedPost;
//        vc.selectedIndex = self.selectedIndex;
        
        
        //self.selectedPost = nil;
        
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
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
        PrivateProfileViewController *privateProfileViewController = segue.destinationViewController;
        
        privateProfileViewController.selectedUserId = self.selectedUserId;
    }
    else if([segue.identifier isEqualToString:@"view new private profile"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
        GLPPrivateProfileViewController *privateProfileViewController = segue.destinationViewController;
        
        privateProfileViewController.selectedUserId = self.selectedUserId;

    }
    else if([segue.identifier isEqualToString:@"show image"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
        ViewPostImageViewController *viewPostImageViewController = segue.destinationViewController;
        
        viewPostImageViewController.image = self.imageToBeView;
        
        
    }
    else if([segue.identifier isEqualToString:@"view profile"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
//        GLPUser *incomingUser = [[GLPUser alloc] init];
//        
//        incomingUser.remoteKey = self.selectedUserId;
//        
//        if(self.selectedUserId == -1)
//        {
//            incomingUser = nil;
//        }
//        
//        profileViewController.incomingUser = incomingUser;
    }
    
}

@end
