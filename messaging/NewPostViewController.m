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
#import "GLPSelectCategoryViewController.h"
#import "TDNavigationCategories.h"
#import "GLPiOS6Helper.h"
#import "UINavigationBar+Utils.h"

@interface NewPostViewController () <GLPSelectCategoryViewControllerDelegate>


//IBOutlets.
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *charactersLeftLbl;
@property (weak, nonatomic) IBOutlet UIView *textFieldView;
@property (weak, nonatomic) IBOutlet UIView *navigateToCategoriesView;
//Category buttons.
@property (weak, nonatomic) IBOutlet UIButton *forSaleCategoryBtn;
@property (weak, nonatomic) IBOutlet UIButton *newsCategoryBtn;
@property (weak, nonatomic) IBOutlet UIButton *eventsCategoryBtn;
@property (weak, nonatomic) IBOutlet UIButton *jobsCategoryBtn;
@property (weak, nonatomic) IBOutlet UIButton *questionsCategoryBtn;
@property (strong, nonatomic) GLPCategory *eventCategory;

//Navigation bar.
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postNavBarBtn;

@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) FDTakeController *fdTakeController;
@property (strong, nonatomic) GLPPostUploader *postUploader;
@property (assign, nonatomic) BOOL hasImage;
@property (weak, nonatomic) UIImage *imgToUpload;
@property (strong, nonatomic) NSDate *eventDateStart;
@property (strong, nonatomic) NSString *eventTitle;
@property (strong, nonatomic) PBJVideoPlayerController *previewVC;

@property (strong, nonatomic) TDNavigationCategories *transitionViewCategories;


@property (assign, nonatomic) BOOL inCategorySelection;
@property (assign, nonatomic) NSInteger remainingNumberOfCharacters;
//@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

- (IBAction)cancelButtonClick:(id)sender;
- (IBAction)postButtonClick:(id)sender;

@end

@implementation NewPostViewController

const NSString *CHARACTERS_LEFT = @"Characters Left";
const NSInteger MAX_NO_OF_CHARACTERS = 70;
const float LIGHT_BLACK_RGB = 48.0f/255.0f;

@synthesize delegate;
@synthesize postUploader=_postUploader;
@synthesize hasImage=_hasImage;

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
    
    [self configureCategoryButtons];
    
    [self configureNavigationBar];
    
    [self configureLabel];
    
    [self configureViewsPositions];
    
    [self configureViewsGestures];
    
    [self configureTextView];
    
    [self formatNavigationButtons];
    
    [self formatBackgroundViews];
    
    [self formatTextView];
    
    
//    [self generateCategoryButtons];
    

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setUpNotifications];

    [self formatStatusBar];
    
    [self.contentTextView becomeFirstResponder];

    self.fdTakeController = [[FDTakeController alloc] init];
    self.fdTakeController.viewControllerForPresentingImagePickerController = self;
    self.fdTakeController.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.contentTextView resignFirstResponder];
    
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
    _categories = [NSMutableArray array];
    _postUploader = [[GLPPostUploader alloc] init];
    _hasImage = NO;
    _eventDateStart = nil;
    _remainingNumberOfCharacters = MAX_NO_OF_CHARACTERS;
}

-(void)configureCategoryButtons
{
    [self formatButton: self.newsCategoryBtn];
    [self formatButton: self.forSaleCategoryBtn];
    [self formatButton: self.eventsCategoryBtn];
    [self formatButton: self.jobsCategoryBtn];
    [self formatButton: self.questionsCategoryBtn];
}

-(void)formatButton:(UIButton*)btn
{
    btn.layer.cornerRadius = 11;
    btn.layer.borderColor = [AppearanceHelper colourForNotFocusedItems].CGColor;
    btn.layer.borderWidth = 2.5f;
    btn.clipsToBounds = YES;
    [btn.titleLabel setFont:[UIFont fontWithName:GLP_TITLE_FONT size:18.0f]];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 1, 0);

}

-(void)formatTextView
{
    _contentTextView.placeholderColor = [UIColor colorWithRed:LIGHT_BLACK_RGB green:LIGHT_BLACK_RGB blue:LIGHT_BLACK_RGB alpha:1.0];
}

-(void)configureTextView
{
    _contentTextView.delegate = self;
}

