//
//  GLPLoadingCell.m
//  Gleepost
//
//  Created by Lukas on 10/29/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPLoadingCell.h"

@interface GLPLoadingCell()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIView *errorView;

@property (assign, nonatomic) GLPLoadingCellStatus loadingStatus;
@property (strong, nonatomic) NSString *loadMoreButtonText;

- (IBAction)loadMoreButtonClicked:(id)sender;

@end

@implementation GLPLoadingCell

@synthesize loadingStatus = _loadingStatus;
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize loadingView=_loadingView;
@synthesize errorView=_errorView;
@synthesize delegate=_delegate;
@synthesize shouldShowError=_shouldShowError;

float const kGLPLoadingCellHeight = 40;
NSString * const kGLPLoadingCellIdentifier = @"Loading Cell";
NSString * const kGLPLoadingCellNibName = @"GLPLoadingCell";

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self) {
        return nil;
    }
    
    _shouldShowError = YES;
    _loadingView.hidden = YES;
    _errorView.hidden = YES;
    
    self.loadingStatus = -1;
    
    return self;
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
            
            // show error if it should
            if(_shouldShowError) {
                [self showError];
            }
            break;
        case kGLPLoadingCellStatusFinished:
            [self finishLoading];
            break;
        case kGLPLoadingCellStatusSuccess:
            break;
    }
}

- (void)startLoading
{
    if(!_loadingView.hidden) {
        return;
    }
    
    _loadingView.hidden = NO;
    _errorView.hidden = YES;
    
    [_activityIndicatorView startAnimating];
}

- (void)finishLoading
{
    if(_loadingView.hidden) {
        return;
    }
    
    [_activityIndicatorView stopAnimating];
}

- (void)showError
{
    if(!_errorView.hidden) {
        return;
    }
    
    _errorView.hidden = NO;
    _loadingView.hidden = YES;
}


- (IBAction)loadMoreButtonClicked:(id)sender
{
    if(!_delegate) {
        return;
    }
    
    [_delegate loadingCellDidReload];
}

@end
