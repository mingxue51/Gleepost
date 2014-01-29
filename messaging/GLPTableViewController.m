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
    if(indexPath.row == [self topLoadingCellRow]) {
        return [_topLoadingCellDelegate cellForRowAtIndexPath:indexPath];
    }
    else if(indexPath.row == [self bottomLoadingCellRow]) {
        return [_bottomLoadingCellDelegate cellForRowAtIndexPath:indexPath];
    }
    
    return [self cellForItem:[self itemForIndexPath:indexPath] forIndexPath:indexPath];
}


- (id)itemForIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    
    if(_topLoadingCellDelegate.isVisible) {
        row++;
    }
    
    return _items[row];
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
    if(_topLoadingCellDelegate.isVisible) {
        return NSNotFound;
    }
    
    return 0;
}

- (NSInteger)bottomLoadingCellRow
{
    if(_bottomLoadingCellDelegate.isVisible) {
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
