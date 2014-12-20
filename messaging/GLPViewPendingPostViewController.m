//
//  GLPViewPendingPostViewController.m
//  Gleepost
//
//  Created by Silouanos on 29/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  TODO: We should create in the future a super class for both this class and ViewPostViewController.

#import "GLPViewPendingPostViewController.h"
#import "GLPPost.h"
#import "GLPPostCell.h"
#import "CommentCell.h"
#import "GLPPendingPostsManager.h"
#import "UINavigationBar+Utils.h"
#import "GLPPostManager.h"
#import "PendingPostManager.h"
#import "NewPostViewController.h"
#import "GLPPrivateProfileViewController.h"
#import "ContactsManager.h"

@interface GLPViewPendingPostViewController () <UITableViewDataSource, UITabBarDelegate, GLPPostCellDelegate, GLPImageViewDelegate, GLPLabelDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) NSInteger selectedUserRemoteKey;

@end

@implementation GLPViewPendingPostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerTableViewCells];
    
    [self selfLoadPendingPostIfNeeded];
    
    [self configureNavigationBar];
    
    [self configureNotificationsAfterViewDidLoad];
    
    [self getProgressViewAndAddItIfNeeded];
}

- (void)dealloc
{
    [self removeNotificationsJustBeforeDealloc];
}

#pragma mark - Configuration

- (void)registerTableViewCells
{
    //Register nib files in table view.
    [self.tableView registerNib:[UINib nibWithNibName:@"PostImageCell" bundle:nil] forCellReuseIdentifier:@"ImageCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTextCellView" bundle:nil] forCellReuseIdentifier:@"TextCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostVideoCell" bundle:nil] forCellReuseIdentifier:@"VideoCell"];
    
    //Register nib files in table view.
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentTextCellView" bundle:nil] forCellReuseIdentifier:@"CommentTextCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentTitleCellView" bundle:nil] forCellReuseIdentifier:@"CommentTitleCellView"];
}

- (void)configureNavigationBar
{
    [self.navigationController.navigationBar setTextButton:kRight withTitle:@"EDIT" withButtonSize:CGSizeMake(50, 20) withSelector:@selector(editPendingPost) andTarget:self];
}

- (void)configureNotificationsAfterViewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postEditedFinished:) name:GLPNOTIFICATION_POST_EDITED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postEditedStartedUploading:) name:GLPNOTIFICATION_POST_STARTED_EDITING object:nil];
}

- (void)removeNotificationsJustBeforeDealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POST_EDITED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POST_STARTED_EDITING object:nil];
}

- (void)getProgressViewAndAddItIfNeeded
{
    [self.view addSubview:(UIView *)[[GLPPendingPostsManager sharedInstance] progressViewWithPostRemoteKey:_pendingPost.remoteKey]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.pendingPost.reviewHistory && self.pendingPost.reviewHistory.count > 0)
    {
        GLPReviewHistory *rHistory = self.pendingPost.reviewHistory[0];
        if(!rHistory.reason)
        {
            self.pendingPost.reviewHistory = [[NSMutableArray alloc] init];
        }
    }
    
    return self.pendingPost.reviewHistory.count + 2;
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
        if([self.pendingPost imagePost])
        {
            //If image.
            postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithImage forIndexPath:indexPath];
            [postViewCell reloadMedia: YES];
        }
        else if ([self.pendingPost isVideoPost])
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
        
        [postViewCell setIsViewPost:YES];
        
        [postViewCell setPost:self.pendingPost withPostIndexPath:indexPath];
        
        return postViewCell;
    }
    else if (indexPath.row == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierTitle forIndexPath:indexPath];
        
        return cell;
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierComment forIndexPath:indexPath];
        
        [cell setDelegate:self];
        
        GLPReviewHistory *reviewHistory = self.pendingPost.reviewHistory[indexPath.row - 2];
        
        [cell setComment:[reviewHistory toComment] withIndex:indexPath.row - 2 andNumberOfComments:self.pendingPost.reviewHistory.count];
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [self navigateToViewControllerWithIndex:indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        if([self.pendingPost imagePost])
        {
            return [GLPPostCell getCellHeightWithContent:self.pendingPost cellType:kImageCell isViewPost:YES] + 10.0f;
        }
        else if([self.pendingPost isVideoPost])
        {
            return [GLPPostCell getCellHeightWithContent:self.pendingPost cellType:kVideoCell isViewPost:YES] + 10.0f;
        }
        else
        {
            return [GLPPostCell getCellHeightWithContent:self.pendingPost cellType:kTextCell isViewPost:YES] + 10.0f;
        }
    }
    else if (indexPath.row == 1)
    {
        return 30.0;
    }
    else
    {
        GLPComment *comment = [[self.pendingPost.reviewHistory objectAtIndex:indexPath.row-2] toComment];
        
        return [CommentCell getCellHeightWithContent:comment.content image:NO];
    }
}

