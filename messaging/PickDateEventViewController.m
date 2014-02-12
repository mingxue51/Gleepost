//
//  PickDateEventViewController.m
//  Gleepost
//
//  Created by Silouanos on 10/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "PickDateEventViewController.h"
#import "WebClientHelper.h"

@interface PickDateEventViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;

@end

@implementation PickDateEventViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[_titleTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Actions

-(IBAction)dismissViewController:(id)sender
{
    UIBarButtonItem *button = (UIBarButtonItem *)sender;
    
//TODO: Check for 30 characters.
    
    if(button.tag == 1)
    {
        if([_titleTextField.text isEqualToString:@""])
        {
            [WebClientHelper showStandardErrorWithTitle:@"Cannot continue" andContent:@"Please enter a title to continue"];
            
            return;
        }
        
        //Send the date to the parent view.
        [_delegate doneSelectingDateForEvent:_datePicker.date andTitle:_titleTextField.text];
    }
    else
    {
        [_delegate cancelSelectingDateForEvent];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        

        
    }];
}

@end
