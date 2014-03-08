//
//  FakeNavigationBar.m
//  Gleepost
//
//  Created by Silouanos on 27/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "FakeNavigationBar.h"
#import "ShapeFormatterHelper.h"

@interface FakeNavigationBar ()

@property (weak, nonatomic) IBOutlet UIButton *eventsBtn;
@property (weak, nonatomic) IBOutlet UIButton *createPostBtn;

@property (weak, nonatomic) IBOutlet UILabel *titleLbl;

@end

@implementation FakeNavigationBar

const CGFloat WIDHT_FAKE = 320.0f;
const CGFloat HEIGH_FAKE = 64.0f;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self setFrame:CGRectMake(0.0f, 0.0f, WIDHT_FAKE, HEIGH_FAKE)];
    }
    
    return self;
}


-(void)formatElements
{
    [ShapeFormatterHelper setCornerRadiusWithView:self.eventsBtn andValue:10];
    
    //Change the size of the image in buttons in order to make the touch range bigger.
    CGFloat createPostEdge = 5.0f;
    CGFloat showCategoriesEdge = 5.0f;
    
    [self.eventsBtn setImageEdgeInsets:UIEdgeInsetsMake(showCategoriesEdge, showCategoriesEdge, showCategoriesEdge, showCategoriesEdge)];
    [self.createPostBtn setImageEdgeInsets:UIEdgeInsetsMake(createPostEdge, createPostEdge, createPostEdge, createPostEdge)];
    
    [_titleLbl setFont:[UIFont fontWithName:GLP_APP_FONT_BOLD size:20.0f]];
    
    //Add gesture to cardinal wall label.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadGroupsFeed:)];
    [tap setNumberOfTapsRequired:1];
    [self.titleLbl addGestureRecognizer:tap];
}

- (IBAction)createNewPost:(id)sender
{    
    [self.delegate newPostButtonClick];
}

- (IBAction)showTags:(id)sender
{
    [self.delegate showCategories:sender];
}

-(void)loadGroupsFeed:(id)sender
{
    if([self.titleLbl.text isEqualToString:@"Cardinal Wall"])
    {
        [UIView animateWithDuration:1.0f animations:^{
            
            [self groupFeedEnabled];
        }];
        
        [self.delegate loadGroupsFeed];
    }
    else
    {
        [UIView animateWithDuration:1.0f animations:^{
            
            [self groupFeedDisabled];
            
        }];
        
        [self.delegate loadRegularPosts];
    }
}

-(void)groupFeedEnabled
{
    [self.titleLbl setText:@"My Groups"];
}

-(void)groupFeedDisabled
{
    [self.titleLbl setText:@"Cardinal Wall"];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
