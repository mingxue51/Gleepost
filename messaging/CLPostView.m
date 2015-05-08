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

@interface CLPostView () <GLPLabelDelegate, GLPImageViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet CLPostTimeLocationView *timeLocationView;
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet GLPImageView *userImageView;
@property (weak, nonatomic) IBOutlet GLPLabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *datePostedLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
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
        self.frame = CGRectMake(0.0, 0.0, [GLPiOSSupportHelper screenWidth] * 0.91, [GLPiOSSupportHelper screenHeight] * 0.72);
        [self configureNotifications];

    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
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
    
    [self.timeLocationView setLocation:post.location andTime:post.dateEventStarts];
    [self setPostImage];
    
    [self setUserViewData];
    
    [self.viewsCountView setViewsCount:self.post.viewsCount];
    
    [self configureContentLabel];
    
    
}

- (void)configureContentLabel
{
    self.contentLabel.text = self.post.content;
    
    //TODO: See if the 270 (in getContentLabelSizeForContent) max width is rigth.
    self.contentLabelHeight.constant =  [GLPPostCell getContentLabelSizeForContent:self.post.content isViewPost:NO cellType:kImageCell].height;
    
    
}

- (void)setPostImage
{
    NSURL *imageUrl = nil;
    
    if(self.post.imagesUrls.count > 0)
    {
        imageUrl = [NSURL URLWithString:self.post.imagesUrls[0]];
//        [self hideVideoView];
    }

    [_activityIndicator stopAnimating];
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
    DDLogDebug(@"CLPostView imageTouchedWithImageView %ld", (long)imageView.tag);
}

#pragma mark - Selectors

- (IBAction)moreOptions:(id)sender
{
    
}

- (IBAction)goingButtonTouched:(id)sender
{
    
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
