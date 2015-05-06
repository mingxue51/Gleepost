//
//  GLPostTableView.m
//  Gleepost
//
//  Created by Silouanos on 04/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  Not used. To be removed.

#import "CLPostTableView.h"
#import "GLPiOSSupportHelper.h"
#import "MemberCell.h"
#import "GLPPostCell.h"
#import "GLPPost.h"
#import "CommentCell.h"
#import "ViewPostTitleCell.h"
#import "GLPLikesCell.h"
#import "GLPCommentsManager.h"

@interface CLPostTableView () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) GLPPost *post;
@property (strong, nonatomic) GLPCommentsManager *commentsManager;

@end

@implementation CLPostTableView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        self.frame = CGRectMake(0.0, 0.0, [GLPiOSSupportHelper screenWidth] - 40, [GLPiOSSupportHelper screenHeight] - 64 - 49);
    }
    return self;
}

- (void)awakeFromNib
{
    [self registerTableViewCells];
}

- (void)registerTableViewCells
{
    //Register nib files in table view.
    [self.tableView registerNib:[UINib nibWithNibName:@"PostImageCell" bundle:nil] forCellReuseIdentifier:@"ImageCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTextCellView" bundle:nil] forCellReuseIdentifier:@"TextCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostVideoCell" bundle:nil] forCellReuseIdentifier:@"VideoCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostPollCell" bundle:nil] forCellReuseIdentifier:@"PollCell"];
    
    //Register nib files in table view.
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentTextCellView" bundle:nil] forCellReuseIdentifier:@"CommentTextCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ViewPostTitleCell" bundle:nil] forCellReuseIdentifier:@"ViewPostTitleCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GLPLikesCell" bundle:nil] forCellReuseIdentifier:@"GLPLikesCell"];
}

#pragma mark - Modifiers

- (void)setPost:(GLPPost *)post
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    [self configureObservers];
    
    _post = post;
    
    //TODO: Load comments for the post.
    self.commentsManager = [[GLPCommentsManager alloc] initWithPost:self.post];
    
    DDLogDebug(@"CLPostTableView : post %@", self.post);
}

/**
 This method should be called once the view is invisible.
 */
- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_COMMENTS_FETCHED object:nil];
}

- (void)configureObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentsReceived:) name:GLPNOTIFICATION_COMMENTS_FETCHED object:nil];
}

#pragma mark - NSNotification selectors

