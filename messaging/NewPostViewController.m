//
//  NewPostViewController.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "NewPostViewController.h"
#import "SessionManager.h"
#import "MBProgressHUD.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "UIPlaceHolderTextView.h"
#import "Post.h"
#import "AppearanceHelper.h"
#import "SessionManager.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageFormatterHelper.h"
#import "GLPPostUploader.h"
#import "NSString+Utils.h"
#import "GLPThemeManager.h"
#import "GLPPostManager.h"
#import "CategoryManager.h"
#import "PickDateEventViewController.h"
#import "GroupViewController.h"
#import "GLPTimelineViewController.h"
#import "ShapeFormatterHelper.h"
#import "TDFadeNavigation.h"
#import "GLPiOSSupportHelper.h"
#import "UINavigationBar+Utils.h"
#import "UINavigationBar+Format.h"
#import "PendingPostManager.h"
#import "GLPVideoPostCWProgressManager.h"
#import "GLPLiveGroupPostManager.h"
#import "GLPApprovalManager.h"
#import "GLPPendingPostsManager.h"
#import "GLPLocation.h"
#import "GLPApplicationHelper.h"
#import "FakeNavigationBarNewPostView.h"
#import "GLPFinalNewEventAnimationHelper.h"
#import "PollFakeNavigationBarNewPostView.h"

@interface NewPostViewController () <GLPImageViewDelegate, GLPFinalNewEventAnimationHelperDelegate>


@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *contentTextView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UILabel *descriptionCharactersLeftLbl;
@property (weak, nonatomic) IBOutlet UILabel *titleCharactersLeftLbl;
@property (weak, nonatomic) IBOutlet UIView *textFieldView;
@property (weak, nonatomic) IBOutlet UIImageView *separatorLineImageView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
//@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *pollQuestionTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceContentViewFromTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;


//Poll view elements.
@property (weak, nonatomic) IBOutlet UIImageView *addImageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *answersTextFields;

/** Should be 2 categories (event and user's selected. */
//@property (strong, nonatomic) NSArray *eventCategories;


//Top Buttons.
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
/** This imageview is used only when user tries to edit existing post */
@property (weak, nonatomic) IBOutlet GLPImageView *pendingImageView;
@property (weak, nonatomic) IBOutlet UIButton *addVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *addLocationButton;
@property (weak, nonatomic) IBOutlet UILabel *optionalExtras;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

//@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) GLPPostUploader *postUploader;
@property (weak, nonatomic) UIImage *imgToUpload;
@property (strong, nonatomic) NSDate *eventDateStart;
@property (strong, nonatomic) GLPLocation *selectedLocation;
@property (strong, nonatomic) PBJVideoPlayerController *previewVC;

@property (strong, nonatomic) TDFadeNavigation *transitionViewCategories;


@property (assign, nonatomic) BOOL inCategorySelection;
@property (assign, nonatomic) BOOL inSelectLocation;
@property (assign, nonatomic) BOOL isNewPoll;
@property (assign, nonatomic) NSInteger descriptionRemainingNoOfCharacters;
@property (assign, nonatomic) NSInteger titleRemainingNoOfCharacters;

/** Avoids the ability of the user to touch multible times the post button and thus create
 miltible same posts*/
@property (assign, nonatomic, getter=isPostButtonClicked) BOOL postButttonClicked;


@property (strong, nonatomic) FakeNavigationBarNewPostView *fakeNavigationBar;
@property (strong, nonatomic) GLPFinalNewEventAnimationHelper *animationHelper;

//Constraints.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoButtonXAligment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewXAligment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainViewXAligment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *optionalExtrasLabelXAligment;

@end

@implementation NewPostViewController

const NSInteger MAX_DESCRIPTION_CHARACTERS = 1001;
const NSInteger MAX_QUESTION_CHARACTERS = 300;
const NSInteger MAX_TITLE_CHARACTERS = 60;
const float LIGHT_BLACK_RGB = 200.0f/255.0f;

@synthesize postUploader=_postUploader;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tabBarController.tabBar.hidden = NO;

    [self configureObjects];
    
    [self configureGestures];
    
    [self configurePollElements];
    
    [self preparePositionsBeforeIntro:YES];
    
    [self configureNavigationBar];
    
    [self configureLabels];
    
    [self configureViewsPositions];
    
    [self configureTextViews];
    
    [self formatElements];
    
    [self loadDataIfNeeded];
    
    DDLogDebug(@"Categories %@", [[PendingPostManager sharedInstance] categories]);
    
    if(![[PendingPostManager sharedInstance] isEditMode])
    {
        if(![self shouldPostPresentedInWall])
        {
            [[PendingPostManager sharedInstance] postNeedsApprove];
            DDLogDebug(@"Post should not be presented in the wall");
            
        }
    }
    
    [self configureCustomBackButton];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self animateElementsAfterViewDidLoad];

    [self setUpNotifications];

    [self formatStatusBar];
    
    self.navigationController.delegate = nil;
    
    [self becomeFirstResponderForTextField];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar invisible];

    [self configureContents];

    [self hideNetworkErrorViewIfNeeded];
    
    [self removeUnnecessaryViews];
}

