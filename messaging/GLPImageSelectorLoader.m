//
//  GLPImageSelectorLoader.m
//  Gleepost
//
//  Created by Σιλουανός on 17/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPImageSelectorLoader.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface GLPImageSelectorLoader ()
{
    ALAssetsLibraryAccessFailureBlock failureBlock;
}

@property (strong, nonatomic) NSMutableArray *images;
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property (strong, nonatomic) NSMutableArray *assets;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;


@end

@implementation GLPImageSelectorLoader

- (id)init
{
    self = [super init];
    
    if(self)
    {
        [self initialiseObjects];
        
        [self checkIfThereIsFailure];
        
        [self loadGroup];
        
    }
    
    return self;
}

- (void)initialiseObjects
{
    _images = [[NSMutableArray alloc] init];
    _assetsLibrary = [[ALAssetsLibrary alloc] init];
    _assets = [[NSMutableArray alloc] init];

}

#pragma mark - Loaders

- (void)checkIfThereIsFailure
{
    // setup our failure view controller in case enumerateGroupsWithTypes fails
    failureBlock = ^(NSError *error) {
        
        NSString *errorMessage = nil;
        
        switch ([error code]) {
                
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"The user has declined access to it.";
                break;
            default:
                errorMessage = @"Reason unknown.";
                break;
        }
        
        DDLogInfo(@"Possible error loading images: %@", errorMessage);
    };
    
}

- (void)loadGroup
{
    // emumerate through our groups and only add groups that contain photos
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        if ([group numberOfAssets] > 0)
        {
            _assetsGroup = group;
            [self loadImagesFromTheGroup];
        }
        else
        {
        }
    };
    
    // enumerate only photos
    NSUInteger groupTypes = /*ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces |*/ ALAssetsGroupSavedPhotos;
    
    
    [_assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];

}

- (void)loadImagesFromTheGroup
{
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if (result) {
            [_assets addObject:result];
        }
    };
    
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [_assetsGroup setAssetsFilter:onlyPhotosFilter];
    [_assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetsEnumerationBlock];
    
    
//    for(ALAsset *a in _assets)
//    {
//        ALAssetRepresentation *realSizeImage = [a defaultRepresentation];
//        
//        [_images addObject: [UIImage imageWithCGImage:[realSizeImage fullResolutionImage]]];
    
//        CGImageRef thumbnailImageRef = [a thumbnail];
//        UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
//        [_images addObject:thumbnail];
//    }
    
    [_delegate imagesLoaded];
}

#pragma mark - Accessors

- (UIImage *)thumbnailAtIndex:(NSInteger)index
{
    ALAsset *asset = [_assets objectAtIndex:index];
    CGImageRef thumbnailImageRef = [asset thumbnail];
    UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    
    return thumbnail;
}

- (UIImage *)realImageAtIndex:(NSInteger)index
{
    ALAsset *asset = [_assets objectAtIndex:index];
    
    ALAssetRepresentation *realSizeImage = [asset defaultRepresentation];
    
    UIImage *img = [UIImage imageWithCGImage:[realSizeImage fullResolutionImage]];
    
    return img;
}

- (NSInteger)numberOfImages
{
    return _assets.count;
}

@end
