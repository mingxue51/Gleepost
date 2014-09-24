//
//  NewGroupViewController.m
//  Gleepost
//
//  Created by Silouanos on 05/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "NewGroupViewController.h"
#import "UIPlaceHolderTextView.h"
#import "WebClientHelper.h"
#import "GroupOperationManager.h"
#import "UINavigationBar+Format.h"
#import "UINavigationBar+Utils.h"
#import "UIView+GLPDesign.h"
#import "ShapeFormatterHelper.h"

@interface NewGroupViewController ()

@property (weak, nonatomic) IBOutlet UITextField *groupNameTextField;

@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *groupDescriptionTextView;

@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (weak, nonatomic) IBOutlet UIView *dropDownView;

@property (weak, nonatomic) IBOutlet UIView *selectGroupTypeView;

@property (weak, nonatomic) IBOutlet UIView *selectImageView;

@property (weak, nonatomic) IBOutlet UIView *nameDescriptionView;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *groupTypesButtons;

@property (weak, nonatomic) IBOutlet UILabel *selectedGroupLbl;

@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;

@property (weak, nonatomic) IBOutlet UILabel *addGroupImageLbl;

@property (weak, nonatomic) UIViewController <GroupCreatedDelegate> *delegate;

@property (strong, nonatomic) UIImage *groupImage;
@property (weak, nonatomic) IBOutlet UIButton *addImageBtn;
@property (strong, nonatomic) FDTakeController *fdTakeController;
@property (strong, nonatomic) UIProgressView *progress;

@property (strong, nonatomic) NSDate *timestamp;

@property (strong, nonatomic) NSDictionary *groupTypes;

@property (strong, nonatomic) NSDictionary *selectedGroupType;

//@property (strong, nonatomic) NSKeyValueChange

@end

@implementation NewGroupViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureTextView];
    
    [self configureFDTakeController];
    
    [self configureGesturesOnViews];
    
    [self formatViews];
    
    [self configureGroupTypeDictionary];
    
    [self formatSelectedGroup];
    
    [self setDataToGroupViews];

    if(!IS_IPHONE_5) {
        CGFloat offset = -25;
//        CGRectMoveY(_groupDescriptionTextView, offset);
        CGRectAddH(_groupDescriptionTextView, offset);

    }
//    [self configureProgressBar];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_groupNameTextField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureNavigationBar];
}

#pragma mark - Configuration

-(void)configureTextView
{
    _groupDescriptionTextView.placeholder = @"Group description";
}

- (void)configureGesturesOnViews
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dropDownList)];
    [tap setNumberOfTapsRequired:1];
    [_selectGroupTypeView addGestureRecognizer:tap];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectImage)];
    [tap setNumberOfTapsRequired:1];
    [_selectImageView addGestureRecognizer:tap];
}

- (void)formatViews
{
    [_selectGroupTypeView setGleepostStyleBorder];
    [_selectImageView setGleepostStyleBorder];
    [_nameDescriptionView setGleepostStyleBorder];
    [_dropDownView setGleepostStyleBorder];
    [ShapeFormatterHelper setTwoLeftCornerRadius:_selectedImageView withViewFrame:_selectedImageView.frame withValue:4];
}

-(void)configureFDTakeController
{
    self.fdTakeController = [[FDTakeController alloc] init];
    self.fdTakeController.viewControllerForPresentingImagePickerController = self;
    self.fdTakeController.delegate = self;
}

//-(void)configureProgressBar
//{
//    // Do any additional setup after loading the view.
//    
//    self.progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
//    self.progress.tag = 100;
//    [self.view addSubview:self.progress];
//    UINavigationBar *navBar = [self navBar];
//    
//    NSLayoutConstraint *constraint;
//    constraint = [NSLayoutConstraint constraintWithItem:self.progress attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:navBar attribute:NSLayoutAttributeBottom multiplier:1 constant:-0.5];
//    [self.view addConstraint:constraint];
//    
//    constraint = [NSLayoutConstraint constraintWithItem:self.progress attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:navBar attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
//    [self.view addConstraint:constraint];
//    
//    constraint = [NSLayoutConstraint constraintWithItem:self.progress attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:navBar attribute:NSLayoutAttributeRight multiplier:1 constant:0];
//    [self.view addConstraint:constraint];
//    
//    [self.progress setTranslatesAutoresizingMaskIntoConstraints:NO];
//    self.progress.hidden = NO;
//    
//    [self.progress setProgress:1.0f];
//}

