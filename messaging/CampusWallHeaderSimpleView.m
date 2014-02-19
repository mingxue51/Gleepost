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
        [self setFrame:CGRectMake(0, 0, 320.0f, 290.0f)];
        
        
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
    
    [_stanfordLbl setFont:[UIFont fontWithName:GLP_APP_FONT_BOLD size:24.0f]];

}



-(void)formatElements
{
    [ShapeFormatterHelper setCornerRadiusWithView:self.eventsBtn andValue:10];
    
    CGFloat createPostEdge = 7.5f;
    
    [self.eventsBtn setImageEdgeInsets:UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f)];
    [self.createPostBtn setImageEdgeInsets:UIEdgeInsetsMake(createPostEdge, createPostEdge, createPostEdge, createPostEdge)];
    
    [self formatNavigationBar];
}


-(void)setAlphaToBasicElements:(CGFloat)alpha
{
    [self.eventsBtn setAlpha:alpha];
    [self.stanfordLbl setAlpha:alpha];
}


- (IBAction)showTags:(id)sender
{
    [self.delegate showCategories:sender];

}

- (IBAction)createNewPost:(id)sender
{
    [self.delegate newPostButtonClick];
}



-(IBAction)clearAndReloadData:(id)sender
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
