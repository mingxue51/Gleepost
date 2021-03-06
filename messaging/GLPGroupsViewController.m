//
//  GLPGroupsViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 24/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPGroupsViewController.h"
#import "GLPGroup.h"
#import "AppearanceHelper.h"
#import "UINavigationBar+Format.h"
#import "UINavigationBar+Utils.h"
#import "GLPGroupManager.h"
#import "GroupViewController.h"
#import "UIViewController+Flurry.h"
#import "UIViewController+GAI.h"
#import "ImageFormatterHelper.h"
#import "IntroNewGroupViewController.h"
#import "GLPLiveGroupManager.h"
#import "GLPGroupSearchViewController.h"
#import "GLPEmptyViewManager.h"
#import "GLPThemeManager.h"

@interface GLPGroupsViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) UITabBarItem *groupTabbarItem;

@property (strong, nonatomic) GLPSearchBar *glpSearchBar;

@property (weak, nonatomic) IBOutlet UIView *searchBarView;

@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *groups;
@property (strong, nonatomic) NSMutableArray *filteredGroups;
@property (strong, nonatomic) NSArray *groupSections;
@property (strong, nonatomic) GLPGroup *selectedGroup;

@property (strong, nonatomic) UITapGestureRecognizer *tap;

@end

@implementation GLPGroupsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configTabbar];
    
    [self configureGestures];
    
    [self initialiseObjects];
    
    [self registerViews];
    
    [self configNotifications];
    
    [self configureNavigationButton];
    
    //Change the colour of the tab bar.
    self.tabBarController.tabBar.tintColor = [[GLPThemeManager sharedInstance] tabbarSelectedColour];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [AppearanceHelper setSelectedColourForTabbarItem:_groupTabbarItem withColour:[AppearanceHelper redGleepostColour]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    [self loadGroupsWithGroup:nil];
    
    [self sendViewToGAI:NSStringFromClass([self class])];
    
    [self sendViewToFlurry:NSStringFromClass([self class])];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    [self configNavigationBar];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPGroupUploaded" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_NEW_GROUP_CREATED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_GROUP_IMAGE_LOADED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_SEARCH_FOR_GROUPS object:nil];
}

#pragma mark - Configuration

-(void)initialiseObjects
{
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _groups = [[NSMutableArray alloc] init];
    _filteredGroups = [[NSMutableArray alloc] init];
}

- (void)configNavigationBar
{
    //Change the format of the navigation bar.
    
//    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
    [self.navigationController.navigationBar setFontFormatWithColour:kBlack];
//    [self.navigationController.navigationBar setTranslucent:NO];
    
    //    [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:GLP_CAMPUS_WALL_TITLE_FONT size:17.0f], UITextAttributeFont, [self colourWithGLPColour:colour], UITextAttributeTextColor, nil]];
    
    _navigationBar.topItem.title = @"MY GROUPS";
    
    [_navigationBar setFontFormatWithColour:kBlack];
    
    [_navigationBar whiteBackgroundFormatWithShadow:NO];
    
    [self.view setBackgroundColor:[[GLPThemeManager sharedInstance] navigationBarColour]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)configureNavigationButton
{
    [self.navigationController.navigationBar setButton:kRight specialButton:kNoSpecial withImage:@"new_group" withButtonSize:CGSizeMake(22.5, 22.5) withSelector:@selector(popUpIntroView:) withTarget:self andNavigationItem:_navItem];
    
    
    [self.navigationController.navigationBar setButton:kLeft specialButton:kNoSpecial withImage:@"search_groups_magnify_glass" withButtonSize:CGSizeMake(22.5, 22.5) withSelector:@selector(popUpSearchGroupsView) withTarget:self andNavigationItem:_navItem];
}

- (void)configTabbar
{
    NSArray *items = self.tabBarController.tabBar.items;
    
    _groupTabbarItem = [items objectAtIndex:2];
}

- (void)configNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroupRemoteKeyAndImage:) name:@"GLPGroupUploaded" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupCreatedWithNotification:) name:GLPNOTIFICATION_NEW_GROUP_CREATED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupImageLoaded:) name:GLPNOTIFICATION_GROUP_IMAGE_LOADED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popUpSearchGroupsView) name:GLPNOTIFICATION_SEARCH_FOR_GROUPS object:nil];
}

