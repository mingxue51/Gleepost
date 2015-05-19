//
//  CampusWallHeaderTableView.m
//  Gleepost
//
//  Created by Silouanos on 22/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "CampusWallHeaderSimpleView.h"
#import "ShapeFormatterHelper.h"
#import "CampusWallHeader.h"
#import "FakeNavigationBar.h"

@interface CampusWallHeaderSimpleView ()

@property (weak, nonatomic) IBOutlet UIButton *eventsBtn;
@property (weak, nonatomic) IBOutlet UIButton *createPostBtn;
@property (weak, nonatomic) IBOutlet UILabel *stanfordLbl;
@property (weak, nonatomic) IBOutlet UIImageView *backTagsImgView;

@property (weak, nonatomic) CampusWallHeader *scrollViewHeader;

@property (weak, nonatomic) FakeNavigationBar *fakeNavBar;

@end

@implementation CampusWallHeaderSimpleView


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        //was 200 (campus wall header + 50) - 283
        [self setFrame:CGRectMake(0, 0, 320.0f, 288.0f)];
        
//        [ShapeFormatterHelper setBorderToView:self withColour:[UIColor redColor]];
        
        for(UIView * v in self.subviews)
        {
            if([v isKindOfClass:[CampusWallHeader class]])
            {
                _scrollViewHeader = (CampusWallHeader*) v;
                _scrollViewHeader.timeLineDelegate = _delegate;
                break;
            }
        }
    }
    
    return self;
}

#pragma mark - Fake Navigation Bar

-(void)formatNavigationBar
{
    //    [self.userName setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@",GLP_APP_FONT_BOLD] size:14.0f]];
    
//    [_stanfordLbl setFont:[UIFont fontWithName:GLP_APP_FONT_BOLD size:18.0f]];

}

-(void)formatElements
{
    [self formatButtons];
    
    [self formatNavigationBar];
    
    [self addGestureToTitle];
}

-(void)setAlphaToBasicElements:(CGFloat)alpha
{
    [self.eventsBtn setAlpha:alpha];
    [self.stanfordLbl setAlpha:alpha];
}

-(void)addGestureToTitle
{
    //Add gesture to cardinal wall label.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadGroupsFeed:)];
    [tap setNumberOfTapsRequired:1];
    [self.stanfordLbl addGestureRecognizer:tap];
}

-(void)formatButtons
{
//    [ShapeFormatterHelper setCornerRadiusWithView:self.eventsBtn andValue:10];
    
//    CGFloat createPostEdge = 5.0f;
//    CGFloat showCategoriesEdge = 5.0f;
//    
//    [self.eventsBtn setImageEdgeInsets:UIEdgeInsetsMake(showCategoriesEdge, showCategoriesEdge, showCategoriesEdge, showCategoriesEdge)];
//    [self.createPostBtn setImageEdgeInsets:UIEdgeInsetsMake(createPostEdge, createPostEdge, createPostEdge, createPostEdge)];
}

#pragma mark - Selectors

- (IBAction)showTags:(id)sender
{
//    [self.delegate showCategories:sender];

}

- (IBAction)createNewPost:(id)sender
{
    [self.delegate newPostButtonClick];
}

-(void)loadGroupsFeed:(id)sender
{
    if([self.stanfordLbl.text isEqualToString:@"Stanford Wall"])
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
    [self.stanfordLbl setText:@"My Groups"];
    [self.createPostBtn setHidden:YES];
}

-(void)groupFeedDisabled
{
    [self.stanfordLbl setText:@"Stanford Wall"];
    [self.createPostBtn setHidden:NO];
}

-(IBAction)clearAndReloadData:(id)sender
{
    [_scrollViewHeader clearViews];
}

- (void)reloadData
{
    [_scrollViewHeader clearViews];
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
