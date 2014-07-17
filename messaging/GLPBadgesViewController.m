//
//  GLPBadgesViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 16/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPBadgesViewController.h"
#import "UINavigationBar+Format.h"


@interface GLPBadgesViewController ()

@end

@implementation GLPBadgesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationBar];
}

- (void)configureNavigationBar
{
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
    
    [self.navigationController.navigationBar setFontFormatWithColour:kBlack];
    
    self.title = [NSString stringWithFormat:@"%@ Badges", _customTitle];
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
