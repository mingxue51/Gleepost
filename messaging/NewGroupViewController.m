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
#import "GLPiOSSupportHelper.h"

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
@property (strong, nonatomic) UIProgressView *progress;

@property (strong, nonatomic) NSDate *timestamp;

@property (strong, nonatomic) NSDictionary *groupTypes;

@property (strong, nonatomic) NSDictionary *selectedGroupType;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainViewHeight;



@end

@implementation NewGroupViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureTextView];
    
    [self configureGesturesOnViews];
    
    [self formatViews];
    
    [self configureGroupTypeDictionary];
    
    [self formatSelectedGroup];
    
    [self setDataToGroupViews];

    [self configureViews];

//    if(!IS_IPHONE_5) {
//        CGFloat offset = -25;
////        CGRectMoveY(_groupDescriptionTextView, offset);
//        CGRectAddH(_groupDescriptionTextView, offset);
//
//    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [_groupNameTextField resignFirstResponder];
    
    [_groupDescriptionTextView resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [_groupDescriptionTextView resignFirstResponder];
        
        return NO;
    }
    
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self configureNotifications];
    
    [_groupNameTextField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureNavigationBar];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self removeNotifications];
    
    [super viewWillDisappear:animated];
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

- (void)configureViews
{
    if([GLPiOSSupportHelper useShortConstrains])
    {
        [_mainViewHeight setConstant:50.0];
    }
}

- (void)configureNotifications
{
    // keyboard management
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
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

- (void)dismissModalView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createNewGroup:(id)sender
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
        
        group.privacy = _groupType;
        
        group.pendingImage = _groupImage;
        
        [[GroupOperationManager sharedInstance] setGroup:group withTimestamp:_timestamp];
        
        
        DDLogDebug(@"FINAL Group type: %u and key %ld", _groupType, (long)group.key);

        [_delegate groupCreatedWithData:group];
    }
    else
    {
        [WebClientHelper showEmptyTextError];
    }
    
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
    
    float newHeightOfMainView = [self findNewHeightForTheCentralViewWithKeboardFrame:keyboardBounds];
    
    float newYSelectImageView = [self findNewYOfSelectImageViewWithKeyboardFrame:keyboardBounds];
        
    [UIView animateWithDuration:[duration doubleValue] delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|(animationCurve << 16)) animations:^{
        
//        CGRectSetH(_mainView, newHeightOfMainView);
//        CGRectSetY(_selectImageView, newYSelectImageView);
        
    } completion:^(BOOL finished) {
        
    }];
}

- (float)findNewHeightForTheCentralViewWithKeboardFrame:(CGRect)keyboardFrame
{
    float keyboardY = keyboardFrame.origin.y;
    
    //We are substracting with 125 because without it the position is wrong.
    //So if we don't substract with that number the position of the button will be wrong.
    
    return keyboardY - _mainView.frame.origin.y - 5 - 125;
}

- (float)findNewYOfSelectImageViewWithKeyboardFrame:(CGRect)keyboardFrame
{
    float keyboardY = keyboardFrame.origin.y;

    return keyboardY - _selectImageView.frame.size.height - 5 - 189;
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
