//
//  GLPLoadingCell.m
//  Gleepost
//
//  Created by Lukas on 10/29/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPLoadingCell.h"

@interface GLPLoadingCell()

@property (assign, nonatomic) GLPLoadingCellStatus loadingStatus;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
//@property (strong, nonatomic) UIButton *loadMoreButton;
@property (strong, nonatomic) UILabel *loadMoreLabel;

@end

@implementation GLPLoadingCell

@synthesize loadingStatus = _loadingStatus;
@synthesize activityIndicatorView = _activityIndicatorView;

float const kGLPLoadingCellHeight = 40;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self) {
        return nil;
    }
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.center = self.contentView.center;
    [self.contentView addSubview:self.activityIndicatorView];
    
    self.loadMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    self.loadMoreLabel.text = @"Load more";
    self.loadMoreLabel.textColor = [UIColor blackColor];
    self.loadMoreLabel.font = [UIFont systemFontOfSize:13.0];
    self.loadMoreLabel.textAlignment = NSTextAlignmentCenter;
    self.loadMoreLabel.hidden = YES;
    [self.contentView addSubview:self.loadMoreLabel];
    
//    self.loadMoreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
//    [self.loadMoreButton setTitle:@"Load more" forState:UIControlStateNormal];
//    [self.loadMoreButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    self.loadMoreButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
//    [self.loadMoreButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadMoreButtonClicked)]];
//    self.loadMoreButton.hidden = YES;
//    [self.contentView addSubview:self.loadMoreButton];
    
    self.loadingStatus = -1;
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateWithStatus:(GLPLoadingCellStatus)status
{
    switch (status) {
        case kGLPLoadingCellStatusInit:
        case kGLPLoadingCellStatusLoading: // same as init but only for animaation purpose
            [self startLoading];
            break;
        case kGLPLoadingCellStatusError:
            [self finishLoading];
            [self showReload];
            break;
        case kGLPLoadingCellStatusFinished:
            [self finishLoading];
            break;
        case kGLPLoadingCellStatusSuccess:
            break;
    }
}

- (void)show
{
}

- (void)startLoading
{
    if(!self.activityIndicatorView.hidden) {
        return;
    }
    
    self.loadMoreLabel.hidden = YES;
    self.activityIndicatorView.hidden = NO;
    [self.activityIndicatorView startAnimating];
}

- (void)finishLoading
{
    if(self.activityIndicatorView.hidden) {
        return;
    }
    
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden = YES;
}

- (void)showReload
{
    self.loadMoreLabel.hidden = NO;
}

//- (void)loadMoreButtonClicked
//{
//    
//}



@end
