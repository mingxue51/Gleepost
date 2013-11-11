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

@interface NewPostViewController ()

@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *contentTextView;
@property (strong, nonatomic) FDTakeController *fdTakeController;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (strong, nonatomic) GLPPost *sendPost;


//@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

- (IBAction)cancelButtonClick:(id)sender;
- (IBAction)postButtonClick:(id)sender;

@end

@implementation NewPostViewController

static dispatch_queue_t myQueue;

@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];

    myQueue = dispatch_queue_create("My Queue",NULL);
    
    [self.contentTextView becomeFirstResponder];
    
    
    //Initialise post.
    self.sendPost = [[GLPPost alloc] init];

//    self.view.opaque = YES;
//    self.view.backgroundColor = [UIColor blackColor];
    
    //Add background image view.
    
    
//    self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];

    
    if(!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7"))
    {
        //If iOS 6 add transparent black UIImageView.
        UIImageView *imageViewBlack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, self.contentTextView.frame.size.height+50)];
        
        imageViewBlack.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.67];
        
        [self.view addSubview:imageViewBlack];
        [self.view sendSubviewToBack:imageViewBlack];
    }

    
    
    self.tabBarController.tabBar.hidden = NO;
    [self.simpleNavBar setBackgroundImage:[UIImage imageNamed:@"navigationbar2"] forBarMetrics:UIBarMetricsDefault];
    //[self.simpleNavBar setBackgroundColor:[UIColor clearColor]];
    
    
    //Not working.
    //[AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar2" forBarMetrics:UIBarMetricsDefault];
    
    [self.simpleNavBar setTranslucent:YES];
    [self.simpleNavBar setFrame:CGRectMake(0.f, 0.f, 320.f, 65.f)];
   
    //Change the colour of the status bar.
   // [self setNeedsStatusBarAppearanceUpdate];
    
    
    self.uploadedImage = [[UIImageView alloc] init];
    
    self.imagePosted = NO;
    self.imageReady = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.contentTextView becomeFirstResponder];

    self.fdTakeController = [[FDTakeController alloc] init];
    self.fdTakeController.viewControllerForPresentingImagePickerController = self;
    self.fdTakeController.delegate = self;
    
    
    [self formatBackground];
}



-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.delegate.view setBackgroundColor:[UIColor whiteColor]];

}


-(void)formatBackground
{
//    [self.view setBackgroundColor:[UIColor clearColor]];
//    [self.view setAlpha:0.5];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    NSLog(@"In status bar.");
    return UIStatusBarStyleLightContent;
}

- (IBAction)cancelButtonClick:(id)sender
{
    [self.delegate setNavigationBarName];
    [self.delegate setPlusButtonToNavigationBar];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postButtonClick:(id)sender
{
    
    [self.delegate setNavigationBarName];
    [self.delegate setPlusButtonToNavigationBar];
    
    
    [self.contentTextView resignFirstResponder];
    

    //GLPPost *post = [[GLPPost alloc] init];
    self.sendPost.content = self.contentTextView.text;
    self.sendPost.date = [NSDate date];
    self.sendPost.author = [[SessionManager sharedInstance]user];
//    self.sendPost.imagesUrls = [NSArray arrayWithObjects:@"uploading...", nil];
    self.sendPost.tempImage = self.uploadedImage.image;

    //Deactivate the load posts from server.
    self.delegate.readyToReloadPosts = NO;
    
    
    

    //Dismiss View Controller.
    [self dismissViewControllerAnimated:YES completion:^{
        //[self.delegate loadPosts];
        //Show updated campus wall.
        [self.delegate addNewPost:self.sendPost];
    }];
    
    //Create the post asychronously.
    
    if(self.imagePosted)
    {
        //Block until ready.
        
        //[NSTimer timerWithTimeInterval:0.5f target:self selector:@selector(tryUploadImage:) userInfo:nil repeats:YES];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_async(queue, ^{
           
            
            while (TRUE)
            {
                
                if (self.imageReady)
                {
                    NSLog(@"Ready to create post with images urls %@", self.sendPost.imagesUrls[0]);
                    // the condition is reached
                    [self createPost:self.sendPost];
                    break;
                }
                

                
                // adapt this value in microseconds.
                usleep(10000);
            }
        });
        

         //NSData* imageData = UIImagePNGRepresentation(self.uploadedImage.image);
        //NSLog(@"Image size before: %d",imageData.length);

        
        //Resize image before uploading.

        
        //UIImage* imageToUpload = [self resizeImage:[self.uploadedImage image] WithSize:CGSizeMake(300, 300)];
        
//        NSData *imageData = UIImagePNGRepresentation(self.uploadedImage.image);
//        
//        NSLog(@"Image size after: %d",imageData.length);
//        
//        int userRemoteKey = [[SessionManager sharedInstance]user].remoteKey;
//        
//        [WebClientHelper showStandardLoaderWithTitle:@"Uploading image" forView:self.view];
//
//        
//        [[WebClient sharedInstance] uploadImage:imageData ForUserRemoteKey:userRemoteKey callbackBlock:^(BOOL success, NSString* response) {
//            
//            [WebClientHelper hideStandardLoaderForView:self.view];
//
//            
//            if(success)
//            {
//                NSLog(@"IMAGE UPLOADED. URL: %@",response);
//                
//                post.imagesUrls = [[NSArray alloc] initWithObjects:response, nil];
//                
//                //[WebClientHelper showStandardErrorWithTitle:@"Image uploaded successfully" andContent:[NSString stringWithFormat:@"Url: %@",response]];
//
//                
//                [self createPost:post];
//                
//            }
//            else
//            {
//                NSLog(@"ERROR");
//                [WebClientHelper showStandardErrorWithTitle:@"Error uploading the image" andContent:@"Please check your connection and try again"];
//
//            }
//        }];

    }
    else
    {
        self.sendPost.imagesUrls = nil;
        [self createPost:self.sendPost];
    }
    


    
}


