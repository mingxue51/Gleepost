//
//  CLPost.m
//  Gleepost
//
//  Created by Silouanos on 05/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  This class represents the post cell view in the CampusLiveTableViewTopView class.

#import "CLPostView.h"
#import "GLPiOSSupportHelper.h"
#import "GLPPost.h"
#import "CLPostTimeLocationView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "GLPImageView.h"
#import "GLPLabel.h"
#import "NSDate+TimeAgo.h"
#import "GLPImageHelper.h"
#import "GLPViewsCountView.h"
#import "GLPPostCell.h"
#import "ShapeFormatterHelper.h"
#import "AppearanceHelper.h"
#import "SessionManager.h"
#import "GLPFacebookConnect.h"
#import "WebClientHelper.h"
#import "CampusLiveManager.h"
#import "GLPPostManager.h"
#import "GLPPostNotificationHelper.h"

@interface CLPostView () <GLPLabelDelegate, GLPImageViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet CLPostTimeLocationView *timeLocationView;
@property (weak, nonatomic) IBOutlet GLPImageView *postImageView;
@property (weak, nonatomic) IBOutlet GLPImageView *userImageView;
@property (weak, nonatomic) IBOutlet GLPLabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *datePostedLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelHeight;

@property (weak, nonatomic) IBOutlet GLPViewsCountView *viewsCountView;


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) GLPPost *post;

@end

@implementation CLPostView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        self.frame = CGRectMake(0.0, 0.0, [GLPiOSSupportHelper screenWidth] * 0.91, [GLPiOSSupportHelper screenHeight] * 0.75);
        [self configureNotifications];

    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self formatElements];
}

- (void)formatElements
{
    [ShapeFormatterHelper setCornerRadiusWithView:self.backgroundImageView andValue:5];
    [ShapeFormatterHelper setBorderToView:self.backgroundImageView withColour:[AppearanceHelper mediumGrayGleepostColour] andWidth:1.0f];
}

- (void)configureNotifications
{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notify:) name:@"GLPNotificationCatched" object:nil];
}

- (void)notify:(NSNotification *)notification
{
    DDLogDebug(@"CLPostView : notify post %@", self.post.eventTitle);
}

- (void)setPost:(GLPPost *)post
{
    _post = post;
    self.eventTitleLabel.text = post.eventTitle;
    
    [self setLikeImageToButton];
    [self.timeLocationView setLocation:post.location andTime:post.dateEventStarts];
    [self configurePostImage];
    
    [self setUserViewData];
    
    [self.viewsCountView setViewsCount:self.post.viewsCount];
    
    [self configureCommentsAndLikesLabels];
    
    [self configureContentLabel];
    
    
}

- (void)configureContentLabel
{
    self.contentLabel.text = self.post.content;
    
    self.contentLabelHeight.constant =  [GLPPostCell getContentLabelSizeForContent:self.post.content isViewPost:NO cellType:kImageCell].height;
}

- (void)configureCommentsAndLikesLabels
{
    self.commentsLabel.hidden = (self.post.commentsCount == 0);
    self.likesLabel.hidden = (self.post.likes == 0);
    
    self.commentsLabel.text = [NSString stringWithFormat:@"%ld", self.post.commentsCount];
    self.likesLabel.text = [NSString stringWithFormat:@"%ld", self.post.likes];
}

