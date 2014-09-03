//
//  GLPPostCell.m
//  Gleepost
//
//  Created by Silouanos on 15/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPPostCell.h"
#import "VideoView.h"
#import "SessionManager.h"
#import "GLPPostOperationManager.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "GLPPostManager.h"
#import "NewCommentView.h"

@interface GLPPostCell ()

@property (assign, nonatomic)  BOOL isViewPost;
@property (assign, nonatomic) BOOL imageAvailable;

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
@property (assign, nonatomic) BOOL mediaNeedsToReload;
@property (strong, nonatomic) GLPPost *post;
@property (assign, nonatomic) NSInteger postIndex;

@end

@implementation GLPPostCell

const float IMAGE_CELL_HEIGHT = 386;        //393
const float VIDEO_CELL_HEIGHT = 510;        //498
const float TEXT_CELL_HEIGHT = 200;
const float IMAGE_CELL_ONE_LINE_HEIGHT = IMAGE_CELL_HEIGHT - 15;
const float VIDEO_CELL_ONE_LINE_HEIGHT = VIDEO_CELL_HEIGHT - 21;
const float TEXT_CELL_ONE_LINE_HEIGHT = TEXT_CELL_HEIGHT - 15;
const float FIXED_SIZE_OF_NON_EVENT_VIDEO_CELL = VIDEO_CELL_HEIGHT - 75; //65
const float FIXED_SIZE_OF_NON_EVENT_IMAGE_CELL = IMAGE_CELL_HEIGHT - 60; //70
const float FIXED_SIZE_OF_NON_EVENT_TEXT_CELL = TEXT_CELL_HEIGHT - 87;
const float POST_CONTENT_LABEL_MAX_WIDTH = 270;
const float FIVE_LINES_LIMIT = 101.0;
const float ONE_LINE_LIMIT = 18.0;

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
    _mediaNeedsToReload = NO;
}


#pragma mark - Modifiers

-(void)setPost:(GLPPost *)post withPostIndex:(NSInteger)index
{
    _post = post;
    _postIndex = index;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self configureTopView];

    //Set elements to top view.
    [_topView setElementsWithPost:_post];
    
    [_topView setDelegate:self];

    [_mainView setDelegate:self];
    
    [_mainView setMediaNeedsToReload:_mediaNeedsToReload];
    
    //Set elements to main view.
    [_mainView setElementsWithPost:post withViewPost:_isViewPost];
    

    //[ShapeFormatterHelper setBorderToView:self withColour:[UIColor redColor] andWidth:1.0f];

//    [ShapeFormatterHelper setBorderToView:_mainView withColour:[UIColor redColor]];
//    [ShapeFormatterHelper setBorderToView:_topView withColour:[UIColor blackColor]];
}

- (void)deregisterNotificationsInVideoView
{
    [_mainView deregisterNotificationsForVideoView];
}

#pragma mark - Configuration

/**
 This method manages the distances and the apprearance of each UI element
 depending on different status of the post (eg. post is event or the size of the
 content text lable).
 */
-(void)setNewPositions
{
    CGSize labelSize = [GLPPostCell getContentLabelSizeForContent:self.post.content isViewPost:self.isViewPost cellType:[self findCellType]];
    
//    [_mainView setNewHeightDependingOnLabelHeight:labelSize.height andIsViewPost:self.isViewPost];
    [_mainView setHeightDependingOnLabelHeight:labelSize.height andIsViewPost:self.isViewPost];

}

-(void)configureTopView
{    
    if([self isCurrentPostEvent])
    {
        [_topView setHidden:NO];
    }
    else
    {
        //Hide elements on top, bring other elements up and make the cell smaller.
        [_topView setHidden:YES];
    }
}

#pragma mark - Modifiers

-(void)reloadMedia:(BOOL)loadMedia
{
    self.mediaNeedsToReload = loadMedia;
}

-(void)setIsViewPost:(BOOL)isViewPost
{
    _isViewPost = isViewPost;
}

#pragma mark - Helper methods

-(BOOL)isCurrentPostBelongsToCurrentUser
{
    return ([SessionManager sharedInstance].user.remoteKey == self.post.author.remoteKey);
}

