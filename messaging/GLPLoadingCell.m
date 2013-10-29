//
//  GLPLoadingCell.m
//  Gleepost
//
//  Created by Lukas on 10/29/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPLoadingCell.h"

@implementation GLPLoadingCell

@synthesize activityIndicatorView = _activityIndicatorView;

float const kGLPLoadingCellHeight = 40;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSLog(@"Init loading cell 2");
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self) {
        return nil;
    }
    
    NSLog(@"Init loading cell %f %f", self.contentView.center.x, self.contentView.center.y );
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.center = self.contentView.center;
    [self.contentView addSubview:self.activityIndicatorView];
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