- (void)registerViews
{
    [self.collectionView registerNib:[UINib nibWithNibName:@"GroupCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"GroupCell"];
    
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"GLPSearchBar" owner:self options:nil];
    
    GLPSearchBar *view = [array lastObject];
    [view setDelegate:self];
    
    [view setPlaceholderWithText:@"Search your groups"];
    
    view.tag = 101;
    
//    CGRectSetX(view, 10);
    
    _glpSearchBar = view;
    
    [_searchBarView addSubview:view];
}

- (void)configureGestures
{
    _tap = [[UITapGestureRecognizer alloc]
            initWithTarget:self
            action:@selector(viewTouched:)];
    
    _tap.cancelsTouchesInView = NO;
    
    [_collectionView addGestureRecognizer:_tap];
}

#pragma mark - Notifications

-(void)updateGroupRemoteKeyAndImage:(NSNotification *)notification
{
    DDLogDebug(@"updateGroupRemoteKeyAndImage");
    
    [self loadGroupsWithGroup:nil];
    
    
//    int remoteKey = [GLPGroupManager parseNotification:notification withGroupsArray:_groups];
//    
//    if(remoteKey == -1)
//    {
//        return;
//    }
//    
////    [self.collectionView reloadData];
//    
//    NSIndexPath *indexPath = [GLPGroupManager findIndexPathForGroupRemoteKey:remoteKey inGroups:_groups];
//    
//    DDLogDebug(@"Reload with index path: %d", indexPath.row);
//    
//    [_collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject: indexPath]];
}

- (void)groupImageLoaded:(NSNotification *)notification
{
    GLPGroup *group = nil;
    
    NSIndexPath *indexPath = [GLPGroupManager parseGroup:&group imageNotification:notification withGroupsArray:_groups];
    
    DDLogDebug(@"groupImageLoaded %@", notification);
    
    if(!indexPath)
    {
        return;
    }
    
    [_collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject: indexPath]];
}



#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _filteredGroups.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"GroupCell";
    
    GroupCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    [cell setDelegate:self];
    
    [cell setGroupData:[_filteredGroups objectAtIndex:indexPath.row]];
    
    [self showOrHideEmptyView];

    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    if([_searchBar isFirstResponder])
//    {
//        return;
//    }
    
    if([_glpSearchBar isTextFieldFirstResponder])
    {
        return;
    }
    
    self.selectedGroup = [_filteredGroups objectAtIndex:indexPath.row];
    
    //If the group is pending (is not already uploaded) then don't do anything.

    if(_selectedGroup.sendStatus == kSendStatusLocal)
    {
        return;
    }
    
    [self performSegueWithIdentifier:@"view group" sender:self];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return GROUP_COLLECTION_CELL_DIMENSIONS;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10.0, 10.0, 0.0, 10.0);
}

#pragma mark - UISearchBarDelegate

- (void)glpSearchBarDidBeginEditing:(UITextField *)textField
{
    [_tap setCancelsTouchesInView:YES];
}

