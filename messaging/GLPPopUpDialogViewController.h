//
//  GLPPopUpDialogViewController.h
//  Gleepost
//
//  Created by Silouanos on 27/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GLPPopUpDialogViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *centralView;
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UIImageView *overlayTopImageView;



- (IBAction)dismissView:(id)sender;
- (void)setTopImage:(UIImage *)image;
- (void)setTitleWithText:(NSString *)title;

@end
