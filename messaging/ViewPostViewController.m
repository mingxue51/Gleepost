//
//  ViewPostViewController.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ViewPostViewController.h"
#import "WebClient.h"
#import "MBProgressHUD.h"
#import "Comment.h"
#import "KeyboardHelper.h"
#import "CommentCell.h"
#import "NSString+Utils.h"
#import "ViewPostTableView.h"

@interface ViewPostViewController ()

@property (strong, nonatomic) NSMutableArray *comments;
@property (strong, nonatomic) NSMutableArray *commentsHeight;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (assign, nonatomic) float keyboardAppearanceSpaceY;

@property (weak, nonatomic) IBOutlet ViewPostTableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;

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
    //[self setBackgroundToNavigationBar];
    
    
    
    NSLog(@"ViewPostViewController");
    
    
    //Set image despite title.
//    UIImage *image = [UIImage imageNamed:@"gleepost"];
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    

    
//    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    //self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [self.tableView initTableView];
    [self initHeaderTableView];
    [self initFooterTableView];
    
    //Initialise elements.
    self.commentsHeight = [[NSMutableArray alloc] init];
    
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
    
    [self loadComments];
    
    //[self initialiseCommentsHeightArray];
    

    
   // [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Initialise header and footer

-(void) initFooterTableView
{
    self.tableView.typeTextView.footerTextView.delegate = self;
}

/**
 
 Initialises the header view. A UIView presenting the current post.
 
 */

-(void) initHeaderTableView
{
    
    //Add the user's image to the corresponding cell.
    UIImage *img = [UIImage imageNamed:@"avatar_big"];
    self.tableView.headerView.userImage.image = img;
    self.tableView.headerView.userImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.tableView.headerView.userImage setFrame:CGRectMake(10.0f, 0.0f+10.0f, img.size.width-15, img.size.height-15)];
    //Post *post = self.posts[indexPath.row];
    
    //Add the user's name.
    [self.tableView.headerView.userName setText:@"Test User"];
    
    //Add the post's time.
    [self.tableView.headerView.postTime setText:@"20 min ago"];
    
    //Add the post's text content.
    [self.tableView.headerView.content setText:@"Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Contesont Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content Content "];
    
    //Add the main image to the post.
    UIImage *postImage = [UIImage imageNamed:@"post_image"];
    self.tableView.headerView.mainImage.image = postImage;
    
    //TODO: See again the postImage width. Problem.
    [self.tableView.headerView.mainImage setFrame:CGRectMake(10.0f, 80.0f, postImage.size.width-20, postImage.size.height)];
    
    //Add selector to the buttons.
    [self buttonWithName:@"Like" andSubviews:[self.tableView.headerView.socialPanel subviews]];
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
 
 */
-(UIButton*) buttonWithName: (NSString*)buttonName andSubviews: (NSArray*)subArray
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
 
 When like button is pushed turn it to our application's custom colour.
 
 */
-(void)likeButtonPushed: (id)sender
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

- (IBAction)addCommentButtonClick:(id)sender
{
    if([self.commentTextField isFirstResponder])
    {
        [self.commentTextField resignFirstResponder];
    }
    
    
    [self hideKeyboardFromTextViewIfNeeded];
    
    //Post the comment.
    //[self postComment];
}


#pragma mark - Other methods

static bool firstTime = YES;
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

