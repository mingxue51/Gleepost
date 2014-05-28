//
//  GLPSelectCategoryViewController.m
//  Gleepost
//
//  Created by Silouanos on 27/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPSelectCategoryViewController.h"
#import "AppearanceHelper.h"
#import "ATNavigationCategories.h"

@interface GLPSelectCategoryViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;



@end

@implementation GLPSelectCategoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationBar];

}

-(void)configureNavigationBar
{
//    [self.navigationBar setBackgroundColor:[UIColor clearColor]];
    
    self.navigationBar.tag = 1;
    
    [AppearanceHelper setNavigationBarFontForNavigationBar:_navigationBar];

}


#pragma mark - Selectors

- (IBAction)goBack:(id)sender
{
//    DDLogDebug(@"GO back!");
//    ATNavigationCategories *t = [self.transitioningDelegate animationControllerForDismissedController:self];
//    

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
