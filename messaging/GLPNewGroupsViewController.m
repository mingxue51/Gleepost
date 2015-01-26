//
//  GLPNewGroupsViewController.m
//  Gleepost
//
//  Created by Silouanos on 23/01/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  This class is a super class of all the groups' list view controllers.

#import "GLPNewGroupsViewController.h"
#import "GLPGroupCell.h"
#import "GLPGroup.h"
#import "GroupViewController.h"
#import "UINavigationBar+Format.h"
#import "GLPEmptyViewManager.h"
#import "GLPGroupManager.h"

@interface GLPNewGroupsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) NSArray *groups;
@property (strong, nonatomic) GLPGroup *selectedGroup;

@end

@implementation GLPNewGroupsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureNavigationBar];
    [self registerTableViewCells];
    [self configureTableView];
}

/**
 Override this method in order to add more configurations in the navigation bar.
 */
- (void)configureNavigationBar
{
    [_navigationBar setFontFormatWithColour:kBlack];
    [_navigationBar whiteBackgroundFormatWithShadow:YES];
    [self.navigationBar setFontFormatWithColour:kBlack];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)setNavigationBarTitle:(NSString *)title
{
    _navigationBar.topItem.title = title;
}

- (void)registerTableViewCells
{
    [_tableView registerNib:[UINib nibWithNibName:[GLPGroupCell cellIdentifier] bundle:nil] forCellReuseIdentifier:[GLPGroupCell cellIdentifier]];
}

- (void)configureTableView
{
    
}

- (void)reloadTableViewWithGroups:(NSArray *)groups
{
    _groups = groups;
    [_tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLPGroupCell *groupCell = [tableView dequeueReusableCellWithIdentifier:[GLPGroupCell cellIdentifier] forIndexPath:indexPath];
    
    [groupCell setGroupData:[_groups objectAtIndex:indexPath.row]];
    
    return groupCell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogDebug(@"Navigate to view group.");
    
    self.selectedGroup = [_groups objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"view group" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [GLPGroupCell height];
}

#pragma mark - UI methods

- (void)showOrHideEmptyView
{
    if(_groups.count == 0)
    {
        [[GLPEmptyViewManager sharedInstance] addEmptyViewWithKindOfView:kGroupsEmptyView withView:_tableView];
    }
    else
    {
        [[GLPEmptyViewManager sharedInstance] hideViewWithKind:kGroupsEmptyView];
    }
}

- (void)groupImageLoadedWithNotification:(NSNotification *)notification
{
    GLPGroup *group = nil;
    NSIndexPath *indexPath = [GLPGroupManager parseGroup:&group imageNotification:notification withGroupsArray:_groups];
    if(!indexPath)
    {
        return;
    }
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

//Call this when there is a need to pass elements to the next controller.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Hide tabbar.
    // [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    
    if([segue.identifier isEqualToString:@"view group"])
    {
        GroupViewController *gvc = segue.destinationViewController;
        
        gvc.group = self.selectedGroup;
    }
}

@end
