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
#import "IntroNewGroupViewController.h"
#import "GLPGroupSearchViewController.h"

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
    [self.navigationController.navigationBar setButton:kRight specialButton:kNoSpecial withImage:@"new_group" withButtonSize:CGSizeMake(22.5, 22.5) withSelector:@selector(popUpIntroView) withTarget:self andNavigationItem:self.navItem];
    [self.navigationController.navigationBar setButton:kLeft specialButton:kNoSpecial withImage:@"search_groups_magnify_glass" withButtonSize:CGSizeMake(22.5, 22.5) withSelector:@selector(popUpSearchGroupsView) withTarget:self andNavigationItem:self.navItem];
}

- (void)configureViewDidLoadNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupsLoaded:) name:GLPNOTIFICATION_GROUPS_LOADED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupImageLoaded:) name:GLPNOTIFICATION_GROUP_IMAGE_LOADED object:nil];
}

- (void)removeDeallocNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_GROUPS_LOADED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_GROUP_IMAGE_LOADED object:nil];
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

- (void)groupImageLoaded:(NSNotification *)notification
{
    [super groupImageLoadedWithNotification:notification];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)popUpIntroView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    IntroNewGroupViewController *introNewGroupVC = [storyboard instantiateViewControllerWithIdentifier:@"IntroNewGroupViewController"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:introNewGroupVC];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)popUpSearchGroupsView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    GLPGroupSearchViewController *searchGroupsVC = [storyboard instantiateViewControllerWithIdentifier:@"GLPGroupSearchViewController"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:searchGroupsVC];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}


@end
