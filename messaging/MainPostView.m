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

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (weak, nonatomic) IBOutlet VideoView *videoView;

@property (weak, nonatomic) IBOutlet UIImageView *indicatorImageView;

@property (weak, nonatomic) IBOutlet UIImageView *postImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topBackgroundHeightConstrain;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelHeightConstrain;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceFromTopView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceFromTop;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainViewHeight;

@property (strong, nonatomic) GLPPost *post;

@property (assign, nonatomic) BOOL mediaAvailable;

@property (assign, nonatomic, getter = doesImageNeedLoadAgain) BOOL imageNeedsToLoadAgain;

@property (assign, nonatomic, getter = isViewPost) BOOL viewPost;

@end

@implementation MainPostView

const float FIXED_TOP_BACKGROUND_HEIGHT = 70;
const float FIXED_BOTTOM_VIEW_HEIGHT = 100;


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


#pragma mark - Modifiers

-(void)setElementsWithPost:(GLPPost *)post withViewPost:(BOOL)viewPost
{
    /** TODO: See if this assign is good. */
    _post = post;
    
    [_likesLbl setText:[NSString stringWithFormat:@"%ld", (long)post.likes]];

    [_commentsLbl setText:[NSString stringWithFormat:@"%ld", (long)post.commentsCount]];
    
    [_contentLbl setText:post.content];
    
    [_nameLbl setText:post.author.name];
    
    [self addGesturesToElements];
    
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


}

-(void)setNewHeightDependingOnLabelHeight:(float)height
{
    [_contentLabelHeightConstrain setConstant:height];
    [_topBackgroundHeightConstrain setConstant:height+FIXED_TOP_BACKGROUND_HEIGHT];
    
    [_distanceFromTopView setConstant:16];
    
    if([self isCurrentPostEvent])
    {
        [self.distanceFromTop setConstant:81];
    }
    else
    {
        [self.distanceFromTop setConstant:5];
    }
    
    [self.mainViewHeight setConstant:height + FIXED_BOTTOM_VIEW_HEIGHT];

}

#pragma mark - Media

-(void)setPostImage
{
    NSURL *imageUrl = nil;
    
    if(_post.imagesUrls.count > 0)
    {
        imageUrl = [NSURL URLWithString:_post.imagesUrls[0]];
        _mediaAvailable = YES;
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
    [_videoView setHidden:NO];
    [_postImageView setHidden:YES];
    [_videoView setUpPreviewWithUrl:self.post.videosUrls[0]];
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
    NSAttributedString *contentAttributeText = [[NSAttributedString alloc] initWithString:_contentLbl.text
                                                            attributes:@{ NSKernAttributeName : @(0.3f)}];
    
    [ShapeFormatterHelper setRoundedView:_indicatorImageView toDiameter:_indicatorImageView.frame.size.height];
    
    [ShapeFormatterHelper setRoundedView:_userImageView toDiameter:_userImageView.frame.size.height];

    [ShapeFormatterHelper setTopCornerRadius:_postImageView withViewFrame:_postImageView.frame withValue:8];
    
    _contentLbl.attributedText = contentAttributeText;
    
    [ShapeFormatterHelper setTwoBottomCornerRadius:_socialView withViewFrame:_socialView.frame withValue:10];

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
    if([self isCurrentPostBelongsToCurrentUser] || [self isCurrentPostEvent])
    {
        [_moreBtn setHidden:NO];
        
    }
    else
    {
        [_moreBtn setHidden:YES];
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
    //Add selector to post image.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:_delegate action:@selector(viewPostImage:)];
    [tap setNumberOfTapsRequired:1];
    [_postImageView addGestureRecognizer:tap];
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

#warning implementation pending.

-(IBAction)sharePost:(id)sender
{
    
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
    
    if([self isCurrentPostBelongsToCurrentUser])
    {
        if([self isCurrentPostEvent])
        {
            actionSheet = [[UIActionSheet alloc]initWithTitle:@"More" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles: @"Share to Facebook", @"More options", nil];
        }
        else
        {
            actionSheet = [[UIActionSheet alloc]initWithTitle:@"More" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles: nil];
        }
    }
    else if([self isCurrentPostEvent])
    {
        actionSheet = [[UIActionSheet alloc]initWithTitle:@"More" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Share to Facebook", @"More options", nil];
    }
    
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
    
    NSArray * excludeActivities = @[UIActivityTypeAssignToContact, UIActivityTypePostToWeibo, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypePostToFacebook, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    
    //UIActivityTypePostToFlickr UIActivityTypeSaveToCameraRoll
    
    shareItems.excludedActivityTypes = excludeActivities;
    
    [_delegate showShareViewWithItems:shareItems];
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
