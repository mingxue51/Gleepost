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
#import "TopPostView.h"
#import "AppearanceHelper.h"
#import "UIColor+GLPAdditions.h"
#import "NSNotificationCenter+Utils.h"
#import "GLPImageHelper.h"
#import "GLPPostImageLoader.h"
#import "GLPImageHelper.h"
#import "GLPThemeManager.h"
#import "GLPViewsCountView.h"
#import "PollingPostView.h"

@interface MainPostView ()

@property (weak, nonatomic) IBOutlet UIView *socialView;

@property (weak, nonatomic) IBOutlet UILabel *likesLbl;

@property (weak, nonatomic) IBOutlet UILabel *pollTitleLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pollTitleLabelHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pollImageViewHeight;

@property (weak, nonatomic) IBOutlet UILabel *commentsLbl;

@property (weak, nonatomic) IBOutlet UILabel *timePostLbl;

@property (weak, nonatomic) IBOutlet GLPLabel *nameLbl;

@property (weak, nonatomic) IBOutlet UILabel *contentLbl;

@property (weak, nonatomic) IBOutlet UIButton *likeBtn;

@property (weak, nonatomic) IBOutlet UIButton *commentBtn;

@property (weak, nonatomic) IBOutlet UIButton *wideCommentBtn;

@property (weak, nonatomic) IBOutlet UIButton *wideShareBtn;
           
@property (weak, nonatomic) IBOutlet UIButton *goingBtn;

@property (weak, nonatomic) IBOutlet UIButton *moreBtn;

@property (weak, nonatomic) IBOutlet UIButton *shareBtn;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (weak, nonatomic) IBOutlet VideoView *videoView;

@property (weak, nonatomic) IBOutlet PollingPostView *pollingView;

@property (weak, nonatomic) IBOutlet UIImageView *indicatorImageView;

@property (weak, nonatomic) IBOutlet UIImageView *postImageView;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

//@property (weak, nonatomic) IBOutlet UILabel *viewsCountLabel;

@property (weak, nonatomic) IBOutlet UIView *loadingView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingViewIndicator;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelHeightConstrain;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceFromTopView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceFromTop;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainViewHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundImageHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loadingViewHeight;

@property (weak, nonatomic) IBOutlet UIView *userView;

@property (weak, nonatomic) IBOutlet GLPViewsCountView *viewsCountView;

//This variable is temporary.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceBetweenTitleAndClockView;

/** Image constrains. */
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postImageWidthConstrain;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postImageDistanceFromTopConstrain;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postImageDistanceFromLeftConstrain;

/** Constrains have to do with video. */

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceUserViewFromThePostImageConstrain;

//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postImageDistanceFromRightConstrain;

@property (strong, nonatomic) GLPPost *post;

@property (assign, nonatomic, getter = doesMediaNeedLoadAgain) BOOL mediaNeedsToReload;

@property (assign, nonatomic, getter = isViewPost) BOOL viewPost;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation MainPostView

const float FIXED_TOP_TEXT_BACKGROUND_HEIGHT = 70;
const float FIXED_BOTTOM_TEXT_VIEW_HEIGHT = 114; //100

const float FIXED_TOP_MEDIA_BACKGROUND_HEIGHT = 250;
const float FIXED_BOTTOM_MEDIA_VIEW_HEIGHT = 330; //315

#pragma mark - Modifiers

