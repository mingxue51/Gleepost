//
//  PollFakeNavigationBarNewPostView.m
//  Gleepost
//
//  Created by Silouanos on 29/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "PollFakeNavigationBarNewPostView.h"
#import "UIColor+GLPAdditions.h"

@interface PollFakeNavigationBarNewPostView ()

@property (weak, nonatomic) IBOutlet UILabel *charactersLeftLabel;
@property (assign, nonatomic) NSInteger remainingCharacters;
@property (strong, nonatomic) NSMutableDictionary *elementsCharsLeft;
@property (strong, nonatomic) NSDictionary *maximumCharsForElements;

@property (assign, nonatomic) PollViewElement selectedElement;

@property (assign, nonatomic, readonly) NSInteger maximumCharsForAnswer;
@property (assign, nonatomic, readonly) NSInteger maximumCharsForQuestion;

@end

@implementation PollFakeNavigationBarNewPostView

- (instancetype)init
{
    self = [super initWithNibName:@"PollFakeNavigationBarNewPostView"];
    
    if (self)
    {
        [self initialiseObjects];
        [self configureConstants];
        [self configureDictionaries];
    }
    return self;
}

#pragma mark - Configuration

- (void)initialiseObjects
{
    self.selectedElement = kQuestionTextView;
}

- (void)configureConstants
{
    _maximumCharsForAnswer = 36;
    _maximumCharsForQuestion = 144;
}

- (void)configureDictionaries
{
    self.elementsCharsLeft = [[NSMutableDictionary alloc] init];
    [self.elementsCharsLeft setObject:@(self.maximumCharsForQuestion) forKey:@(kQuestionTextView)];
    [self.elementsCharsLeft setObject:@(self.maximumCharsForAnswer) forKey:@(kAnswerTextField)];
    self.maximumCharsForElements = [[NSDictionary alloc] initWithObjectsAndKeys:@(self.maximumCharsForQuestion), @(kQuestionTextView), @(self.maximumCharsForAnswer), @(kAnswerTextField), nil];
}

#pragma mark - Modifiers

- (void)setNumberOfCharacters:(NSInteger)charsNumber toElement:(PollViewElement)element
{
    self.selectedElement = element;
    
    NSInteger maximumCharsForElement = [[self.maximumCharsForElements objectForKey:@(element)] integerValue];
    
    [self.elementsCharsLeft setObject:@(maximumCharsForElement - charsNumber) forKey:@(element)];
    
    [self refreshCharsLeftLabel];
}

- (void)elementChangedFocus:(PollViewElement)element
{
    self.selectedElement = element;
    [self refreshCharsLeftLabel];
}

- (void)refreshCharsLeftLabel
{
    PollFakeNavigationBarNewPostView *externalView = (PollFakeNavigationBarNewPostView *)self.externalView;

    NSInteger charsLeft = [[self.elementsCharsLeft objectForKey:@(self.selectedElement)] integerValue];
    
    if(charsLeft < 0)
    {
        externalView.charactersLeftLabel.textColor = [UIColor redColor];
    }
    else
    {
        externalView.charactersLeftLabel.textColor = [UIColor colorWithR:204.0 withG:204.0 andB:204.0];
    }
    
    externalView.charactersLeftLabel.text = [NSString stringWithFormat:@"%ld", (long)charsLeft];
}

#pragma mark - Accessors

/**
 Returns YES if text count in question text view and in answers fields are more than the preset lenght limits.
 */
- (BOOL)doesATextFieldExceedsTheLimitOfChars
{
    for(NSNumber *elementNSNumber in self.elementsCharsLeft)
    {
        NSInteger charsLeft = [[self.elementsCharsLeft objectForKey:elementNSNumber] integerValue];
        
        if(charsLeft < 0)
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)doesStringExceedsTheLimitOfChars:(NSString *)textElementString withKindOfElement:(PollViewElement)element
{
    NSInteger maxCharsNumber = [[self.maximumCharsForElements objectForKey:@(element)] integerValue];
    
    return (textElementString.length > maxCharsNumber);
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
