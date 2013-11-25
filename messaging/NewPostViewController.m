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

@interface NewPostViewController ()

@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *contentTextView;
@property (strong, nonatomic) FDTakeController *fdTakeController;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;

@property (strong, nonatomic) GLPPostUploader *postUploader;
@property (assign, nonatomic) BOOL hasImage;
@property (weak, nonatomic) UIImage *imgToUpload;


//@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

- (IBAction)cancelButtonClick:(id)sender;
- (IBAction)postButtonClick:(id)sender;

@end

@implementation NewPostViewController


@synthesize delegate;
@synthesize postUploader=_postUploader;
@synthesize hasImage=_hasImage;

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    [self.contentTextView becomeFirstResponder];
    
    
    if(!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7"))
    {
        //If iOS 6 add transparent black UIImageView.
        UIImageView *imageViewBlack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, self.contentTextView.frame.size.height+50)];
        
        imageViewBlack.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.67];
        
        [self.view addSubview:imageViewBlack];
        [self.view sendSubviewToBack:imageViewBlack];
    }

    
    
    self.tabBarController.tabBar.hidden = NO;
    [self.simpleNavBar setBackgroundImage:[UIImage imageNamed:@"navigationbar2"] forBarMetrics:UIBarMetricsDefault];
    
    [self.simpleNavBar setTranslucent:YES];
    [self.simpleNavBar setFrame:CGRectMake(0.f, 0.f, 320.f, 65.f)];
    
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
    [self.delegate setPlusButtonToNavigationBar];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postButtonClick:(id)sender
{
    [self.delegate setNavigationBarName];
    [self.delegate setPlusButtonToNavigationBar];
    
    [self.contentTextView resignFirstResponder];
    [_postUploader uploadImage:self.imgToUpload];
    
    GLPPost* inPost = [_postUploader uploadPostWithContent:self.contentTextView.text hasImage:_hasImage];
    
    [self dismissViewControllerAnimated:YES completion:^{
        if(_hasImage)
        {
            [delegate reloadNewImagePostWithPost:inPost];
        }
        else
        {
            [delegate reloadNewLocalPosts];
        }
        
    }];
}


#pragma mark - FDTakeController delegate

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)inDict
{
    [self.addImageButton setImage:photo forState:UIControlStateNormal];

    _hasImage = YES;
    
    self.imgToUpload = photo;
   // [_postUploader uploadImage:photo];
}


- (IBAction)addImage:(id)sender
{
    [self.fdTakeController takePhotoOrChooseFromLibrary];
}



@end
