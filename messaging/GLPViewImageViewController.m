//
//  GLPViewImageViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 9/9/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPViewImageViewController.h"
#import "GLPViewImageScrollView.h"
#import "GLPiOS6Helper.h"

@interface GLPViewImageViewController ()

//@property (weak, nonatomic) IBOutlet GLPViewImageScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *mainView;

@end

@implementation GLPViewImageViewController

//- (void)loadView
//{
//    // replace our view property with our custom image scroll view
//    GLPViewImageScrollView *scrollView = [[GLPViewImageScrollView alloc] init];
////    scrollView.index = _pageIndex;
//    
//    //TODO: Add the image passed from the parent view.
//    
//    [scrollView setImage:_image];
//    
////    self.view = scrollView;
//    
//    [_scView addSubview:scrollView];
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // set the navigation bar's title to indicate which photo index we are viewing,
    // note that our parent is MyPageViewController
    //
//    self.parentViewController.navigationItem.title =
//    [NSString stringWithFormat:@"%@ of %@", [@(self.pageIndex+1) stringValue], [@([[PageViewControllerData sharedInstance] photoCount]) stringValue]];
    
//    [_scrollView setImage:_image];

}

- (IBAction)dismissViewController:(id)sender
{
    
    if([GLPiOS6Helper isIOS6])
    {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    else
    {
        [UIView animateWithDuration:0.25 animations:^{
            
            self.view.alpha = 0;
            
        } completion:^(BOOL b){
            
            [self dismissViewControllerAnimated:NO completion:^{
                
            }];
        }];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    GLPViewImageScrollView *scrollView = [[GLPViewImageScrollView alloc] initWithFrame:self.mainView.bounds];
    
    [scrollView setImage:_image];
    
    [self.mainView addSubview:scrollView];

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
