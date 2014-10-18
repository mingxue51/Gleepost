//
//  GLPGroupSearchViewController.m
//  Gleepost
//
//  Created by Silouanos on 17/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPGroupSearchViewController.h"
#import "UINavigationBar+Format.h"
#import "UINavigationBar+Utils.h"

@interface GLPGroupSearchViewController ()

@end

@implementation GLPGroupSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationBar];
}

- (void)configureNavigationBar
{
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
    
    [self.navigationController.navigationBar setButton:kLeft withImageName:@"cancel" withButtonSize:CGSizeMake(19, 21) withSelector:@selector(dismissModalView) andTarget:self];
}

- (void)dismissModalView
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
