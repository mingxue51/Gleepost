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
#import "GLPGroupCell.h"
#import "GLPPrivateGroupPopUpViewController.h"
#import "TDPopUpAfterGoingView.h"

@class GLPGroup;

@interface GLPShowUsersGroupsViewController ()

@property (strong, nonatomic) GLPGroup *selectedGroup;
@property (strong, nonatomic) TDPopUpAfterGoingView *privateGroupPopUp;

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

- (void)initialiseObjects
{
    [super initialiseObjects];
    _privateGroupPopUp = [[TDPopUpAfterGoingView alloc] init];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLPGroup *selectedGroup = [super groupWithIndexPath:indexPath];
    
    if(selectedGroup.privacy == kPrivateGroup)
    {
        DDLogDebug(@"Group is private!");
        
        GLPGroupCell *cell = (GLPGroupCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        [self showPrivatePopUpViewWithGroupImage:[cell groupImage]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    [super navigateToGroup:selectedGroup];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Client

- (void)loadGroups
{
    [super startLoading];
    
    [[GLPLiveGroupManager sharedInstance] loadUsersGroupsWithRemoteKey:self.user.remoteKey];
}

#pragma mark - NSNotifications

- (void)groupsLoaded:(NSNotification *)notification
{
    BOOL success = [notification.userInfo[@"success"] boolValue];
    NSArray *groups = notification.userInfo[@"groups"];
    
    [super stopLoading];
    
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

- (void)showPrivatePopUpViewWithGroupImage:(UIImage *)image
{
    //Show the pop up view.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    GLPPrivateGroupPopUpViewController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"GLPPrivateGroupPopUpViewController"];
    
    [cvc setGroupImage:image];
    
    cvc.modalPresentationStyle = UIModalPresentationCustom;
    
    [cvc setTransitioningDelegate:self.privateGroupPopUp];
    
    [self presentViewController:cvc animated:YES completion:nil];
}

@end
