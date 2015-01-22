//
//  ImageSelectorViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 17/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This is custom image selector. This class provides to the user the ability to
//  snap a photo or to choose photo from his/her library.

#import "ImageSelectorViewController.h"
#import "UINavigationBar+Format.h"
#import "ImageCollectionViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ImageFormatterHelper.h"
#import "AppearanceHelper.h"

@interface ImageSelectorViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) GLPImageSelectorLoader *imageLoader;
@property (strong, nonatomic) UIImage *snapPhotoImage;
@property (strong, nonatomic) UIImagePickerController *cameraUI;

@end

@implementation ImageSelectorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerCollectionViewCells];
    
    [self initialiseObjects];
    

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.navigationController.navigationBar.topItem.title = @"PICK AN IMAGE";
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureNavigationBar];

}

- (void)configureNavigationBar
{
    
    [self.navigationController.navigationBar setHidden:NO];

    
    if(![self comesFromGroupViewController])
    {
        [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
    }
    
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES andView:self.view];


    [self.navigationController.navigationBar setShadowImage:[ImageFormatterHelper generateOnePixelHeightImageWithColour:[AppearanceHelper mediumGrayGleepostColour]]];
    
    [self.navigationController.navigationBar setFontFormatWithColour:kRed];
}

- (void)initialiseObjects
{
    _cameraUI = [[UIImagePickerController alloc] init];
    _snapPhotoImage = [UIImage imageNamed:@"snap_photo"];
    _imageLoader = [[GLPImageSelectorLoader alloc] init];
    [_imageLoader setDelegate:self];
}

- (void)registerCollectionViewCells
{
    [self.collectionView registerNib:[UINib nibWithNibName:@"ImageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ImageCell"];
}

#pragma mark - GLPImageSelectorLoaderDelegate

- (void)imagesLoaded
{
    [_collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_imageLoader numberOfImages] + 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ImageCell";
    
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    if(indexPath.row == 0)
    {
        [cell setImageViewImage:_snapPhotoImage];
    }
    else
    {
        [cell setImageViewImage:[_imageLoader thumbnailAtIndex:indexPath.row - 1]];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 0)
    {
        //We are doing that because otherwise the app crashes. iOS 7/8 bug?
        [self performSelector:@selector(startCameraController) withObject:nil afterDelay:0.3];

    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_delegate takeImage:[_imageLoader realImageAtIndex:indexPath.row -1]];
            
        });
        
        [self.navigationController popViewControllerAnimated:YES];

    }
    
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return IMAGE_COLLECTION_CELL_DIMENSIONS;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return IMAGE_COLLECTION_CELL_MARGIN;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return IMAGE_COLLECTION_CELL_MARGIN;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
}

#pragma mark - Camera management

- (BOOL) startCameraController
{
    if (([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] == NO)
        || (self == nil)
        || (self == nil))
        return NO;
    
    
//    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    _cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    _cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];

    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    _cameraUI.allowsEditing = YES;
    
    _cameraUI.delegate = self;
    
    [self presentViewController:_cameraUI animated:YES completion:nil];
    

    return YES;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
        
        [_delegate takeImage: imageToSave];
        
        // Save the new image (original or edited) to the Camera Roll
        UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
    }
    
    [_cameraUI dismissViewControllerAnimated:YES completion:nil];

    
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [_cameraUI dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
