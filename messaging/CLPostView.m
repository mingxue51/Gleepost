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

@interface CLPostView ()

@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet CLPostTimeLocationView *timeLocationView;

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
