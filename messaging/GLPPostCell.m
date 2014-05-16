//
//  GLPPostCell.m
//  Gleepost
//
//  Created by Silouanos on 15/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPPostCell.h"
#import "VideoView.h"
#import "TopPostView.h"
#import "SessionManager.h"
#import "GLPPostOperationManager.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "GLPPostManager.h"
#import "NewCommentView.h"

@interface GLPPostCell ()

@property BOOL isViewPost;
@property BOOL imageAvailable;

@property (weak, nonatomic) IBOutlet TopPostView *topView;
@property (weak, nonatomic) IBOutlet MainPostView *mainView;

/** Main view elements. */
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UIImageView *uploadIndicatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLbl;
@property (weak, nonatomic) IBOutlet UIButton *goingBtn;


/** Other variables. */
@property (assign, nonatomic) BOOL imageNeedsToLoadAgain;
@property (strong, nonatomic) GLPPost *post;
@property (assign, nonatomic) NSInteger postIndex;

@end

@implementation GLPPostCell

const float IMAGE_CELL_HEIGHT = 372;
const float TEXT_CELL_HEIGHT = 192;
const float POST_CONTENT_LABEL_MAX_WIDTH = 300;
const float FIVE_LINES_LIMIT = 101.0;
const float FIXED_SIZE_OF_NON_EVENT_IMAGE_CELL = IMAGE_CELL_HEIGHT - 80;
const float FIXED_SIZE_OF_NON_EVENT_TEXT_CELL = TEXT_CELL_HEIGHT - 80;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self initialiseObjects];
    }
    
    return self;
}

-(void)initialiseObjects
{
    _isViewPost = NO;
    _imageNeedsToLoadAgain = NO;
}

#pragma mark - Modifiers

-(void)setPost:(GLPPost *)post withPostIndex:(NSInteger)index
{
    
    _post = post;
    _postIndex = index;
    
    //Set elements to top view.
    [_topView setElementsWithPost:_post];
    
    
    //Set elements to main view.
    [_mainView setElementsWithPost:post withViewPost:_isViewPost];
    [_mainView setDelegate:self];

    [self configureTopView];
    
}

#pragma mark - Configuration

/**
 This method manages the distances and the apprearance of each UI element
 depending on different status of the post (eg. post is event or the size of the
 content text lable).
 */
-(void)setNewPositions
{
    CGSize labelSize = [GLPPostCell getContentLabelSizeForContent:self.post.content isViewPost:self.isViewPost isImage:self.imageAvailable];
    
    [_mainView setNewHeightDependingOnLabelHeight:labelSize.height];
}

-(void)configureTopView
{
    if(![self isCurrentPostEvent])
    {
        //Hide elements on top, bring other elements up and make the cell smaller.
        [_topView setHidden:YES];
    }
    else
    {
        [_topView setHidden:NO];
    }
}

#pragma mark - Modifiers

-(void)reloadImage:(BOOL)loadImage
{
    self.imageNeedsToLoadAgain = loadImage;
}

#pragma mark - Helper methods

-(BOOL)isCurrentPostBelongsToCurrentUser
{
    return ([SessionManager sharedInstance].user.remoteKey == self.post.author.remoteKey);
}

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

#pragma mark - MainPostViewDelegate

-(void)viewPostImage:(id)sender
{
    UITapGestureRecognizer *incomingImage = (UITapGestureRecognizer*) sender;
    
    UIImageView *clickedImageView = (UIImageView*)incomingImage.view;
    
    [self.delegate viewPostImage:clickedImageView.image];
}

-(void)showViewOptionsWithActionSheer:(UIActionSheet *)actionSheet
{
    [actionSheet showInView:[_delegate.view window]];
}

-(void)showShareViewWithItems:(UIActivityViewController *)shareItems
{
    [self.delegate presentViewController:shareItems animated:YES completion:nil];
}

-(void)deleteCurrentPost
{
    if(_post.remoteKey == 0)
    {
        BOOL postPending = [[GLPPostOperationManager sharedInstance] cancelPostWithKey:_post.key];
        
        
        if(!postPending)
        {
            [self deletePostFromServer];
        }
        else
        {
            [_delegate removePostWithPost:_post];
        }
    }
    else
    {
        [self deletePostFromServer];
    }
}

-(void)commentButtonSelected
{
    //Hide navigation bar.
    [self.delegate hideNavigationBarAndButtonWithNewTitle:@"New Comment"];
    
    NewCommentView *loadingView = [NewCommentView loadingViewInView:[self.delegate.view.window.subviews objectAtIndex:0]];
    
    loadingView.post = self.post;
    loadingView.postIndex = self.postIndex;
    loadingView.profileDelegate = self.delegate;
}

#pragma mark - Static methods

+(CGSize)getContentLabelSizeForContent:(NSString *)content isViewPost:(BOOL)isViewPost isImage:(BOOL)isImage
{
    UIFont *font = nil;
    
    int maxWidth = 0;
    
    if(isImage)
    {
        font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
        maxWidth = POST_CONTENT_LABEL_MAX_WIDTH;
        
        
    }
    else
    {
        font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
        maxWidth = 264;
        
    }
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName: font,
                                                                                                         NSKernAttributeName : @(0.3f)}];
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){maxWidth, CGFLOAT_MAX}
                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               context:nil];
    
    CGSize size = rect.size;
    
    
    if(size.height > FIVE_LINES_LIMIT && !isViewPost)
    {
        return CGSizeMake(size.width, FIVE_LINES_LIMIT);
    }
    
    
    return size;
}

+(CGFloat)getCellHeightWithContent:(GLPPost *)post image:(BOOL)isImage isViewPost:(BOOL)isViewPost
{
    // initial height
    float height = (isImage) ? IMAGE_CELL_HEIGHT : TEXT_CELL_HEIGHT;
    
    
    if(isImage)
    {
        if(!post.eventTitle)
        {
            height = FIXED_SIZE_OF_NON_EVENT_IMAGE_CELL;
        }
    }
    else
    {
        if(!post.eventTitle)
        {
            height = FIXED_SIZE_OF_NON_EVENT_TEXT_CELL;
        }
    }
    
    // add content label height
    height += [GLPPostCell getContentLabelSizeForContent:post.content isViewPost:isViewPost isImage:isImage].height;
    
    return height;
}

#pragma mark - Client

-(void)deletePostFromServer
{
    [[WebClient sharedInstance] deletePostWithRemoteKey:_post.remoteKey callbackBlock:^(BOOL success) {
        
        if(!success)
        {
            [WebClientHelper showFailedToDeletePostError];
            return;
        }
        
        [_delegate removePostWithPost:_post];
        
        
        //Delete post from database.
        [GLPPostManager deletePostWithPost:self.post];
        
    }];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if(self.post.content)
    {
        [self setNewPositions];
    }
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
