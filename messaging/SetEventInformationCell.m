//
//  SetEventInformationCell.m
//  Gleepost
//
//  Created by Silouanos on 28/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "SetEventInformationCell.h"
#import "GCPlaceholderTextView.h"
#import "ShapeFormatterHelper.h"
#import "PendingPost.h"


@interface SetEventInformationCell () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *charactersLeftLbl;

@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *textView;

@property (assign, nonatomic) NSInteger remainingNumberOfCharacters;

@property (assign, nonatomic) UIViewController <SetEventInformationCellDelegate>* delegate;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (strong, nonatomic) PendingPost *pendingPost;

@end

@implementation SetEventInformationCell

const NSString *CHARACTERS_LEFT_EVENT_TITLE = @"Characters Left";
const NSInteger MAX_NO_OF_CHARACTERS_EVENT_TITLE = 25;
const float LIGHT_GRAY_RGB = 176.0f/255.0f;

float const INFORMATION_CELL_HEIGHT = 150.0f;

float const INFORMATION_DATE_PICKER_HEIGHT = 400.0f;

NSString *const kGLPSetInformationCell = @"InformationCell";

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
    }
    
    return self;
}

#pragma mark - Initialisations

-(void)initialiseElementsWithDelegate:(UIViewController<SetEventInformationCellDelegate> *)delegate withPendingPost:(PendingPost *)pendingPost
{

    [self configureTextView];
    [self configureCharactersLeftLabel];
    [self clearAllElements];
    [self setUpDatePicker];
 
    _pendingPost = pendingPost;

    
    [self setObjectsWithPost:pendingPost];
        
    
    
    _delegate = delegate;
}

-(void)setHiddenToDatePicker:(BOOL)hidden
{
    [_datePicker setHidden:hidden];
}

-(void)initialiseObjects
{
    _remainingNumberOfCharacters = MAX_NO_OF_CHARACTERS_EVENT_TITLE;
}

-(void)setObjectsWithPost:(PendingPost *)post
{
    [_textView setText:post.eventTitle];
//    [_datePicker setDate:post.currentDate];
    [self setNumberOfCharacters:post.numberOfCharacters];
    [self setHiddenToDatePicker:[_pendingPost isDatePickerHidden]];
}

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

-(void)configureCharactersLeftLabel
{
    [_charactersLeftLbl setText:[NSString stringWithFormat:@"%ld %@", (long)MAX_NO_OF_CHARACTERS_EVENT_TITLE, CHARACTERS_LEFT_EVENT_TITLE]];
}

-(void)configureTextView
{
    [_textView setBackgroundColor:[UIColor whiteColor]];
    _textView.clipsToBounds = YES;
    _textView.placeholderColor = [UIColor blackColor];
    _textView.delegate = self;
    [ShapeFormatterHelper setCornerRadiusWithView:_textView andValue:5];
}

-(void)clearAllElements
{
    [_textView setText:@""];
    [_charactersLeftLbl setTextColor:[UIColor colorWithRed:LIGHT_GRAY_RGB green:LIGHT_GRAY_RGB blue:LIGHT_GRAY_RGB alpha:1.0f]];

}

#pragma makr - Text text view

-(void)setNumberOfCharacters:(NSInteger)numberOfChars
{
    _remainingNumberOfCharacters = MAX_NO_OF_CHARACTERS_EVENT_TITLE - numberOfChars;
    
    [_charactersLeftLbl setText:[NSString stringWithFormat:@"%d %@", _remainingNumberOfCharacters , CHARACTERS_LEFT_EVENT_TITLE]];
    
    if(_remainingNumberOfCharacters < 0)
    {
        [_charactersLeftLbl setTextColor:[UIColor redColor]];
    }
    else
    {
        [_charactersLeftLbl setTextColor:[UIColor colorWithRed:LIGHT_GRAY_RGB green:LIGHT_GRAY_RGB blue:LIGHT_GRAY_RGB alpha:1.0f]];
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    _pendingPost.numberOfCharacters = textView.text.length;
    _pendingPost.eventTitle = textView.text;
    
    [self setNumberOfCharacters:textView.text.length];
}

#pragma mark - Selectors

- (IBAction)addTimeToEvent:(id)sender
{
    if([_datePicker isHidden])
    {
        _pendingPost.datePickerHidden = NO;
        [_datePicker setHidden:NO];
        [_delegate showDatePickerWithPendingPost:_pendingPost withHiddenDatePicker:NO];
        
    }
    else
    {
        _pendingPost.datePickerHidden = YES;
        [_datePicker setHidden:YES];
        [_delegate showDatePickerWithPendingPost:_pendingPost withHiddenDatePicker:YES];

    }
    

}


- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
