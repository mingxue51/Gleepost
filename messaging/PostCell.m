//
//  PostCell.m
//  Gleepost
//
//  Created by Σιλουανός on 11/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "PostCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "NSDate+TimeAgo.h"
#import "ShapeFormatterHelper.h"
#import "ViewPostViewController.h"
#import "WebClient.h"
#import "NewCommentView.h"
#import "GLPPostManager.h"
#import "GLPPostNotificationHelper.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "GLPCategory.h"
#import "ImageFormatterHelper.h"

@interface PostCell()

@property (strong, nonatomic) GLPPost *post;
@property (assign, nonatomic) int postIndex;
@property (assign, nonatomic) float initialPostContentLabelY;
@property (assign, nonatomic) float initialPostContentLabelHeight;
@property (assign, nonatomic) CGRect labelDimensions;
@property (assign, nonatomic) float socialPanelY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textLabelConstrain;
@property (assign, nonatomic) BOOL freshPost;
@property (assign, nonatomic) BOOL isViewPostNotifications;

//@property (strong, nonatomic) UIView *lineView;
@end

@implementation PostCell

const float IMAGE_CELL_HEIGHT = 270;
const float TEXT_CELL_HEIGHT = 70;


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        self.socialPanelY = self.socialPanel.frame.origin.y;
        
        self.labelDimensions = CGRectMake(60.0f, 30.0f, 250.0f, 50.0f);

        
        self.isViewPost = NO;
        self.isViewPostNotifications = NO;
        
//        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.frame.size.height-1, self.contentView.frame.size.width, 1)];
//
//        self.lineView.backgroundColor = [UIColor colorWithRed:217.0f/255.0f green:228.0f/255.0f blue:234.0f/255.0f alpha:0.4];
//        [self.contentView addSubview:self.lineView];
        
//        NSLog(@"Label content Y: %f",self.contentLbl.frame.origin.y);
//        self.initialPostContentLabelY = 37;
//        self.initialPostContentLabelHeight = self.contentLbl.frame.size.height;

    }
    
    return self;
}


static const float FixedSizeOfTextCell = TEXT_CELL_HEIGHT; //110 before.
static const float FixedSizeOfImageCell = IMAGE_CELL_HEIGHT;
static const float FollowingCellPadding = 7;
static const float PostContentViewPadding = 10;  //15 before. 10 before.
static const float PostContentLabelMaxWidth = 300;
static const float FollowingSocialPanel = 40;
static const float OneLinePadding = 10;
//static const float ThreeLinesLimit = 62.0;
static const float FiveLinesLimit = 76.0;
static const float OneLineText = 16.0;