#pragma mark - Client

- (void)selfLoadPendingPostIfNeeded
{
//    self.pendingPost = [[GLPPendingPostsManager sharedInstance] postWithRemoteKey:self.pendingPost.remoteKey];
    
    if([self comesFromNotifications])
    {
        //Load the post.
        self.pendingPost.content = @"Loading...";
        self.title = @"Loading...";
        
        [GLPPostManager loadPostWithRemoteKey:self.pendingPost.remoteKey callback:^(BOOL success, GLPPost *post) {
            
            self.title = @"VIEW POST";
            
            if(success)
            {
                self.pendingPost = post;
                
                self.pendingPost = [GLPPostManager setFakeKeyToPost:self.pendingPost];
                
                [self.tableView reloadData];
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Post may not exist anymore." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                
                [alertView show];
            }
            
        }];
    }
}

#pragma mark - Selectors

/**
 Set the selected post to PendingPostManager and show NewPostViewController.
 */
- (void)editPendingPost
{
    _pendingPost.sendStatus = kEdited;
    [[PendingPostManager sharedInstance] setPendingPost:_pendingPost];
    
    [self performSegueWithIdentifier:@"edit post" sender:self];
}

#pragma mark - GLPPostCellDelegate

//TODO: Implement the following methods.

- (void)showLocationWithLocation:(GLPLocation *)location
{
    DDLogDebug(@"showLocationWithLocation");
}

- (void)elementTouchedWithRemoteKey:(NSInteger)remoteKey
{
    //Decide where to navigate. Private or current profile.
    
    [self performSegueWithIdentifier:@"view profile" sender:self];
}

#pragma mark - Notifications

/**
 This method is called once a post is finished editing.
 
 @param nsnotification
 
 */
- (void)postEditedFinished:(NSNotification *)notification
{
    NSDictionary *notificationDict = [notification userInfo];
    
    DDLogDebug(@"GLPViewPendingPostsViewController : postEditedFinished %@", [(GLPPost *)notificationDict[@"post_edited"] video]);
    
    [self setNewPostAndRefreshPostCell:notificationDict[@"post_edited"]];
}

- (void)postEditedStartedUploading:(NSNotification *)notification
{
    [self getProgressViewAndAddItIfNeeded];
    
    NSDictionary *notificationDict = [notification userInfo];
    DDLogDebug(@"GLPViewPendingPostViewController : postEditedStartedUploading %@", notificationDict);

    GLPPost *editedPost = notificationDict[@"posts_started_editing"];
    
    editedPost.sendStatus = kSendStatusLocalEdited;
    
    [self setNewPostAndRefreshPostCell:editedPost];
}

- (void)setNewPostAndRefreshPostCell:(GLPPost *)newPost
{
    if(newPost.remoteKey == _pendingPost.remoteKey)
    {
        _pendingPost = newPost;
        
        DDLogDebug(@"GLPViewPendingPostViewController : pending post %@, edited post %@ sendstatus %d", _pendingPost.imagesUrls, newPost.imagesUrls, newPost.sendStatus);

        //TODO: Remove reload data.
        [self.tableView reloadData];
        
        
//        [self refreshCellViewWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
}

#pragma mark - RemovePostCellDelegate

-(void)removePostWithPost:(GLPPost *)post
{
    
}

#pragma mark - GLPImageViewDelegate

- (void)imageTouchedWithImageView:(UIImageView *)imageView
{
    NSInteger userRemoteKey = imageView.tag;
    
    //Decide where to navigate. Private or current profile.
    if([[ContactsManager sharedInstance] userRelationshipWithId:userRemoteKey] == kCurrentUser)
    {
        [self performSegueWithIdentifier:@"view profile" sender:self];
    }
    else
    {
        self.selectedUserRemoteKey = userRemoteKey;
        [self performSegueWithIdentifier:@"view private profile" sender:self];
    }
}

#pragma mark - GLPLabelDelegate

- (void)labelTouchedWithTag:(NSInteger)tag
{
    
}

#pragma mark - Table view refresh methods

-(void)refreshCellViewWithIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"view private profile"])
    {
        GLPPrivateProfileViewController *profileViewController = segue.destinationViewController;
        
        profileViewController.selectedUserId = self.selectedUserRemoteKey;
    }
}


@end