-(void)setElementsWithPost:(GLPPost *)post withViewPost:(BOOL)viewPost
{
    /** TODO: See if this assign is good. */
    _post = post;
    
    [self formatElements];
    
    if(_post.sendStatus == kSendStatusLocalEdited)
    {        
        [_loadingView setHidden:NO];
        
        [_loadingViewIndicator startAnimating];
        
        return;
    }
    else
    {
        [_loadingView setHidden:YES];
    }
    
    [self showOrHideLikeLabel];
    
    [self showOrHideCommentsLabel];
    
    [_likesLbl setText:[NSString stringWithFormat:@"%ld", (long)post.likes]];

    [_commentsLbl setText:[NSString stringWithFormat:@"%ld", (long)post.commentsCount]];
    
    [_contentLbl setText:post.content];
    
    [_nameLbl setText:post.author.name];
    [_nameLbl setTextColor:[[GLPThemeManager sharedInstance] nameTintColour]];
    _nameLbl.tag = _post.author.remoteKey;
    
    [_viewsCountView setViewsCount:_post.viewsCount];
    
    _viewPost = viewPost;
    
    [self configureIfComesFromViewPost];
    
    //Set like button status.
    [self setLikeImageToButton];
    
    [self setCategories];
    
    [self setTimeWithDate:post.date];
    
    [self setUserImage];
    
    [self setPostImage];
    
    [self setVideo];
    
    [self setPoll];
    
    [self updateIndicatorWithRemoteKey:post.remoteKey];
    
    [self configureGoingButton];
    
    [self configureMoreButton];
    
    [self configureShareButton];
    
    [self addGesturesToElements];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POST_CELL_VIEWS_UPDATE object:nil];
    
    
    if([_post isVideoPost])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNewViewsCount:) name:GLPNOTIFICATION_POST_CELL_VIEWS_UPDATE object:nil];
    }
    
    
//    [ShapeFormatterHelper setBorderToView:_videoView withColour:[UIColor redColor] andWidth:1.0];
//    [ShapeFormatterHelper setBorderToView:_wideCommentBtn withColour:[UIColor redColor]];
    
//    [ShapeFormatterHelper setBorderToView:self.pollTitleLabel withColour:[UIColor blueColor]];
    
//    [ShapeFormatterHelper setBorderToView:self withColour:[UIColor blueColor] andWidth:1.0];
    
//    [ShapeFormatterHelper setBorderToView:_commentBtn withColour:[UIColor redColor]];
//    
//    [ShapeFormatterHelper setBorderToView:_wideCommentBtn withColour:[UIColor blackColor]];
//    
//    [ShapeFormatterHelper setBorderToView:_shareBtn withColour:[UIColor greenColor]];
}

- (void)willRemoveSubview:(UIView *)subview
{
    if([subview.class isSubclassOfClass:[PollingPostView class]])
    {
        DDLogDebug(@"MainPostView willRemoveSubview %@", [subview class]);

        //Deregister ns notifications from polling post view.
        [self.pollingView deregisterNotifications];
    }
}


- (void)setNewViewsCount:(NSNotification *)viewsCountNotification
{
    NSInteger postRemoteKey = [viewsCountNotification.userInfo[@"PostRemoteKey"] integerValue];
    NSInteger viewsCount = [viewsCountNotification.userInfo[@"UpdatedViewsCount"] integerValue];
    
    if(postRemoteKey != self.post.remoteKey)
    {
        return;
    }
    
    FLog(@"MainPostView : setNewViewsCount %@", viewsCountNotification);

    _post.viewsCount = viewsCount;
    [_viewsCountView setViewsCount:viewsCount];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POST_CELL_VIEWS_UPDATE object:nil];
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
    float distanceFromTop = 0.0f;
    float fixedBottomViewHeight = FIXED_BOTTOM_TEXT_VIEW_HEIGHT;
    float backgroundImageViewHeight = 219.0f + height;
    
    if([self isCurrentPostEvent])
    {
        distanceFromTop = 111.0f;
        
        distanceFromTop = [self configureDistanceFromTopDependingOnFactor:17 withBasicValue:distanceFromTop];
        
        if([TopPostView isTitleTextOneLineOfCodeWithContent:_post.eventTitle])
        {
            backgroundImageViewHeight -= 15;
        }
    }
    else
    {
        distanceFromTop = 28.0f;
        backgroundImageViewHeight -= 80.0f;
    }
    
    //Set constrains.
    [_backgroundImageHeight setConstant:backgroundImageViewHeight];
    
    [_distanceFromTop setConstant:distanceFromTop];

    
    [self.mainViewHeight setConstant:height + fixedBottomViewHeight];

    [_contentLabelHeightConstrain setConstant:height];

}