- (void)loadComments
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading posts";
    hud.detailsLabelText = @"Please wait few seconds";
    
    WebClient *client = [WebClient sharedInstance];
    [client getCommentsForPost:self.post withCallbackBlock:^(BOOL success, NSArray *comments) {
        [hud hide:YES];
        
        if(success) {
            self.comments = [comments mutableCopy];
            
            //Add height for each comment.
            for(Comment *cmt in self.comments)
            {
                NSString *commentContent = cmt.content;
                
                CGSize textSize = { 240.0, 10000.0 };
                
//                CGSize sizeOfTextView = [commentContent sizeWithFont:[UIFont boldSystemFontOfSize:12]
//                                                constrainedToSize:textSize
//                                                    lineBreakMode:NSLineBreakByWordWrapping];
                
                UIFont *font = [UIFont boldSystemFontOfSize:12.0];
                CGSize sizeOfTextView = [commentContent sizeWithFont:font
                                 constrainedToSize:textSize
                                     lineBreakMode:NSLineBreakByWordWrapping]; // default mode
                
                float numberOfLines = sizeOfTextView.height / font.lineHeight;
                
                NSLog(@"Comment-> %f",sizeOfTextView.height*3);
                
                if(numberOfLines == 1)
                {
                  [self.commentsHeight addObject:[NSNumber numberWithFloat:70.0]];
                }
                else
                {
                    [self.commentsHeight addObject:[NSNumber numberWithFloat:numberOfLines*30]];
                }
                
                
                
            }
            NSLog(@"HEIGHT: %@",self.commentsHeight);
            NSLog(@"COMMENTS: %@",self.comments);
            NSLog(@"Reload Data.");
            [self.tableView reloadData];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading failed"
                                                            message:@"Check your id or your internet connection dude."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
    
    //Create an array consisting of height of each corresponding comment.
    
}

-(float) calculateCommentSize: (NSString*) content
{
    
    //Return default.
    return 70.0;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    return self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForRowAtIndexPath");
    
    static NSString *CellIdentifier = @"CommentCell";
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell createElements];
    
    Comment *comment = self.comments[indexPath.row];
    
    //Set comment's content.
    cell.contentTextView.text = comment.content;
    
    //Set user's image.
    UIImage *img = [UIImage imageNamed:@"avatar_big"];
    cell.userImageView.image = img;
    cell.userImageView.contentMode = UIViewContentModeScaleAspectFit;
    [cell.userImageView setFrame:CGRectMake(5.0f, 10.0f, img.size.width-25, img.size.height-25)];
    
    
    //Set user's name.
    [cell.userNameLabel setText:@"User Name"];
    
    //Set post's time.
    [cell.postDateLabel setText:@"2 minutes ago"];
    
    

    //cell.userImageView.image = [UIImage imageNamed:@"avatar_big"];
    
//    cell.textLabel.text = comment.content;
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", comment.user.name, [self.dateFormatter stringFromDate:comment.date]];
    
    return cell;
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
    float height = [[self.commentsHeight objectAtIndex:indexPath.row] floatValue];
    
    return height;
}

#pragma mark - Keyboard methods

- (void)hideKeyboardFromTextViewIfNeeded
{
    if(self.commentTextField.isFirstResponder) {
        [self.commentTextField resignFirstResponder];
    }
    
    if(self.tableView.typeTextView.footerTextView.isFirstResponder)
    {
        [self.tableView.typeTextView.footerTextView resignFirstResponder];
        
        //Clear footer text view.
        self.tableView.typeTextView.footerTextView.text = @"Add comment...";
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if(self.keyboardAppearanceSpaceY != 0) {
        return;
    }
    
    float height = [KeyboardHelper keyboardHeight:notification] - 49;
    self.keyboardAppearanceSpaceY = height;
    
    [self animateViewWithVerticalMovement:-self.keyboardAppearanceSpaceY duration:[KeyboardHelper keyboardAnimationDuration:notification] andAnimationOptions:[KeyboardHelper keyboardAnimationOptions:notification]];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self animateViewWithVerticalMovement:fabs(self.keyboardAppearanceSpaceY) duration:[KeyboardHelper keyboardAnimationDuration:notification] andAnimationOptions:[KeyboardHelper keyboardAnimationOptions:notification]];
    self.keyboardAppearanceSpaceY = 0;
}

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


#pragma mark - Text view delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if(![self.commentTextField.text isEmpty]) {
        [self postComment];
    }
    
    return YES;
}

- (void)postComment
{
    Comment *comment = [[Comment alloc] init];
    comment.content = self.commentTextField.text;
    comment.remoteThreadId = self.post.remoteId;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Posting comment";
    hud.detailsLabelText = @"Please wait few seconds";
    
    [[WebClient sharedInstance] createComment:comment callbackBlock:^(BOOL success) {
        [hud hide:YES];
        
        if(success) {
            [self loadComments];
            self.commentTextField.text = @"";
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Posting comment failed"
                                                            message:@"Check your internet connection, dude."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - footer TextView delegate

-(BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    NSLog(@"textViewShouldBeginEditing");
//    self.tableView.textInputMode.footerTextView.textColor = [UIColor blackColor];
    
    self.tableView.typeTextView.footerTextView.textColor = [UIColor blackColor];
    return YES;
}






@end
