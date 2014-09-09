//
//  ImageSelectorViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 17/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "ImageSelectorViewController.h"
#import "UINavigationBar+Format.h"
#import "ImageCollectionViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ImageSelectorViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) GLPImageSelectorLoader *imageLoader;

@end

@implementation ImageSelectorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerCollectionViewCells];
    
    [self initialiseObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureNavigationBar];
}

- (void)configureNavigationBar
{
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
    
    [self.navigationController.navigationBar setFontFormatWithColour:kRed];
}

- (void)initialiseObjects
{
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
    return [_imageLoader numberOfImages];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ImageCell";
    
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
//    [cell setDelegate:self];
    
    [cell setImageViewImage:[_imageLoader thumbnailAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_delegate takeImage:[_imageLoader realImageAtIndex:indexPath.row]];
        
    });
    
    
    [self.navigationController popViewControllerAnimated:YES];
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
