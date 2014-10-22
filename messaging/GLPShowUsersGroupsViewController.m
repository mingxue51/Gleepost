//
//  GLPShowUsersGroupsViewController.m
//  Gleepost
//
//  Created by Silouanos on 21/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPShowUsersGroupsViewController.h"
#import "SearchGroupCell.h"
#import "WebClient.h"
#import "GroupViewController.h"
#import "UINavigationBar+Format.h"

@class GLPGroup;

@interface GLPShowUsersGroupsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *usersGroups;

@property (strong, nonatomic) GLPGroup *selectedGroup;

@end

@implementation GLPShowUsersGroupsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerTableViewCells];
    
    [self loadGroups];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureTitle];
    
    [self configureNavigationBar];
}

- (void)registerTableViewCells
{
    [_tableView registerNib:[UINib nibWithNibName:@"SearchGroupCell" bundle:nil] forCellReuseIdentifier:@"SearchGroupCell"];
}

- (void)configureNavigationBar
{
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
}

- (void)configureTitle
{
    self.title = [NSString stringWithFormat:@"%@'s groups", _user.name];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _usersGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchGroupCell";
    
    SearchGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell setGroupData:_usersGroups[indexPath.row]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedGroup = _usersGroups[indexPath.row];
    
    [self performSegueWithIdentifier:@"view group" sender:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLPGroup *group = _usersGroups[indexPath.row];
    
    return [SearchGroupCell getCellHeightWithGroup:group];
}

#pragma mark - Client

- (void)loadGroups
{
    [[WebClient sharedInstance] searchGroupsWithUsersRemoteKey:self.user.remoteKey callback:^(BOOL success, NSArray *groups) {
       
        if(success)
        {
            _usersGroups = groups;
            
            [_tableView reloadData];
        }
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"view group"])
    {
        GroupViewController *gvc = segue.destinationViewController;
        
        gvc.group = self.selectedGroup;
    }
    
    
}


@end