-(void)viewWillDisappear:(BOOL)animated
{
    if([self.contentTextView isFirstResponder])
    {
        [self.contentTextView resignFirstResponder];
    }
    else if([self.titleTextField isFirstResponder])
    {
        [self.titleTextField resignFirstResponder];
    }
    [self removeNotifications];
    
    [super viewWillDisappear:animated];
}

-(void)hideKeyboard
{
    [self.contentTextView resignFirstResponder];
}

-(void)showKeyboard
{
    [self.contentTextView becomeFirstResponder];
}

#pragma mark - Configuration

-(void)setUpNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoReadyForUpload:) name:GLPNOTIFICATION_RECEIVE_VIDEO_PATH object:nil];
    
    // keyboard management
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

-(void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_RECEIVE_VIDEO_PATH object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];

}

-(void)configureObjects
{
    _transitionViewCategories = [[TDFadeNavigation alloc] init];
    _postUploader = [[GLPPostUploader alloc] init];
    self.animationHelper = [[GLPFinalNewEventAnimationHelper alloc] init];
    self.animationHelper.delegate = self;
    _eventDateStart = nil;
    _descriptionRemainingNoOfCharacters = MAX_DESCRIPTION_CHARACTERS;
    _titleRemainingNoOfCharacters = MAX_TITLE_CHARACTERS;
    _selectedLocation = nil;
    _inSelectLocation = NO;
    _postButttonClicked = NO;
    
    //We added in the poll VC view tag 1 in order to distinguish the VC.
    _isNewPoll = (self.view.tag == 1) ? YES : NO;
}

- (void)configureGestures
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addImageOrImage:)];
    [self.addImageView addGestureRecognizer:tapGesture];
}

- (void)configurePollElements
{
    if(!self.isNewPoll)
    {
        return;
    }
    
    for(UITextField *textField in self.answersTextFields)
    {
        textField.delegate = self;
    }
}

- (void)configureCustomBackButton
{
    // change the back button to cancel and add an event handler
    self.navigationItem.leftBarButtonItems = [GLPApplicationHelper customBackButtonWithTarget:self];
}

/**
 This method rearrange any content in the view controller
 depending on what user has selected before in kind of post view.
 */
- (void)configureContents
{
    if([[PendingPostManager sharedInstance] kindOfPost] == kGeneralPost)
    {
        [_titleTextField setHidden:YES];
        [_titleCharactersLeftLbl setHidden:YES];
        [_separatorLineImageView setHidden:YES];
        [_distanceContentViewFromTop setConstant:-30];
    }
}

- (void)becomeFirstResponderForTextField
{
    switch ([[PendingPostManager sharedInstance] kindOfPost]) {
        case kGeneralPost:
        case kPollPost:
            [_contentTextView becomeFirstResponder];
            break;
            
        default:
            [self.titleTextField becomeFirstResponder];
            break;
    }
    
}

