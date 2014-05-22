//
//  MainPostView.m
//  Gleepost
//
//  Created by Silouanos on 16/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "MainPostView.h"
#import "VideoView.h"
#import "NSDate+TimeAgo.h"
#import "ShapeFormatterHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "GLPCategory.h"
#import "SessionManager.h"
#import "GLPFacebookConnect.h"
#import "GLPPostManager.h"
#import "GLPPostNotificationHelper.h"
#import "WebClientHelper.h"

@interface MainPostView ()

@property (weak, nonatomic) IBOutlet UIView *socialView;

@property (weak, nonatomic) IBOutlet UILabel *likesLbl;

@property (weak, nonatomic) IBOutlet UILabel *commentsLbl;

@property (weak, nonatomic) IBOutlet UILabel *timePostLbl;

@property (weak, nonatomic) IBOutlet UILabel *nameLbl;

@property (weak, nonatomic) IBOutlet UILabel *contentLbl;

@property (weak, nonatomic) IBOutlet UIButton *likeBtn;

@property (weak, nonatomic) IBOutlet UIButton *commentBtn;

@property (weak, nonatomic) IBOutlet UIButton *goingBtn;

@property (weak, nonatomic) IBOutlet UIButton *moreBtn;

@property (weak, nonatomic) IBOutlet UIButton *shareBtn;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (weak, nonatomic) IBOutlet VideoView *videoView;

@property (weak, nonatomic) IBOutlet UIImageView *indicatorImageView;

@property (weak, nonatomic) IBOutlet UIImageView *postImageView;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelHeightConstrain;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceFromTopView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceFromTop;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainViewHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundImageHeight;

/** Image constrains. */
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postImageWidthConstrain;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postImageDistanceFromTopConstrain;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postImageDistanceFromLeftConstrain;

/** Constrains have to do with video. */

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceUserViewFromThePostImageConstrain;

//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postImageDistanceFromRightConstrain;

@property (strong, nonatomic) GLPPost *post;

@property (assign, nonatomic) BOOL mediaAvailable;

@property (assign, nonatomic, getter = doesImageNeedLoadAgain) BOOL imageNeedsToLoadAgain;

@property (assign, nonatomic, getter = isViewPost) BOOL viewPost;

@end

@implementation MainPostView

const float FIXED_TOP_TEXT_BACKGROUND_HEIGHT = 70;
const float FIXED_BOTTOM_TEXT_VIEW_HEIGHT = 100;

const float FIXED_TOP_MEDIA_BACKGROUND_HEIGHT = 250;
const float FIXED_BOTTOM_MEDIA_VIEW_HEIGHT = 295;



-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        
    }
    
    return self;
}

-(void)initialiseObjects
{
    _mediaAvailable = NO;
}

-(void)configureMediaAvailable
{
    if((_post.imagesUrls && _post.imagesUrls.count > 0) || (_post.videosUrls && _post.videosUrls.count > 0))
    {
        _mediaAvailable = YES;
    }
    else
    {
        _mediaAvailable = NO;
    }
}

#pragma mark - Modifiers

-(void)setElementsWithPost:(GLPPost *)post withViewPost:(BOOL)viewPost
{
    /** TODO: See if this assign is good. */
    _post = post;
    
    [_likesLbl setText:[NSString stringWithFormat:@"%ld", (long)post.likes]];

    [_commentsLbl setText:[NSString stringWithFormat:@"%ld", (long)post.commentsCount]];
    
    [_contentLbl setText:post.content];
    
    [_nameLbl setText:post.author.name];
    
    [self configureMediaAvailable];
    
    _viewPost = viewPost;
    
    [self configureIfComesFromViewPost];
    
    //Set like button status.
    [self setLikeImageToButton];
    
    [self setCategories];
    
    [self setTimeWithDate:post.date];
    
    [self setUserImage];
    
    [self setPostImage];
    
    [self setVideo];
    
    [self formatElements];
    
    [self updateIndicatorWithRemoteKey:post.remoteKey];
    
    [self configureGoingButton];
    
    [self configureMoreButton];
    
    [self configureShareButton];
    
    [self addGesturesToElements];

    
//    [ShapeFormatterHelper setBorderToView:_contentLbl withColour:[UIColor redColor]];
    
//    [ShapeFormatterHelper setBorderToView:_socialView withColour:[UIColor blueColor]];
    
//    [ShapeFormatterHelper setBorderToView:self withColour:[UIColor blueColor]];
    
}


