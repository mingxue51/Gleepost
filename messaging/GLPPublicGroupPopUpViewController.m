//
//  GLPPublicGroupPopUpViewController.m
//  Gleepost
//
//  Created by Silouanos on 27/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPPublicGroupPopUpViewController.h"

@interface GLPPublicGroupPopUpViewController ()

@end

@implementation GLPPublicGroupPopUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)setGroupImage:(UIImage *)groupImage
{
    if(!groupImage)
    {
        return;
    }
    
    [super setTopImage:groupImage];
}

#pragma mark - Selectors

- (IBAction)showMembers:(id)sender
{
    [_delegate showMembers];
    [super dismissView:nil];
}

- (IBAction)invitePeople:(id)sender
{
    [_delegate invitePeople];
    [super dismissView:nil];
}

- (IBAction)dismissView:(id)sender
{
    [super dismissView:sender];
    [_delegate dismissNavController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
