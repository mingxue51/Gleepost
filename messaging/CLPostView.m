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


@interface CLPostView ()

@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet CLPostTimeLocationView *timeLocationView;
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
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
}

-(void)setPostImage
{
    NSURL *imageUrl = nil;
    
    if(self.post.imagesUrls.count > 0)
    {
        imageUrl = [NSURL URLWithString:self.post.imagesUrls[0]];
//        [self hideVideoView];
    }
    
//    if([self doesMediaNeedLoadAgain])
//    {
        [_activityIndicator stopAnimating];
        [self.postImageView setImageWithURL:imageUrl placeholderImage:nil usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        return;
//    }
    
//    if(self.isViewPost && _postImageView.image != nil)
//    {
//        [_activityIndicator stopAnimating];
//        return;
//    }
//    
//    if(_postImageView.image != nil && self.post.remoteKey == _postImageView.tag)
//    {
//        [_activityIndicator stopAnimating];
//        return;
//    }
//    
//    _postImageView.tag = self.post.remoteKey;
//    
//    [_postImageView setImage:nil];
//    
//    
//    //This happens only when the image is not fetched or is save in cache.
//
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        
//        // Look in cache and request for the image.
//        [[GLPPostImageLoader sharedInstance] findImageWithUrl:imageUrl callback:^(UIImage *image, BOOL found) {
//            
//            if (found)
//            {
//                if([imageUrl.absoluteString isEqualToString:_post.imagesUrls[0]])
//                {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        
//                        [_postImageView setImage:image];
//                        [_activityIndicator stopAnimating];
//                        
//                    });
//                }
//                else
//                {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        
//                        DDLogDebug(@"Image not the same, abord");
//                        [_postImageView setImage:nil];
//                    });
//                }
//            }
//            
//        }];
//        
//    });

    
}

#pragma mark - Selectors

- (IBAction)moreOptions:(id)sender
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