-(void)setPositionsForImagePostWithHeight:(float)height
{
    float backgroundImageViewHeight = 0.0f;
    float fixedBottomViewHeight = 0.0f;
    float distanceFromTop = 0.0f;
    
    backgroundImageViewHeight = 416.0f + height;  //388 //new 402 + 14
    fixedBottomViewHeight = FIXED_BOTTOM_MEDIA_VIEW_HEIGHT;
    
    if([self isCurrentPostEvent])
    {
        [_postImageDistanceFromTopConstrain setConstant:0];

        distanceFromTop = 95; //83

        distanceFromTop = [self configureDistanceFromTopDependingOnFactor:15 withBasicValue:distanceFromTop];

        if([TopPostView isTitleTextOneLineOfCodeWithContent:_post.eventTitle])
        {
            backgroundImageViewHeight -= 15.0f;
            _distanceBetweenTitleAndClockView.constant = 5;
        }
        else
        {
            _distanceBetweenTitleAndClockView.constant = 3;
        }
        
    }
    else
    {
        
        [_postImageDistanceFromTopConstrain setConstant:0];
        
        backgroundImageViewHeight -= (90.0f - 22); //70
        distanceFromTop = 25.0f;
    }
    
    [_backgroundImageHeight setConstant:backgroundImageViewHeight];
    
    [_loadingViewHeight setConstant:backgroundImageViewHeight];
    
    [_contentLabelHeightConstrain setConstant:height];
    
    [self.distanceFromTop setConstant:distanceFromTop];
    
    [self.mainViewHeight setConstant:height + fixedBottomViewHeight];
}

-(void)setPositionsForVideoWithHeight:(float)height
{
    float fixedBottomViewHeight = 459.0f;
    float backgroundImageViewHeight = 538.0f + height;
    float distanceFromTop = 0.0f;
    
    if([self isCurrentPostEvent])
    {
//        backgroundImageViewHeight = 490.0f;
        distanceFromTop = 93.0f;  //100
        
        distanceFromTop = [self configureDistanceFromTopDependingOnFactor:21.0f withBasicValue:distanceFromTop];
        
        if([TopPostView isTitleTextOneLineOfCodeWithContent:_post.eventTitle])
        {
            backgroundImageViewHeight -= 21.0f;
        }
    }
    else
    {
        backgroundImageViewHeight -= 75;
        distanceFromTop = 20.0f;
    }
    
    [_backgroundImageHeight setConstant:backgroundImageViewHeight];
    
    [_loadingViewHeight setConstant:backgroundImageViewHeight];
    
    [self.distanceFromTop setConstant:distanceFromTop];
    
    [self.mainViewHeight setConstant:height + fixedBottomViewHeight];
    
    
    [_contentLabelHeightConstrain setConstant:height];
    
//    [ShapeFormatterHelper setBorderToView:self withColour:[UIColor redColor]];
    
    /** TODO: use them later. */
    
//    [_postImageDistanceFromTopConstrain setConstant:7];
//    [_postImageDistanceFromLeftConstrain setConstant:0];
    

}

/**
 Finds and returns the distance from top depending on the number of lines of title
 and the factor that is passed as a parameter. Each factor is different depending
 on each different post cell.
 
 @param factor.
 
 @return the final distance from top.
 */
- (float)configureDistanceFromTopDependingOnFactor:(float)factor withBasicValue:(float)basicValue
{
    BOOL oneLineOfTitle = [TopPostView isTitleTextOneLineOfCodeWithContent:_post.eventTitle];
    
    if(oneLineOfTitle)
    {
        return (basicValue - factor);
    }

    return basicValue;
}