- (void)configurePostImage
{
    NSURL *imageUrl = nil;
    
    if(self.post.imagesUrls.count > 0)
    {
        imageUrl = [NSURL URLWithString:self.post.imagesUrls[0]];
//        [self hideVideoView];
    }

    [_activityIndicator stopAnimating];
    
    self.postImageView.delegate = self;
    [self.postImageView setGesture:YES];
    self.postImageView.tag = -1;
    [self.postImageView setImageWithURL:imageUrl placeholderImage:nil usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    return;
}

- (void)setUserViewData
{
    [self setUserImage];
    self.userNameLabel.text = self.post.author.name;
    self.userNameLabel.tag = self.post.author.remoteKey;
    self.userNameLabel.delegate = self;
    self.datePostedLabel.text = [self.post.date timeAgo];
}

- (void)setUserImage
{
    [self.userImageView makeImageRounded];
    [self.userImageView setGesture:YES];
    self.userImageView.delegate = self;
    [self.userImageView setImageUrl:self.post.author.profileImageUrl withPlaceholderImage:[GLPImageHelper placeholderUserImagePath]];
    
    //Add to the user's tag's image view the user id.
    self.userImageView.tag = _post.author.remoteKey;
}


#pragma mark - GLPLabelDelegate

- (void)labelTouchedWithTag:(NSInteger)tag
{
    DDLogDebug(@"CLPostView labelTouchedWithTag %ld", (long)tag);
}

#pragma mark - GLPImageViewDelegate

- (void)imageTouchedWithImageView:(UIImageView *)imageView
{
    
    //If the image view tag is -1 it means that the user touched on the post image.
    
    if(imageView.tag == -1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_CL_IMAGE_SHOULD_VIEWED object:self userInfo:@{@"image" : imageView.image}];
    }
    else
    {
        //TODO: Navigate to user's profile.
    }
    
}

#pragma mark - Action Sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSString *selectedButtonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if([selectedButtonTitle isEqualToString:@"Share to Facebook"])
    {
        //Share post.
        [[GLPFacebookConnect sharedConnection] sharePostWithPost:self.post];
        
    }
    else if ([selectedButtonTitle isEqualToString: @"More options"])
    {
        [self sharePostToSocialMedia];
    }
    else if ([selectedButtonTitle isEqualToString:@"Delete"])
    {
        //Delete post.
        //TODO: Implement that later.
        //[_delegate deleteCurrentPost];
    }
    else if ([selectedButtonTitle isEqualToString:@"Save image"])
    {
        //Save image to camera roll.
        [self savePostImage];
    }
    else if ([selectedButtonTitle isEqualToString:@"Report"])
    {
        //Report post.
        [self reportCurrentPost];
    }
}

#pragma mark - Selectors