-(void) updateWithPostData:(GLPPost *)postData withPostIndex:(int)postIndex
{
    self.post = postData;
    self.postIndex = postIndex;
    
    self.imageAvailable = NO;
    [self updateOnlinePost:postData.remoteKey];
    
    //Format uploaded indicator.
    [ShapeFormatterHelper setRoundedView:self.uploadedIndicator toDiameter:self.uploadedIndicator.frame.size.height];
    
    
    //Change the mode of the post imageview.
    //self.postImage.contentMode = UIViewContentModeScaleAspectFill;
   // self.postImage.autoresizingMask = (UIViewAutoresizingNone);
    
    [self.contentLbl setText:self.post.content];

    NSURL *url = nil;

    for(NSString* str in postData.imagesUrls)
    {
        url = [NSURL URLWithString:str];
        self.imageAvailable = YES;
        break;
    }
    
    
    UIImage *userImage;
    
    //Add the default image.
    userImage = [UIImage imageNamed:@"default_user_image"];

    
    if(url!=nil && postData.tempImage==nil /**added**/ && postData.finalImage!=nil)
    {
        // Here we use the new provided setImageWithURL: method to load the web image
        //TODO: Removed for now.
        //[self.postImage setImageWithURL:url placeholderImage:[UIImage imageNamed:nil] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        //New approach.
        [self.postImage setImage:postData.finalImage];
        
        
        //[self setPostOnline:YES];
    }
    else if(postData.tempImage != nil)
    {
        //Set live image.
        [self.postImage setImage:postData.tempImage];
    }
    else if(postData.finalImage==nil && !self.isViewPostNotifications)
    {
        [self.postImage setImageWithURL:nil placeholderImage:[UIImage imageNamed:nil] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    if(self.isViewPostNotifications)
    {
        [self.postImage setImageWithURL:url placeholderImage:[UIImage imageNamed:nil] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    
    NSURL *userImageUrl = [NSURL URLWithString:postData.author.profileImageUrl];

    
    if([postData.author.profileImageUrl isEqualToString:@""])
    {
        [self.userImageView setImage:userImage];
    }
    else
    {
        [self.userImageView setImageWithURL:userImageUrl placeholderImage:nil];
    }

    [self formatUsersImage];
    [self formatPostImage];
    
    //Add to the user's tag's image view the user id.
    self.userImageView.tag = postData.author.remoteKey;

    //Add the user's name.
    [self.userName setText:postData.author.name];
    
    NSDate *currentDate = postData.date;
    
    //Add the post's time.
    [self.postTime setText:[currentDate timeAgo]];
    
    //Temp categories string.
    NSMutableString *categoriesStr = [NSMutableString string];
    
    for(GLPCategory *c in postData.categories)
    {
        [categoriesStr appendString:c.tag];
    }
    
    [categoriesStr appendString:@" General"];
    
    //Add text to information label.
    [self.informationLabel setText:[NSString stringWithFormat:@"%d likes %d comments %d views Category: %@",postData.likes, postData.commentsCount, postData.remoteKey, categoriesStr]];
    
    [self.numberOfLikesLbl setText:[NSString stringWithFormat:@"%d",postData.likes]];
    
    [self.numberOfCommentsLbl setText:[NSString stringWithFormat:@"%d",postData.commentsCount]];
    
    
    //Set like button status.
    if(postData.liked)
    {
        [self.thumpsUpBtn setTitleColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationbar"]] forState:UIControlStateNormal];
        
        //Add the thumbs up selected version of image.
        [self.thumpsUpBtn setImage:[UIImage imageNamed:@"icon_like_pushed"] forState:UIControlStateNormal];
    }
    else
    {
        [self.thumpsUpBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        //Add the thumbs up selected version of image.
        [self.thumpsUpBtn setImage:[UIImage imageNamed:@"icon_like"] forState:UIControlStateNormal];
        
    }
    
    if(self.isViewPost)
    {
        [self.contentLbl setNumberOfLines:0];
        
        //Hide comment button.
        [self.commentBtn setEnabled:NO];
        
    }
    
    

//    [self setBorderToContentLabel];

    
    //Add selector to post image.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewPostImage:)];
    [tap setNumberOfTapsRequired:1];
    [self.postImage addGestureRecognizer:tap];
    
    
    [self setFontToLabels];
    
    

}

#pragma mark - Format UI

-(void)setFontToLabels
{
    [self.userName setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@",GLP_UNIVERS_LIGHT_BOLD] size:14.0f]];
    
    [self.postTime setFont:[UIFont fontWithName:GLP_UNIVERS_LIGHT_BOLD size:13.0f]];
    
    [self.numberOfCommentsLbl setFont:[UIFont fontWithName:GLP_UNIVERS_LIGHT_BOLD size:12.0f]];
    
    [self.numberOfLikesLbl setFont:[UIFont fontWithName:GLP_UNIVERS_LIGHT_BOLD size:12.0f]];
}

-(void)formatUsersImage
{
    [ShapeFormatterHelper setRoundedView:self.userImageView toDiameter:self.userImageView.frame.size.height];
}

-(void)formatPostImage
{
    [ShapeFormatterHelper setCornerRadiusWithView:self.postImage andValue:8];
}

-(void)setBorderToContentLabel
{
    self.contentLbl.layer.borderColor = [UIColor redColor].CGColor;
    self.contentLbl.layer.borderWidth = 0.5f;
    
//    self.contentView.layer.borderColor = [UIColor blueColor].CGColor;
//    self.contentView.layer.borderWidth = 0.5f;
}

#pragma mark - Online indicator

-(void)updateOnlinePost:(int)remoteKey
{
    if(remoteKey!=0)
    {
//        [self setPostOnline:YES];
//        [self hideIndicator];
        [self.uploadedIndicator setAlpha:0.0];
    }
    else
    {
        [self setPostOnline:NO];
        [self blinkIndicator];
    }
}

-(void)hideIndicator
{
    [self.uploadedIndicator setAlpha:1.0];

    
    [UIView animateWithDuration:2.0 delay:5.0 options:(UIViewAnimationCurveEaseOut | UIViewAnimationCurveEaseOut) animations:^{
        
        [self.uploadedIndicator setAlpha:0.0];
        
    } completion:^(BOOL finished) {
        
    }];
  
}

-(void)blinkIndicator
{
    [self.uploadedIndicator setAlpha:1.0];

    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseInOut animations:^{
        
        [self.uploadedIndicator setAlpha:0.0];
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void)setPostOnline:(BOOL)online
{
    if(online)
    {
        [self.uploadedIndicator setBackgroundColor:[UIColor greenColor]];
    }
    else
    {
        [self.uploadedIndicator setBackgroundColor:[UIColor orangeColor]];
    }
}

#pragma mark - Accessors

-(void)setNewPositions
{
    //Change the height of the label.
    [self setElement:self.contentLbl size:[PostCell getContentLabelSizeForContent:self.post.content isViewPost:self.isViewPost]];
    
    if(!self.imageAvailable)
    {
        [self.textLabelConstrain setConstant:self.contentLbl.frame.size.height];
    }
    
    //Change the position of the social view.
    float socialViewY = self.contentLbl.frame.origin.y + self.contentLbl.frame.size.height + 5;
    
    if(socialViewY < 52)
    {
        socialViewY += OneLinePadding;
    }
    
    CGRect socialFrame = self.socialPanel.frame;
    
    [self.socialPanel setFrame:CGRectMake(socialFrame.origin.x, socialViewY, socialFrame.size.width, socialFrame.size.height)];
    
    //Change the height of the content view.
    CGRect contentViewFrame = self.contentView.frame;   
    
    float contentViewH = socialViewY + socialFrame.size.height + FollowingCellPadding;
    
//    NSLog(@"ContentViewH: %f Content: %@",contentViewH, self.contentLbl.text);
    
    [self.contentView setFrame:CGRectMake(contentViewFrame.origin.x, contentViewFrame.origin.y, contentViewFrame.size.width, contentViewH)];
    
    if(!self.imageAvailable)
    {
//        NSLog(@"Text With content: %@ with height: %f", self.contentLbl.text, self.contentView.frame.size.height);
    }
}

-(void)postFromNotifications:(BOOL)notifications
{
    self.isViewPostNotifications = notifications;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setNewPositions];
}

-(void)refreshInformationLabel
{
    [self.informationLabel setText:[NSString stringWithFormat:@"%d likes %d comments %d views",self.post.likes, self.post.commentsCount, self.post.remoteKey]];
}


+ (CGSize)getContentLabelSizeForContent:(NSString *)content isViewPost:(BOOL)isViewPost
{
//    CGSize maximumLabelSize = CGSizeMake(PostContentLabelMaxWidth, FLT_MAX);
    //[UIFont systemFontOfSize:13.0]
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:13.0];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName: font}];
    
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){PostContentLabelMaxWidth, CGFLOAT_MAX}
                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               context:nil];
    
    CGSize size = rect.size;
    
    
    if(size.height > FiveLinesLimit && !isViewPost)
    {
        return CGSizeMake(size.width, FiveLinesLimit);
    }
    
//    if(isViewPost)
//    {
//        //Decrease the height.
//        size.height -= 15;
//    }

    //
    
    return size;
//    return [content sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0] constrainedToSize: maximumLabelSize lineBreakMode: NSLineBreakByWordWrapping];
}

+ (CGFloat)getCellHeightWithContent:(NSString *)content image:(BOOL)isImage isViewPost:(BOOL)isViewPost
{
    // initial height
    float height = (isImage) ? FixedSizeOfImageCell : FixedSizeOfTextCell;
    
    // add content label height + message content view padding
    height += [PostCell getContentLabelSizeForContent:content isViewPost:isViewPost].height /*+ PostContentViewPadding*/;
    
    //Decrease by 10 points when the text is over one line.
//    if([PostCell getContentLabelSizeForContent:content isViewPost:isViewPost].height > OneLineText)
//    {
//        height -= 10;
//    }
    
//    NSLog(@"Final Height: %f Label size: %f. Content: %@",height, [PostCell getContentLabelSizeForContent:content].height, content);
    
    //return height + FollowingCellPadding;
    
    return height;
}

-(void)setElement:(UIView*)element size:(CGSize)size
{
    [element setFrame:CGRectMake(element.frame.origin.x, element.frame.origin.y, PostContentLabelMaxWidth, size.height)];
}

//-(void)layoutSubviews
//{
//    if(self.isViewPost)
//    {
//        self.contentView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
//
//        //Hide and disable comment button.
//        [self.commentBtn setHidden:YES];
//        [self.commentBtn setUserInteractionEnabled:NO];
//        
//        
//        CGSize contentSize = [PostCell getContentLabelSizeForContent:self.contentLbl.text];
//        
//        
//        CGRect frameSize = self.contentLbl.frame;
//        
// 
//        [self.contentLbl setNumberOfLines:0];
//
//        if(self.imageAvailable)
//        {
//            
//            self.contentLbl.frame = CGRectMake(self.contentLbl.frame.origin.x, self.contentLbl.frame.origin.y+5, self.contentLbl.frame.size.width, contentSize.height);
//            
//            frameSize = self.contentLbl.frame;
//            
////            NSLog(@"Frame Size after: %f : %f",frameSize.size.width, frameSize.size.height);
//            
//            //Move all views below content label.
//            frameSize = self.postImage.frame;
//            
//            CGRect socialFrame = self.socialPanel.frame;
//            
//            self.socialPanel.frame = CGRectMake(socialFrame.origin.x, self.frame.size.height-(socialFrame.size.height+50.0), socialFrame.size.width, socialFrame.size.height);
//
//        }
//        else
//        {
//            if([self.contentLbl.text isEqualToString:@""])
//            {
//                return;
//            }
//            
//                self.contentLbl.frame = CGRectMake(self.contentLbl.frame.origin.x, self.initialPostContentLabelY+10, self.contentLbl.frame.size.width, contentSize.height+self.initialPostContentLabelHeight);
//                
//                CGRect socialFrame = self.socialPanel.frame;
//            
//                
//            self.socialPanel.frame = CGRectMake(socialFrame.origin.x, self.frame.size.height-(socialFrame.size.height), socialFrame.size.width, socialFrame.size.height);
//
//        }
//    }
//
//}

#pragma - mark Selector methods

- (IBAction)likePost:(id)sender
{
    UIButton *btn = (UIButton*) sender;
    
    //If like button is pushed then set the pushed variable to NO and change the
    //colour of the image.
    if([self.post liked])
    {
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        //Add the thumbs up selected version of image.
        [btn setImage:[UIImage imageNamed:@"icon_like"] forState:UIControlStateNormal];
        
        [self.post setLiked:NO];
        
        //Change the like status and send to server the change.
        [self postLike:NO withPostRemoteKey:[self.post remoteKey]];
        
        //Decrease the number of likes.
        --self.post.likes;
    }
    else
    {
        [btn setTitleColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationbar"]] forState:UIControlStateNormal];
        //Add the thumbs up selected version of image.
        [btn setImage:[UIImage imageNamed:@"icon_like_pushed"] forState:UIControlStateNormal];
        
        [self.post setLiked:YES];
        
        //Change the like status and send to server the change.
        [self postLike:YES withPostRemoteKey:[self.post remoteKey]];
        
        //Increase the number of likes.
        ++self.post.likes;
    }
    
    //Update the UI.
    [self refreshInformationLabel];
    
    //Update post in local database.
    [GLPPostManager updatePostWithLiked: self.post];
    
    [GLPPostNotificationHelper updatePostWithNotifiationName:@"GLPPostUpdated" withObject:self remoteKey:self.post.remoteKey numberOfLikes:self.post.likes andNumberOfComments:self.post.commentsCount];
    
    [GLPPostNotificationHelper updatePostWithNotifiationName:@"GLPLikedPostUdated" withObject:self remoteKey:self.post.remoteKey withLiked:self.post.liked];
}

- (IBAction)commentPost:(id)sender
{
    //Hide navigation bar.
    [self.delegate hideNavigationBarAndButtonWithNewTitle:@"New Comment"];
    
    NewCommentView *loadingView = [NewCommentView loadingViewInView:[self.delegate.view.window.subviews objectAtIndex:0]];
    
    loadingView.post = self.post;
    loadingView.postIndex = self.postIndex;
    loadingView.profileDelegate = self.delegate;
}

- (IBAction)sharePost:(id)sender
{
    NSLog(@"sharePost.");
    NSArray *items = @[[NSString stringWithFormat:@"%@",@"Share1"],[NSURL URLWithString:@"http://www.gleepost.com"]];
    
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
    
    [self.delegate presentViewController:shareItems animated:YES completion:nil];

}

-(void)viewPostImage:(id)sender
{
    UITapGestureRecognizer *incomingImage = (UITapGestureRecognizer*) sender;
    
    UIImageView *clickedImageView = (UIImageView*)incomingImage.view;
    
    [self.delegate viewPostImage:clickedImageView.image];
}

/**
 Sends a post notification to timeline view controller to update dynamically the number of likes.
 */
-(void)updateStatusInPost
{
    //Inform timeline view controller that number of likes changed.
//    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:self.post.remoteKey],@"RemoteKey", [NSNumber numberWithInt:self.post.commentsCount], @"NumberOfComments",[NSNumber numberWithInt:self.post.likes], @"NumberOfLikes", nil];
//    
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"GLPPostUpdated" object:self userInfo:dataDict];
    
    

}

#pragma mark - Client

-(void)postLike:(BOOL)like withPostRemoteKey:(int)postRemoteKey
{
    [[WebClient sharedInstance] postLike:like forPostRemoteKey:postRemoteKey callbackBlock:^(BOOL success) {
        
        if(success)
        {
            NSLog(@"Like for post %d succeed.",postRemoteKey);
        }
        else
        {
            NSLog(@"Like for post %d not succeed.",postRemoteKey);
        }
        
        
    }];
}


static const float firstContentTextViewHeight = 60;
static const float firstImagePosition = 110;

static const float firstSocialPanelPosition = 363;
static const float firstImageButtonsPosition = firstSocialPanelPosition+20;
static const float firstImageInformationPosition = firstSocialPanelPosition+5;

static const float firstTextButtonsPosition = 99;
static const float firstTextInformationPosition = 300;

static const float contentTextViewLimit = 100;


/**
 
 @param option 1 for image, 0 without image and 2 none.
 
 */
-(void) setNewYViewLocationWithView: (UIView*)view andNewYLocation: (float)y withImage: (int)option
{
    //viewFrame = CGRectMake(viewFrame.origin.x, y, viewFrame.size.width, viewFrame.size.height);
    
    //return viewFrame;
    
    if(option == 0)
    {
        view.frame = CGRectMake(view.frame.origin.x, y-40, view.frame.size.width, view.frame.size.height);
    }
    else if(option == 1)
    {
        view.frame = CGRectMake(view.frame.origin.x, y-55, view.frame.size.width, view.frame.size.height);
    }
    else if(option == 2)
    {
        view.frame = CGRectMake(view.frame.origin.x, y, view.frame.size.width, view.frame.size.height);
    }
    
}


//+ (CGFloat)getContentLabelHeightForContent:(NSString *)content
//{
//    CGSize maximumLabelSize = CGSizeMake(236, 60);
//
//    CGFloat contentHeight = [content sizeWithFont: [UIFont systemFontOfSize:12.0] constrainedToSize: maximumLabelSize lineBreakMode: NSLineBreakByCharWrapping].height;
//    
//   //  NSLog(@"ONE LINE!\n%@",content);
//  //  NSLog(@"Content Height:%f",contentHeight);
//    
//    return contentHeight;
//}
//
//+ (CGFloat)getCellHeightWithContent:(NSString *)content andImage:(BOOL)containsImage
//{
//    // initial height
//    //float height = (isFirst) ? FirstCellOtherElementsTotalHeight : 0;
//    
//    float height = containsImage?StandardImageCellHeight:StandardTextCellHeight;
//
//    
//    // add content label height + message content view padding
//    height += [PostCell getContentLabelHeightForContent:content] + MessageContentViewPadding;
//    
//    return height + FollowingCellPadding;
//}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
