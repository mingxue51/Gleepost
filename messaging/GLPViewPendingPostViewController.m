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
#import "UINavigationBar+Utils.h"

@interface GLPViewPendingPostViewController () <UITableViewDataSource, UITabBarDelegate, GLPPostCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GLPViewPendingPostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerTableViewCells];
    
    [self loadCommentsIfExist];
    
    [self configureNavigationBar];
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

- (void)loadCommentsIfExist
{
    
}

- (void)configureNavigationBar
{
    [self.navigationController.navigationBar setTextButton:kRight withTitle:@"EDIT" withButtonSize:CGSizeMake(50, 20) withSelector:@selector(editPendingPost) andTarget:self];
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
        [postViewCell setPost:self.pendingPost withPostIndex:indexPath.row];
        
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

#pragma mark - Selectors

- (void)editPendingPost
{
    DDLogDebug(@"Edit post.");
}

#pragma mark - GLPPostCellDelegate

//TODO: Implement the following methods.

- (void)showLocationWithLocation:(GLPLocation *)location
{
    DDLogDebug(@"showLocationWithLocation");
}

- (void)elementTouchedWithRemoteKey:(NSInteger)remoteKey
{
    DDLogDebug(@"elementTouchedWithRemoteKey");
}

- (void)navigateToPostForCommentWithIndex:(NSInteger)postIndex
{
    //TODO: Pending implementation.
}

#pragma mark - RemovePostCellDelegate

-(void)removePostWithPost:(GLPPost *)post
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
