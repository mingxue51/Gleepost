//
//  NewPostViewController.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "NewPostViewController.h"
#import "TimelineViewController.h"
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
#import "TDNavigationCategories.h"
#import "GLPiOS6Helper.h"
#import "UINavigationBar+Utils.h"
#import "UINavigationBar+Format.h"
#import "PendingPostManager.h"

@interface NewPostViewController ()


@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *contentTextView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UILabel *descriptionCharactersLeftLbl;
@property (weak, nonatomic) IBOutlet UILabel *titleCharactersLeftLbl;
@property (weak, nonatomic) IBOutlet UIView *textFieldView;
@property (weak, nonatomic) IBOutlet UIImageView *separatorLineImageView;

/** Should be 2 categories (event and user's selected. */
//@property (strong, nonatomic) NSArray *eventCategories;


//Top Buttons.
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (weak, nonatomic) IBOutlet UIButton *addVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *addLocationButton;

//@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) FDTakeController *fdTakeController;
@property (strong, nonatomic) GLPPostUploader *postUploader;
@property (weak, nonatomic) UIImage *imgToUpload;
@property (strong, nonatomic) NSDate *eventDateStart;
@property (strong, nonatomic) PBJVideoPlayerController *previewVC;

@property (strong, nonatomic) TDNavigationCategories *transitionViewCategories;


@property (assign, nonatomic) BOOL inCategorySelection;
@property (assign, nonatomic) NSInteger descriptionRemainingNoOfCharacters;
@property (assign, nonatomic) NSInteger titleRemainingNoOfCharacters;


@end

@implementation NewPostViewController

const NSInteger MAX_DESCRIPTION_CHARACTERS = 210;
const NSInteger MAX_TITLE_CHARACTERS = 60;
const float LIGHT_BLACK_RGB = 200.0f/255.0f;

@synthesize postUploader=_postUploader;

- (void)backButtonTapped {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.navigationItem.leftBarButtonItem = [AppDelegate customBackButtonWithTarget:self];
    
    
    if(NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1)
    {
        //If iOS 6 add transparent black UIImageView.
        UIImageView *imageViewBlack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, self.contentTextView.frame.size.height+50)];
        
        imageViewBlack.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.67];
        
        [self.view addSubview:imageViewBlack];
        [self.view sendSubviewToBack:imageViewBlack];
    }

    
    self.tabBarController.tabBar.hidden = NO;

    [self configureObjects];
        
    [self configureNavigationBar];
    
    [self configureLabels];
    
    [self configureViewsPositions];
    
    [self configureViewsGestures];
    
    [self configureTextViews];
    
    [self formatBackgroundViews];
    
    [self formatTextView];
    
    [self loadDataIfNeeded];
    

}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setUpNotifications];

    [self formatStatusBar];
    

    self.fdTakeController = [[FDTakeController alloc] init];
    self.fdTakeController.viewControllerForPresentingImagePickerController = self;
    self.fdTakeController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureContents];

    [self hideNetworkErrorViewIfNeeded];
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
    
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    
//    [self.contentTextView resignFirstResponder];
    
    
    [self removeNotifications];
    
    [super viewDidDisappear:animated];

//    [self.delegate.view setBackgroundColor:[UIColor whiteColor]];
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
}

-(void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_RECEIVE_VIDEO_PATH object:nil];
}

-(void)configureObjects
{
    _transitionViewCategories = [[TDNavigationCategories alloc] init];
    _postUploader = [[GLPPostUploader alloc] init];
    _eventDateStart = nil;
    _descriptionRemainingNoOfCharacters = MAX_DESCRIPTION_CHARACTERS;
    _titleRemainingNoOfCharacters = MAX_TITLE_CHARACTERS;
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
        CGRectSetY(_contentTextView, 10);
        CGRectAddH(_contentTextView, 30);
        [_contentTextView becomeFirstResponder];
    }
    else
    {
        [self.titleTextField becomeFirstResponder];
    }
}

-(void)formatTextView
{
//    _contentTextView.placeholderColor = [UIColor colorWithRed:LIGHT_BLACK_RGB green:LIGHT_BLACK_RGB blue:LIGHT_BLACK_RGB alpha:1.0];
}

