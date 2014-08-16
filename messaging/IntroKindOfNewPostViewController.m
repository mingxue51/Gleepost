//
//  IntroKindOfNewPostViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 14/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "IntroKindOfNewPostViewController.h"
#import "PendingPostManager.h"
#import "UINavigationBar+Format.h"
#import "UINavigationBar+Utils.h"
#import "PendingPostManager.h"

@interface IntroKindOfNewPostViewController ()

@end

@implementation IntroKindOfNewPostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationBar];
}

//- (void)viewDidDisappear:(BOOL)animated
//{
//    [[PendingPostManager sharedInstance] reset];
//    
//    [super viewDidDisappear:animated];
//}

- (void)dealloc
{    
    [[PendingPostManager sharedInstance] reset];
}

- (void)configureNavigationBar
{
    self.title = @"NEW POST";
    
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
    
    [self.navigationController.navigationBar setButton:kLeft withImageOrTitle:@"cancel" withButtonSize:CGSizeMake(19, 21) withSelector:@selector(dismiss) andTarget:self];
}

#pragma mark - Selectors

- (IBAction)selectEvent:(id)sender
{
    if([[PendingPostManager sharedInstance] kindOfPost] != kEventPost)
    {
        [[PendingPostManager sharedInstance] reset];
    }
    
    
    [[PendingPostManager sharedInstance] setKindOfPost:kEventPost];
    
    [self performSegueWithIdentifier:@"view event selector" sender:self];
}

- (IBAction)selectAnnouncement:(id)sender
{
    if([[PendingPostManager sharedInstance] kindOfPost] != kAnnouncementPost)
    {
        [[PendingPostManager sharedInstance] reset];
    }
    
    [[PendingPostManager sharedInstance] setKindOfPost:kAnnouncementPost];
    
    [self performSegueWithIdentifier:@"final new post" sender:self];

}

- (IBAction)selectGeneral:(id)sender
{
    if([[PendingPostManager sharedInstance] kindOfPost] != kGeneralPost)
    {
        [[PendingPostManager sharedInstance] reset];
    }
    
    [[PendingPostManager sharedInstance] setKindOfPost:kGeneralPost];
    
    [self performSegueWithIdentifier:@"final new post" sender:self];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