- (void)setMediaNeedsToReload:(BOOL)imageNeedsToReload
{
    _mediaNeedsToReload = imageNeedsToReload;
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
    
    if([self doesMediaNeedLoadAgain])
    {
        [_activityIndicator stopAnimating];
        [_postImageView setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:nil] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        return;
    }
    
    if(self.isViewPost && _postImageView.image != nil)
    {
        [_activityIndicator stopAnimating];
        return;
    }
    
    if(_postImageView.image != nil && self.post.remoteKey == _postImageView.tag)
    {
        [_activityIndicator stopAnimating];
        return;
    }
    
    _postImageView.tag = self.post.remoteKey;
    
    [_postImageView setImage:nil];
    

    //This happens only when the image is not fetched or is save in cache.
    if(imageUrl!=nil && _post.tempImage==nil)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        // Look in cache and request for the image.
        [[GLPPostImageLoader sharedInstance] findImageWithUrl:imageUrl callback:^(UIImage *image, BOOL found) {
            
            if (found)
            {
                    if([imageUrl.absoluteString isEqualToString:_post.imagesUrls[0]])
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{

                            [_postImageView setImage:image];
                            [_activityIndicator stopAnimating];
                            
                        });
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{

                            DDLogDebug(@"Image not the same, abord");
                            [_postImageView setImage:nil];
                        });
                    }
            }
            
        }];
            
            });
    }
    //This now is used ONLY when the image is fetched for the first time.
//    else if(imageUrl!=nil && _post.tempImage==nil && _post.finalImage!=nil)
//    {
//        DDLogDebug(@"THIS SHOULD NOT BE USED ANYMORE");
//        
//        [_postImageView setImage:_post.finalImage];
//        
//        [_activityIndicator stopAnimating];
//    }
    else if(_post.tempImage != nil)
    {
        //Set live image.
        [_postImageView setImage:_post.tempImage];
        [_activityIndicator stopAnimating];

    }
    else if(_post.finalImage==nil && !self.mediaNeedsToReload)
    {
//        [_postImageView sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:nil]];
        
        [_postImageView setImage:nil];
        
        [_activityIndicator startAnimating];

    }
}

-(void)setVideo
{
    if([_post isVideoPost])
    {
        [self showVideoView];
    }
}

-(void)showVideoView
{
//    if([_videoView isVideoLoading])
//    {
//        DDLogDebug(@"MainPostView : Video is loading");
//        
//        return;
//    }
    
    [_activityIndicator stopAnimating];
    [_videoView setHidden:NO];
    [_postImageView setHidden:YES];
    DDLogDebug(@"MainPostView : New video %@", _post.video);
    
    [_videoView setUpVideoViewWithPost:_post];
//    [_videoView setUpPreviewWithUrl:self.post.videosUrls[0] withRemoteKey:_post.remoteKey];
//    [_videoView initialisePreviewWithUrl:self.post.videosUrls[0]];
}

- (void)deregisterNotificationsForVideoView
{
    [_videoView deregisterNotifications];
}

-(void)hideVideoView
{
    [_activityIndicator startAnimating];
    
    [_videoView setHidden:YES];
    [_postImageView setHidden:NO];
}

#pragma mark - Poll

- (void)setPoll
{
    if([_post isPollPost])
    {
        self.pollTitleLabel.text = [NSString stringWithFormat:@"%@", _post.content];
        self.pollTitleLabelHeight.constant = [PollingPostView pollingTitleHeightWithText:self.post.content];
        [self.pollingView setPollData:self.post.poll withPostRemoteKey:self.post.remoteKey];
        [self configurePollImageView];
    }
}

- (void)configurePollImageView
{
    if([self.post imagePost])
    {
        self.pollImageViewHeight.constant = 130.0;
    }
    else
    {
        self.pollImageViewHeight.constant = 0.0;
        [self.activityIndicator stopAnimating];
    }
}

#pragma mark - Online indicator