-(void)configureTextViews
{
    _contentTextView.delegate = self;
    [_titleTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _titleTextField.delegate = self;
    
    for(UITextField *answerTextField in self.answersTextFields)
    {
        [answerTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
}

-(void)formatElements
{
    [ShapeFormatterHelper setCornerRadiusWithView:_textFieldView andValue:4];
    [ShapeFormatterHelper setCornerRadiusWithView:_pendingImageView andValue:2];
    
    [ShapeFormatterHelper setCornerRadiusWithView:_addImageView andValue:2];
    [ShapeFormatterHelper setCornerRadiusWithView:_selectedImageView andValue:2];
    [ShapeFormatterHelper setCornerRadiusWithView:_mainView andValue:4];
    [ShapeFormatterHelper setBorderToView:_mainView withColour:[AppearanceHelper lightGrayGleepostColour] andWidth:1.0];
}

//TODO: Finish that for the other views.

-(void)configureViewsPositions
{
    if(!IS_IPHONE_5)
    {
        CGRectAddH(_textFieldView, -50.0);
        CGRectMoveY(_descriptionCharactersLeftLbl, -52.0);
    }
}

-(void)configureNavigationBar
{
    [self.navigationController.navigationBar invisible];

    if(self.isNewPoll)
    {
        self.fakeNavigationBar = [[PollFakeNavigationBarNewPostView alloc] init];
    }
    else
    {
        self.fakeNavigationBar = [[FakeNavigationBarNewPostView alloc] init];
    }
    
    
    if(self.comesFromFirstView && !self.isNewPoll)
    {
        [self.fakeNavigationBar setShortModeAndMakeSecondDotSelected];
    }
    else if(self.comesFromFirstView && self.isNewPoll)
    {
        [self.fakeNavigationBar setThreeDotsMode];
        [self.fakeNavigationBar selectDotWithNumber:2];
    }
    else
    {
        [self.fakeNavigationBar selectDotWithNumber:4];
    }
    
    [self.view addSubview:self.fakeNavigationBar];
    
    self.title = @"";
    [self configureRightBarButton];
//    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
    
//    self.navigationController.navigationBar.tag = 2;
//    
//    [AppearanceHelper setNavigationBarFormatForNewPostViews:self.navigationController.navigationBar];
}

-(void)configureRightBarButton
{    
//    [self.navigationController.navigationBar setTextButton:kRight withTitle:@"POST" withButtonSize:CGSizeMake(50, 17) withSelector:@selector(postButtonClick:) andTarget:self];
    
    if(self.isNewPoll)
    {
        [self.navigationController.navigationBar setTextButton:kRight withTitle:@"NEXT" withButtonSize:CGSizeMake(50.0, 17.0) withColour:[AppearanceHelper greenGleepostColour] withSelector:@selector(goToExpirationDatePicker) andTarget:self];
    }
    else
    {
        [self.navigationController.navigationBar setTextButton:kRight withTitle:@"POST" withButtonSize:CGSizeMake(50.0, 17.0) withColour:[AppearanceHelper greenGleepostColour] withSelector:@selector(postButtonClick:) andTarget:self];
    }
}

-(void)formatStatusBar
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

-(void)configureLabels
{
    [_descriptionCharactersLeftLbl setText:[NSString stringWithFormat:@"%ld", (long)MAX_DESCRIPTION_CHARACTERS]];
    [_descriptionCharactersLeftLbl setHidden:YES];
    [_titleCharactersLeftLbl setText:[NSString stringWithFormat:@"%ld", (long)MAX_TITLE_CHARACTERS]];
}


- (void)hideNetworkErrorViewIfNeeded
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_HIDE_ERROR_VIEW object:self userInfo:nil];
}

- (void)removeUnnecessaryViews
{
    if([[PendingPostManager sharedInstance] kindOfPost] == kGeneralPost || [[PendingPostManager sharedInstance] kindOfPost] == kAnnouncementPost)
    {
        [_addLocationButton setHidden:YES];
    }
}

- (void)loadDataIfNeeded
{
    //Load data from PendingPostManager and add them to the fields.
    
    if(![[PendingPostManager sharedInstance] arePendingData])
    {
        return;
    }
    
    [_titleTextField setText:[[PendingPostManager sharedInstance] eventTitle]];
    [_contentTextView setText:[[PendingPostManager sharedInstance] eventDescription]];
    _eventDateStart = [[PendingPostManager sharedInstance] getDate];
    
    NSString *videoUrl = [[PendingPostManager sharedInstance] videoUrl];
    
    if(videoUrl)
    {
        [self showVideoToButtonWithPath:videoUrl];
    }
    
    NSString *imageUrl = [[PendingPostManager sharedInstance] imageUrl];
    
    if(imageUrl)
    {
        //Load and set image url to pending image view.
        [self showPendingImageViewWithImageUrl:imageUrl];
    }
    
    GLPLocation *location = [[PendingPostManager sharedInstance] location];
    
    if(location)
    {
        [_addLocationButton setTitle:location.name.uppercaseString forState:UIControlStateNormal];
    }
    
    DDLogDebug(@"Data loaded: %@", [[PendingPostManager sharedInstance] description]);
}

#pragma mark - Animation configuration

- (void)preparePositionsBeforeIntro:(BOOL)beforeIntro
{
    if(self.isNewPoll)
    {
        [self.animationHelper setInitialValueInConstraint:self.mainViewXAligment forView:self.mainView comingFromRight:beforeIntro];
    }
    else
    {
        [self.animationHelper setInitialValueInConstraint:self.textViewXAligment forView:self.textFieldView comingFromRight:beforeIntro];
        [self.animationHelper setInitialValueInConstraint:self.videoButtonXAligment forView:self.textFieldView comingFromRight:beforeIntro];
        [self.animationHelper setInitialValueInConstraint:self.optionalExtrasLabelXAligment forView:self.optionalExtras comingFromRight:beforeIntro];
        [self.backgroundImageView setAlpha:0.0];
    }
}

#pragma mark - Animations

- (void)animateElementsAfterViewDidLoad
{
    if(self.isNewPoll)
    {
        [self.animationHelper viewDidLoadAnimationWithConstraint:self.mainViewXAligment withKindOfElement:kMainElement];
    }
    else
    {
        [self.animationHelper viewDidLoadAnimationWithConstraint:self.textViewXAligment withKindOfElement:kTextElement];
        [self.animationHelper viewDidLoadAnimationWithConstraint:self.videoButtonXAligment withKindOfElement:kVideoElement];
        [self.animationHelper viewDidLoadAnimationWithConstraint:self.optionalExtrasLabelXAligment withKindOfElement:kTitleElement];
        [self.animationHelper fadeView:self.backgroundImageView withAppearance:YES];
    }
}

- (void)animateElementsBeforeGoingBack:(BOOL)goingBack
{
    if(self.isNewPoll)
    {
        [self.animationHelper viewGoingBack:goingBack disappearingAnimationWithView:self.mainView andKindOfElement:kMainElement];
    }
    else
    {
        [self.animationHelper viewGoingBack:goingBack disappearingAnimationWithView:self.textFieldView andKindOfElement:kTextElement];
        [self.animationHelper viewGoingBack:goingBack disappearingAnimationWithView:self.addImageButton andKindOfElement:kImageElement];
        [self.animationHelper viewGoingBack:goingBack disappearingAnimationWithView:self.pendingImageView andKindOfElement:kImageElement];
        [self.animationHelper viewGoingBack:goingBack disappearingAnimationWithView:self.addVideoButton andKindOfElement:kVideoElement];
        [self.animationHelper viewGoingBack:goingBack disappearingAnimationWithView:self.addLocationButton andKindOfElement:kLocationElement];
        [self.animationHelper viewGoingBack:goingBack disappearingAnimationWithView:self.optionalExtras andKindOfElement:kTitleElement];
        [self.animationHelper fadeView:self.backgroundImageView withAppearance:NO];
    }
}

#pragma mark - Selectors

- (void)postButtonClick:(id)sender
{
    if ([self isInformationValidInElements])
    {
        if([self isPostButtonClicked])
        {
            return;
        }

        _postButttonClicked = YES;
        
        [self.view endEditing:YES];
        
        [[PendingPostManager sharedInstance] readyToSend];
        
        GLPPost *inPost = nil;
        
        //Check if the post is group post or regular post.
        if([[PendingPostManager sharedInstance] isGroupPost])
        {
            inPost = [self createGroupPost];
        }
        else
        {
            inPost = [self createRegularPost];
        }
        
        
        if(![[PendingPostManager sharedInstance] isEditMode] && [self shouldPostPresentedInWall])
        {
            [self informParentVCForNewPost:inPost];
        }
        
        //New post that needs approve.
        if(![[PendingPostManager sharedInstance] isEditMode] && ![self shouldPostPresentedInWall])
        {
            [self newPostNeedsApprove:inPost];
        }
        
        //Old post that needs approve.
        if([[PendingPostManager sharedInstance] isEditMode])
        {
            [self postIsPending:inPost];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            //We are doing that because in iOS 8 there is a weird issue with keyboard.
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                //Dismiss view controller and show immediately the post in the Campus Wall.
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }
        
        [[PendingPostManager sharedInstance] reset];
    }
}

- (void)goToExpirationDatePicker
{
    if (![self isInformationValidInElements])
    {
        return;
    }
    
    if([self tooShortData])
    {
        [WebClientHelper showTooShortDataMessageError];
        return;
    }
    
    if([self doesATextFieldExceedsTheLimitOfChars])
    {
        return;
    }
    
    [[PendingPostManager sharedInstance] setPollPost:[self generatePollPostWithCurrentData]];
    
//    [self navigateToPickDateEventViewController];
    [self animateElementsBeforeGoingBack:NO];

}

- (void)backButtonTapped
{
    [self animateElementsBeforeGoingBack:YES];
}

/**
 Checks the approval level and the kind of post user already selected.
 If the kind of post needs to be approved this method returns YES, otherwise NO.
 */
- (BOOL)shouldPostPresentedInWall
{
    if([[PendingPostManager sharedInstance] isGroupPost])
    {
        return YES;
    }
    else
    {
        switch ([[GLPApprovalManager sharedInstance] currentApprovalLevel])
        {
            case kNone:
                DDLogInfo(@"NewPostViewController : Approval level off.");
                return YES;
                break;
                
            case kOnlyParties:
                if([[PendingPostManager sharedInstance] isEventParty])
                {
                    DDLogInfo(@"NewPostViewController : Approval level on parties.");
                    return NO;
                }
                else
                {
                    return YES;
                }
                break;
                
                case kAllEvents:
                DDLogInfo(@"NewPostViewController : Approval level on all events.");
                return ![[PendingPostManager sharedInstance] isPostEvent];
                break;
                
                case kAll:
                DDLogInfo(@"NewPostViewController : Approval level on all posts.");
                return NO;
                break;
                
            default:
                break;
        }
        
    }
    
    return NO;
    
}

- (GLPPost *)createGroupPost
{
    GLPPost* inPost = nil;
    
    NSArray *eventCategories = [[PendingPostManager sharedInstance] categories];
    
    GLPGroup *group = [[PendingPostManager sharedInstance] group];
    
    DDLogDebug(@"Post button clicked with event categories %@.", eventCategories);

    
    NSAssert(group, @"Group should exist to create a new group post.");
    
    
    if([[PendingPostManager sharedInstance] kindOfPost] == kGeneralPost)
    {
        inPost = [_postUploader uploadPost:self.contentTextView.text withCategories:nil eventTime:nil title:nil group:group andLocation:nil];
        
        FLog(@"GENERAL POST GROUP REMOTE KEY: %ld", (long)group.remoteKey);
        
    }
    else if([[PendingPostManager sharedInstance] kindOfPost] == kPollPost)
    {
        inPost = [self generatePollPostWithCurrentData];
        inPost.group = group;
        [_postUploader uploadPollPostWithPost:inPost];
    }
    else
    {
        inPost = [_postUploader uploadPost:self.contentTextView.text withCategories:eventCategories eventTime:_eventDateStart title:self.titleTextField.text group:group andLocation:_selectedLocation];
        
        FLog(@"REGULAR POST GROUP REMOTE KEY: %ld", (long)group.remoteKey);
    }
    
    if([inPost isVideoPost])
    {
        [[GLPLiveGroupPostManager sharedInstance] postButtonClicked];
    }
    
    return inPost;
}

- (GLPPost *)createRegularPost
{
    GLPPost *inPost = nil;
    
    NSArray *eventCategories = [[PendingPostManager sharedInstance] categories];
    
    DDLogDebug(@"NewPostViewController : createregularpost eventCategories %@", eventCategories);
    
    if([[PendingPostManager sharedInstance] kindOfPost] == kGeneralPost)
    {
        FLog(@"GENERAL POST IS GOING TO BE CREATED");
        
        inPost = [_postUploader uploadPost:self.contentTextView.text withCategories:nil eventTime:nil title:nil andLocation:_selectedLocation];
    }
    else if([[PendingPostManager sharedInstance] kindOfPost] == kPollPost)
    {
//        inPost = [_postUploader uploadPost:self.contentTextView.text withCategories:eventCategories eventTime:nil title:nil andLocation:nil];
        inPost = [self generatePollPostWithCurrentData];
        [_postUploader uploadPollPostWithPost:inPost];

    }
    else
    {
        DDLogDebug(@"Event categories %@", eventCategories);
        
        inPost = [_postUploader uploadPost:self.contentTextView.text withCategories:eventCategories eventTime:_eventDateStart title:self.titleTextField.text andLocation:_selectedLocation];
    }
    
    //    if([inPost isVideoPost] && [[PendingPostManager sharedInstance] doesPostNeedsApprove])

    DDLogDebug(@"NewPostViewController : pending approve %d", [inPost isPendingInEditMode]);
    if([inPost isVideoPost] && [[PendingPostManager sharedInstance] isEditMode])
    {
        [[GLPPendingPostsManager sharedInstance] postButtonClicked];
    }
    
    if([inPost isVideoPost] && ![[PendingPostManager sharedInstance] isEditMode])
    {
        [[GLPVideoPostCWProgressManager sharedInstance] postButtonClicked];
    }
    
    return inPost;
}

- (GLPPost *)generatePollPostWithCurrentData
{
    GLPPost *currentPost = [[GLPPost alloc] init];
    currentPost.eventTitle = self.contentTextView.text;
    currentPost.categories = [[PendingPostManager sharedInstance] categories];
    currentPost.poll = [[GLPPoll alloc] init];
    currentPost.poll.options = [self generateOptionsFromAnswersFields];
    currentPost.content = self.contentTextView.text;
    currentPost.author = [SessionManager sharedInstance].user;
    
    return currentPost;
}

/**
 Adds a new post to pending posts manager and informs Campus Wall to reload data
 in the table view.
 
 @param post the pending post.
 
 */
- (void)postIsPending:(GLPPost *)post
{
    post.pendingInEditMode = YES;
    [[GLPPendingPostsManager sharedInstance] updateNewPendingPostInEditMode:post];
    
    //Reload data in campus wall to let the pending cell appear.
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_NEW_PENDING_POST object:nil];
}