-(void)setNewHeightDependingOnLabelHeight:(float)height andIsViewPost:(BOOL)isViewPost
{
    
//    if([_post isVideoPost] && !isViewPost)
//    {
//        [self setPositionsOfVideo];
//        
//        return;
//    }
    
    float fixedTopBackgroundHeight = 0.0f;
    float fixedBottomViewHeight = 0.0f;
    float backgroundImageViewHeight = 0.0f;

    
    if([_post imagePost])
    {
        fixedTopBackgroundHeight = FIXED_TOP_MEDIA_BACKGROUND_HEIGHT;
        fixedBottomViewHeight = FIXED_BOTTOM_MEDIA_VIEW_HEIGHT;
        backgroundImageViewHeight = 390.0f + height;
    }
    else if ([_post isVideoPost])
    {
        backgroundImageViewHeight = 510.0f;
//        [_backgroundImageHeight setConstant:backgroundImageViewHeight];
        
    }
    else
    {
        fixedTopBackgroundHeight = FIXED_TOP_TEXT_BACKGROUND_HEIGHT;
        fixedBottomViewHeight = FIXED_BOTTOM_TEXT_VIEW_HEIGHT;
        backgroundImageViewHeight = 190.0f + height;
    }
    
    if([self isCurrentPostEvent])
    {
        [_backgroundImageHeight setConstant:backgroundImageViewHeight];
        
        [_postImageDistanceFromTopConstrain setConstant:7];
//        [_postImageDistanceFromLeftConstrain setConstant:0];
        
//        [_postImageWidthConstrain setConstant:300];

    }
    else if(![self isCurrentPostEvent])
    {
        [_backgroundImageHeight setConstant:backgroundImageViewHeight - 85.0f];

        
        [_postImageDistanceFromTopConstrain setConstant:10];

//        [_postImageDistanceFromLeftConstrain setConstant:0];
        
//        [_postImageWidthConstrain setConstant:280];
    }
    
    [_contentLabelHeightConstrain setConstant:height];
    
//    [_topBackgroundHeightConstrain setConstant:height+ (_mediaAvailable) ? FIXED_TOP_MEDIA_BACKGROUND_HEIGHT : FIXED_TOP_TEXT_BACKGROUND_HEIGHT];
    

//    [_topBackgroundHeightConstrain setConstant:height + fixedTopBackgroundHeight];

    
//    [_distanceFromTopView setConstant:16];

    if([self isCurrentPostEvent])
    {
        [self.distanceFromTop setConstant:85]; //81
    }
    else
    {
        [self.distanceFromTop setConstant:25];
    }

    [self.mainViewHeight setConstant:height + fixedBottomViewHeight];

}

-(void)setHeightDependingOnLabelHeight:(float)height andIsViewPost:(BOOL)isViewPost
{
    if([_post imagePost])
    {
        [self setPositionsForImagePostWithHeight:height];
    }
    else if ([_post isVideoPost])
    {
        [self setPositionsForVideoWithHeight:height];
    }
    else
    {
        [self setPositionsForTextPostWithHeight:height];
    }
    
}