-(void)formatBackgroundViews
{
    [ShapeFormatterHelper setCornerRadiusWithView:_textFieldView andValue:4];
    [ShapeFormatterHelper setCornerRadiusWithView:_navigateToCategoriesView andValue:4];

    
//    [ShapeFormatterHelper setBorderToView:_textFieldBackgroundImageView withColour:[UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f] andWidth:1.0f];
    
}

-(void)configureViewsPositions
{
    if(!IS_IPHONE_5)
    {
        CGRectAddH(_textFieldView, -50.0);
        CGRectMoveY(_navigateToCategoriesView, -50.0);
        CGRectMoveY(_charactersLeftLbl, -52.0);
    }
}

-(void)configureViewsGestures
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigateToCategories:)];
    [tap setNumberOfTapsRequired:1];
    [_navigateToCategoriesView addGestureRecognizer:tap];
}

-(void)configureNavigationBar
{
    [self.navigationController.navigationBar setTranslucent:NO];
    self.title = @"NEW POST";
    [self configureLeftBarButton];
    [self configureRightBarButton];
    
    self.navigationController.navigationBar.tag = 2;
    
    [AppearanceHelper setNavigationBarFormatForNewPostViews:self.navigationController.navigationBar];
}

-(void)configureLeftBarButton
{
    [self.navigationController.navigationBar setButton:kLeft withImageOrTitle:@"cancel" withButtonSize:CGSizeMake(19, 21) withSelector:@selector(cancelButtonClick:) andTarget:self];
}

-(void)configureRightBarButton
{
    [self.navigationController.navigationBar setButton:kText withImageOrTitle:@"Post" withButtonSize:CGSizeMake(40, 17) withSelector:@selector(postButtonClick:) andTarget:self];
}

-(void)formatStatusBar
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

-(void)formatNavigationButtons
{
    UIFont *font = [UIFont fontWithName:GLP_TITLE_FONT size:18.0f];
    
    [self.postNavBarBtn setTitleTextAttributes:@{NSFontAttributeName: font}
                                        forState:UIControlStateNormal];
}

-(void)configureLabel
{
    [_charactersLeftLbl setText:[NSString stringWithFormat:@"%ld %@", (long)MAX_NO_OF_CHARACTERS, CHARACTERS_LEFT]];
}

//TODO: Not used. Use this later if there is a need.

