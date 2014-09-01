//
//  PickDateEventViewController.m
//  Gleepost
//
//  Created by Silouanos on 10/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "PickDateEventViewController.h"
#import "WebClientHelper.h"
#import "PendingPostManager.h"

@interface PickDateEventViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation PickDateEventViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpDatePicker];
    
    self.title = @"NEW POST";
    
    [self loadDateIfNeeded];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    DDLogDebug(@"PickDate viewWillDisappear : %@", _datePicker.date);
    
    //Save date before desappearing the view.
    [[PendingPostManager sharedInstance] setDate:_datePicker.date];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initialisations

-(void)setUpDatePicker
{
    NSDate* now = [NSDate date];
    
    // Get current NSDate without seconds & milliseconds, so that I can better compare the chosen date to the minimum & maximum dates.
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* nowWithoutSecondsComponents = [calendar components:
                                                     (NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit) fromDate:now] ;
    
    NSDate* nowWithoutSeconds = [calendar dateFromComponents:nowWithoutSecondsComponents] ;

    _datePicker.minimumDate = nowWithoutSeconds;
    
    
    //TODO: Uncomment the following code to set maximum date. More here: http://stackoverflow.com/questions/14694452/uidatepicker-set-maximum-date
//    NSDateComponents* addOneMonthComponents = [NSDateComponents new] ;
//    addOneMonthComponents.month = 1 ;
//    NSDate* oneMonthFromNowWithoutSeconds = [calendar dateByAddingComponents:addOneMonthComponents toDate:nowWithoutSeconds options:0] ;
//    picker.maximumDate = oneMonthFromNowWithoutSeconds ;
}

- (void)loadDateIfNeeded
{
    if(![[PendingPostManager sharedInstance] arePendingData])
    {
        return;
    }
    
    if([[PendingPostManager sharedInstance] getDate])
    {
        [_datePicker setDate:[[PendingPostManager sharedInstance] getDate]];
    }
    
}


#pragma mark - Actions

-(IBAction)dismissViewController:(id)sender
{
//    UIBarButtonItem *button = (UIBarButtonItem *)sender;
    
    
//    if(button.tag == 1)
//    {
//        if([_titleTextField.text isEqualToString:@""])
//        {
//            [WebClientHelper showStandardErrorWithTitle:@"Cannot continue" andContent:@"Please enter a title to continue"];
//            
//            return;
//        }
//        else if(_titleTextField.text.length > 50)
//        {
//            //Check for 50 characters.
//
//            [WebClientHelper showStandardErrorWithTitle:@"Title too long" andContent:@"The title should be less than 37 characters long"];
//            
//            return;
//        }
//        
//        //Send the date to the parent view.
//        [_delegate doneSelectingDateForEvent:_datePicker.date andTitle:_titleTextField.text];
//    }
//    else
//    {
//        [_delegate cancelSelectingDateForEvent];
//    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        

        
    }];
}

-(IBAction)continueToTheFinalView:(id)sender
{
    [[PendingPostManager sharedInstance] setDate:_datePicker.date];

    [self performSegueWithIdentifier:@"final new post" sender:self];
}

@end