- (void)newPostNeedsApprove:(GLPPost *)post
{
    [[GLPPendingPostsManager sharedInstance] addNewPendingPost:post];
    
    //Reload data in campus wall to let the pending cell appear.
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_NEW_PENDING_POST object:nil];
}

- (void)informParentVCForNewPost:(GLPPost *)post
{
    if([[PendingPostManager sharedInstance] isGroupPost])
    {
        //Notify the group view controller.
        [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_RELOAD_DATA_IN_GVC object:nil userInfo:@{@"new_post": post}];
    }
    else
    {
        //Notify campus wall.
        [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_RELOAD_DATA_IN_CW object:nil userInfo:@{@"new_post": post}];
    }
}

//-(BOOL)isGroupPost
//{
//    if([self.delegate isKindOfClass:[GLPTimelineViewController class]])
//    {
//        return NO;
//    }
//    else if ([self.delegate isKindOfClass:[GroupViewController class]])
//    {
//        return YES;
//    }
//    else
//    {
//        DDLogError(@"ERROR: NewPostViewController needs to be called only from GroupViewController or GLPTimelineViewController.");
//        
//        return NO;
//    }
//}


- (IBAction)addImageOrImage:(id)sender
{
    [self performSegueWithIdentifier:@"show image selector" sender:self];
}

