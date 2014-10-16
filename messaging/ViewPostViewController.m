//
//  ViewPostViewController.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ViewPostViewController.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "MBProgressHUD.h"
#import "GLPComment.h"
#import "KeyboardHelper.h"
#import "NSString+Utils.h"
#import "GLPPrivateProfileViewController.h"
#import "ProfileViewController.h"
#import "SessionManager.h"
#import "UIViewController+GAI.h"
#import "ContactsManager.h"
#import "UIViewController+Flurry.h"
#import "GLPPostNotificationHelper.h"
#import "ViewPostImageViewController.h"
#import "TransitionDelegateViewImage.h"
#import "AppearanceHelper.h"
#import "GLPCommentUploader.h"
#import "GLPCommentManager.h"
#import "GLPPostManager.h"
#import "GLPApplicationHelper.h"
#import "UINavigationBar+Format.h"
#import "UINavigationBar+Utils.h"
#import "UIView+GLPDesign.h"
#import "ShapeFormatterHelper.h"
#import "UIColor+GLPAdditions.h"
#import "GLPShowLocationViewController.h"
#import "GLPViewImageViewController.h"
#import "GLPiOSSupportHelper.h"
#import "GLPCategory.h"
#import "TDPopUpAfterGoingView.h"
#import "GLPPopUpDialogViewController.h"
#import "GLPCalendarManager.h"
#import "GLPShowUsersViewController.h"

@interface ViewPostViewController () <GLPPopUpDialogViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray *comments;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (assign, nonatomic) float keyboardAppearanceSpaceY;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet HPGrowingTextView *commentGrowingTextView;
@property (strong, nonatomic) IBOutlet UIView *commentFormView;

@property (strong, nonatomic) TransitionDelegateViewImage *transitionViewImageController;

@property (strong, nonatomic) GLPLocation *selectedLocation;

@property (strong, nonatomic) TDPopUpAfterGoingView *transitionViewPopUpAttend;

@end

static BOOL likePushed;

@implementation ViewPostViewController

@synthesize post=_post;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initialiseElements];
    
    [self configureNavigationBar];
    
    [self registerCells];
    
    [self configureForm];
    
    [self fillPostWithKey];
    
    [self selfLoadPost];
    
   // [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
    
    if(self.commentJustCreated)
    {
       //Scroll to the bottom only when new comment posted.
        [self scrollToTheEndAnimated:YES];
    }
    else if(self.commentNotificationDate)
    {
        int commentIndex = [self findIndexOfComment];
        
        //Scroll to a particular comment if it is appropriate.
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:commentIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
    }

    [self showCommentIfNeeded];
    

//    [self registerNotifications];
    
    [self sendStatistics];
    
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);


   // [self loadComments];


}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self registerNotifications];

    
    [self hideNetworkErrorViewIfNeeded];
    
    if(![self comesFromNotifications])
    {
        [self loadComments];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self  name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_GOING_BUTTON_TOUCHED object:nil];
    
    self.commentJustCreated = NO;
    
    if([GLPApplicationHelper isTheNextViewCampusWall:self.navigationController.viewControllers])
    {
//        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    

    [super viewWillDisappear:animated];
}

- (void)hideNetworkErrorViewIfNeeded
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_HIDE_ERROR_VIEW object:self userInfo:nil];
}

-(void)sendStatistics
{
    [self sendViewToGAI:NSStringFromClass([self class])];
    [self sendViewToFlurry:NSStringFromClass([self class])];
    
    [self sendView:NSStringFromClass([self class]) withId:self.post.remoteKey];
}

- (void)showCommentIfNeeded
{
    if(_showComment)
    {
//        [self scrollToTheEndAnimated:YES];
        [_commentGrowingTextView becomeFirstResponder];
    }
}


-(int)findIndexOfComment
{
    int index = 0;
    
    for(GLPComment *comment in self.comments)
    {
        if([comment.date compare:self.commentNotificationDate] == NSOrderedSame)
        {
            break;
        }
        
        ++index;
    }
    
    return index;
}

-(void)fillPostWithKey
{
    if(self.post.key == 0)
    {
        [GLPPostManager setFakeKeyToPost:self.post];
    }
}

