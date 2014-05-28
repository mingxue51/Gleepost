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

@interface SetEventInformationCell () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *charactersLeftLbl;

@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *textView;

@property (assign, nonatomic) NSInteger remainingNumberOfCharacters;

@end

@implementation SetEventInformationCell

const NSString *CHARACTERS_LEFT_EVENT_TITLE = @"Characters Left";
const NSInteger MAX_NO_OF_CHARACTERS_EVENT_TITLE = 25;
const float LIGHT_GRAY_RGB = 176.0f/255.0f;

float const INFORMATION_CELL_HEIGHT = 150.0f;

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

-(void)initialiseElements
{
    [self configureTextView];
    [self configureCharactersLeftLabel];
    [self clearAllElements];
}

-(void)initialiseObjects
{
    _remainingNumberOfCharacters = MAX_NO_OF_CHARACTERS_EVENT_TITLE;
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
    [self setNumberOfCharacters:textView.text.length];
}

#pragma mark - Selectors

- (IBAction)addTimeToEvent:(id)sender
{
    DDLogDebug(@"addTimeToEvent");
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
