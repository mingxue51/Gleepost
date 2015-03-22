//
//  GLPNetworkErrorView.m
//  Gleepost
//
//  Created by Σιλουανός on 31/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPNetworkErrorView.h"
#import "GLPNetworkManager.h"
#import "GLPiOSSupportHelper.h"

@interface GLPNetworkErrorView ()

@end

@implementation GLPNetworkErrorView

- (id)init
{
    self = [super init];
    
    if(self)
    {
        [self configureView];
    }
    
    return self;
}

- (void)configureView
{
    GLPNetworkErrorView *view = [[[NSBundle mainBundle] loadNibNamed:@"GLPNetworkErrorView" owner:self options:nil] objectAtIndex:0];
    
    CGRectSetW(view, [GLPiOSSupportHelper screenWidth]);
    
    [self setFrame:view.frame];
    
    [self moveViewBelowNavigationBar];
    
    [self addSubview:view];
}

#pragma mark - Modifiers

- (void)moveViewBelowNavigationBar
{
    CGRectSetY(self, 65);
}

- (void)moveViewBelowSearchBar
{
    CGRectSetY(self, 105);
}

- (IBAction)dismissView:(id)sender
{    
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_DISMISS_ERROR_VIEW object:self userInfo:nil];
    
}


//- (BOOL)shouldBeHidden
//{
//    DDLogDebug(@"Should be hidden: %d : %d", shouldBeHidden, [GLPNetworkManager sharedInstance].networkStatus == kGLPNetworkStatusOnline);
//    
//    return (shouldBeHidden || [GLPNetworkManager sharedInstance].networkStatus == kGLPNetworkStatusOnline);
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