#pragma mark - Init and config

-(void)initialiseElements
{
    self.transitionViewImageController = [[TransitionDelegateViewImage alloc] init];
    self.transitionViewPopUpAttend = [[TDPopUpAfterGoingView alloc] init];
    
    self.keyboardAppearanceSpaceY = 0;
    
    //To hide empty cells
    self.tableView.tableFooterView = [UIView new];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    self.comments = [[NSMutableArray alloc] init];
    
    _selectedLocation = nil;

}

-(void)registerCells
{
    //Register nib files in table view.
    [self.tableView registerNib:[UINib nibWithNibName:@"PostImageCell" bundle:nil] forCellReuseIdentifier:@"ImageCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTextCellView" bundle:nil] forCellReuseIdentifier:@"TextCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostVideoCell" bundle:nil] forCellReuseIdentifier:@"VideoCell"];

    
    //Register nib files in table view.
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentTextCellView" bundle:nil] forCellReuseIdentifier:@"CommentTextCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentTitleCellView" bundle:nil] forCellReuseIdentifier:@"CommentTitleCellView"];
}

-(void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goingButtonTouchedWithNotification:) name:GLPNOTIFICATION_GOING_BUTTON_TOUCHED object:nil];
}

- (void)configureForm
{
    //self.commentFormView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"typing_bar"]];
    
    self.commentGrowingTextView.isScrollable = NO;
    self.commentGrowingTextView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
	self.commentGrowingTextView.minNumberOfLines = 1;
	self.commentGrowingTextView.maxNumberOfLines = 4;
	self.commentGrowingTextView.returnKeyType = UIReturnKeyDefault;
	self.commentGrowingTextView.font = [UIFont systemFontOfSize:15.0f];
	self.commentGrowingTextView.delegate = self;
    self.commentGrowingTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    self.commentGrowingTextView.backgroundColor = [UIColor whiteColor];
    self.commentGrowingTextView.placeholder = @"Write a comment...";
    
    // center vertically because textview height varies from ios version to screen
    CGRect formTextViewFrame = self.commentGrowingTextView.frame;
    formTextViewFrame.origin.y = (self.commentFormView.frame.size.height - self.commentGrowingTextView.frame.size.height) / 2;
    self.commentGrowingTextView.frame = formTextViewFrame;
    
    self.commentGrowingTextView.layer.cornerRadius = 4;
    
    [ShapeFormatterHelper setBorderToView:self.commentGrowingTextView withColour:[UIColor colorWithR:240.0 withG:240.0 andB:240.0] andWidth:1.0];
    
    [self.commentFormView setGleepostStyleTopBorder];
    
    //Set a selector to the send button.
//    [self.tableView.typeTextView.postButton addTarget:self action:@selector(addCommentButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)configureNavigationBar
{
    self.navigationItem.title = @"VIEW POST";
    
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES andView:self.view];

    [self.navigationController.navigationBar setFontFormatWithColour:kBlack];
    
    if(_post.eventTitle)
    {
        [self.navigationController.navigationBar setButton:kRight withImageName:@"pad_icon" withButtonSize:CGSizeMake(25.0, 25.0) withSelector:@selector(showAttendees) andTarget:self];
    }
    
    

    if(self.isFromCampusLive)
    {
        [self addCustomBackButton];
    }
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

-(void)addCustomBackButton
{
    UIImage *img = [UIImage imageNamed:@"cancel"];
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:img forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(0, 0, 19, 21)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
    //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];
}

-(void)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


/**
 If post comes from notifications post is loaded in this method.
 */
- (void)selfLoadPost
{
    if([self comesFromNotifications])
    {
        //Load the post.
        
        self.title = @"Loading...";
        
        DDLogDebug(@"Post remote key: %ld", (unsigned long)_post.remoteKey);
        
        [GLPPostManager loadPostWithRemoteKey:_post.remoteKey callback:^(BOOL success, GLPPost *post) {
            
            self.title = @"VIEW POST";
            
            if(success)
            {
                _post = post;
                
                _post = [GLPPostManager setFakeKeyToPost:_post];
                
                DDLogDebug(@"SELECTED POST: %ld", (long)_post.key);
                
                [self loadComments];
                
                [self.tableView reloadData];
            }
            else
            {
                //[WebClientHelper showStandardError];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Post may not exist anymore." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                
                [alertView show];
                
//                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }];
    }
}

#pragma mark - Social panel button methods

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
//-(UIButton*) buttonWithName: (NSString*)buttonName andSubviews: (NSArray*)subArray withCell: (PostCell*) cell andPostIndex:(int)postIndex
//{
//    for(UIView* view in subArray)
//    {
//        if([view isKindOfClass:[UIButton class]])
//        {
//            UIButton *currentBtn = (UIButton*)view;
//            currentBtn.userInteractionEnabled = YES;
//            if([currentBtn.titleLabel.text isEqualToString:@"Like"])
//            {
//                currentBtn.tag = postIndex;
//                
//                [currentBtn addTarget:self action:@selector(likeButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
//                
//            }
//            else
//            {
//                [currentBtn addTarget:self action:@selector(navigateToProfile:) forControlEvents:UIControlEventTouchUpInside];
//            }
//        }
//    }
//    
//    
//    return nil;
//}

#pragma mark - GLPPostCellDelegate

-(void)elementTouchedWithRemoteKey:(NSInteger)remoteKey
{
    
    [self navigateToProfileWithRemoteKey:remoteKey];
//    self.selectedUserId = remoteKey;
//    
//    if([[ContactsManager sharedInstance] userRelationshipWithId:self.selectedUserId] == kCurrentUser)
//    {
//        self.selectedUserId = -1;
//        
//        [self performSegueWithIdentifier:@"view profile" sender:self];
//    }
//    else
//    {
//        [self performSegueWithIdentifier:@"view private profile" sender:self];
//    }
}

- (void)showLocationWithLocation:(GLPLocation *)location
{
    _selectedLocation = location;
    
    [self performSegueWithIdentifier:@"show location" sender:self];
}

- (void)goingButtonTouchedWithNotification:(NSNotification *)notification
{
    DDLogDebug(@"goingButtonTouchedWithNotification");
    
    
    UIImage *postImage = notification.userInfo[@"image"];
    
    //Show the pop up view.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    GLPPopUpDialogViewController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"GLPPopUpDialogViewController"];
    
    [cvc setDelegate:self];
    [cvc setTopImage:postImage];
    
    cvc.modalPresentationStyle = UIModalPresentationCustom;
    
    [cvc setTransitioningDelegate:self.transitionViewPopUpAttend];
    
    [self presentViewController:cvc animated:YES completion:nil];
  
}

#pragma mark - GLPPopUpDialogViewControllerDelegate

- (void)showAttendees
{
    [self performSegueWithIdentifier:@"show attendees" sender:self];
}

- (void)addEventToCalendar
{
    [[GLPCalendarManager sharedInstance] addEventPostToCalendar:_post withCallback:^(CalendarEventStatus resultStatus) {
        
        switch (resultStatus) {
            case kSuccess:
                
                dispatch_async (dispatch_get_main_queue(), ^{
                    [WebClientHelper showEventSuccessfullyAddedToCalendar];
                });
                
                break;
                
            case kPermissionsError:
                
                dispatch_async (dispatch_get_main_queue(), ^{
                    [WebClientHelper showErrorPermissionsToCalendar];
                });
                break;
                
            case kOtherError:
                
                dispatch_async (dispatch_get_main_queue(), ^{
                    [WebClientHelper showErrorSavingEventToCalendar];
                });
                break;
                
            default:
                break;
        }
        
    }];
    
}

#pragma mark - GLPImageViewDelegate

- (void)imageTouchedWithImageView:(UIImageView *)imageView
{
    NSInteger userRemoteKey = imageView.tag;
    
    [self navigateToProfileWithRemoteKey:userRemoteKey];
    
//    if([[ContactsManager sharedInstance] userRelationshipWithId:userRemoteKey] == kCurrentUser)
//    {
//        _selectedUserId = -1;
//        
//        [self performSegueWithIdentifier:@"view profile" sender:self];
//    }
//    else
//    {
//        _selectedUserId = userRemoteKey;
//        
//        [self performSegueWithIdentifier:@"view private profile" sender:self];
//    }
}

- (void)labelTouchedWithTag:(NSInteger)tag
{
    DDLogDebug(@"User remote key from label: %ld", (long)tag);
    
    [self navigateToProfileWithRemoteKey:tag];
    
//    if([[ContactsManager sharedInstance] userRelationshipWithId:userRemoteKey] == kCurrentUser)
//    {
//        _selectedUserId = -1;
//        
//        [self performSegueWithIdentifier:@"view profile" sender:self];
//    }
//    else
//    {
//        _selectedUserId = userRemoteKey;
//        
//        [self performSegueWithIdentifier:@"view private profile" sender:self];
//    }
}

- (IBAction)addCommentButtonClick:(id)sender
{
//    if([self.commentGrowingTextView isFirstResponder])
//    {
//        [self.commentGrowingTextView resignFirstResponder];
//    }
    
    //Post the comment.
    [self postComment];
    
    if([self.commentGrowingTextView.text isEmpty])
    {
        return;
    }
    
    
    [self hideKeyboardFromTextViewIfNeeded];
}


#pragma mark - Other methods

static bool firstTime = YES;


-(BOOL)isPostEvent
{
    NSArray *categories = self.post.categories;
        
    if(categories)
    {
        for(GLPCategory *c in categories)
        {
            if([c.tag isEqualToString:@"event"])
            {
                return YES;
            }
        }
    }
    else
    {
        return NO;
    }
    
    return NO;
    
}


-(void)viewPostImage:(UIImage*)postImage
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    GLPViewImageViewController *viewImage = [storyboard instantiateViewControllerWithIdentifier:@"GLPViewImageViewController"];
    viewImage.image = postImage;
    viewImage.view.backgroundColor = self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.89];
    viewImage.modalPresentationStyle = UIModalPresentationCustom;
    
    if(![GLPiOSSupportHelper isIOS6])
    {
        [viewImage setTransitioningDelegate:self.transitionViewImageController];
    }
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self presentViewController:viewImage animated:YES completion:nil];
}


-(void) setBackgroundToNavigationBar
{
    if(firstTime)
    {
        NSLog(@"First time.");
        UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.f, -20.f, 320.f, 65.f)];
        
        
        
        [bar setBackgroundColor:[UIColor clearColor]];
        [bar setBackgroundImage:[UIImage imageNamed:@"navigationbar_4"] forBarMetrics:UIBarMetricsDefault];
        [bar setTranslucent:YES];
//        UIBarButtonItem *showDetailViewControllerBBI = [[UIBarButtonItem alloc] initWithTitle:@"Show Details" style:UIBarButtonItemStyleBordered target:self action:@selector(switchToCarouselLayout:)];
//        self.parentViewController.navigationItem.rightBarButtonItem = showDetailViewControllerBBI;
        
        //UIBarButtonItem *backBtn =
        
        //Change the format of the navigation bar.
        [self.navigationController.navigationBar setTranslucent:YES];
        
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar_4"] forBarMetrics:UIBarMetricsDefault];
        
        //[self.navigationController.navigationBar insertSubview:bar atIndex:0];
        
        
        NSArray *arrayView = [self.navigationController.navigationBar subviews];
        
        //[self.navigationController.navigationBar insertSubview:bar aboveSubview: [arrayView objectAtIndex:0]];
        firstTime = NO;
        
        NSLog(@"Views: %@", arrayView);
    }
}


