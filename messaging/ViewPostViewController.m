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
#import "CommentCell.h"
#import "NSString+Utils.h"
#import "ViewPostTableView.h"
#import "PostCell.h"
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

@interface ViewPostViewController ()

@property (strong, nonatomic) NSMutableArray *comments;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (assign, nonatomic) float keyboardAppearanceSpaceY;

@property (weak, nonatomic) IBOutlet ViewPostTableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet HPGrowingTextView *commentGrowingTextView;
@property (strong, nonatomic) IBOutlet UIView *commentFormView;

@property (strong, nonatomic) TransitionDelegateViewImage *transitionViewImageController;



- (IBAction)addCommentButtonClick:(id)sender;

- (IBAction)tableViewClicked:(id)sender;

@end


static BOOL likePushed;
@implementation ViewPostViewController

@synthesize post=_post;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Change the format of the navigation bar.
    //[self.navigationController.navigationBar setTranslucent:YES];
    
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar_4"] forBarMetrics:UIBarMetricsDefault];
    
    self.navigationItem.title = @"View Post";

    //Register cells.
    
    //Register nib files in table view.
    [self.tableView registerNib:[UINib nibWithNibName:@"PostImageCellView" bundle:nil] forCellReuseIdentifier:@"ImageCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTextCellView" bundle:nil] forCellReuseIdentifier:@"TextCell"];
    
    
    //Register nib files in table view.
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentTextCellView" bundle:nil] forCellReuseIdentifier:@"CommentTextCell"];
    
    
    //To hide empty cells
    self.tableView.tableFooterView = [UIView new];

    
//    [self.tableView registerNib:[UINib nibWithNibName:@"PostTextCellView" bundle:nil] forCellReuseIdentifier:@"TextCell"];
    
    
    //Set image despite title.
//    UIImage *image = [UIImage imageNamed:@"gleepost"];
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    

    
//    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    //self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [self.tableView initTableView];


    
    //Initialise elements.

    
    //Set a selector to the send button.
//    [currentBtn addTarget:self action:@selector(likeButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView.typeTextView.postButton addTarget:self action:@selector(addCommentButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.keyboardAppearanceSpaceY = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    self.contentLabel.text = self.post.content;
    [self.contentLabel sizeToFit];
    
    [self configureForm];
    
    
    
    self.transitionViewImageController = [[TransitionDelegateViewImage alloc] init];
    
    
    //[self initialiseCommentsHeightArray];
    

    
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
    
   // [self loadComments];

    [self sendViewToGAI:NSStringFromClass([self class])];
    [self sendViewToFlurry:NSStringFromClass([self class])];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureNavigationBar];
    
    
    [self loadComments];

}

-(void)viewWillDisappear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self  name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    self.commentJustCreated = NO;

    [super viewWillDisappear:animated];


}





#pragma mark - Init and config
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
    self.commentGrowingTextView.placeholder = @"Your comment";
    
    // center vertically because textview height varies from ios version to screen
    CGRect formTextViewFrame = self.commentGrowingTextView.frame;
    formTextViewFrame.origin.y = (self.commentFormView.frame.size.height - self.commentGrowingTextView.frame.size.height) / 2;
    self.commentGrowingTextView.frame = formTextViewFrame;
    
    self.commentGrowingTextView.layer.cornerRadius = 5;
    
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

//TODO: Implement this in post cell.
-(void)navigateToProfile: (id)sender
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
    else if([[ContactsManager sharedInstance] navigateToUnlockedProfileWithSelectedUserId:self.selectedUserId])
    {
        //Navigate to profile view controller.
        
        [self performSegueWithIdentifier:@"view private profile" sender:self];
    }
    else
    {
        //Navigate to private view controller.
        
        [self performSegueWithIdentifier:@"view private profile" sender:self];
    }
    
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

- (void)loadComments
{
    //[WebClientHelper showStandardLoaderWithTitle:@"Loading posts" forView:self.view];
    
    
    [[WebClient sharedInstance] getCommentsForPost:self.post withCallbackBlock:^(BOOL success, NSArray *comments) {
        //[WebClientHelper hideStandardLoaderForView:self.view];
        
        if(success) {
            self.comments = [comments mutableCopy];
            

            
            //Reverse the comments' order.
            NSArray *reversedComments = [[self.comments reverseObjectEnumerator] allObjects];
            
            self.comments = reversedComments.mutableCopy;
   
            [self.tableView reloadData];
        } else {
            [WebClientHelper showStandardError];
        }
    }];
    
    //Create an array consisting of height of each corresponding comment.
    
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
    NSLog(@"Number of comments: %d", self.comments.count);
    return self.comments.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifierWithImage = @"ImageCell";
    static NSString *CellIdentifierWithoutImage = @"TextCell";
    static NSString *CellIdentifierComment = @"CommentTextCell";
    
    PostCell *postViewCell;
    
    CommentCell *cell;
    
    if(indexPath.row == 0)
    {
        if(_post.imagesUrls.count>0)
        {
            //If image.
            postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithImage forIndexPath:indexPath];
            [postViewCell postFromNotifications:YES];
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
        
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigateToProfile:)];
        [tap setNumberOfTapsRequired:1];
        [postViewCell.userImageView addGestureRecognizer:tap];
        
        
        postViewCell.isViewPost = YES;
        [postViewCell updateWithPostData:_post withPostIndex:indexPath.row];
        
    
        
        return postViewCell;

    }
    else
    {
        //TODO: Fix cell by removing the dynamic data generation.
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierComment forIndexPath:indexPath];
        
        cell.delegate = self;
        
        GLPComment *comment = self.comments[indexPath.row-1];
        
        [cell setComment:comment];
        
        
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
    
    if(indexPath.row>0)
    {
        GLPComment *comment = [self.comments objectAtIndex:indexPath.row-1];
        
        NSLog(@"Comment content: %@ with size: %f", comment.content, [CommentCell getCellHeightWithContent:comment.content image:NO]);
        
        //return 200.0f;
        
        return [CommentCell getCellHeightWithContent:comment.content image:NO];
    }
    else
    {
        if([self.post imagePost])
        {
            return [PostCell getCellHeightWithContent:self.post.content image:YES isViewPost:YES];
        }
        else
        {
            return [PostCell getCellHeightWithContent:self.post.content image:NO isViewPost:YES];
        }
        //return 200;
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
        [self.tableView setContentOffset:offset animated:NO];
    }
}

- (void)scrollToTheEndAnimated:(BOOL)animated
{
//    if(self.comments.count > 0)
//    {
    
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.comments.count inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
//    }
//    else
//    {
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
//    }
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
    GLPComment *comment = [[GLPComment alloc] init];
    comment.content = self.commentGrowingTextView.text;
    comment.post = self.post;
    
    //[WebClientHelper showStandardLoaderWithTitle:@"Creating comment" forView:self.view];
    [[WebClient sharedInstance] createComment:comment callbackBlock:^(BOOL success) {
        //[WebClientHelper hideStandardLoaderForView:self.view];
        
        if(success) {
            
            //Increase the number of comments to the post.
            ++self.post.commentsCount;
            
            [self loadComments];
            self.commentGrowingTextView.text = @"";
            
            //Notify timeline view controller.
            [GLPPostNotificationHelper updatePostWithNotifiationName:@"GLPPostUpdated" withObject:self remoteKey:self.post.remoteKey numberOfLikes:self.post.likes andNumberOfComments:self.post.commentsCount];
            
        } else {
            [WebClientHelper showStandardError];
        }
    }];
}

- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
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
}


@end