-(void)setPositionsForTextPostWithHeight:(float)height
{
    float fixedTopBackgroundHeight = 0.0f;
    float fixedBottomViewHeight = FIXED_BOTTOM_TEXT_VIEW_HEIGHT;
    float backgroundImageViewHeight = 0.0f;

    backgroundImageViewHeight = 190.0f + height;

    
    if([self isCurrentPostEvent])
    {
        fixedTopBackgroundHeight = 100.0f;
    }
    else
    {
        fixedTopBackgroundHeight = 25.0f;
        backgroundImageViewHeight -= 75.0f;
    }
    
    //Set constrains.
    [_backgroundImageHeight setConstant:backgroundImageViewHeight];
    
    [_distanceFromTop setConstant:fixedTopBackgroundHeight];
    
    [self.mainViewHeight setConstant:height + fixedBottomViewHeight];

    [_contentLabelHeightConstrain setConstant:height];

}

-(void)setPositionsForImagePostWithHeight:(float)height
{
    float backgroundImageViewHeight = 0.0f;
    float fixedBottomViewHeight = 0.0f;
    float distanceFromTop = 0.0f;
    
    backgroundImageViewHeight = 390.0f + height;
    fixedBottomViewHeight = FIXED_BOTTOM_MEDIA_VIEW_HEIGHT;

    
    if([self isCurrentPostEvent])
    {
        [_postImageDistanceFromTopConstrain setConstant:0];
//        [_postImageDistanceFromLeftConstrain setConstant:0];
        distanceFromTop = 95.0f;
    }
    else
    {
        
        [_postImageDistanceFromTopConstrain setConstant:0];
        
//        [_postImageDistanceFromLeftConstrain setConstant:0];
        
        backgroundImageViewHeight -= 70.0f;
        
        distanceFromTop = 25.0f;
    }
    
    [_backgroundImageHeight setConstant:backgroundImageViewHeight];
    
    [_contentLabelHeightConstrain setConstant:height];
    
    [self.distanceFromTop setConstant:distanceFromTop];
    
    [self.mainViewHeight setConstant:height + fixedBottomViewHeight];
}

-(void)setPositionsForVideoWithHeight:(float)height
{
    float fixedBottomViewHeight = 400.0f;
    float backgroundImageViewHeight = 480.0f + height;
    float distanceFromTop = 0.0f;
    
    if([self isCurrentPostEvent])
    {
//        backgroundImageViewHeight = 490.0f;
        distanceFromTop = 85.0f;
    }
    else
    {
        backgroundImageViewHeight -= 63;
        distanceFromTop = 25.0f;
    }
    
    [_backgroundImageHeight setConstant:backgroundImageViewHeight];
    
    [self.distanceFromTop setConstant:distanceFromTop];
    
    [self.mainViewHeight setConstant:0.0f + fixedBottomViewHeight];
    
    
    [_contentLabelHeightConstrain setConstant:height];
    
    /** TODO: use them later. */
    
//    [_postImageDistanceFromTopConstrain setConstant:7];
//    [_postImageDistanceFromLeftConstrain setConstant:0];
    

}

#pragma mark - Media

