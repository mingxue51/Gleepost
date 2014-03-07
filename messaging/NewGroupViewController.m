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
#import "ShapeFormatterHelper.h"

@interface NewGroupViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property (weak, nonatomic) IBOutlet UITextField *groupNameTextField;

@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *groupDescriptionTextView;

@property (weak, nonatomic) UIViewController <GroupCreatedDelegate> *delegate;

@property (strong, nonatomic) UIImage *groupImage;
@property (weak, nonatomic) IBOutlet UIButton *addImageBtn;
@property (strong, nonatomic) FDTakeController *fdTakeController;
@property (strong, nonatomic) UIProgressView *progress;

@property (strong, nonatomic) NSDate *timestamp;

@end

@implementation NewGroupViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureTextView];
    
    [self configureFDTakeController];
    
//    [self configureProgressBar];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_groupNameTextField becomeFirstResponder];
}

#pragma mark - Configuration

-(void)configureTextView
{
    _groupDescriptionTextView.placeholder = @"Group description";
    
    [ShapeFormatterHelper setCornerRadiusWithView:_groupDescriptionTextView andValue:5];

}

-(void)configureFDTakeController
{
    self.fdTakeController = [[FDTakeController alloc] init];
    self.fdTakeController.viewControllerForPresentingImagePickerController = self;
    self.fdTakeController.delegate = self;
}

-(void)configureProgressBar
{
    // Do any additional setup after loading the view.
    
    self.progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    self.progress.tag = 100;
    [self.view addSubview:self.progress];
    UINavigationBar *navBar = [self navBar];
    
    NSLayoutConstraint *constraint;
    constraint = [NSLayoutConstraint constraintWithItem:self.progress attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:navBar attribute:NSLayoutAttributeBottom multiplier:1 constant:-0.5];
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.progress attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:navBar attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.progress attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:navBar attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    [self.view addConstraint:constraint];
    
    [self.progress setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.progress.hidden = NO;
    
    [self.progress setProgress:1.0f];
}

#pragma mark - Selectors

- (IBAction)dismissModalView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)createNewGroup:(id)sender
{
    GLPGroup *group = [[GLPGroup alloc] init];
    
    if ([self isInformationValid])
    {
        group.name = _groupNameTextField.text;
        
        [[GroupOperationManager sharedInstance] setGroup:group withTimestamp:_timestamp];
        
        group.finalImage = _groupImage;
        
        [_delegate groupCreatedWithData:group];

        [self dismissModalView:nil];
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

-(BOOL)isInformationValid
{
    return /*![_groupDescriptionTextView.text isEqualToString:@""] &&*/ ![_groupNameTextField.text isEqualToString:@""];
}


#pragma mark - FDTakeController delegate

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)inDict
{
    [self.addImageBtn setImage:photo forState:UIControlStateNormal];
    
//    _hasImage = YES;
    
    _groupImage = photo;
    
    
    _timestamp = [NSDate date];
    
    //Add image to image uploader to start the uploading.
    [[GroupOperationManager sharedInstance] uploadImage:_groupImage withTimestamp:_timestamp];
    
        
//    [_postUploader uploadImageToQueue:self.imgToUpload];
    //[_postUploader startUploadingImage:self.imgToUpload];
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

@end