-(void)configureNavigationBar
{
//    [AppearanceHelper setNavigationBarFontForNavigationBar:_navBar];

    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
    [self.navigationController.navigationBar setFontFormatWithColour:kBlack];
        
    [self.navigationController.navigationBar setTextButton:kRight withTitle:@"Done" withButtonSize:CGSizeMake(50, 20) withSelector:@selector(createNewGroup:) andTarget:self];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

/**
 Creates a new dictionary to store the name of each group type
 and enum respectively.
 
 */
- (void)configureGroupTypeDictionary
{
    
    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
    
    [tempDictionary setObject:@"Public group" forKey:[NSNumber numberWithInteger:kPublicGroup]];
    
    [tempDictionary setObject:@"Private group" forKey:[NSNumber numberWithInteger:kPrivateGroup]];
    
    [tempDictionary setObject:@"Secret group" forKey:[NSNumber numberWithInteger: kSecretGroup]];
    
    _groupTypes = [[NSDictionary alloc] initWithDictionary:tempDictionary.mutableCopy];
}

/**
 Create the selected group (from IntroNewGroupVC) in a dictionary.
 */
- (void)formatSelectedGroup
{
    NSString *selectedGroupStr = [_groupTypes objectForKey:[NSNumber numberWithInteger: _groupType]];
    
    _selectedGroupType = [[NSDictionary alloc] initWithObjectsAndKeys:selectedGroupStr, [NSNumber numberWithInteger:_groupType], nil];
    
}

- (void)setDataToGroupViews
{
    int btnIndex = 0;

    NSNumber *selectedGroupNumber = [[_selectedGroupType allKeys] objectAtIndex:0];
    
    [_selectedGroupLbl setText:[[_selectedGroupType allValues] objectAtIndex:0]];
    
    for(NSNumber *number in _groupTypes)
    {
        if(![number isEqualToNumber:selectedGroupNumber])
        {
            UIButton *currentButton = (UIButton *)[_groupTypesButtons objectAtIndex:btnIndex];
            
            [currentButton setTitle:[_groupTypes objectForKey:number] forState:UIControlStateNormal];
            
            currentButton.tag = [number integerValue];
            
            ++btnIndex;
        }
    }
}

#pragma mark - Selectors

- (IBAction)dismissModalView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)createNewGroup:(id)sender
{
    GLPGroup *group = [[GLPGroup alloc] init];
    
    
    if(![self isInformationInBounds])
    {
        [WebClientHelper showOutOfBoundsError];
        return;
    }
    
    
    if ([self isInformationValid])
    {
        group.name = _groupNameTextField.text;
        
        if(![_groupDescriptionTextView.text isEqualToString:@""])
        {
            group.groupDescription = _groupDescriptionTextView.text;
        }
        
        DDLogDebug(@"FINAL Group type: %d", _groupType);
        
        group.privacy = _groupType;
        
        [[GroupOperationManager sharedInstance] setGroup:group withTimestamp:_timestamp];
        
        group.finalImage = _groupImage;
        
        [_delegate groupCreatedWithData:group];

    }
    else
    {
        [WebClientHelper showEmptyTextError];
    }
    
}
- (IBAction)addImage:(id)sender
{
    [self.fdTakeController takePhotoOrChooseFromLibrary];
}

- (void)dropDownList
{
    if(_dropDownView.tag == 0)
    {
        [self showOptionsMenu];
    }
    else
    {
        [self hideOptionsMenu];
    }
}

- (void)selectImage
{
    [self performSegueWithIdentifier:@"show image selector" sender:self];
}

- (IBAction)selectedNewGroupType:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    NSNumber *selectedBtnNumber = [NSNumber numberWithInteger:btn.tag];
    
    NSString *selectedBtnTitle = [_groupTypes objectForKey:selectedBtnNumber];
    
    _selectedGroupType = [[NSDictionary alloc] initWithObjectsAndKeys:selectedBtnTitle, selectedBtnNumber, nil];
    
    _groupType = btn.tag;
    
    [self setDataToGroupViews];
    
    [self hideOptionsMenu];
}


#pragma mark - Helpers

-(BOOL)isInformationValid
{
    return ![_groupNameTextField.text isEqualToString:@""];
}

-(BOOL)isInformationInBounds
{
    if(_groupDescriptionTextView.text.length > 80)
    {
        return NO;
    }
    
    if(_groupNameTextField.text.length > 40)
    {
        return NO;
    }
    
    return YES;
}


#pragma mark - UI methods

- (void)showOptionsMenu
{
    _dropDownView.tag = 1;
    
    [_dropDownView setHidden:NO];
    
    _arrowImageView.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0.0, 1.0);
    
    [UIView animateWithDuration:0.3 animations:^{
       
        CGRectSetY(_mainView, _mainView.frame.origin.y + 90);
        
        [_dropDownView setAlpha:1.0];
        
    }];
}

- (void)hideOptionsMenu
{
    _dropDownView.tag = 0;

    _arrowImageView.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0.0, 0.0);

    [UIView animateWithDuration:0.3 animations:^{
        
        CGRectSetY(_mainView, _mainView.frame.origin.y - 90);

        [_dropDownView setAlpha:0.0];

    } completion:^(BOOL finished) {
      
        [_dropDownView setHidden:YES];
        
    }];
}

#pragma mark - FDTakeController delegate

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)inDict
{
    
    [[self.addImageBtn imageView] setContentMode: UIViewContentModeScaleAspectFill];
    
    [self.addImageBtn setImage:photo forState:UIControlStateNormal];
    
//    _hasImage = YES;
    
    _groupImage = photo;
    
    
    _timestamp = [NSDate date];
    
    //Add image to image uploader to start the uploading.
    [[GroupOperationManager sharedInstance] uploadImage:_groupImage withTimestamp:_timestamp];
    
        
//    [_postUploader uploadImageToQueue:self.imgToUpload];
    //[_postUploader startUploadingImage:self.imgToUpload];
}

#pragma mark - ImageSelectorViewControllerDelegate

- (void)takeImage:(UIImage *)image
{
    [_selectedImageView setImage:image];
    
    [_addGroupImageLbl setHidden:YES];
    
    _groupImage = image;
    
    _timestamp = [NSDate date];
    
    //Add image to image uploader to start the uploading.
    [[GroupOperationManager sharedInstance] uploadImage:_groupImage withTimestamp:_timestamp];
}

-(void)setDelegate:(UIViewController<GroupCreatedDelegate> *)delegate
{
    _delegate = delegate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"show image selector"])
    {
        ImageSelectorViewController *imgSelectorVC = segue.destinationViewController;
        
        [imgSelectorVC setDelegate:self];
    }
}

@end