/**
 Fetches the post's user from the server and set to the corresponding cell its contents.
 
 @param post the corresponding post.
 @param postCell the instance of the cell.
 
 */
//-(void) userWithPost:(GLPPost*) post andPostCell:(PostCell*)postCell
//{
//    [[WebClient sharedInstance] getUserWithKey:self.post.author.remoteKey callbackBlock:^(BOOL success, GLPUser *user) {
//        
//        if(success)
//        {
//            NSLog(@"User Image URL: %@",user.profileImageUrl);
//            [postCell updateWithPostData:self.post andUserData:user];
//            
//            //[self.users addObject:user];
//        }
//        else
//        {
//            NSLog(@"Not Success: %d",success);
//            [postCell updateWithPostData:self.post andUserData:nil];
//            
//        }
//        
//        
//    }];
//}

-(void)loadComments
{
    if(self.post.remoteKey == 0)
    {
        //Load comments from operation manager.
        [self loadLocalComments];
    }
    else
    {
        [self loadCommentsWithScrollToTheEnd:NO];
    }
}

/**
 Load local comments stored in the database.
 This method is called only when the post is not yet uploaded.
 */
-(void)loadLocalComments
{
    NSAssert(self.post.key != 0, @"Post needs to have post key.");
    
    DDLogInfo(@"Loading local comments from comment uploader.");
    
    GLPCommentUploader *uploader = [[GLPCommentUploader alloc] init];
    
    self.comments = [uploader pendingCommentsWithPostKey:self.post.key].mutableCopy;
    
    [self viewCommentsWithScroll:NO];
}

