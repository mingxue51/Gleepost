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

@interface IntroKindOfEventViewController ()


@end

@implementation IntroKindOfEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationBar];
}

- (void)configureNavigationBar
{
    self.title = @"NEW POST";
    
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
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
    
    DDLogInfo(@"Category selected: %@", [[CategoryManager instance] categoryWithOrderKey:senderButton.tag]);
    
    [[PendingPostManager sharedInstance] setCategory: [[CategoryManager instance] categoryWithOrderKey:senderButton.tag]];
    
    [self performSegueWithIdentifier:@"pick date" sender:self];

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