-(void)configureTextViews
{
    _contentTextView.delegate = self;
    
    [_titleTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    _titleTextField.delegate = self;
}

-(void)formatBackgroundViews
{
    [ShapeFormatterHelper setCornerRadiusWithView:_textFieldView andValue:4];

    
//    [ShapeFormatterHelper setBorderToView:_textFieldBackgroundImageView withColour:[UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f] andWidth:1.0f];
    
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

-(void)configureViewsGestures
{
  /**  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigateToCategories:)];
    [tap setNumberOfTapsRequired:1];
    [_navigateToCategoriesView addGestureRecognizer:tap];*/
}

-(void)configureNavigationBar
{
    [self.navigationController.navigationBar setTranslucent:NO];
    self.title = @"NEW POST";
    [self configureRightBarButton];
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
    
//    self.navigationController.navigationBar.tag = 2;
//    
//    [AppearanceHelper setNavigationBarFormatForNewPostViews:self.navigationController.navigationBar];
}

-(void)configureRightBarButton
{
    [self.navigationController.navigationBar setButton:kText withImageOrTitle:@"POST" withButtonSize:CGSizeMake(50, 17) withSelector:@selector(postButtonClick:) andTarget:self];
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
    
    
    DDLogDebug(@"Data loaded: %@", [[PendingPostManager sharedInstance] description]);
    
}


#pragma mark - Selectors

- (void)postButtonClick:(id)sender
{
    //TODO:Check if the lenght of the text views is out of bounds.
    
    if ([self isInformationValidInElements]) {
//        [self.delegate setNavigationBarName];
//        [self.delegate setButtonsToNavigationBar];
        
        [self.contentTextView resignFirstResponder];
        
        
//        GLPPost* inPost = [_postUploader uploadPost:self.contentTextView.text withCategories:[[NSArray alloc] initWithObjects:_chosenCategory, nil]];
        GLPPost* inPost = nil;
        
        
        [[PendingPostManager sharedInstance] readyToSend];
        NSArray *eventCategories = [[PendingPostManager sharedInstance] categories];
        
        
        //Check if the post is group post or regular post.
        if([[PendingPostManager sharedInstance] isGroupPost])
        {
            GLPGroup *group = [[PendingPostManager sharedInstance] group];

            NSAssert(group, @"Group should exist to create a new group post.");
            
            DDLogDebug(@"GROUP REMOTE KEY: %ld", (long)group.remoteKey);
            
            inPost = [_postUploader uploadPost:self.contentTextView.text withCategories:eventCategories eventTime:_eventDateStart title:self.titleTextField.text andGroup:group];
        }
        else
        {
            inPost = [_postUploader uploadPost:self.contentTextView.text withCategories:eventCategories eventTime:_eventDateStart andTitle:self.titleTextField.text];
        }
        
        [self informParentVCForNewPost:inPost];

        
//        [delegate reloadNewImagePostWithPost:inPost];
        

        //Dismiss view controller and show immediately the post in the Campus Wall.
        
        [self dismissViewControllerAnimated:YES completion:^{
//            if(_hasImage)
//            {
//                inPost.tempImage = self.imgToUpload;
                //inPost.imagesUrls = [[NSArray alloc] initWithObjects:@"LIVE", nil];
//                [delegate reloadNewImagePostWithPost:inPost];
//            }
//            else
//            {
//                //[delegate reloadNewLocalPosts];
////                [delegate reloadNewImagePostWithPost:inPost];
//            }
            
        }];
    }
}

- (void)informParentVCForNewPost:(GLPPost *)post
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_RELOAD_DATA_IN_CW object:nil userInfo:@{@"new_post": post}];
}

-(void)navigateToCategories:(id)sender
{
//    [self performSegueWithIdentifier:@"show categories" sender:self];
    
//    [self navigateToCategoriesViewController];
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
//    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Capture Media" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add an image", @"Capture a video", nil];
// 
//    [actionSheet showInView:[self.view window]];
    
    [self.fdTakeController takePhotoOrChooseFromLibrary];
}

- (IBAction)addVideo:(id)sender
{
//    //Remove video preview view if is on the addImageButton.
//    [self removeVideoPreviewView];
    
    //Capture a video.
    [self performSegueWithIdentifier:@"capture video" sender:self];
}

- (IBAction)addLocation:(id)sender
{
    DDLogDebug(@"Add location");
}

