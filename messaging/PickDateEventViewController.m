//
//  PickDateEventViewController.m
//  Gleepost
//
//  Created by Silouanos on 10/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "PickDateEventViewController.h"

@interface PickDateEventViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation PickDateEventViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)dismissViewController:(id)sender
{
    UIBarButtonItem *button = (UIBarButtonItem *)sender;
    

    
    [self dismissViewControllerAnimated:YES completion:^{
        
        if(button.tag == 1)
        {
            //Send the date to the parent view.
            [_delegate doneSelectingDateForEvent:_datePicker.date];
        }
        else
        {
            [_delegate cancelSelectingDateForEvent];
        }
        
    }];
}

@end
