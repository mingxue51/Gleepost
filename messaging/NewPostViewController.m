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

- (void)viewDidLoad
{
    [super viewDidLoad];


    [self.contentTextView becomeFirstResponder];
    
    _categories = [NSMutableArray array];
    
    if(!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7"))
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
    
    [self.delegate.view setBackgroundColor:[UIColor whiteColor]];
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
        
        
//        GLPPost* inPost = [_postUploader uploadPost:self.contentTextView.text withCategories:[[NSArray alloc] initWithObjects:_chosenCategory, nil]];
        
        GLPPost* inPost = [_postUploader uploadPost:self.contentTextView.text withCategories:_categories eventTime:_eventDateStart andTitle:_eventTitle];
        
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

        
        [_categories addObject:chosenCategory];

        
    }
    else
    {        
        
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

}

- (void)doneSelectingDateForEvent:(NSDate *)date andTitle:(NSString *)title
{
    DDLogDebug(@"DATE! : %@ with title: %@",date, title);
    _eventDateStart = date;
    _eventTitle = title;
    
}


-(void)popUpTimeSelectorWithCategory:(GLPCategory *)category
{
    if([category.tag isEqualToString:@"event"])
    {
        
        //Pop up the time selector.
        [self performSegueWithIdentifier:@"pick date" sender:self];
        
    }
}

-(void)deleteCategoryWithRemoteKey:(int)remoteKey
{
    
    for(GLPCategory *c in _categories)
    {
        if(c.remoteKey == remoteKey)
        {
            [_categories removeObject:c];
            break;
        }
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

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PickDateEventViewController *pickDateViewController = segue.destinationViewController;
    
    pickDateViewController.delegate = self;
}







@end