- (void)loadCommentsWithScrollToTheEnd:(BOOL)scroll
{
    //[WebClientHelper showStandardLoaderWithTitle:@"Loading posts" forView:self.view];
    
    DDLogInfo(@"Loading comments from database and from server.");

    
    [GLPCommentManager loadCommentsWithLocalCallback:^(NSArray *comments) {
        
        self.comments = [comments mutableCopy];
        
        [self viewCommentsWithScroll:scroll];
        
        
    } remoteCallback:^(BOOL success, NSArray *comments) {
        
        
        self.comments = [comments mutableCopy];
        
        [self viewCommentsWithScroll:scroll];
        
        
    } withPost:self.post];
    
    
    
//    [[WebClient sharedInstance] getCommentsForPost:self.post withCallbackBlock:^(BOOL success, NSArray *comments) {
//        //[WebClientHelper hideStandardLoaderForView:self.view];
//        
//        if(success) {
//            self.comments = [comments mutableCopy];
//            
//
//            DDLogDebug(@"Comments loaded successfully.");
//            //Reverse the comments' order.
//            NSArray *reversedComments = [[self.comments reverseObjectEnumerator] allObjects];
//            
//            self.comments = reversedComments.mutableCopy;
//   
//            [self.tableView reloadData];
//            
//            
//            if(scroll)
//            {
//                [self scrollToTheEndAnimated:YES];
//            }
//
//        } else {
//            [WebClientHelper showStandardError];
//        }
//    }];
    
    //Create an array consisting of height of each corresponding comment.
    
}