- (void)glpSearchBarDidEndEditing:(UITextField *)textField
{
    //We are setting a delay here because otherwise setCancelsTouchesInView is called after the touch to
    //the collection view.
    
    [_tap performSelector:@selector(setCancelsTouchesInView:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.1];
}

- (void)textChanged:(NSString *)searchText
{
    // remove all data that belongs to previous search
    
    [_filteredGroups removeAllObjects];
    
    if([searchText isEqualToString:@""] || searchText == nil)
    {
        _filteredGroups = _groups.mutableCopy;
        
        [_collectionView reloadData];
        return;
    }
    
    for(GLPGroup *group in _groups)
    {
        NSRange r = [group.name rangeOfString:searchText options:NSCaseInsensitiveSearch];
        
        if(r.location != NSNotFound)
        {
            //that is we are checking only the start of the names.
            
            if(r.location== 0)
            {
                [_filteredGroups addObject:group];
            }
        }
    }
    
    [_collectionView reloadData];
}

#pragma mark - Keyboard management

- (void)viewTouched:(id)sender
{
    [self hideKeyboardFromSearchBarIfNeeded];
}

-(void)hideKeyboardFromSearchBarIfNeeded
{
//    if([self.searchBar isFirstResponder]) {
//        [self.searchBar resignFirstResponder];
//    }
    
    if([_glpSearchBar isTextFieldFirstResponder])
    {
        [_glpSearchBar resignTextFieldFirstResponder];
    }
}

#pragma mark - Group Created Delegate

-(void)groupCreatedWithNotification:(NSNotification *)notification
{
    NSDictionary *dictionary = [notification userInfo];
    
    GLPGroup *group = [dictionary objectForKey:@"new group"];
    
    NSAssert(group.key != 0, @"Group needs to have key");
    
    [self loadGroupsWithGroup:group];
}

#pragma mark - GroupCollectionViewCellDelegate

-(void)groupDeletedWithData:(GLPGroup *)group
{
    [GLPGroupManager deleteGroup:group];
    
    //[self deleteGroupWithRemoteKey:group.remoteKey];
    
    //[self removeGroupFromCollectionViewWithRemoteKey:group.remoteKey];
    
    [self loadGroupsWithGroup:nil];
}

-(void)showViewOptionsWithActionSheer:(UIActionSheet *)actionSheet
{
    [actionSheet showInView:[self.view window]];
}

#pragma mark - Client methods

//TODO: This method should be changed. We shoud unified the loading
//by introducing new approach of managing pending group etc.
//See more: https://www.pivotaltracker.com/story/show/77912494

- (void)loadGroupsWithGroup:(GLPGroup *)createdGroup
{
    if(createdGroup)
    {
        //Add the new group in order to preserve it as is.
        //We are doing that because the new group has a real image
        //in order to create better user experience for the user.
    
        [_groups addObject:createdGroup];
        [_filteredGroups addObject:createdGroup];
        
        DDLogInfo(@"Load groups with pending group: %@ key %ld", createdGroup, (long)createdGroup.key);
    }
    
    
    [[GLPLiveGroupManager sharedInstance] loadGroupsWithPendingGroups:_groups  withLiveCallback:^(NSArray *groups) {
        
//        if(![groups isEqualToArray:_groups])
//        {
            DDLogInfo(@"GLPGroupsViewController : local updates");
            _groups = groups.mutableCopy;
            _filteredGroups = groups.mutableCopy;
            [_collectionView reloadData];
//        }
        
    } remoteCallback:^(BOOL success, NSArray *remoteGroups) {
        
//        if(success && ![remoteGroups isEqualToArray:_groups])
//        {
            DDLogInfo(@"GLPGroupsViewController : remote updates");

            _groups = remoteGroups.mutableCopy;
            _filteredGroups = remoteGroups.mutableCopy;
            [_collectionView reloadData];
//        }
        
    }];
}

#pragma mark - UI loaders

- (void)removeGroupFromCollectionViewWithRemoteKey:(NSInteger)groupRemoteKey
{
    NSIndexPath *indexPath = nil;
    
    for(int i = 0; i < _groups.count; ++i)
    {
        GLPGroup *g = _groups[i];
        
        if(g.remoteKey == groupRemoteKey)
        {
            indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        }
        
    }

    [_collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
}

- (void)showOrHideEmptyView
{
    if(_filteredGroups.count == 0)
    {
        [[GLPEmptyViewManager sharedInstance] addEmptyViewWithKindOfView:kGroupsEmptyView withView:self.collectionView];
    }
    else
    {
        [[GLPEmptyViewManager sharedInstance] hideViewWithKind:kGroupsEmptyView];
    }
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

- (IBAction)popUpIntroView:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    IntroNewGroupViewController *introNewGroupVC = [storyboard instantiateViewControllerWithIdentifier:@"IntroNewGroupViewController"];
//    [newPostVC setDelegate:self];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:introNewGroupVC];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)popUpSearchGroupsView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    GLPGroupSearchViewController *searchGroupsVC = [storyboard instantiateViewControllerWithIdentifier:@"GLPGroupSearchViewController"];
    //    [newPostVC setDelegate:self];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:searchGroupsVC];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
