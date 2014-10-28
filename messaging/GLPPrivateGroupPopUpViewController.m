//
//  GLPPrivateGroupPopUpViewController.m
//  Gleepost
//
//  Created by Silouanos on 27/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPPrivateGroupPopUpViewController.h"

@interface GLPPrivateGroupPopUpViewController ()

@end

@implementation GLPPrivateGroupPopUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureDataInElements];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureDataInElements
{
    [super setTitleWithText:@"This group is private!"];
}

- (void)setGroupImage:(UIImage *)groupImage
{
    if(!groupImage)
    {
        return;
    }
    
    [super setTopImage:groupImage];
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