-(void)viewCommentsWithScroll:(BOOL)scroll
{
    
    //Reverse the comments' order.
    NSArray *reversedComments = [[self.comments reverseObjectEnumerator] allObjects];
    
    self.comments = reversedComments.mutableCopy;
    
    [self.tableView reloadData];
    
    
    if(scroll)
    {
        [self scrollToTheEndAnimated:YES];
    }
}

//TODO: Call this only when there is a need to pass data to the segue.

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    NSLog(@"Modal View Controller");
//    //Hide tabbar.
//    
//    if([segue.identifier isEqualToString:@"view post"])
//    {
//        
//        ViewPostViewController *vc = segue.destinationViewController;
//        /**
//         Forward data of the post the to the view. Or in future just forward the post id
//         in order to fetch it from the server.
//         */
//        
//        vc.post = self.selectedPost;
//        
//        self.selectedPost = nil;
//    }
//}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Add 1 in order to create another cell for post.
    return self.comments.count+2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifierWithImage = @"ImageCell";
    static NSString *CellIdentifierWithoutImage = @"TextCell";
    static NSString *CellIdentifierVideo = @"VideoCell";
    static NSString *CellIdentifierComment = @"CommentTextCell";
    static NSString *CellIdentifierTitle = @"CommentTitleCellView";
    
    GLPPostCell *postViewCell;
    
    CommentCell *cell;
    
    if(indexPath.row == 0)
    {
        if([_post imagePost])
        {
            //If image.
            postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithImage forIndexPath:indexPath];
//            [postViewCell postFromNotifications:_isViewPostNotifications];
            [postViewCell reloadMedia:[self comesFromNotifications] || [self isFromCampusLive]];
        }
        else if ([_post isVideoPost])
        {
            postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierVideo forIndexPath:indexPath];
