//
//  GLPLoadingCellDelegate.m
//  Gleepost
//
//  Created by Lukas on 1/28/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPLoadingCellDelegate.h"

@interface GLPLoadingCellDelegate()

@property (assign, nonatomic) BOOL isVisible;
@property (assign, nonatomic) GLPLoadingCellState cellState;
@property (assign, nonatomic) GLPLoadingCellPosition cellPosition;
@property (weak, nonatomic) UITableView *tableView;

@end

@implementation GLPLoadingCellDelegate

@synthesize isVisible=_isVisible;
@synthesize cellState=_cellState;
@synthesize cellPosition=_cellPosition;
@synthesize tableView=_tableView;

- (id)initWithPosition:(GLPLoadingCellPosition)cellPosition tableView:(UITableView *)tableView
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    _isVisible = NO;
    _cellState = kGLPLoadingStateStopped;
    _cellPosition = cellPosition;
    _tableView = tableView;
    
    return self;
}

- (void)activate
{
    _cellState = kGLPLoadingStateReady;
}

- (NSInteger)numberOfRows
{
    return _isVisible ? 1 : 0;
}

- (GLPLoadingCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_isVisible) {
        return nil;
    }
    
    GLPLoadingCell *loadingCell = [_tableView dequeueReusableCellWithIdentifier:kGLPLoadingCellIdentifier forIndexPath:indexPath];
    
    if(_cellState == kGLPLoadingStateLoading) {
        [loadingCell startAnimating];
    }
    
    return loadingCell;
}

@end