- (IBAction)moreOptions:(id)sender
{
    UIActionSheet *actionSheet = nil;
    
    if([_post imagePost] && [self isCurrentPostBelongsToCurrentUser])
    {
        actionSheet = [[UIActionSheet alloc]initWithTitle:@"More" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Save image", @"Report", nil];
    }
    else if([_post imagePost] && ![self isCurrentPostBelongsToCurrentUser])
    {
        actionSheet = [[UIActionSheet alloc]initWithTitle:@"More" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save image", @"Report", nil];
    }
    else if (![_post imagePost] && [self isCurrentPostBelongsToCurrentUser])
    {
        actionSheet = [[UIActionSheet alloc]initWithTitle:@"More" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Report", nil];
    }
    else
    {
        actionSheet = [[UIActionSheet alloc]initWithTitle:@"More" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Report", nil];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_CL_SHOW_MORE_OPTIONS object:self userInfo:@{@"action_sheet" : actionSheet}];
}

- (IBAction)goingButtonTouched:(id)sender
{
    
}

-(IBAction)sharePost:(id)sender
{
    UIActionSheet *actionSheet = nil;
    
    actionSheet = [[UIActionSheet alloc]initWithTitle:@"Share Post" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Share to Facebook", @"More options", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_CL_SHOW_MORE_OPTIONS object:self userInfo:@{@"action_sheet" : actionSheet}];
}

- (IBAction)likePost:(id)sender
{
    //If like button is pushed then set the pushed variable to NO and change the colour of the image.
    
    if([self.post liked])
    {
        [self.post setLiked:NO];
        
        //Change the like status and send to server the change.
//        [self postLike:NO withPostRemoteKey:[self.post remoteKey]];
   
        [[CampusLiveManager sharedInstance] postLike:NO withPostRemoteKey:self.post.remoteKey];
        
        //Decrease the number of likes.
        --self.post.likes;
    }
    else
    {
        [self.post setLiked:YES];
        
        //Change the like status and send to server the change.
        [[CampusLiveManager sharedInstance] postLike:YES withPostRemoteKey:self.post.remoteKey];
        
        //Increase the number of likes.
        ++self.post.likes;
    }
    
    [self showOrHideLikeLabel];
    
    //Update like label.
    [self.likesLabel setText:[NSString stringWithFormat:@"%ld", (long)_post.likes]];
    
    [self setLikeImageToButton];
    
    //Update post in local database.
    [GLPPostManager updatePostWithLiked:self.post];
    
    [GLPPostNotificationHelper updatePostWithNotifiationName:@"GLPPostUpdated" withObject:self remoteKey:self.post.remoteKey numberOfLikes:self.post.likes andNumberOfComments:self.post.commentsCount];
    
    [GLPPostNotificationHelper updatePostWithNotifiationName:@"GLPLikedPostUdated" withObject:self remoteKey:self.post.remoteKey withLiked:self.post.liked];
}

#pragma mark - Actions

-(void)setLikeImageToButton
{
    if(self.post.liked)
    {
        [self.likeButton setTitleColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationbar"]] forState:UIControlStateNormal];
        //Add the thumbs up selected version of image.
        [self.likeButton setImage:[UIImage imageNamed:@"icon_like_pushed"] forState:UIControlStateNormal];
    }
    else
    {
        [self.likeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        //Add the thumbs up selected version of i   age.
        [self.likeButton setImage:[UIImage imageNamed:@"icon_like"] forState:UIControlStateNormal];
    }
}

/**
 Shows or hides like label depending on how many likes there are on the post.
 */
- (void)showOrHideLikeLabel
{
    if(_post.likes == 0)
    {
        [self.likesLabel setHidden:YES];
    }
    else
    {
        [self.likesLabel setHidden:NO];
    }
}

- (void)savePostImage
{
    UIImageWriteToSavedPhotosAlbum(_postImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *) image didFinishSavingWithError:(NSError *) error contextInfo:(void *) contextInfo
{
    if(error)
    {
        [WebClientHelper showErrorSavingImageWithMessage:error.description];
    }
    else
    {
        [WebClientHelper showSaveImageMessage];
    }
}

- (void)reportCurrentPost
{
    [[WebClient sharedInstance] reportPostWithRemoteKey:_post.remoteKey callbackBlock:^(BOOL success) {
        
        if(success)
        {
            [WebClientHelper showReportedDone];
        }
        else
        {
            [WebClientHelper showFailedToReport];
        }
        
    }];
}

#pragma mark - Sharing

-(void)sharePostToSocialMedia
{
    if(self.post.imagesUrls[0] != nil)
    {
        //Fetch from the cache to avoid redundant download.
        
        [[SDImageCache sharedImageCache] queryDiskCacheForKey:self.post.imagesUrls[0] done:^(UIImage *image, SDImageCacheType cacheType) {
            
            NSArray *items = @[[NSString stringWithFormat:@"\"%@\" shared via #Gleepost",self.post.content], image];
            [self sharePostToSocialMediaWithItems:items];
            
        }];
    }
    else
    {
        NSArray *items = @[[NSString stringWithFormat:@"\"%@\" shared via #Gleepost",self.post.content]];
        [self sharePostToSocialMediaWithItems:items];
    }
    
}

-(void)sharePostToSocialMediaWithItems:(NSArray *)items
{
    UIActivityViewController *shareItems = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    
    NSArray * excludeActivities = @[UIActivityTypeAssignToContact, UIActivityTypePostToWeibo, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypePostToFacebook, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo, UIActivityTypeSaveToCameraRoll];
    
    //UIActivityTypePostToFlickr
    
    shareItems.excludedActivityTypes = excludeActivities;
    
//    [_delegate showShareViewWithItems:shareItems];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_CL_SHOW_SHARE_OPTIONS object:self userInfo:@{@"share_items" : shareItems}];

}

#pragma mark - Helper methods

- (BOOL)isCurrentPostBelongsToCurrentUser
{
    return ([SessionManager sharedInstance].user.remoteKey == self.post.author.remoteKey);
}

#pragma mark - Static

+ (CGFloat)width
{
    return [GLPiOSSupportHelper screenWidth] * 0.91;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