//            [postViewCell reloadMedia:self.mediaNeedsToReload];
        }
        else
        {
            //If text.
            postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithoutImage forIndexPath:indexPath];
        }
        
        postViewCell.delegate = self;
        
        //Add touch gestures to like and share buttons.
//        [self buttonWithName:@"Like" andSubviews:[postViewCell.socialPanel subviews] withCell:postViewCell andPostIndex:indexPath.row];
//        
//        [self buttonWithName:@"Comment" andSubviews:[postViewCell.socialPanel subviews] withCell:postViewCell andPostIndex:indexPath.row];
//        [self buttonWithName:@"" andSubviews:[postViewCell.socialPanel subviews] withCell:postViewCell andPostIndex:indexPath.row];
        
        
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigateToProfile:)];
//        [tap setNumberOfTapsRequired:1];
//        [postViewCell.userImageView addGestureRecognizer:tap];
        
        
        [postViewCell setIsViewPost:YES];
        [postViewCell setPost:_post withPostIndex:indexPath.row];
        
        
        return postViewCell;

    }
    else if (indexPath.row == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierTitle forIndexPath:indexPath];
        
        return cell;
    }
    else
    {
        //TODO: Fix cell by removing the dynamic data generation.
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierComment forIndexPath:indexPath];
        
        [cell setDelegate:self];
        
        GLPComment *comment = self.comments[indexPath.row - 2];
        
        [cell setComment:comment withIndex:indexPath.row - 2 andNumberOfComments:_comments.count];
        
        return cell;
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //float height = [[self.commentsHeight objectAtIndex:indexPath.row] floatValue];
    
    if(indexPath.row == 0)
    {
        if([self.post imagePost])
        {
            return [GLPPostCell getCellHeightWithContent:self.post cellType:kImageCell isViewPost:YES] + 10.0f;
            
//            return 650;
        }
        else if([self.post isVideoPost])
        {
            return [GLPPostCell getCellHeightWithContent:self.post cellType:kVideoCell isViewPost:YES] + 10.0f;
        }
        else
        {
             return [GLPPostCell getCellHeightWithContent:self.post cellType:kTextCell isViewPost:YES] + 10.0f;
        }
        //return 200;
    }
    else if (indexPath.row == 1)
    {
        return 30.0;
    }
    else
    {
        GLPComment *comment = [self.comments objectAtIndex:indexPath.row-2];
        
        return [CommentCell getCellHeightWithContent:comment.content image:NO];
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


#pragma mark - RemovePostCellDelegate

-(void)removePostWithPost:(GLPPost *)post
{
    if(_groupController)
    {
        [_groupController removePostWithPost:post];
    }
    else
    {
        [GLPPostNotificationHelper deletePostNotificationWithPostRemoteKey:post.remoteKey inCampusLive:NO];
    }
    
    if(self.isFromCampusLive)
    {
        [self dismissViewControllerAnimated:YES completion:^{
            
            //Inform Campus Wall that the campus live status changed.
            //i.e. refresh campus live.
            [GLPPostNotificationHelper deletePostNotificationWithPostRemoteKey:post.remoteKey inCampusLive:YES];
            
        }];
    }
    else
    {
        // Pop-up view controller.
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Form management

- (void)keyboardWillShow:(NSNotification *)note{
    
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curve.intValue;
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = self.commentFormView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
	CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.height = containerFrame.origin.y - self.tableView.frame.origin.y;
    
    [UIView animateWithDuration:[duration doubleValue] delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|(animationCurve << 16)) animations:^{
        self.commentFormView.frame = containerFrame;
        self.tableView.frame = tableViewFrame;
        
        [self scrollToTheEndAnimated:NO];
        
    } completion:^(BOOL finished) {
        [self.tableView setNeedsLayout];
    }];
}

- (void)keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curve.intValue;
	
	// get a rect for the textView frame
	CGRect containerFrame = self.commentFormView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
	CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.height = containerFrame.origin.y - self.tableView.frame.origin.y;
    
    [UIView animateWithDuration:[duration doubleValue] delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|(animationCurve << 16)) animations:^{
        self.commentFormView.frame = containerFrame;
        self.tableView.frame = tableViewFrame;
        
    } completion:^(BOOL finished) {
        [self.tableView setNeedsLayout];
    }];
}