-(void)savePostImage
{
    UIImageWriteToSavedPhotosAlbum(_postImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
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

-(void)setPostImage
{
    NSURL *imageUrl = nil;
    
    if(_post.imagesUrls.count > 0)
    {
        imageUrl = [NSURL URLWithString:_post.imagesUrls[0]];
        [self hideVideoView];
    }
    
    if(imageUrl!=nil && _post.tempImage==nil /**added**/ && _post.finalImage!=nil)
    {
        // Here we use the new provided setImageWithURL: method to load the web image
        //TODO: Removed for now.
        //[self.postImage setImageWithURL:url placeholderImage:[UIImage imageNamed:nil] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        //New approach.
        [_postImageView setImage:_post.finalImage];
        
        
        //[self setPostOnline:YES];
    }
    else if(_post.tempImage != nil)
    {
        //Set live image.
        [_postImageView setImage:_post.tempImage];
    }
    else if(_post.finalImage==nil && !self.imageNeedsToLoadAgain)
    {
        [_postImageView setImageWithURL:nil placeholderImage:[UIImage imageNamed:nil] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    if([self doesImageNeedLoadAgain])
    {
        [_postImageView setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:nil] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
}

-(void)setVideo
{
    if(_post.videosUrls && _post.videosUrls.count > 0)
    {
        [self showVideoView];
    }
}


-(void)showVideoView
{
    DDLogDebug(@"Video url: %@, Post content: %@", self.post.videosUrls[0], self.post.content);
    
    [_videoView setHidden:NO];
    [_postImageView setHidden:YES];
    [_videoView setUpPreviewWithUrl:self.post.videosUrls[0] withRemoteKey:_post.remoteKey];
//    [_videoView initialisePreviewWithUrl:self.post.videosUrls[0]];
}

-(void)hideVideoView
{
    [_videoView setHidden:YES];
    [_postImageView setHidden:NO];
}



#pragma mark - Online indicator

-(void)updateIndicatorWithRemoteKey:(NSInteger)remoteKey
{
    if(remoteKey!=0)
    {
        [_indicatorImageView setAlpha:0.0];
    }
    else
    {
        [self setPostOnline:NO];
        [self blinkIndicator];
    }
}

-(void)setPostOnline:(BOOL)online
{
    if(online)
    {
        [_indicatorImageView setBackgroundColor:[UIColor greenColor]];
    }
    else
    {
        [_indicatorImageView setBackgroundColor:[UIColor orangeColor]];
    }
}

-(void)blinkIndicator
{
    [_indicatorImageView setAlpha:1.0];
    
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseInOut animations:^{
        
        [_indicatorImageView setAlpha:0.0];
        
    } completion:^(BOOL finished) {
        
    }];
}


#pragma mark - Elements initialisation

-(void)formatElements
{
    NSAttributedString *contentAttributeText = nil;
    
    if(_contentLbl)
    {
       contentAttributeText = [[NSAttributedString alloc] initWithString:_contentLbl.text attributes:@{ NSKernAttributeName : @(0.3f)}];
    }
    

    [ShapeFormatterHelper setRoundedView:_indicatorImageView toDiameter:_indicatorImageView.frame.size.height];
    
    [ShapeFormatterHelper setRoundedView:_userImageView toDiameter:_userImageView.frame.size.height];

    [ShapeFormatterHelper setTopCornerRadius:_postImageView withViewFrame:_postImageView.frame withValue:0];
    
    [ShapeFormatterHelper setCornerRadiusWithView:_backgroundImageView andValue:5];
    
    [ShapeFormatterHelper setBorderToView:_backgroundImageView withColour:[UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f] andWidth:1.0f];
    
    _contentLbl.attributedText = contentAttributeText;
}

-(void)setTimeWithDate:(NSDate *)date
{
    //Add the post's time.
    [_timePostLbl setText:[date timeAgo]];
}

-(void)setUserImage
{
    NSURL *userImageUrl = [NSURL URLWithString:_post.author.profileImageUrl];
    
    [_userImageView setImageWithURL:userImageUrl placeholderImage:nil options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    //Add to the user's tag's image view the user id.
    _userImageView.tag = _post.author.remoteKey;
}

-(void)setLikeImageToButton
{
    if(_post.liked)
    {
        [_likeBtn setTitleColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationbar"]] forState:UIControlStateNormal];
        
        //Add the thumbs up selected version of image.
        [_likeBtn setImage:[UIImage imageNamed:@"icon_like_pushed"] forState:UIControlStateNormal];
        
    }
    else
    {
        [_likeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        //Add the thumbs up selected version of i   age.
        [_likeBtn setImage:[UIImage imageNamed:@"icon_like"] forState:UIControlStateNormal];
        
    }
}

-(void)configureIfComesFromViewPost
{
    if(_viewPost)
    {
        [_contentLbl setNumberOfLines:0];
        
        //Hide comment button.
        [_commentBtn setEnabled:NO];
//        [self.wideCommentBtn setEnabled:NO];
    }
}

-(void)configureGoingButton
{
    if([self isCurrentPostEvent])
    {
        [_goingBtn setHidden:NO];
    }
    else
    {
        [_goingBtn setHidden:YES];
    }
    
    if([self.post.dateEventStarts compare:[NSDate date]] == NSOrderedAscending)
    {
        [_goingBtn setImage:[UIImage imageNamed:@"going_expired"] forState:UIControlStateNormal];
        [_goingBtn setEnabled:NO];
    }
    else if(self.post.attended)
    {
        [_goingBtn setImage:[UIImage imageNamed:@"going_pressed"] forState:UIControlStateNormal];
        [_goingBtn setEnabled:YES];
        _goingBtn.tag = 1;
    }
    else
    {
        [_goingBtn setImage:[UIImage imageNamed:@"going"] forState:UIControlStateNormal];
        [_goingBtn setEnabled:YES];
        _goingBtn.tag = 2;
    }
}

-(void)configureMoreButton
{
    if([self isCurrentPostBelongsToCurrentUser])
    {
        [_moreBtn setHidden:NO];
    }
    else
    {
        [_moreBtn setHidden:YES];
    }
}

-(void)configureShareButton
{
    if([self isCurrentPostEvent])
    {
        [_shareBtn setHidden:NO];
    }
    else
    {
        [_shareBtn setHidden:YES];
    }
}

-(void)setCategories
{
    //Temp categories string.
    NSMutableString *categoriesStr = [NSMutableString string];
    
    for(GLPCategory *c in _post.categories)
    {
        [categoriesStr appendString:c.tag];
    }
    
    [categoriesStr appendString:@" General"];
}

-(void)addGesturesToElements
{
    [self addGestureToPostImage];
    
    [self addGestureToProfileImage];
}

-(void)addGestureToPostImage
{
    //Add selector to post image.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:_delegate action:@selector(viewPostImage:)];
    [tap setNumberOfTapsRequired:1];
    [_postImageView addGestureRecognizer:tap];
}

-(void)addGestureToProfileImage
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:_delegate action:@selector(navigateToProfile:)];
    [tap setNumberOfTapsRequired:1];
    [_userImageView addGestureRecognizer:tap];
}

#pragma mark - UI changes

-(void)makeButtonSelected
{
    [_goingBtn setImage:[UIImage imageNamed:@"going_pressed"] forState:UIControlStateNormal];
    _goingBtn.tag = 1;
}

-(void)makeButtonUnselected
{
    [_goingBtn setImage:[UIImage imageNamed:@"going"] forState:UIControlStateNormal];
    _goingBtn.tag = 2;
}

#pragma mark - Helper methods

-(BOOL)isCurrentPostEvent
{
    if(self.post.eventTitle == nil)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

-(BOOL)isCurrentPostBelongsToCurrentUser
{
    return ([SessionManager sharedInstance].user.remoteKey == self.post.author.remoteKey);
}

#pragma mark - Actions

-(IBAction)likePost:(id)sender
{
    //If like button is pushed then set the pushed variable to NO and change the colour of the image.
    
    if([self.post liked])
    {
        [self.post setLiked:NO];
        
        //Change the like status and send to server the change.
        [self postLike:NO withPostRemoteKey:[self.post remoteKey]];
        
        //Decrease the number of likes.
        --self.post.likes;
    }
    else
    {
        [self.post setLiked:YES];
        
        //Change the like status and send to server the change.
        [self postLike:YES withPostRemoteKey:[self.post remoteKey]];
        
        //Increase the number of likes.
        ++self.post.likes;
    }
    
    [self setLikeImageToButton];
    
    //Update post in local database.
    [GLPPostManager updatePostWithLiked:self.post];
    
    [GLPPostNotificationHelper updatePostWithNotifiationName:@"GLPPostUpdated" withObject:self remoteKey:self.post.remoteKey numberOfLikes:self.post.likes andNumberOfComments:self.post.commentsCount];
    
    [GLPPostNotificationHelper updatePostWithNotifiationName:@"GLPLikedPostUdated" withObject:self remoteKey:self.post.remoteKey withLiked:self.post.liked];
}

-(IBAction)commentPost:(id)sender
{
    [_delegate commentButtonSelected];
}

-(IBAction)sharePost:(id)sender
{
    UIActionSheet *actionSheet = nil;
    
    actionSheet = [[UIActionSheet alloc]initWithTitle:@"Share Post" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Share to Facebook", @"More options", nil];
    
    [_delegate showViewOptionsWithActionSheer:actionSheet];

}

-(IBAction)goingToEvent:(id)sender
{
    if(_goingBtn.tag == 1)
    {
        //Not attend.
        [self notAttendingToEvent];
        [self makeButtonUnselected];
        
    }
    else if(_goingBtn.tag == 2)
    {
        //Attend.
        [self attendingToEvent];
        [self makeButtonSelected];
        //        [_goingButton setImage:[UIImage imageNamed:@"going_pressed"] forState:UIControlStateNormal];
        //        _goingButton.tag = 1;
        
    }
}

-(IBAction)moreOptions:(id)sender
{
    //Pop up a bottom menu.
    
    UIActionSheet *actionSheet = nil;
    
    if([_post imagePost])
    {
        actionSheet = [[UIActionSheet alloc]initWithTitle:@"More" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Save image", nil];
    }
    else
    {
        actionSheet = [[UIActionSheet alloc]initWithTitle:@"More" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
    }
    
//    if([self isCurrentPostBelongsToCurrentUser])
//    {
//        if([self isCurrentPostEvent])
//        {
//            actionSheet = [[UIActionSheet alloc]initWithTitle:@"More" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles: @"Share to Facebook", @"More options", nil];
//        }
//        else
//        {
//            actionSheet = [[UIActionSheet alloc]initWithTitle:@"More" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles: nil];
//        }
//    }
//    else if([self isCurrentPostEvent])
//    {
//        actionSheet = [[UIActionSheet alloc]initWithTitle:@"More" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Share to Facebook", @"More options", nil];
//    }
    
    [_delegate showViewOptionsWithActionSheer:actionSheet];
}

#pragma mark - Client

-(void)postLike:(BOOL)like withPostRemoteKey:(int)postRemoteKey
{
    [[WebClient sharedInstance] postLike:like forPostRemoteKey:postRemoteKey callbackBlock:^(BOOL success) {
        
        if(success)
        {
            DDLogInfo(@"Like %d for post %d succeed.",like, postRemoteKey);
        }
        else
        {
            DDLogInfo(@"Like %d for post %d not succeed.",like, postRemoteKey);
        }
        
        
    }];
}

-(void)notAttendingToEvent
{
    self.post.attended = NO;
    
    [[WebClient sharedInstance] attendEvent:NO withPostRemoteKey:self.post.remoteKey callbackBlock:^(BOOL success, NSInteger popularity) {
        
        if(success)
        {
            //Update local database.
            [GLPPostManager updatePostAttending:self.post];
        }
        else
        {
            [self makeButtonSelected];
            
            [WebClientHelper showStandardError];
        }
        
    }];
}

-(void)attendingToEvent
{
    self.post.attended = YES;
    
    [[WebClient sharedInstance] attendEvent:YES withPostRemoteKey:self.post.remoteKey callbackBlock:^(BOOL success, NSInteger popularity) {
        
        if(success)
        {
            //Update local database.
            [GLPPostManager updatePostAttending:self.post];
        }
        else
        {
            [self makeButtonUnselected];
            
            [WebClientHelper showStandardError];
            
        }
        
    }];
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
        [_delegate deleteCurrentPost];
    }
    else if ([selectedButtonTitle isEqualToString:@"Save image"])
    {
        //Save image to camera roll.
        [self savePostImage];
    }
    else if ([selectedButtonTitle isEqualToString:@"Report"])
    {
        //Report post.
        DDLogDebug(@"Report");
        
    }
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
    
    [_delegate showShareViewWithItems:shareItems];
}

#pragma mark - Temporary methods

-(NSString *)content
{
    return _contentLbl.text;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