- (IBAction)addVideo:(id)sender
{
//    //Remove video preview view if is on the addImageButton.
//    [self removeVideoPreviewView];

    [self.view endEditing:YES];
    
    //We are doing that because in iOS 8 there is a weird issue with keyboard.
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self performSegueWithIdentifier:@"capture video" sender:self];
        
    });
}

- (IBAction)addLocation:(id)sender
{
    _inSelectLocation = YES;
    
    [self performSegueWithIdentifier:@"pick location" sender:self];
}

#pragma mark - GLPFinalNewEventAnimationHelperDelegate

- (void)goingBackViewsDisappeared
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)goingForwardViewsDisappeared
{
    [self preparePositionsBeforeIntro:NO];
    [self navigateToPickDateEventViewController];
}

#pragma mark - ImageSelectorViewControllerDelegate

- (void)takeImage:(UIImage *)image
{
    //Remove video preview view if is on the addImageButton.
    [self removeVideoPreviewView];
    
    [[self.addImageButton imageView] setContentMode: UIViewContentModeScaleAspectFill];
    
    if([[PendingPostManager sharedInstance] isEditMode])
    {
        [_pendingImageView setImage:image];
    }
    else
    {
        [self.addImageButton setImage:image forState:UIControlStateNormal];
    }
    
    self.selectedImageView.image = image;
    
    self.imgToUpload = image;
    
    [_postUploader uploadImageToQueue:self.imgToUpload];
    
}
//
//#pragma mark - Action Sheet delegate
//
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSString *selectedButtonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
//    
//    if([selectedButtonTitle isEqualToString:@"Add an image"])
//    {
//        //Add image.
////        [self.fdTakeController takePhotoOrChooseFromLibrary];
//
//    }
//    else if([selectedButtonTitle isEqualToString:@"Capture a video"])
//    {
//        //Remove video preview view if is on the `.
//        [self removeVideoPreviewView];
//        
//        //Capture a video.
//        [self performSegueWithIdentifier:@"capture video" sender:self];
//    }
//}