- (void)hideKeyboardFromTextViewIfNeeded
{
    if([self.commentGrowingTextView isFirstResponder]) {
        [self.commentGrowingTextView resignFirstResponder];
    }
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = self.commentFormView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	self.commentFormView.frame = r;
    
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.height += diff;
    self.tableView.frame = tableViewFrame;

    DDLogDebug(@"growingTextView: %f", height);
    
    
    [self scrollToTheEndAnimated:NO];
}



- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
    if(self.comments.count == 0)
    {
        CGPoint origin = growingTextView.frame.origin;
        CGPoint point = [growingTextView.superview convertPoint:origin toView:self.tableView];
        float navBarHeight = self.navigationController.navigationBar.frame.size.height;
        CGPoint offset = self.tableView.contentOffset;
        // Adjust the below value as you need
        offset.y += (point.y - navBarHeight);
        
        DDLogDebug(@"growingTextViewDidBeginEditing: %@", growingTextView);
        
        [self.tableView setContentOffset:offset animated:NO];
    }
}




#pragma mark - Keyboard methods

//- (void)hideKeyboardFromTextViewIfNeeded
//{
////    if(self.commentTextField.isFirstResponder) {
////        [self.commentTextField resignFirstResponder];
////    }
////    
//    
//    if(self.commentGrowingTextView.isFirstResponder)
//    {
//        [self.commentGrowingTextView resignFirstResponder];
//    }
//    
//    if(self.tableView.typeTextView.footerTextView.isFirstResponder)
//    {
//        [self.tableView.typeTextView.footerTextView resignFirstResponder];
//        
//        //Clear footer text view.
//        self.tableView.typeTextView.footerTextView.text = @"Add comment...";
//    }
//}

//- (void)keyboardWillShow:(NSNotification *)notification
//{
//    if(self.keyboardAppearanceSpaceY != 0) {
//        return;
//    }
//    
////    float height = [KeyboardHelper keyboardHeight:notification] - 49;
//    float height = [KeyboardHelper keyboardHeight:notification];
//
//    self.keyboardAppearanceSpaceY = height;
//    
//    [self animateViewWithVerticalMovement:-self.keyboardAppearanceSpaceY duration:[KeyboardHelper keyboardAnimationDuration:notification] andAnimationOptions:[KeyboardHelper keyboardAnimationOptions:notification]];
//}

//- (void)keyboardWillHide:(NSNotification *)notification
//{
//    [self animateViewWithVerticalMovement:fabs(self.keyboardAppearanceSpaceY) duration:[KeyboardHelper keyboardAnimationDuration:notification] andAnimationOptions:[KeyboardHelper keyboardAnimationOptions:notification]];
//    self.keyboardAppearanceSpaceY = 0;
//}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self hideKeyboardFromTextViewIfNeeded];
}


