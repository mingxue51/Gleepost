//
//  ChatViewAnimationController.m
//  Gleepost
//
//  Created by Silouanos on 29/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "ChatViewAnimationController.h"

@interface ChatViewAnimationController ()

@end

@implementation ChatViewAnimationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor greenColor]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
