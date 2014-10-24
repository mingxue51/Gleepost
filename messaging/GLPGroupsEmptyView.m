//
//  GLPGroupsEmptyView.m
//  Gleepost
//
//  Created by Silouanos on 23/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  When searchForGroupsButton pushed this object sends an NSNotification.

#import "GLPGroupsEmptyView.h"

@interface GLPGroupsEmptyView ()

@property (weak, nonatomic) IBOutlet UIButton *searchForGroupsButton;

@end

@implementation GLPGroupsEmptyView


- (IBAction)searchForGroups:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_SEARCH_FOR_GROUPS object:self userInfo:nil];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
