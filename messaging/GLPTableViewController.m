//
//  GLPTableViewController.m
//  Gleepost
//
//  Created by Lukas on 1/27/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPTableViewController.h"

@interface GLPTableViewController ()

@property (strong, nonatomic) GLPLoadingCellDelegate *topLoadingCellDelegate;
@property (strong, nonatomic) GLPLoadingCellDelegate *bottomLoadingCellDelegate;

@end


@implementation GLPTableViewController

@synthesize items=_items;
@synthesize topLoadingCellDelegate=_topLoadingCellDelegate;
@synthesize bottomLoadingCellDelegate=_bottomLoadingCellDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    DDLogInfo(@"View did load %@", self.tableView);
    
    [self.tableView registerNib:[UINib nibWithNibName:kGLPLoadingCellNibName bundle:nil] forCellReuseIdentifier:kGLPLoadingCellIdentifier];
    
    _topLoadingCellDelegate = [[GLPLoadingCellDelegate alloc] init];
    _bottomLoadingCellDelegate = [[GLPLoadingCellDelegate alloc] init];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = _items.count;
    count += _topLoadingCellDelegate.isVisible ? 1 : 0;
    count += _bottomLoadingCellDelegate.isVisible ? 1 : 0;
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogInfo(@"Cell for row at index path %d", indexPath.row);
    
    if([self isLoadingRowForIndexPath:indexPath]) {
        GLPLoadingCell *loadingCell = [_tableView dequeueReusableCellWithIdentifier:kGLPLoadingCellIdentifier forIndexPath:indexPath];
        
        if(indexPath.row == [self topLoadingCellRow]) {
            [_topLoadingCellDelegate configureCell:loadingCell];
        }
        else if(indexPath.row == [self bottomLoadingCellRow]) {
            [_bottomLoadingCellDelegate configureCell:loadingCell];
        }
        
        return loadingCell;
    }
    
    return [self cellForItem:[self itemForIndexPath:indexPath] forIndexPath:indexPath];
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self isLoadingRowForIndexPath:indexPath]) {
        return kGLPLoadingCellHeight;
    }
    
    return [self heightForItem:[self itemForIndexPath:indexPath]];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLPLoadingCellPosition position = NSNotFound;
    
    if(indexPath.row == [self topLoadingCellRow] && _topLoadingCellDelegate.cellState == kGLPLoadingStateReady) {
        position = kGLPLoadingCellPositionTop;
    }
    else if(indexPath.row == [self bottomLoadingCellRow] && _bottomLoadingCellDelegate.cellState == kGLPLoadingStateReady) {
        position = kGLPLoadingCellPositionBottom;
    }
    
    if((int)position != NSNotFound) {
        DDLogDebug(@"Will display cell for loading cell with position %@", position == kGLPLoadingCellPositionTop ? @"TOP" : @"BOTTOM");
        [self performSelector:@selector(activateForPosition:) withObject:[NSNumber numberWithInt:(int)position]];
    }
}


- (void)reloadWithItems:(NSArray *)items
{
    _items = items;
    [_tableView reloadData];
}

- (id)itemForIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    
    if(_topLoadingCellDelegate.isVisible) {
        row++;
    }
    
    return _items[row];
}

- (void)activateForPosition:(NSNumber *)enumValue
{
    GLPLoadingCellPosition position = [enumValue integerValue];
    DDLogInfo(@"Activate loading cell for position %@", position == kGLPLoadingCellPositionTop ? @"TOP" : @"BOTTOM");
    
    [self loadingCellActivatedForPosition:position];
}

- (BOOL)isLoadingRowForIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == [self topLoadingCellRow] ||
            indexPath.row == [self bottomLoadingCellRow];
}

- (NSInteger)topLoadingCellRow
{
    if(!_topLoadingCellDelegate.isVisible) {
        return NSNotFound;
    }
    
    return 0;
}

- (NSInteger)bottomLoadingCellRow
{
    if(!_bottomLoadingCellDelegate.isVisible) {
        return NSNotFound;
    }
    
    // after the last message
    int row = _items.count;
    
    // add +1 if there is a top loading cell row
    if(_topLoadingCellDelegate.isVisible) {
        row++;
    }
    
    return row;
}

- (void)showTopLoader
{
    if(_topLoadingCellDelegate.isVisible || _bottomLoadingCellDelegate.isVisible) {
        return;
    }
    DDLogInfo(@"Show top loader");
    
    [_topLoadingCellDelegate show];
    
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)hideTopLoader
{
    if(!_topLoadingCellDelegate.isVisible) {
        return;
    }
    
    DDLogInfo(@"Hide top loader");
    
    [_topLoadingCellDelegate hide];
    
    [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)showBottomLoader
{
    if(_topLoadingCellDelegate.isVisible || _bottomLoadingCellDelegate.isVisible) {
        return;
    }
    DDLogInfo(@"Show bottom loader");

    [_bottomLoadingCellDelegate show];

    int rows = [self tableView:self.tableView numberOfRowsInSection:0] - 1;
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rows inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)hideBottomLoader
{
    if(!_bottomLoadingCellDelegate.isVisible) {
        return;
    }
    
    DDLogInfo(@"Hide bottom loader");
    
    [_bottomLoadingCellDelegate hide];
    
    int rows = [self tableView:self.tableView numberOfRowsInSection:0];
    [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rows inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)scrollToTheEndAnimated:(BOOL)animated
{
    if(_items.count > 0) {
        int row = [self tableView:_tableView numberOfRowsInSection:0] - 1;
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
    }
}


#pragma mark - Abstracts

- (UITableViewCell *)cellForItem:(id)item forIndexPath:(NSIndexPath *)indexPath
{
    // to be overidden
    return nil;
}

- (CGFloat)heightForItem:(id)item
{
    // to be overidden
    return 0.0f;
}

- (void)loadingCellActivatedForPosition:(GLPLoadingCellPosition)position
{
    // to be overriden
}

@end
