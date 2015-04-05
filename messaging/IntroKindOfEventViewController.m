//
//  IntorKinfOfEventViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 14/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "IntroKindOfEventViewController.h"
#import "PendingPostManager.h"
#import "CategoryManager.h"
#import "UINavigationBar+Format.h"
#import "GLPiOSSupportHelper.h"
#import "ATNavigationNewPost.h"

@interface IntroKindOfEventViewController () <UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distancePartyButtonFromTop;
@property (nonatomic, retain) IBOutletCollection(NSLayoutConstraint) NSArray *distancesBetweenButtons;
@property (weak, nonatomic) IBOutlet UIButton *topButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation IntroKindOfEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureNavigationBar];
    [self configureConstrainsDependingOnScreenSize];
    self.navigationController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES andView:self.view];
    
    self.distancePartyButtonFromTop.constant = (self.topButton.frame.origin.y / 2) - (self.titleLabel.frame.size.height / 2);
    
//    ((UIView*)[[self.navigationController.navigationBar subviews] objectAtIndex:1]).alpha = 0.0;

    self.navigationController.navigationBar.alpha = 0.0;
    
    [UIView animateWithDuration:0.9 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        self.navigationController.navigationBar.alpha = 1.0;

    } completion:^(BOOL finished) {
        
    }];
    
//    [UIView animateWithDuration:0.5 animations:^{
//       
////        [self.navigationController.navigationItem.titleView setAlpha:1.0];
////        ((UIView*)[[self.navigationController.navigationBar subviews] objectAtIndex:1]).alpha = 1.0;
//        self.navigationController.navigationBar.alpha = 1.0;
//
//
//    }];
}

- (void)configureNavigationBar
{
    self.title = @"NEW POST";
    
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
}

- (void)configureConstrainsDependingOnScreenSize
{
    if([GLPiOSSupportHelper useShortConstrains])
    {
        for(NSLayoutConstraint *constraint in self.distancesBetweenButtons)
        {
            constraint.constant = 5.0;
        }
    }
}


#pragma mark - Selectors

- (IBAction)selectCategory:(UIButton *)senderButton
{
//    switch (senderButton.tag) {
//        case 1:
//            //Party selected.
//            break;
//            
//        case 2:
//            //Music selected.
//            break;
//            
//        case 3:
//            //Sports selected.
//            break;
//            
//        case 4:
//            //Theater selected.
//            break;
//            
//        case 5:
//            //Speaker selected.
//            break;
//            
//        case 6:
//            //Other selected.
//            break;
//            
//        default:
//            break;
//    }
    
    DDLogInfo(@"Category selected: %@", [[CategoryManager sharedInstance] categoryWithOrderKey:senderButton.tag]);
    
    [[PendingPostManager sharedInstance] setCategory: [[CategoryManager sharedInstance] categoryWithOrderKey:senderButton.tag]];
    
    
    [self navigateToDatePickerView];
//    [self performSegueWithIdentifier:@"pick date" sender:self];

}

- (void)navigateToDatePickerView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"new_post" bundle:nil];
    IntroKindOfEventViewController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"PickDateEventViewController"];
    [self.navigationController pushViewController:cvc animated:NO];
}


#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
    if (operation == UINavigationControllerOperationPush)
        return [[ATNavigationNewPost alloc] init];
    
    if (operation == UINavigationControllerOperationPop)
        return [[ATNavigationNewPost alloc] init];
    
    return nil;
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