#pragma mark - FDTakeController delegate

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)inDict
{
    //Remove video preview view if is on the addImageButton.
    [self removeVideoPreviewView];
    
    [[self.addImageButton imageView] setContentMode: UIViewContentModeScaleAspectFill];
    
    [self.addImageButton setImage:photo forState:UIControlStateNormal];
    
    self.imgToUpload = photo;
    
    [_postUploader uploadImageToQueue:self.imgToUpload];
    
    //[_postUploader startUploadingImage:self.imgToUpload];
}

#pragma mark - Action Sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *selectedButtonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if([selectedButtonTitle isEqualToString:@"Add an image"])
    {
        //Add image.
        [self.fdTakeController takePhotoOrChooseFromLibrary];

    }
    else if([selectedButtonTitle isEqualToString:@"Capture a video"])
    {
        //Remove video preview view if is on the addImageButton.
        [self removeVideoPreviewView];
        
        //Capture a video.
        [self performSegueWithIdentifier:@"capture video" sender:self];
    }
}

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
    if(videoPlayer.playbackState == PBJVideoPlayerPlaybackStatePaused && !_inCategorySelection)
    {
        [self addVideo:nil];
    }
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
    [[PendingPostManager sharedInstance] setEventDescription:textView.text];
    
    [self setNumberOfCharactersToDescription:textView.text.length];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [_descriptionCharactersLeftLbl setHidden:NO];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [_descriptionCharactersLeftLbl setHidden:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidChange:(UITextField *)textField
{
    [[PendingPostManager sharedInstance] setEventTitle:textField.text];

    [self setNumberOfCharactersToTitle:textField.text.length];

}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [_titleCharactersLeftLbl setHidden:NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [_titleCharactersLeftLbl setHidden:YES];
}

#pragma mark - Text text view

-(void)setNumberOfCharactersToDescription:(NSInteger)numberOfChars
{
    _descriptionRemainingNoOfCharacters = MAX_DESCRIPTION_CHARACTERS - numberOfChars;
    
    [_descriptionCharactersLeftLbl setText:[NSString stringWithFormat:@"%d", _descriptionRemainingNoOfCharacters]];
    
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
    
    [_titleCharactersLeftLbl setText:[NSString stringWithFormat:@"%d", _titleRemainingNoOfCharacters]];
    
    if(_titleRemainingNoOfCharacters < 0)
    {
        [_titleCharactersLeftLbl setTextColor:[UIColor redColor]];
    }
    else
    {
        [_titleCharactersLeftLbl setTextColor:[UIColor colorWithRed:LIGHT_BLACK_RGB green:LIGHT_BLACK_RGB blue:LIGHT_BLACK_RGB alpha:1.0f]];
    }
}

#pragma mark - Helpers

- (BOOL)isInformationValidInElements
{
    return ![NSString isStringEmpty:self.contentTextView.text] && ![NSString isStringEmpty:self.titleTextField.text] && ![self.titleTextField.text exceedsNumberOfCharacters:MAX_TITLE_CHARACTERS] && ![self.contentTextView.text exceedsNumberOfCharacters:MAX_DESCRIPTION_CHARACTERS];
}

#pragma mark - VC Navigation

//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    
//    if([segue.identifier isEqualToString:@"pick date"])
//    {
//        PickDateEventViewController *pickDateViewController = segue.destinationViewController;
//        
//        pickDateViewController.delegate = self;
//    }
//    else if ([segue.identifier isEqualToString:@"show categories"])
//    {
//        
//    }
//
//}

-(void)navigateToVideoController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    GLPVideoViewController *videoVC = [storyboard instantiateViewControllerWithIdentifier:@"GLPVideoViewController"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:videoVC];
//    navigationController.navigationBarHidden = YES;
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}

//-(void)navigateToCategoriesViewController
//{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
//    GLPSelectCategoryViewController *categoriesVC = [storyboard instantiateViewControllerWithIdentifier:@"GLPSelectCategoryViewController"];
//    [categoriesVC setDelegate:self];
//    categoriesVC.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.67];
//
//    categoriesVC.modalPresentationStyle = UIModalPresentationCustom;
//    
//    
//    if(![GLPiOS6Helper isIOS6])
//    {
//        [categoriesVC setTransitioningDelegate:_transitionViewCategories];
//    }
//    
//
//    [self presentViewController:categoriesVC animated:YES completion:nil];
//    
//    
//}






@end
