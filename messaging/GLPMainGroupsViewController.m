//
//  GLPMainGroupsViewController.m
//  Gleepost
//
//  Created by Silouanos on 26/01/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  This view controller is the main groups view controller appears in groups tab.
//  It is a subclass of GLPNewGroupsViewController.

#import "GLPMainGroupsViewController.h"
#import "GLPThemeManager.h"
#import "UINavigationBar+Utils.h"
#import "AppearanceHelper.h"
#import "UIViewController+Flurry.h"
#import "UIViewController+GAI.h"
#import "GLPLiveGroupManager.h"

@interface GLPMainGroupsViewController ()

@property (strong, nonatomic) UITabBarItem *groupTabbarItem;

@end

@implementation GLPMainGroupsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configTabbar];
    [self configureNavigationButtons];
    [self configureViewDidLoadNotifications];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self sendViewToGAI:NSStringFromClass([self class])];
    [self sendViewToFlurry:NSStringFromClass([self class])];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureNavigationBar];
    [self showGroups];
}


-(void)dealloc
{
    [self removeDeallocNotifications];
}

#pragma mark - Configuration

- (void)configureNavigationBar
{
    [super configureNavigationBar];
    [super setNavigationBarTitle:@"MY GROUPS"];
    [self.view setBackgroundColor:[[GLPThemeManager sharedInstance] navigationBarColour]];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)configTabbar
{
    NSArray *items = self.tabBarController.tabBar.items;
    _groupTabbarItem = [items objectAtIndex:2];
    
    //Change the colour of the tab bar.
    self.tabBarController.tabBar.tintColor = [[GLPThemeManager sharedInstance] tabbarSelectedColour];
    [AppearanceHelper setSelectedColourForTabbarItem:_groupTabbarItem withColour:[AppearanceHelper redGleepostColour]];
}

- (void)configureNavigationButtons
{
    [self.navigationController.navigationBar setButton:kRight specialButton:kNoSpecial withImage:@"new_group" withButtonSize:CGSizeMake(22.5, 22.5) withSelector:@selector(popUpIntroView:) withTarget:self andNavigationItem:self.navItem];
    [self.navigationController.navigationBar setButton:kLeft specialButton:kNoSpecial withImage:@"search_groups_magnify_glass" withButtonSize:CGSizeMake(22.5, 22.5) withSelector:@selector(popUpSearchGroupsView) withTarget:self andNavigationItem:self.navItem];
}

- (void)configureViewDidLoadNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupsLoaded:) name:GLPNOTIFICATION_GROUPS_LOADED object:nil];
}

- (void)removeDeallocNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_GROUPS_LOADED object:nil];
}

#pragma mark - Groups operations

- (void)showGroups
{
    [[GLPLiveGroupManager sharedInstance] getGroups];
}

#pragma mark - NSNotifications

- (void)groupsLoaded:(NSNotification *)notification
{
    NSArray *groups = notification.userInfo[@"groups"];
    [super reloadTableViewWithGroups:groups];
    [super showOrHideEmptyView];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
