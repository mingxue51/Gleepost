//
//  GLPLoadMoreCell.m
//  Gleepost
//
//  Created by Aashish Dhawan on 10/02/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPLoadMoreCell.h"

@implementation GLPLoadMoreCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.userInteractionEnabled = NO;
        
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.center = self.contentView.center;
        activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                              UIViewAutoresizingFlexibleRightMargin |
                                              UIViewAutoresizingFlexibleTopMargin |
                                              UIViewAutoresizingFlexibleBottomMargin);
        [self addSubview:activityIndicator];
        [activityIndicator startAnimating];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

+ (id)cell {
    return [self cellWithBackgroundColor:[UIColor whiteColor]];
}

+ (id)cellWithBackgroundColor:(UIColor *)color {
    GLPLoadMoreCell *cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([self class])];
    cell.backgroundColor = color;
    return cell;
}

+ (CGFloat)height {
    return 44.f;
}



@end
