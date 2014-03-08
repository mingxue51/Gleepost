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

@interface NewPostViewController ()


//IBOutlets.
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *categoriesLbl;

//Category buttons.
@property (weak, nonatomic) IBOutlet UIButton *forSaleCategoryBtn;
@property (weak, nonatomic) IBOutlet UIButton *newsCategoryBtn;
@property (weak, nonatomic) IBOutlet UIButton *eventsCategoryBtn;
@property (weak, nonatomic) IBOutlet UIButton *jobsCategoryBtn;
@property (weak, nonatomic) IBOutlet UIButton *questionsCategoryBtn;
@property (strong, nonatomic) GLPCategory *eventCategory;

//Navigation bar.
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelNavBarBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postNavBarBtn;

@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) FDTakeController *fdTakeController;
@property (strong, nonatomic) GLPPostUploader *postUploader;
@property (assign, nonatomic) BOOL hasImage;
@property (weak, nonatomic) UIImage *imgToUpload;
@property (strong, nonatomic) NSDate *eventDateStart;
@property (strong, nonatomic) NSString *eventTitle;

//@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

- (IBAction)cancelButtonClick:(id)sender;
- (IBAction)postButtonClick:(id)sender;

@end

@implementation NewPostViewController


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



    [self.contentTextView becomeFirstResponder];
    
    _categories = [NSMutableArray array];
    
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
    [self configureCategoryButtons];
    [self configureLabel];

//    [self generateCategoryButtons];
    
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
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
//    [self.delegate.view setBackgroundColor:[UIColor whiteColor]];
}


#pragma mark - Configuration

-(void)configureObjects
{
    _eventDateStart = nil;
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

-(void)configureNavigationBar
{
    [self formatNavigationBar];
    [self formatNavigationButtons];
}

-(void)formatNavigationBar
{
    [self.simpleNavBar setBackgroundColor:[UIColor clearColor]];
    
    [self.simpleNavBar setTranslucent:NO];
    [self.simpleNavBar setFrame:CGRectMake(0.f, 0.f, 320.f, 65.f)];
    self.simpleNavBar.tintColor = [UIColor blackColor];
    
    [self.simpleNavBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor blackColor], UITextAttributeTextColor, [UIFont fontWithName:GLP_TITLE_FONT size:20.0f], UITextAttributeFont, nil]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

}

-(void)formatNavigationButtons
{
    UIFont *font = [UIFont fontWithName:GLP_TITLE_FONT size:17.0f];
    [self.cancelNavBarBtn setTitleTextAttributes:@{NSFontAttributeName: font}
                                     forState:UIControlStateNormal];
    
    
    font = [UIFont fontWithName:GLP_TITLE_FONT size:22.0f];
    [self.postNavBarBtn setTitleTextAttributes:@{NSFontAttributeName: font}
                                        forState:UIControlStateNormal];
}

-(void)configureLabel
{
    [self.categoriesLbl setFont:[UIFont fontWithName:GLP_TITLE_FONT size:14.0f]];
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
            
            DDLogDebug(@"GROUP REMOTE KEY: %d", _group.remoteKey);
            
            inPost = [_postUploader uploadPost:self.contentTextView.text withCategories:_categories eventTime:_eventDateStart title:_eventTitle andGroup:_group];
        }
        else
        {
            inPost = [_postUploader uploadPost:self.contentTextView.text withCategories:_categories eventTime:_eventDateStart andTitle:_eventTitle];
        }
        
        
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


#pragma mark - Selectors

-(IBAction)selectCategory:(id)sender
{
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

- (void)doneSelectingDateForEvent:(NSDate *)date andTitle:(NSString *)title
{
    DDLogDebug(@"DATE! : %@ with title: %@",date, title);
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

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PickDateEventViewController *pickDateViewController = segue.destinationViewController;
    
    pickDateViewController.delegate = self;
}







@end
