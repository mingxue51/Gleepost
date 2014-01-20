//
//  ViewPostImageViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 6/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ViewPostImageViewController.h"

@interface ViewPostImageViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *viewImage;

@end

@implementation ViewPostImageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.67]];
	[self.viewImage setImage:self.image];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)goBack:(id)sender
{

    
    [self.transitioningDelegate animationControllerForDismissedController:self];
    
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.view.alpha = 0;
        
    } completion:^(BOOL b){

//        self.view.alpha = 1;
        [self dismissViewControllerAnimated:NO completion:^{
                        
        }];
    }];
    
    


}

@end