- (void) animateViewWithVerticalMovement:(float)movement duration:(float)duration andAnimationOptions:(UIViewAnimationOptions)animationOptions
{
    [UIView animateWithDuration:duration delay:0 options:(UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveLinear) animations:^{
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)tableViewClicked:(id)sender
{
    NSLog(@"Table View Touched");
    [self hideKeyboardFromTextViewIfNeeded];
}


//#pragma mark - Text view delegate
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [textField resignFirstResponder];
//    
//    if(![self.commentTextField.text isEmpty]) {
//        [self postComment];
//    }
//    
//    return YES;
//}

- (void)postComment
{
    
    if([self isCommmentEmpty])
    {
        return;
    }
    
    GLPCommentUploader *commentUploader = [[GLPCommentUploader alloc] init];
    
    GLPComment *comment = [commentUploader uploadCommentWithContent:self.commentGrowingTextView.text andPost:self.post];
    
    [self reloadNewComment:comment];
    
    [self clearCommentFieldAndUpdatePostWithNewComment];

    
//    [[WebClient sharedInstance] createComment:comment callbackBlock:^(BOOL success) {
//        
//        if(success) {
//            
//            //Increase the number of comments to the post.
//            ++self.post.commentsCount;
//            
////            [self loadCommentsWithScrollToTheEnd:YES];
//            self.commentGrowingTextView.text = @"";
//
//            //Notify timeline view controller.
//            [GLPPostNotificationHelper updatePostWithNotifiationName:@"GLPPostUpdated" withObject:self remoteKey:self.post.remoteKey numberOfLikes:self.post.likes andNumberOfComments:self.post.commentsCount];
//
//        } else {
//            [WebClientHelper showStandardError];
//        }
//    }];
}

-(void)clearCommentFieldAndUpdatePostWithNewComment
{
    //Increase the number of comments to the post.
    ++self.post.commentsCount;
    
    self.commentGrowingTextView.text = @"";
    
    //Notify timeline view controller.
    [GLPPostNotificationHelper updatePostWithNotifiationName:@"GLPPostUpdated" withObject:self remoteKey:self.post.remoteKey numberOfLikes:self.post.likes andNumberOfComments:self.post.commentsCount];
}

-(BOOL)isCommmentEmpty
{
    if(self.commentGrowingTextView.text.length == 0)
    {
        [WebClientHelper showEmptyTextError];
        
        return YES;
    }
    
    return NO;
}

#pragma mark - UI methods

-(void)reloadNewComment:(GLPComment *)comment
{
    
    //    GLPPost *post = (self.posts.count > 0) ? self.posts[0] : nil;
    
    NSArray *comments = [[NSArray alloc] initWithObjects:comment, nil];
    
    
    [self.comments insertObjects:comments atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.comments.count, comments.count)]];
    
    
//    [self.comments addObject:comment];
    
//    DDLogDebug(@"Local comments: %@ Global comments: %@", comments, self.comments);
    
    [self scrollToBottomAndUpdateTableViewWithNewComments:comments.count];
    

}

- (void)scrollToBottomAndUpdateTableViewWithNewComments:(int)count
{
    
    
    NSMutableArray *rowsInsertIndexPath = [[NSMutableArray alloc] init];
        
    
    for(int i = self.comments.count; i < self.comments.count+count; i++)
    {
        [rowsInsertIndexPath addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    

    
    //The condition is added to prevent error when there are no posts in the table view.
    
//    if(self.posts.count == 1 || !self.posts)
//    {
//        [self.tableView reloadData];
//    }
//    else
//    {
//        [self.tableView insertRowsAtIndexPaths:rowsInsertIndexPath withRowAnimation:UITableViewRowAnimationFade];
//    }
    
    [self.tableView reloadData];
    
    [self scrollToTheEndAnimated:YES];
    

    
    //Bring the fake navigation bar to from because is hidden by new cell.
    //    [self.tableView bringSubviewToFront:self.reNavBar];
}

- (void)scrollToTheEndAnimated:(BOOL)animated
{
    if(self.comments.count > 0)
    {
    
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.comments.count + 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
    else
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

#pragma mark - Navigation

- (void)navigateToProfileWithRemoteKey:(NSInteger)remoteKey
{
    if([[ContactsManager sharedInstance] userRelationshipWithId:remoteKey] == kCurrentUser)
    {
        _selectedUserId = -1;
        
        [self performSegueWithIdentifier:@"view profile" sender:self];
    }
    else
    {
        _selectedUserId = remoteKey;
        
        [self performSegueWithIdentifier:@"view private profile" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"view private profile"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:NO];
        
        GLPPrivateProfileViewController *privateProfileViewController = segue.destinationViewController;
        
        privateProfileViewController.selectedUserId = self.selectedUserId;
    }
    else if([segue.identifier isEqualToString:@"view profile"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
//        ProfileViewController *profileViewController = segue.destinationViewController;
//        
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
    else if ([segue.identifier isEqualToString:@"show location"])
    {
        GLPShowLocationViewController *showLocationVC = segue.destinationViewController;
        
        showLocationVC.location = _selectedLocation;
    }
    else if ([segue.identifier isEqualToString:@"show attendees"])
    {
        GLPShowUsersViewController *showUsersVC = segue.destinationViewController;
        
        showUsersVC.postRemoteKey = _post.remoteKey;
        
        showUsersVC.selectedTitle = @"GUEST LIST";
    }
}


@end
