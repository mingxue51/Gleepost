//
//  GLPWalkthoughDataViewController.m
//  Gleepost
//
//  Created by Silouanos on 02/06/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPWalkthoughDataViewController.h"

@interface GLPWalkthoughDataViewController ()

@property (strong, nonatomic) IBOutlet UIView *walkthroughView;

@end

@implementation GLPWalkthoughDataViewController

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
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    _dataLabel.text = [self.dataObject description];
    
//    [self.view addSubview:self.dataObject];
    [self.navigationController setNavigationBarHidden:YES];

}


-(NSInteger)currentViewTag
{
    return self.view.tag;
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