-(void)updateIndicatorWithRemoteKey:(NSInteger)remoteKey
{
    if(remoteKey != 0)
    {
        [_indicatorImageView setAlpha:0.0];
        [self.layer removeAllAnimations];
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
    
    if([self.post isPollPost])
    {
        [ShapeFormatterHelper setCornerRadiusWithView:self andValue:5];
        [ShapeFormatterHelper setBorderToView:self withColour:[AppearanceHelper mediumGrayGleepostColour] andWidth:1.0f];
    }
    
    [ShapeFormatterHelper setRoundedView:_indicatorImageView toDiameter:_indicatorImageView.frame.size.height];
    
    [ShapeFormatterHelper setRoundedView:_userImageView toDiameter:_userImageView.frame.size.height];

//    [ShapeFormatterHelper setTopCornerRadius:_postImageView withViewFrame:_postImageView.frame withValue:0];
    
    [ShapeFormatterHelper setCornerRadiusWithView:_backgroundImageView andValue:5];
    
    [ShapeFormatterHelper setBorderToView:_backgroundImageView withColour:[AppearanceHelper mediumGrayGleepostColour] andWidth:1.0f];
    
    [ShapeFormatterHelper setCornerRadiusWithView:_loadingView andValue:5];
    
    [ShapeFormatterHelper setBorderToView:_loadingView withColour:[AppearanceHelper mediumGrayGleepostColour] andWidth:1.0f];
    
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
    
    [_userImageView sd_setImageWithURL:userImageUrl placeholderImage:[GLPImageHelper placeholderUserImage] options:SDWebImageRetryFailed];
    
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
        [_wideCommentBtn setEnabled:NO];
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
//        [_goingBtn setImage:[UIImage imageNamed:@"going_expired"] forState:UIControlStateNormal];
//        [_goingBtn setEnabled:NO];
        [_goingBtn setHidden:YES];

    }
    else if(self.post.attended)
    {
        //[_goingBtn setImage:[UIImage imageNamed:@"going_pushed_back_btn"] forState:UIControlStateNormal];
//        [_goingBtn setBackgroundImage:[UIImage imageNamed:@"going_pushed_back_btn"] forState:UIControlStateNormal];
//        _goingBtn.tintColor = [UIColor whiteColor];
//        [_goingBtn setEnabled:YES];
//        _goingBtn.tag = 1;
        
        [self makeButtonSelected];
    }
    else
    {
//        [_goingBtn setImage:[UIImage imageNamed:@"going_unpushed_back_btn"] forState:UIControlStateNormal];
//        [_goingBtn setBackgroundImage:[UIImage imageNamed:@"going_unpushed_back_btn"] forState:UIControlStateNormal];
//        _goingBtn.tintColor = [AppearanceHelper grayGleepostColour];
//        [_goingBtn setEnabled:YES];
//        _goingBtn.tag = 2;
        
        [self makeButtonUnselected];
        
    }
}

-(void)configureMoreButton
{
    if([self isCurrentPostEvent])
    {
        [_moreBtn setHidden:YES];
        
        return;
    }
    else
    {
        [_moreBtn setHidden:NO];
    }
    
//    if([self isCurrentPostBelongsToCurrentUser])
//    {
//        [_moreBtn setHidden:NO];
//    }
//    else
//    {
//        [_moreBtn setHidden:YES];
//    }
}

-(void)configureShareButton
{
    [_shareBtn setHidden:NO];
    [_wideShareBtn setHidden:NO];
    
//    if([self isCurrentPostEvent])
//    {
//        [_shareBtn setHidden:NO];
//        [_wideShareBtn setHidden:NO];
//    }
//    else
//    {
//        [_shareBtn setHidden:YES];
//        [_wideShareBtn setHidden:YES];
//    }
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
    
    [self addGesturesToLabels];
}

