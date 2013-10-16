//
//  ViewPostTableView.m
//  Gleepost
//
//  Created by Σιλουανός on 3/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ViewPostTableView.h"

@implementation ViewPostTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
    }
    return self;
}

-(void) initTableView
{
    //Add a UIView as a header of table view.
    //self.headerView = [[PostView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
    //[self.headerView setBackgroundColor:[UIColor greenColor]];
    
    //self.tableHeaderView = self.headerView;
    
    
    //TODO: Create footer view a text view to let the user to add new comment. (?)
//    self.footerTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
//    self.footerTextView.text = @"Add comment...";
//    self.footerTextView.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    
    

    self.typeTextView = [[TypeTextView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    
    self.tableFooterView = self.typeTextView;
    
    
    //Set table view's colour.
    self.backgroundColor = [UIColor clearColor];
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
