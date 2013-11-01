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

@interface NewPostViewController ()

@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *contentTextView;
@property (strong, nonatomic) FDTakeController *fdTakeController;

//@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

- (IBAction)cancelButtonClick:(id)sender;
- (IBAction)postButtonClick:(id)sender;

@end

@implementation NewPostViewController

@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabBarController.tabBar.hidden = NO;
    [self.simpleNavBar setBackgroundImage:[UIImage imageNamed:@"navigationbar2"] forBarMetrics:UIBarMetricsDefault];
    
    //Not working.
    //[AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar2" forBarMetrics:UIBarMetricsDefault];
    
    [self.simpleNavBar setTranslucent:YES];
    [self.simpleNavBar setFrame:CGRectMake(0.f, 0.f, 320.f, 60.f)];
   
    //Change the colour of the status bar.
   // [self setNeedsStatusBarAppearanceUpdate];
    
    [self.contentTextView becomeFirstResponder];
    


    
    self.imagePosted = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.fdTakeController = [[FDTakeController alloc] init];
    self.fdTakeController.viewControllerForPresentingImagePickerController = self;
    self.fdTakeController.delegate = self;
    
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    NSLog(@"In status bar.");
    return UIStatusBarStyleLightContent;
}

- (IBAction)cancelButtonClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postButtonClick:(id)sender
{
    [self.contentTextView resignFirstResponder];
    

    GLPPost *post = [[GLPPost alloc] init];
    post.content = self.contentTextView.text;
    post.date = [NSDate date];

    
    
    if(self.imagePosted)
    {
         NSData* imageData = UIImagePNGRepresentation(self.uploadedImage.image);
        NSLog(@"Image size before: %d",imageData.length);

        
        //Resize image before uploading.
//        CGSize newSize = CGSizeMake(300, 300);
//        UIGraphicsBeginImageContext(newSize);
//        [self.uploadedImage.image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
//        UIImage* imageToUpload = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
        
        UIImage* imageToUpload = [self resizeImage:[self.uploadedImage image] WithSize:CGSizeMake(300, 300)];
        
        imageData = UIImagePNGRepresentation(imageToUpload);
        
        NSLog(@"Image size after: %d",imageData.length);
        
        int userRemoteKey = [[SessionManager sharedInstance]user].remoteKey;
        
        [WebClientHelper showStandardLoaderWithTitle:@"Uploading image" forView:self.view];

        
        [[WebClient sharedInstance] uploadImage:imageData ForUserRemoteKey:userRemoteKey callbackBlock:^(BOOL success, NSString* response) {
            
            [WebClientHelper hideStandardLoaderForView:self.view];

            
            if(success)
            {
                NSLog(@"IMAGE UPLOADED. URL: %@",response);
                
                post.imagesUrls = [[NSArray alloc] initWithObjects:response, nil];
                
                //[WebClientHelper showStandardErrorWithTitle:@"Image uploaded successfully" andContent:[NSString stringWithFormat:@"Url: %@",response]];

                
                [self createPost:post];
                
            }
            else
            {
                NSLog(@"ERROR");
                [WebClientHelper showStandardErrorWithTitle:@"Error uploading the image" andContent:@"Please check your connection and try again"];

            }
        }];

    }
    else
    {
        post.imagesUrls = nil;
        [self createPost:post];
    }
    
}

-(UIImage*)resizeImage:(UIImage*)image WithSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* imageToUpload = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageToUpload;
}

-(void)createPost:(GLPPost*)post
{
    [WebClientHelper showStandardLoaderWithTitle:@"Creating post" forView:self.view];
    
    [[WebClient sharedInstance] createPost:post callbackBlock:^(BOOL success) {
        
        [WebClientHelper hideStandardLoaderForView:self.view];
        
        if(success)
        {
            
            [self dismissViewControllerAnimated:YES completion:^{
                [self.delegate loadPosts];
            }];
            
        } else
        {
            [WebClientHelper showStandardError];
            [self.contentTextView becomeFirstResponder];
        }
    }];

}

- (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
            break;
        case 0x42:
            return @"image/bmp";
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}


- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)in
{
    self.imagePosted = YES;
    
    self.uploadedImage.image = photo;
}


- (IBAction)addImage:(id)sender
{
    
    [self.fdTakeController takePhotoOrChooseFromLibrary];
    
    
    //////////////////////////////
    
//    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
//	picker.delegate = self;
//    
//  
//    
//    
////	if((UIButton *) sender == choosePhotoBtn) {
////		picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
////	} else {
//		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
////	}
//    
//    
//	//[self presentModalViewController:picker animated:YES];
//    
//    [self presentViewController:picker animated:YES completion:^{
//        
//    }];
}

//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    
//    [picker dismissViewControllerAnimated:YES completion:^{
//       
//    }];
//    self.imagePosted = YES;
//	self.uploadedImage.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
//}





@end