-(void)generateCategoryButtons
{
    NSArray *names = [[CategoryManager instance] categoriesNames];
    
    for(NSString *name in names)
    {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(79.0f, 229.0f, 10.0f, 30.0f)];
        
        btn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        
        [btn setTitle:name forState:UIControlStateNormal];
        
        [btn sizeToFit];
        
        [self.view addSubview:btn];
        break;
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Selectors

- (IBAction)cancelButtonClick:(id)sender
{
//    [self.delegate setNavigationBarName];
//    [self.delegate setButtonsToNavigationBar];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postButtonClick:(id)sender
{
    if (![NSString isStringEmpty:self.contentTextView.text]) {
//        [self.delegate setNavigationBarName];
//        [self.delegate setButtonsToNavigationBar];
        
        [self.contentTextView resignFirstResponder];
        
        
//        GLPPost* inPost = [_postUploader uploadPost:self.contentTextView.text withCategories:[[NSArray alloc] initWithObjects:_chosenCategory, nil]];
        GLPPost* inPost = nil;
        
        //Check if the post is group post or regular post.
        if([self isGroupPost])
        {
            NSAssert(_group, @"Group should exist to create a new group post.");
            
            DDLogDebug(@"GROUP REMOTE KEY: %ld", (long)_group.remoteKey);
            
            inPost = [_postUploader uploadPost:self.contentTextView.text withCategories:_categories eventTime:_eventDateStart title:_eventTitle andGroup:_group];
        }
        else
        {
            inPost = [_postUploader uploadPost:self.contentTextView.text withCategories:_categories eventTime:_eventDateStart andTitle:_eventTitle];
        }
        
        [delegate reloadNewImagePostWithPost:inPost];

        //Dismiss view controller and show immediately the post in the Campus Wall.
        
        [self dismissViewControllerAnimated:YES completion:^{
            if(_hasImage)
            {
//                inPost.tempImage = self.imgToUpload;
                //inPost.imagesUrls = [[NSArray alloc] initWithObjects:@"LIVE", nil];
//                [delegate reloadNewImagePostWithPost:inPost];
            }
            else
            {
                //[delegate reloadNewLocalPosts];
//                [delegate reloadNewImagePostWithPost:inPost];
            }
            
        }];
    }
}



-(IBAction)selectCategory:(id)sender
{
    
    _inCategorySelection = YES;
    
    UIButton *currentButton = (UIButton*)sender;
    
    if([[currentButton titleColorForState:UIControlStateNormal] isEqual:[AppearanceHelper colourForNotFocusedItems]])
    {
        
        GLPCategory *chosenCategory = [[CategoryManager instance] categoryWithRemoteKey:currentButton.tag];
        
        
        [self popUpTimeSelectorWithCategory:chosenCategory];
        
        [self makeButtonSelected:currentButton];

        
        [_categories addObject:[[CategoryManager instance] generateEventCategory]];
        [_categories addObject:chosenCategory];

        
    }
    else
    {        
        [self enableButtons];
        
        [self makeButtonUnselected:currentButton];

        
        [self deleteCategoryWithRemoteKey:currentButton.tag];
        
    }
}


-(void)makeButtonUnselected:(UIButton *)btn
{
    [btn setTitleColor:[AppearanceHelper colourForNotFocusedItems] forState:UIControlStateNormal];
    [btn.layer setBorderColor:[AppearanceHelper colourForNotFocusedItems].CGColor];
}

-(void)makeButtonSelected:(UIButton *)btn
{
    [btn setTitleColor:[AppearanceHelper defaultGleepostColour] forState:UIControlStateNormal];
    [btn.layer setBorderColor:[AppearanceHelper defaultGleepostColour].CGColor];
}

-(void)navigateToCategories:(id)sender
{
//    [self performSegueWithIdentifier:@"show categories" sender:self];
    
    [self navigateToCategoriesViewController];
}

#pragma mark - PickDateEvent delegate

-(void)cancelSelectingDateForEvent
{
    //Unselect event category.
    [self makeButtonUnselected:_eventsCategoryBtn];
    [self makeButtonUnselected:_forSaleCategoryBtn];
    [self makeButtonUnselected:_newsCategoryBtn];
    [self makeButtonUnselected:_jobsCategoryBtn];
    [self makeButtonUnselected:_questionsCategoryBtn ];

    //Enable all disabled buttons.
    [self enableButtons];
    
    //Remove all objects from selected categories array.
    [self deleteCategoryWithRemoteKey:0];

}

#pragma mark - GLPSelectCategoryViewControllerDelegate

-(void)eventPostReadyWith:(NSString *)eventTitle andEventDate:(NSDate *)eventDate andCategory:(GLPCategory *)category
{
    _eventTitle = eventTitle;
    _eventDateStart = eventDate;
    [_categories addObject:category];
}

- (void)doneSelectingDateForEvent:(NSDate *)date andTitle:(NSString *)title
{
    _eventDateStart = date;
    _eventTitle = title;
    
    //Disable all the other events buttons.
    [self disableButtons];
    
}

-(void)disableButtons
{
    if([[self.newsCategoryBtn titleColorForState:UIControlStateNormal] isEqual:[AppearanceHelper colourForNotFocusedItems]])
    {
        [self.newsCategoryBtn setEnabled:NO];
    }
    
    if ([[self.forSaleCategoryBtn titleColorForState:UIControlStateNormal] isEqual:[AppearanceHelper colourForNotFocusedItems]])
    {
        [self.forSaleCategoryBtn setEnabled:NO];
    }
    
    if ([[self.eventsCategoryBtn titleColorForState:UIControlStateNormal] isEqual:[AppearanceHelper colourForNotFocusedItems]])
    {
        [self.eventsCategoryBtn setEnabled:NO];

    }
    if ([[self.jobsCategoryBtn titleColorForState:UIControlStateNormal] isEqual:[AppearanceHelper colourForNotFocusedItems]])
    {
        [self.jobsCategoryBtn setEnabled:NO];

    }
   
    if ([[self.questionsCategoryBtn titleColorForState:UIControlStateNormal] isEqual:[AppearanceHelper colourForNotFocusedItems]])
    {
        [self.questionsCategoryBtn setEnabled:NO];

    }

}

-(void)enableButtons
{
    [self.newsCategoryBtn setEnabled:YES];
    [self.forSaleCategoryBtn setEnabled:YES];
    [self.eventsCategoryBtn setEnabled:YES];
    [self.jobsCategoryBtn setEnabled:YES];
    [self.questionsCategoryBtn setEnabled:YES];
}


-(void)popUpTimeSelectorWithCategory:(GLPCategory *)category
{
    //Pop up the time selector.
    [self performSegueWithIdentifier:@"pick date" sender:self];
}

-(BOOL)isGroupPost
{
    if([self.delegate isKindOfClass:[GLPTimelineViewController class]])
    {
        return NO;
    }
    else if ([self.delegate isKindOfClass:[GroupViewController class]])
    {
        return YES;
    }
    else
    {
        DDLogError(@"ERROR: NewPostViewController needs to be called only from GroupViewController or GLPTimelineViewController.");
        
        return NO;
    }
}

-(void)deleteCategoryWithRemoteKey:(int)remoteKey
{
   
    [_categories removeAllObjects];
    
//    for(GLPCategory *c in _categories)
//    {
//        if(c.remoteKey == remoteKey)
//        {
//            [_categories removeObject:c];
//            break;
//        }
//    }
    
    
}


- (IBAction)addImageOrImage:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Capture Media" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add an image", @"Capture a video", nil];
 
    [actionSheet showInView:[self.view window]];
}