-(BOOL)isCurrentPostEvent
{
    if(_post.eventTitle == nil)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

-(GLPCellType)findCellType
{
    if([_post isVideoPost])
    {
        return kVideoCell;
    }
    else if([_post imagePost])
    {
        return kImageCell;
    }
    else
    {
        return kTextCell;
    }
}

#pragma mark - TopPostViewDelegate

- (void)locationPushed
{
    [_delegate showLocationWithLocation:_post.location];
}

#pragma mark - MainPostViewDelegate

-(void)viewPostImage:(id)sender
{    
    UITapGestureRecognizer *incomingImage = (UITapGestureRecognizer*) sender;
    
    UIImageView *clickedImageView = (UIImageView*)incomingImage.view;
    
    [self.delegate viewPostImage:clickedImageView.image];
}

-(void)navigateToProfile:(id)sender
{
    UITapGestureRecognizer *incomingImage = (UITapGestureRecognizer*) sender;

    NSInteger userRemoteKey = incomingImage.view.tag;
    
    [self.delegate elementTouchedWithRemoteKey:userRemoteKey];
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

+(CGSize)getContentLabelSizeForContent:(NSString *)content isViewPost:(BOOL)isViewPost cellType:(GLPCellType)cellType
{
    UIFont *font = nil;
    
    int maxWidth = 0;
    
    font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    maxWidth = POST_CONTENT_LABEL_MAX_WIDTH;


    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName: font,
                                                                                                         NSKernAttributeName : @(0.3f)}];
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){maxWidth, CGFLOAT_MAX}
                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               context:nil];
    
    CGSize size = rect.size;
    
    if(cellType == kVideoCell)
    {
        if(size.height > ONE_LINE_LIMIT && !isViewPost)
        {
            return CGSizeMake(size.width, ONE_LINE_LIMIT);
        }
    }
    else
    {
        if(size.height > FIVE_LINES_LIMIT && !isViewPost)
        {
            return CGSizeMake(size.width, FIVE_LINES_LIMIT);
        }
    }
    
    return size;
}

+(CGFloat)getCellHeightWithContent:(GLPPost *)post cellType:(GLPCellType)cellType isViewPost:(BOOL)isViewPost
{
//    if([post isVideoPost])
//    {
//        return [GLPPostCell getVideoCellHeightWithPost:post isViewPost:isViewPost];
//    }
    
    float height = [GLPPostCell getConstantHeightOfCellWithType:cellType wihtPost:post];
    
    
    // initial height
//    float height = (isImage) ? IMAGE_CELL_HEIGHT : TEXT_CELL_HEIGHT;
    
    
    if(cellType == kImageCell)
    {
        if(!post.eventTitle)
        {
            height = FIXED_SIZE_OF_NON_EVENT_IMAGE_CELL;
        }
    }
    else if (cellType == kVideoCell)
    {
        if(!post.eventTitle)
        {
            height = FIXED_SIZE_OF_NON_EVENT_VIDEO_CELL;
        }
    }
    else if(cellType == kTextCell)
    {
        if(!post.eventTitle)
        {
            height = FIXED_SIZE_OF_NON_EVENT_TEXT_CELL;
        }
    }
    
    // add content label height
    height += [GLPPostCell getContentLabelSizeForContent:post.content isViewPost:isViewPost cellType:cellType].height;
    
    return height;
}

+(CGFloat)getVideoCellHeightWithPost:(GLPPost *)post isViewPost:(BOOL)isViewPost
{
    float height = VIDEO_CELL_HEIGHT;
    
    if(!post.eventTitle)
    {
        height -= 63;
    }
    
    if(isViewPost)
    {
//        height += [GLPPostCell getContentLabelSizeForContent:post.content isViewPost:isViewPost isImage:YES].height;
    }
    
    return height;
}

+(float)getConstantHeightOfCellWithType:(GLPCellType)cellType wihtPost:(GLPPost *)post
{
    BOOL oneLineEventTitle = [TopPostView isTitleTextOneLineOfCodeWithContent:post.eventTitle];
    
    if(cellType == kVideoCell)
    {
        if(oneLineEventTitle)
        {
            return VIDEO_CELL_ONE_LINE_HEIGHT;
        }
        
        return VIDEO_CELL_HEIGHT;
    }
    else if (cellType == kImageCell)
    {
        if(oneLineEventTitle)
        {
            return IMAGE_CELL_ONE_LINE_HEIGHT;
        }
        
        return IMAGE_CELL_HEIGHT;
    }
    else
    {
        if(oneLineEventTitle)
        {
            return TEXT_CELL_ONE_LINE_HEIGHT;
        }
        
        return TEXT_CELL_HEIGHT;
    }
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
