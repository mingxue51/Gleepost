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

@interface NewPostViewController ()

@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *contentTextView;
@property (strong, nonatomic) FDTakeController *fdTakeController;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;

@property (strong, nonatomic) GLPPostUploader *postUploader;
@property (assign, nonatomic) BOOL hasImage;
@property (weak, nonatomic) UIImage *imgToUpload;
@property (weak, nonatomic) IBOutlet UIButton *testCategoryBtn;
@property (strong, nonatomic) GLPCategory *chosenCategory;

//@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

- (IBAction)cancelButtonClick:(id)sender;
- (IBAction)postButtonClick:(id)sender;

@end

@implementation NewPostViewController


@synthesize delegate;
@synthesize postUploader=_postUploader;
@synthesize hasImage=_hasImage;
@synthesize chosenCategory = _chosenCategory;

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    [self.contentTextView becomeFirstResponder];
    
    _chosenCategory = nil;
    
    if(!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7"))
    {
        //If iOS 6 add transparent black UIImageView.
        UIImageView *imageViewBlack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, self.contentTextView.frame.size.height+50)];
        
        imageViewBlack.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.67];
        
        [self.view addSubview:imageViewBlack];
        [self.view sendSubviewToBack:imageViewBlack];
    }

    
    self.tabBarController.tabBar.hidden = NO;

    [self configureNavigationBar];

    
    _postUploader = [[GLPPostUploader alloc] init];
    _hasImage = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.contentTextView becomeFirstResponder];

    self.fdTakeController = [[FDTakeController alloc] init];
    self.fdTakeController.viewControllerForPresentingImagePickerController = self;
    self.fdTakeController.delegate = self;
    
    [self formatBackground];
}



-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.delegate.view setBackgroundColor:[UIColor whiteColor]];
}


#pragma mark - Configuration

-(void)configureNavigationBar
{
    //UIColor *tabColour = [[GLPThemeManager sharedInstance] colorForTabBar];

//    [self.simpleNavBar setBackgroundImage:[UIImage imageNamed:@"chat_background_default"] forBarMetrics:UIBarMetricsDefault];
    
    [self.simpleNavBar setBackgroundColor:[UIColor clearColor]];
    
    [self.simpleNavBar setTranslucent:NO];
    [self.simpleNavBar setFrame:CGRectMake(0.f, 0.f, 320.f, 65.f)];
    self.simpleNavBar.tintColor = [UIColor whiteColor];
    
    [self.simpleNavBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor,[UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f], UITextAttributeFont, nil]];
}


-(void)formatBackground
{
//    [self.view setBackgroundColor:[UIColor clearColor]];
//    [self.view setAlpha:0.5];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)cancelButtonClick:(id)sender
{
    [self.delegate setNavigationBarName];
    [self.delegate setButtonsToNavigationBar];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postButtonClick:(id)sender
{
    if (![NSString isStringEmpty:self.contentTextView.text]) {
        [self.delegate setNavigationBarName];
        [self.delegate setButtonsToNavigationBar];
        
        [self.contentTextView resignFirstResponder];
        
        
        GLPPost* inPost = [_postUploader uploadPost:self.contentTextView.text withCategories:[[NSArray alloc] initWithObjects:_chosenCategory, nil]];
        
        //Dismiss view controller and show immediately the post in the Campus Wall.
        
        [self dismissViewControllerAnimated:YES completion:^{
            if(_hasImage)
            {
//                inPost.tempImage = self.imgToUpload;
                //inPost.imagesUrls = [[NSArray alloc] initWithObjects:@"LIVE", nil];
                [delegate reloadNewImagePostWithPost:inPost];
            }
            else
            {
                //[delegate reloadNewLocalPosts];
                [delegate reloadNewImagePostWithPost:inPost];
            }
            
        }];
    }
}
- (IBAction)selectTestCategory:(id)sender
{
    if([[self.testCategoryBtn titleColorForState:UIControlStateNormal] isEqual:[UIColor whiteColor]])
    {
        _chosenCategory = nil;
        [self.testCategoryBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
    else
    {
        _chosenCategory = [[GLPCategory alloc]initWithTag:@"test" name:@"" andPostRemoteKey:0];
        //test category was chosen.
        
        [self.testCategoryBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (IBAction)addImage:(id)sender
{
    [self.fdTakeController takePhotoOrChooseFromLibrary];
}

#pragma mark - FDTakeController delegate

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)inDict
{
    [self.addImageButton setImage:photo forState:UIControlStateNormal];

    _hasImage = YES;
    
    self.imgToUpload = photo;
    [_postUploader uploadImageToQueue:self.imgToUpload];
    //[_postUploader startUploadingImage:self.imgToUpload];
}






@end