#pragma mark - Video

/**
 This method is called when the user finished the video.
 
 @param notification the notification contains the video path.
 */
-(void)videoReadyForUpload:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    
    NSString *videoPath = [dict objectForKey:@"video path"];
    
    [self showVideoToButtonWithPath:videoPath];
    
    [_postUploader uploadVideoInPath:videoPath];
    
    DDLogDebug(@"videoReadyForUpload : video path: %@", videoPath);
}

-(void)showVideoToButtonWithPath:(NSString *)videoPath
{
    //Remove video preview view if is on the addImageButton.
    [self removeVideoPreviewView];
    [self resetImageButton];
    
    _previewVC = [[PBJVideoPlayerController alloc] init];
    _previewVC.delegate = self;
    [_previewVC setPlaybackLoops:YES];
    _previewVC.view.frame = _addVideoButton.bounds;
//    [_addImageButton addSubview:_previewVC.view];
    [_addVideoButton addSubview:_previewVC.view];
    _previewVC.videoPath = videoPath;
    
    [_previewVC playFromBeginning];
}

-(void)removeVideoPreviewView
{
    if(_previewVC)
    {
        [_previewVC.view removeFromSuperview];
        _previewVC = nil;
    }
}

- (void)resetImageButton
{
    [_addImageButton setImage:nil forState:UIControlStateNormal];
}


#pragma mark - PBJVideoPlayerControllerDelegate

- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer
{
}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
    if(videoPlayer.playbackState == PBJVideoPlayerPlaybackStatePaused && !_inCategorySelection && !_inSelectLocation)
    {
        [self addVideo:nil];
    }
    
    _inSelectLocation = NO;

}

- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer
{
    
}

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer
{
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    if(self.isNewPoll)
    {
        [(PollFakeNavigationBarNewPostView *)self.fakeNavigationBar setNumberOfCharacters:textView.text.length toElement:kQuestionTextView];
    }
    
    [[PendingPostManager sharedInstance] setEventDescription:textView.text];
    
    [self setNumberOfCharactersToDescription:textView.text.length];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if(self.isNewPoll)
    {
        [(PollFakeNavigationBarNewPostView *)self.fakeNavigationBar elementChangedFocus:kQuestionTextView];
    }
    
    [_descriptionCharactersLeftLbl setHidden:NO];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [_descriptionCharactersLeftLbl setHidden:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidChange:(UITextField *)textField
{
    if(self.isNewPoll)
    {
        [(PollFakeNavigationBarNewPostView *)self.fakeNavigationBar setNumberOfCharacters:textField.text.length toElement:kAnswerTextField];
    }

    [[PendingPostManager sharedInstance] setEventTitle:textField.text];

    [self setNumberOfCharactersToTitle:textField.text.length];

}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(self.isNewPoll)
    {
        [(PollFakeNavigationBarNewPostView *)self.fakeNavigationBar setNumberOfCharacters:textField.text.length toElement:kAnswerTextField];
        [(PollFakeNavigationBarNewPostView *)self.fakeNavigationBar elementChangedFocus:kAnswerTextField];
    }
    

    [_titleCharactersLeftLbl setHidden:NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    DDLogDebug(@"NewPostViewController : textFieldDidEndEditing %ld", (long)textField.tag);

    [_titleCharactersLeftLbl setHidden:YES];
}

#pragma mark - Text text view

-(void)setNumberOfCharactersToDescription:(NSInteger)numberOfChars
{
    _descriptionRemainingNoOfCharacters = MAX_DESCRIPTION_CHARACTERS - numberOfChars;
    
    [_descriptionCharactersLeftLbl setText:[NSString stringWithFormat:@"%ld", (long)_descriptionRemainingNoOfCharacters]];
    
    if(_descriptionRemainingNoOfCharacters < 0)
    {
        [_descriptionCharactersLeftLbl setTextColor:[UIColor redColor]];
    }
    else
    {
        [_descriptionCharactersLeftLbl setTextColor:[UIColor colorWithRed:LIGHT_BLACK_RGB green:LIGHT_BLACK_RGB blue:LIGHT_BLACK_RGB alpha:1.0f]];
    }
}

-(void)setNumberOfCharactersToTitle:(NSInteger)numberOfChars
{
    _titleRemainingNoOfCharacters = MAX_TITLE_CHARACTERS - numberOfChars;
    
    [_titleCharactersLeftLbl setText:[NSString stringWithFormat:@"%ld", (long)_titleRemainingNoOfCharacters]];
    
    if(_titleRemainingNoOfCharacters < 0)
    {
        [_titleCharactersLeftLbl setTextColor:[UIColor redColor]];
    }
    else
    {
        [_titleCharactersLeftLbl setTextColor:[UIColor colorWithRed:LIGHT_BLACK_RGB green:LIGHT_BLACK_RGB blue:LIGHT_BLACK_RGB alpha:1.0f]];
    }
}

#pragma mark - GLPSelectSelectLocationViewControllerDelegate

- (void)locationSelected:(GLPLocation *)location withMapImage:(UIImage *)mapImage
{
    
    if(mapImage)
    {
        UIImageView *v = [[UIImageView alloc] initWithImage:mapImage];
        
        [v setFrame:_addLocationButton.bounds];
        
        CGRectSetX(v, 0.0);
        CGRectSetY(v, 0.0);
        
        [v setContentMode:UIViewContentModeScaleAspectFill];
//        [[_addLocationButton imageView] setContentMode: UIViewContentModeScaleToFill];
        
//        [_addLocationButton.imageView setImage:v.image];
//        
//       [_addLocationButton setImage:v.image forState:UIControlStateNormal];
//
        
        [_addLocationButton addSubview:v];
        
    }
    
    DDLogInfo(@"Location selected in NewPostViewController: %@", location);
    _selectedLocation = location;
    
}

#pragma mark - Pending Image View

- (void)showPendingImageViewWithImageUrl:(NSString *)imageUrl
{
    [_pendingImageView setGesture:YES];
    
    _pendingImageView.delegate = self;
    
    [_pendingImageView setHidden:NO];
    
    [_pendingImageView setImageUrl:imageUrl withPlaceholderImage:nil];
}

- (void)imageTouchedWithImageView:(UIImageView *)imageView;
{
    //Show image selector.
    [self addImageOrImage:nil];
}

#pragma mark - Helpers

- (BOOL)isInformationValidInElements
{
    if([[PendingPostManager sharedInstance] kindOfPost] == kGeneralPost)
    {
        return ![NSString isStringEmpty:self.contentTextView.text] && ![self.contentTextView.text exceedsNumberOfCharacters:MAX_DESCRIPTION_CHARACTERS];
    }
    else if([[PendingPostManager sharedInstance] kindOfPost] == kPollPost)
    {
        return ![NSString isStringEmpty:self.contentTextView.text] && ![self.contentTextView.text exceedsNumberOfCharacters:MAX_QUESTION_CHARACTERS] && [self answersCompleted];
    }
    else
    {
        return ![NSString isStringEmpty:self.contentTextView.text] && ![NSString isStringEmpty:self.titleTextField.text] && ![self.titleTextField.text exceedsNumberOfCharacters:MAX_TITLE_CHARACTERS] && ![self.contentTextView.text exceedsNumberOfCharacters:MAX_DESCRIPTION_CHARACTERS];
    }

}

/**
 Returns YES if text count in question text view and in answers fields is less than 3 characters.
 */
- (BOOL)tooShortData
{
    for(UITextField *answerTextField in self.answersTextFields)
    {
        if(answerTextField.tag == 1 || answerTextField.tag == 2)
        {
            if(answerTextField.text.length < 2)
            {
                return YES;
            }
        }
        else
        {
            if(![NSString isStringEmpty:answerTextField.text])
            {
                if(answerTextField.text.length < 2)
                {
                    return YES;
                }
            }
        }
    }
    
    return self.contentTextView.text.length < 3;
}

/**
 Returns YES if text count in question text view and in answers fields are more than the preset lenght limits.
 */

- (BOOL)doesATextFieldExceedsTheLimitOfChars
{
    
    for(UITextField *answerTextField in self.answersTextFields)
    {
        if(answerTextField.tag == 1 || answerTextField.tag == 2)
        {
            if([(PollFakeNavigationBarNewPostView *)self.fakeNavigationBar doesStringExceedsTheLimitOfChars:answerTextField.text withKindOfElement:kAnswerTextField])
            {
                return YES;
            }
        }
        else
        {
            if(![NSString isStringEmpty:answerTextField.text])
            {
                if([(PollFakeNavigationBarNewPostView *)self.fakeNavigationBar doesStringExceedsTheLimitOfChars:answerTextField.text withKindOfElement:kAnswerTextField])
                {
                    return YES;
                }
            }
        }
    }
    
    return [(PollFakeNavigationBarNewPostView *)self.fakeNavigationBar doesStringExceedsTheLimitOfChars:self.contentTextView.text withKindOfElement:kQuestionTextView];
}

/**
 Returns YES if the first 2 answers are completed.
 */
- (BOOL)answersCompleted
{
    for(UITextField *answerTextField in self.answersTextFields)
    {
        if(answerTextField.tag == 1 || answerTextField.tag == 2)
        {
            if([NSString isStringEmpty:answerTextField.text])
            {
                return NO;
            }
        }
    }
    
    return YES;
}

- (NSArray *)generateOptionsFromAnswersFields
{
    NSMutableArray *options = [[NSMutableArray alloc] init];
    
    for(UITextField *answerTextField in self.answersTextFields)
    {
        if(![NSString isStringEmpty:answerTextField.text])
        {
            [options addObject:answerTextField.text];
        }
    }
    
    return options;
}

#pragma mark - Keyboard management

- (void)keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curve.intValue;
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    if(keyboardBounds.size.height == 0)
    {
        return;
    }
    
    [_textFieldView layoutIfNeeded];
    [_mainView layoutIfNeeded];

    float newHeightOfTextFieldView = 0;
    
    if(self.isNewPoll)
    {
        newHeightOfTextFieldView = [self findNewHeithForPollViewWithKeyboardFrame:keyboardBounds];
    }
    else
    {
         newHeightOfTextFieldView = [self findNewHeightForTextFieldViewWithKeyboardFrame:keyboardBounds];
    }
    
    DDLogDebug(@"keybardwillshow : new height %f", newHeightOfTextFieldView);
    
    [UIView animateWithDuration:[duration doubleValue] delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|(animationCurve << 16)) animations:^{

        [_textViewHeight setConstant:newHeightOfTextFieldView];
        [_mainViewHeight setConstant:newHeightOfTextFieldView];
        
        [_mainView layoutIfNeeded];
        [_textFieldView layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (float)findNewHeightForTheContentTextViewWithKeboardFrame:(CGRect)keyboardFrame
{
    float keyboardY = keyboardFrame.origin.y;
    
    //We are substracting with 250 because without it the position is wrong.
    //So if we don't substract with that number the position of the button will be wrong.
    
    return keyboardY - _contentTextView.frame.origin.y - 5 - 250;
}

- (float)findNewYForDescriptionCharactersLeftWithKeboardFrame:(CGRect)keyboardFrame
{
    float keyboardY = keyboardFrame.origin.y;
    
    return keyboardY - _descriptionCharactersLeftLbl.frame.size.height - 5 - 230;
}

- (float)findNewHeightForTextFieldViewWithKeyboardFrame:(CGRect)keyboardFrame
{
    CGFloat keyboardY = keyboardFrame.origin.y;
    
    CGFloat distanceFromKeyboard = 10.0;
    
    DDLogDebug(@"Keboard Y %f - %f", keyboardY, _textFieldView.frame.origin.y);
    
    return keyboardY - _textFieldView.frame.origin.y - distanceFromKeyboard;
}

- (CGFloat)findNewHeithForPollViewWithKeyboardFrame:(CGRect)keyboardFrame
{
    CGFloat keyboardY = keyboardFrame.origin.y;
    
    CGFloat distanceFromKeyboard = 10.0;
    
    DDLogDebug(@"Keboard Y %f - %f", keyboardY, _textFieldView.frame.origin.y);
    
    return keyboardY - self.mainView.frame.origin.y - distanceFromKeyboard;
}

//- (float)findNewYOfSelectImageViewWithKeyboardFrame:(CGRect)keyboardFrame
//{
//    float keyboardY = keyboardFrame.origin.y;
//    
//    return keyboardY - _selectImageView.frame.size.height - 5 - 189;
//}

#pragma mark - VC Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"pick location"])
    {
        GLPSelectLocationViewController *selectLocation = segue.destinationViewController;
        
        selectLocation.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"show image selector"])
    {
        ImageSelectorViewController *imgSelectorVC = segue.destinationViewController;
        
        [imgSelectorVC setDelegate:self];
    }
}

- (void)navigateToPickDateEventViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"new_post" bundle:nil];
    PickDateEventViewController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"PickDateEventViewController"];
    cvc.isNewPoll = YES;
    [self.navigationController pushViewController:cvc animated:NO];
}

-(void)navigateToVideoController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    GLPVideoViewController *videoVC = [storyboard instantiateViewControllerWithIdentifier:@"GLPVideoViewController"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:videoVC];
//    navigationController.navigationBarHidden = YES;
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end