-(void)createPost:(GLPPost*)post
{
    [WebClientHelper showStandardLoaderWithTitle:@"Creating post" forView:self.view];
    
    [[WebClient sharedInstance] createPost:post callbackBlock:^(BOOL success, int remoteKey) {
        
        [WebClientHelper hideStandardLoaderForView:self.view];
        
        if(success)
        {
            NSLog(@"Post created successfully in delegate with remote key: %@ : %d.",self.delegate, remoteKey);
            //Active again the functionality of loading posts.
            self.sendPost.remoteKey = remoteKey;
            self.delegate.readyToReloadPosts = YES;
            [self.delegate saveNewPostToDatabase:self.sendPost];

//            [self dismissViewControllerAnimated:YES completion:^{
//                [self.delegate loadPosts];
//            }];
            
        } else
        {
//            [WebClientHelper showStandardError];
            [WebClientHelper showStandardErrorWithTitle:@"Problem posting" andContent:@"Check your internet connection"];
            [self.contentTextView becomeFirstResponder];
        }
    }];

}



#pragma mark - FDTakeController delegate

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)inDict
{
    self.imagePosted = YES;

    [self.addImageButton setImage:photo forState:UIControlStateNormal];

    
    //Compress image and set it in uploaded image.
//    NSData* imageData = UIImagePNGRepresentation(photo);
//    NSLog(@"Image size before: %d",imageData.length);
//    NSData *imageData;
//    
//    //Resize image before uploading.
////    UIImage* imageToUpload = [self resizeImage:photo WithSize:CGSizeMake(300, 300)];
//    
//    UIImage *imageToUpload = [self imageWithImage:photo scaledToHeight:640];
//    
//    //imageToUpload = [self rectImage:photo withRect:CGRectMake([self calculateCenterX:photo.size.width], [self calculateCenterX:photo.size.height], 300, 300)];
//    
//    self.uploadedImage.image = imageToUpload;
//    
//    [self.addImageButton setImage:self.uploadedImage.image forState:UIControlStateNormal];
//    
//    
//    
//    
//    //Upload the image in the background.
//    
//    imageData = UIImagePNGRepresentation(self.uploadedImage.image);
//    
//    NSLog(@"Image size after: %d",imageData.length);
//    
//    int userRemoteKey = [[SessionManager sharedInstance]user].remoteKey;
    
    //[WebClientHelper showStandardLoaderWithTitle:@"Uploading image" forView:self.view];
    
    
    //dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(myQueue, ^{
        
        
        NSData *imageData;
        
        //Resize image before uploading.
        //    UIImage* imageToUpload = [self resizeImage:photo WithSize:CGSizeMake(300, 300)];
        
        UIImage *imageToUpload = [ImageFormatterHelper imageWithImage:photo scaledToHeight:640];
        
        //imageToUpload = [self rectImage:photo withRect:CGRectMake([self calculateCenterX:photo.size.width], [self calculateCenterX:photo.size.height], 300, 300)];
        
        self.uploadedImage.image = imageToUpload;
        
//        [self.addImageButton setImage:self.uploadedImage.image forState:UIControlStateNormal];
        
        
        
        
        //Upload the image in the background.
        
        imageData = UIImagePNGRepresentation(self.uploadedImage.image);
        
        NSLog(@"Image size after: %d",imageData.length);
        
        int userRemoteKey = [[SessionManager sharedInstance]user].remoteKey;
        
        
        [[WebClient sharedInstance] uploadImage:imageData ForUserRemoteKey:userRemoteKey callbackBlock:^(BOOL success, NSString* response) {
            
            //[WebClientHelper hideStandardLoaderForView:self.view];
            
            
            if(success)
            {
                NSLog(@"IMAGE UPLOADED. URL: %@",response);
                
                self.sendPost.imagesUrls = [[NSArray alloc] initWithObjects:response, nil];
                
                self.imageReady = YES;
                
                //[WebClientHelper showStandardErrorWithTitle:@"Image uploaded successfully" andContent:[NSString stringWithFormat:@"Url: %@",response]];
                
            }
            else
            {
                NSLog(@"ERROR Uploading the image.");
                [WebClientHelper showStandardErrorWithTitle:@"Error uploading the image" andContent:@"Please check your connection and try again"];
                
            }
        }];
        
        
    });
    


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



@end
