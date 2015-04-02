//
//  GLPNewCategoriesViewController.m
//  Gleepost
//
//  Created by Silouanos on 01/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPNewCategoriesViewController.h"
#import "UIImage+StackBlur.h"
#import "GPUImage.h"
#import "GLPCategoriesAnimationHelper.h"
#import "ShapeFormatterHelper.h"
#import "CategoryManager.h"

@interface GLPNewCategoriesViewController () <GLPCategoriesAnimationHelperDelegate>

//IBOutlets.
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *allPostsView;

@property (strong, nonatomic) GLPCategoriesAnimationHelper *animationHelper;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *collectionViews;

//Constraints.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceAllPostsViewFromTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceFreeFoodViewFromTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distancePartiesViewFromTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceSportsViewFromTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceSpeakersViewFromTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceMusicViewFromTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceTheaterViewFromTop;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceAnnouncementsViewFromTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceGeneralViewFromTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceQuestionsViewFromTop;


@end

@implementation GLPNewCategoriesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialiseObjects];
    [self formatElements];
    [self configureGestures];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self intialisePositions];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self bringElementsWithAnimations];
}

- (void)initialiseObjects
{
    self.animationHelper = [[GLPCategoriesAnimationHelper alloc] init];
    self.animationHelper.delegate = self;
}

- (void)intialisePositions
{
    CGFloat initialPosition = [self.animationHelper getInitialElementsPosition];
    self.distanceAllPostsViewFromTop.constant = initialPosition;
    self.distanceFreeFoodViewFromTop.constant = initialPosition;
    self.distancePartiesViewFromTop.constant = initialPosition;
    self.distanceSportsViewFromTop.constant = initialPosition;
    self.distanceAnnouncementsViewFromTop.constant = initialPosition;
    self.distanceGeneralViewFromTop.constant = initialPosition;
    self.distanceQuestionsViewFromTop.constant = initialPosition;
}

- (void)formatElements
{
    [self formatAllPostsView];
}

- (void)configureGestures
{
    UITapGestureRecognizer *allPostsGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(elementSelected:)];
    [self.allPostsView addGestureRecognizer:allPostsGesture];
}

#pragma mark - Actions

- (void)bringElementsWithAnimations
{
    [self.animationHelper animateElementWithTopConstraint:self.distanceAllPostsViewFromTop withKindOfView:kAllOrder];
    [self.animationHelper animateElementWithTopConstraint:self.distanceFreeFoodViewFromTop withKindOfView:kFreeFood];
    [self.animationHelper animateElementWithTopConstraint:self.distancePartiesViewFromTop withKindOfView:kPartiesOrder];
    [self.animationHelper animateElementWithTopConstraint:self.distanceSportsViewFromTop withKindOfView:kSportsOrder];
    [self.animationHelper animateElementWithTopConstraint:self.distanceSpeakersViewFromTop withKindOfView:kSpeakersOrder];
    [self.animationHelper animateElementWithTopConstraint:self.distanceMusicViewFromTop withKindOfView:kMusicOrder];
    [self.animationHelper animateElementWithTopConstraint:self.distanceTheaterViewFromTop withKindOfView:kTheaterOrder];
    [self.animationHelper animateElementWithTopConstraint:self.distanceAnnouncementsViewFromTop withKindOfView:kAnnouncementsOrder];
    [self.animationHelper animateElementWithTopConstraint:self.distanceGeneralViewFromTop withKindOfView:kGeneralOrder];
    [self.animationHelper animateElementWithTopConstraint:self.distanceQuestionsViewFromTop withKindOfView:kQuestionsOrder];
}

- (void)dismissElementsWithAnimations
{
//    [self.animationHelper dismissElementWithTopConstraint:self.distanceAllPostsViewFromTop withKindOfView:kAllOrder];
//    [self.animationHelper dismissElementWithTopConstraint:self.distanceFreeFoodViewFromTop withKindOfView:kFreeFood];
//    [self.animationHelper dismissElementWithTopConstraint:self.distancePartiesViewFromTop withKindOfView:kPartiesOrder];
//    [self.animationHelper dismissElementWithTopConstraint:self.distanceSportsViewFromTop withKindOfView:kSportsOrder];
//    [self.animationHelper dismissElementWithTopConstraint:self.distanceSpeakersViewFromTop withKindOfView:kSpeakersOrder];
//    [self.animationHelper dismissElementWithTopConstraint:self.distanceMusicViewFromTop withKindOfView:kMusicOrder];
//    [self.animationHelper dismissElementWithTopConstraint:self.distanceTheaterViewFromTop withKindOfView:kTheaterOrder];
//    [self.animationHelper dismissElementWithTopConstraint:self.distanceAnnouncementsViewFromTop withKindOfView:kAnnouncementsOrder];
//    [self.animationHelper dismissElementWithTopConstraint:self.distanceGeneralViewFromTop withKindOfView:kGeneralOrder];
//    [self.animationHelper dismissElementWithTopConstraint:self.distanceQuestionsViewFromTop withKindOfView:kQuestionsOrder];
    
    for(UIView *v in self.collectionViews)
    {        
        [self.animationHelper dismissElementWithView:v withKindOfView:v.tag];
    }
}

#pragma mark - Format

- (void)formatAllPostsView
{
    [self.allPostsView layoutIfNeeded];
    [ShapeFormatterHelper setBorderToView:self.allPostsView withColour:[UIColor whiteColor] andWidth:3.0f];
    [ShapeFormatterHelper setCornerRadiusWithView:self.allPostsView andValue:6];
}

#pragma mark - Image

- (void)setCampusWallScreenshot:(UIImage *)campusWallImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:campusWallImage];
        
        GPUImageGaussianSelectiveBlurFilter *stillImageFilter = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
        
        [stillImageSource addTarget:stillImageFilter];
        stillImageFilter.excludeBlurSize = 0.0;
        stillImageFilter.excludeCircleRadius = 0.0;
        stillImageFilter.excludeCirclePoint = CGPointMake(0.0, 0.0);
        stillImageFilter.blurRadiusInPixels = 4.0;
        [stillImageFilter useNextFrameForImageCapture];
        [stillImageSource processImage];
        
        UIImage *currentFilteredVideoFrame = [stillImageFilter imageFromCurrentFramebuffer];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.backgroundImageView setImage:currentFilteredVideoFrame];
        });
    });
}

#pragma mark - GLPCategoriesAnimationHelperDelegate

- (void)viewsDisappeared
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Selectors

- (IBAction)hideViewController:(id)sender
{
    [self dismissViewController];
}

- (IBAction)elementSelected:(id)sender
{
    UIView *selectedView = nil;
    
    if([sender isKindOfClass:[UITapGestureRecognizer class]])
    {
        selectedView = [(UITapGestureRecognizer *)sender view];
    }
    else
    {
        selectedView = (UIView *)sender;
    }
    
    GLPCategory *selectedCategory = [[CategoryManager sharedInstance] setSelectedCategoryWithOrderKey:selectedView.tag];
    [self informCampusLiveWithCategory:selectedCategory];
    [self.delegate refreshPostsWithNewCategory];
    [self dismissViewController];
}

- (void)dismissViewController
{
    [self dismissElementsWithAnimations];
}

#pragma mark - Post notifications

- (void)informCampusLiveWithCategory:(GLPCategory *)category
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_UPDATE_CATEGORY_LABEL object:nil userInfo:@{@"Category": category.name}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
