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
#import "UIPlaceHolderTextView.h"
#import "Post.h"

@interface NewPostViewController ()

@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *contentTextView;
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
    [self.simpleNavBar setBackgroundImage:[UIImage imageNamed:@"navigationbar_4"] forBarMetrics:UIBarMetricsDefault];
    [self.simpleNavBar setTranslucent:YES];
    [self.simpleNavBar setFrame:CGRectMake(0.f, 0.f, 320.f, 60.f)];
   
    //Change the colour of the status bar.
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.contentTextView becomeFirstResponder];
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
    
    
    
    Post *post = [[Post alloc] init];
    post.content = self.contentTextView.text;
    post.date = [NSDate date];
    post.remoteUserId = [SessionManager sharedInstance].user.remoteId;
    
    NSLog(@"NEW POST: CREATING A POST: %@ - %@ - %d",post.content,post.date,post.remoteUserId);
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Creating post";
    hud.detailsLabelText = @"Please wait few seconds";
    
    WebClient *client = [WebClient sharedInstance];
    
    [client createPost:post callbackBlock:^(BOOL success) {
        [hud hide:YES];
        
        if(success) {
            [self dismissViewControllerAnimated:YES completion:^{
                [self.delegate loadPosts];
            }];
        } else {
            [self.contentTextView becomeFirstResponder];
        }
    }];
}
@end