- (void)commentsReceived:(NSNotification *)notification
{
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogDebug(@"PollingPostView : didDeselectRowAtIndexPath %ld", (long)indexPath.row);

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    if(indexPath.row == 0)
//    {
//        if([self.post imagePost] && ![_post isPollPost])
//        {
//            return [GLPPostCell getCellHeightWithContent:self.post cellType:kImageCell isViewPost:YES] + 10.0f;
//            
//            //            return 650;
//        }
//        else if([self.post isVideoPost])
//        {
//            return [GLPPostCell getCellHeightWithContent:self.post cellType:kVideoCell isViewPost:YES] + 10.0f;
//        }
//        else if ([self.post isPollPost])
//        {
//            return [GLPPostCell getCellHeightWithContent:self.post cellType:kPollCell isViewPost:NO] + 10.0f;
//        }
//        else
//        {
//            return [GLPPostCell getCellHeightWithContent:self.post cellType:kTextCell isViewPost:YES] + 10.0f;
//        }
//        //return 200;
//    }
//    else if (indexPath.row == 1)
//    {
//        if([self.post isPostLiked])
//        {
//            return [GLPLikesCell height];
//        }
//        else
//        {
//            return 30.0;
//        }
//    }
//    else if(indexPath.row == 2)
//    {
//        if([self.post isPostLiked])
//        {
//            return 30.0;
//        }
//        else
//        {
//            GLPComment *comment = [self.comments objectAtIndex:0];
//            
//            return [CommentCell getCellHeightWithContent:comment.content image:NO];
//        }
//    }
//    else
//    {
//        if([self.post isPostLiked])
//        {
//            GLPComment *comment = [self.comments objectAtIndex:indexPath.row-3];
//            
//            return [CommentCell getCellHeightWithContent:comment.content image:NO];
//        }
//        else
//        {
//            GLPComment *comment = [self.comments objectAtIndex:indexPath.row-2];
//            
//            return [CommentCell getCellHeightWithContent:comment.content image:NO];
//        }
//    }

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSInteger numberOfRows = 1;
//    
////    if(_postReadyToBeShown)
////    {
//        //Add 1 in order to create another cell for post.
//        //        return self.comments.count+2;
//        
//        if([_post isPostLiked])
//        {
//            ++numberOfRows;
//        }
//        
//        if(self.comments.count > 0)
//        {
//            numberOfRows += (self.comments.count + 1);
//        }
//        
//        return numberOfRows;
////    }
//    
//    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifierWithImage = @"ImageCell";
//    static NSString *CellIdentifierWithoutImage = @"TextCell";
//    static NSString *CellIdentifierVideo = @"VideoCell";
//    static NSString *CellIdentifierComment = @"CommentTextCell";
//    static NSString *CellIdentifierTitle = @"ViewPostTitleCell";
//    static NSString *CellIdentifierLikesCell = @"GLPLikesCell";
//    static NSString *CellIdentifierPoll = @"PollCell";
//    
//    GLPPostCell *postViewCell;
//    CommentCell *cell;
//    ViewPostTitleCell *titleCell;
//    GLPLikesCell *likesCell;
//    
//    if(indexPath.row == 0)
//    {
//        if([_post imagePost] && ![_post isPollPost])
//        {
//            //If image.
//            postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithImage forIndexPath:indexPath];
//            [postViewCell reloadMedia:YES];
//        }
//        else if ([_post isVideoPost])
//        {
//            postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierVideo forIndexPath:indexPath];
//            //            [postViewCell reloadMedia:self.mediaNeedsToReload];
//        }
//        else if([_post isPollPost])
//        {
//            postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierPoll forIndexPath:indexPath];
//        }
//        else
//        {
//            //If text.
//            postViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierWithoutImage forIndexPath:indexPath];
//        }
//        
//        postViewCell.delegate = self;
//        [postViewCell setIsViewPost:YES];
//        [postViewCell setPost:_post withPostIndexPath:indexPath];
//        
//        return postViewCell;
//        
//    }
//    else if(indexPath.row == 1)
//    {
//        if([self.post isPostLiked])
//        {
//            likesCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierLikesCell forIndexPath:indexPath];
//            [likesCell setLikedUsers:self.post.usersLikedThePost];
//            likesCell.delegate = self;
//            return likesCell;
//        }
//        else
//        {
//            titleCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierTitle forIndexPath:indexPath];
//            [titleCell setTitle:@"COMMENTS"];
//            return titleCell;
//        }
//    }
//    else if (indexPath.row == 2)
//    {
//        if([self.post isPostLiked])
//        {
//            titleCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierTitle forIndexPath:indexPath];
//            [titleCell setTitle:@"COMMENTS"];
//            return titleCell;
//        }
//        else
//        {
//            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierComment forIndexPath:indexPath];
//            
//            [cell setDelegate:self];
//            
//            GLPComment *comment = self.comments[0];
//            
//            [cell setComment:comment withIndex:0 andNumberOfComments:_comments.count];
//            
//            return cell;
//        }
//        
//    }
//    else
//    {
//        
//        if([self.post isPostLiked])
//        {
//            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierComment forIndexPath:indexPath];
//            
//            [cell setDelegate:self];
//            
//            GLPComment *comment = self.comments[indexPath.row - 3];
//            
//            [cell setComment:comment withIndex:indexPath.row - 3 andNumberOfComments:_comments.count];
//            
//            return cell;
//        }
//        else
//        {
//            //TODO: Fix cell by removing the dynamic data generation.
//            
//            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierComment forIndexPath:indexPath];
//            
//            [cell setDelegate:self];
//            
//            GLPComment *comment = self.comments[indexPath.row - 2];
//            
//            [cell setComment:comment withIndex:indexPath.row - 2 andNumberOfComments:_comments.count];
//            
//            return cell;
//        }
//    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