#pragma mark - FDTakeController delegate

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)inDict
{
    //Remove video preview view if is on the addImageButton.
    [self removeVideoPreviewView];
    
    [[self.addImageButton imageView] setContentMode: UIViewContentModeScaleAspectFill];
    
    [self.addImageButton setImage:photo forState:UIControlStateNormal];

    _hasImage = YES;
    
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
    _previewVC = [[PBJVideoPlayerController alloc] init];
    _previewVC.delegate = self;
    [_previewVC setPlaybackLoops:YES];
    _previewVC.view.frame = _addImageButton.bounds;
    [_addImageButton addSubview:_previewVC.view];
    
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

#pragma mark - PBJVideoPlayerControllerDelegate

- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer
{
}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
    if(videoPlayer.playbackState == PBJVideoPlayerPlaybackStatePaused && !_inCategorySelection)
    {
        [self addImageOrImage:nil];
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
    [self setNumberOfCharacters:textView.text.length];
}

#pragma makr - Text text view

-(void)setNumberOfCharacters:(NSInteger)numberOfChars
{
    _remainingNumberOfCharacters = MAX_NO_OF_CHARACTERS - numberOfChars;
    
    [_charactersLeftLbl setText:[NSString stringWithFormat:@"%d %@", _remainingNumberOfCharacters , CHARACTERS_LEFT]];
    
    if(_remainingNumberOfCharacters < 0)
    {
        [_charactersLeftLbl setTextColor:[UIColor redColor]];
    }
    else
    {
        [_charactersLeftLbl setTextColor:[UIColor colorWithRed:LIGHT_BLACK_RGB green:LIGHT_BLACK_RGB blue:LIGHT_BLACK_RGB alpha:1.0f]];
    }
}

#pragma mark - VC Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.identifier isEqualToString:@"pick date"])
    {
        PickDateEventViewController *pickDateViewController = segue.destinationViewController;
        
        pickDateViewController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"show categories"])
    {
        
    }

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

-(void)navigateToCategoriesViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    GLPSelectCategoryViewController *categoriesVC = [storyboard instantiateViewControllerWithIdentifier:@"GLPSelectCategoryViewController"];
    [categoriesVC setDelegate:self];
    categoriesVC.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.67];

    categoriesVC.modalPresentationStyle = UIModalPresentationCustom;
    
    
    if(![GLPiOS6Helper isIOS6])
    {
        [categoriesVC setTransitioningDelegate:_transitionViewCategories];
    }
    

    [self presentViewController:categoriesVC animated:YES completion:nil];
    
    
    
    //    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:videoVC];
    //    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
//    [self.navigationController pushViewController:categoriesVC animated:YES];
    
}






@end