-(void)addGesturesToLabels
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:_delegate action:@selector(likePost:)];
    [tap setNumberOfTapsRequired:1];
    [_likesLbl addGestureRecognizer:tap];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:_delegate action:@selector(commentPost:)];
    [tap setNumberOfTapsRequired:1];
    [_commentsLbl addGestureRecognizer:tap];
    
    [_nameLbl setDelegate:self];
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
//    [_goingBtn setImage:[UIImage imageNamed:@"going_pressed"] forState:UIControlStateNormal];
    [_goingBtn setBackgroundImage:[UIImage imageNamed:@"going_pushed_back_btn"] forState:UIControlStateNormal];
    [_goingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    _goingBtn.tag = 1;
}

-(void)makeButtonUnselected
{
//    [_goingBtn setImage:[UIImage imageNamed:@"going"] forState:UIControlStateNormal];
    [_goingBtn setBackgroundImage:[UIImage imageNamed:@"going_unpushed_back_btn"] forState:UIControlStateNormal];
    [_goingBtn setTitleColor:[UIColor colorWithR:70.0 withG:70.0 andB:70.0] forState:UIControlStateNormal];

    _goingBtn.tag = 2;
}


/**
 Shows or hides like label depending on how many likes there are on the post.
 */
- (void)showOrHideLikeLabel
{
    if(_post.likes == 0)
    {
        [_likesLbl setHidden:YES];
    }
    else
    {
        [_likesLbl setHidden:NO];
    }
}

/**
 Shows or hides comments label depending on how many comments there are on the post.
 */
- (void)showOrHideCommentsLabel
{
    if(_post.commentsCount == 0)
    {
        [_commentsLbl setHidden:YES];
    }
    else
    {
        [_commentsLbl setHidden:NO];
    }
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
    
    [self showOrHideLikeLabel];
    
    //Update like label.
    [_likesLbl setText:[NSString stringWithFormat:@"%ld", (long)_post.likes]];
    
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
        DDLogDebug(@"MainPostView : goingToEvent");

        //Not attend.
        [self notAttendingToEvent];
        [self makeButtonUnselected];
        [self sendNotificationGoingUnpressed];
        
    }
    else if(_goingBtn.tag == 2)
    {
        //Attend.
        [self attendingToEvent];
        [self makeButtonSelected];
        [self notifyViewPostAfterGoingPressed];
    }
    
    if(self.viewPost)
    {
        [self notifyToRefreshThePostInCampusWall];
    }
}

-(IBAction)moreOptions:(id)sender
{
    //Pop up a bottom menu.
    
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
    
    [_delegate showViewOptionsWithActionSheer:actionSheet];
}

#pragma mark - Notifications

- (void)notifyViewPostAfterGoingPressed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_GOING_BUTTON_TOUCHED object:self userInfo:@{@"post" : _post, @"attend" : @(YES), @"post_image" : _postImageView.image}];
}

- (void)sendNotificationGoingUnpressed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_GOING_BUTTON_UNTOUCHED object:self userInfo:@{@"post" : _post, @"attend" : @(NO), @"post_image" : _postImageView.image}];
}

- (void)notifyToRefreshThePostInCampusWall
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GLPPostUpdated" object:self userInfo:@{@"RemoteKey":@(_post.remoteKey)}];

}

#pragma mark - Client

-(void)postLike:(BOOL)like withPostRemoteKey:(NSInteger)postRemoteKey
{
    [[WebClient sharedInstance] postLike:like forPostRemoteKey:postRemoteKey callbackBlock:^(BOOL success) {
        
        if(success)
        {
            DDLogInfo(@"Like %d for post %ld succeed.",like, (long)postRemoteKey);
        }
        else
        {
            DDLogInfo(@"Like %d for post %ld not succeed.",like, (long)postRemoteKey);
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
            
            [WebClientHelper showInternetConnectionErrorWithTitle:@"Not attending to the event failed."];
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
            
            [WebClientHelper showInternetConnectionErrorWithTitle:@"Attending to the event failed."];
            
        }
        
    }];
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

#pragma mark - GLPLabelDelegate

- (void)labelTouchedWithTag:(NSInteger)tag
{
    [_delegate navigateToProfile:_nameLbl];
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
        [self reportCurrentPost];
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
