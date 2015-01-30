//
//  GLPShowUsersGroupsViewController.m
//  Gleepost
//
//  Created by Silouanos on 21/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPShowUsersGroupsViewController.h"
#import "WebClient.h"
#import "GroupViewController.h"
#import "UINavigationBar+Format.h"
#import "GLPLiveGroupManager.h"

@class GLPGroup;

@interface GLPShowUsersGroupsViewController ()

@property (strong, nonatomic) GLPGroup *selectedGroup;

@end

@implementation GLPShowUsersGroupsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureNotifications];
    [self loadGroups];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureTitle];
    [self configureNavigationBar];
}

- (void)dealloc
{
    [self removeNotifications];
}

- (void)configureNavigationBar
{
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
}

- (void)configureTitle
{
    self.title = [NSString stringWithFormat:@"%@'S GROUPS", _user.name.uppercaseString];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_USER_GROUPS_LOADED object:nil];
}

- (void)configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupsLoaded:) name:GLPNOTIFICATION_USER_GROUPS_LOADED object:nil];
}


#pragma mark - Client

- (void)loadGroups
{
    [[GLPLiveGroupManager sharedInstance] loadUsersGroupsWithRemoteKey:self.user.remoteKey];
}

#pragma mark - NSNotifications

- (void)groupsLoaded:(NSNotification *)notification
{
    BOOL success = [notification.userInfo[@"success"] boolValue];
    NSArray *groups = notification.userInfo[@"groups"];
    
    if(success)
    {
        [self reloadTableViewWithGroups:groups];
    }
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
