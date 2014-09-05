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
#import "EmptyMessage.h"
#import "GroupViewController.h"
#import "UIViewController+Flurry.h"
#import "UIViewController+GAI.h"
#import "ImageFormatterHelper.h"
#import "IntroNewGroupViewController.h"
#import "GLPLiveGroupManager.h"

@interface GLPGroupsViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) UITabBarItem *groupTabbarItem;

@property (strong, nonatomic) GLPSearchBar *glpSearchBar;

@property (weak, nonatomic) IBOutlet UIView *searchBarView;

@property (weak, nonatomic) IBOutlet UIButton *rightNavigationButton;

@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *groups;
@property (strong, nonatomic) NSMutableArray *filteredGroups;
@property (strong, nonatomic) NSArray *groupSections;
@property (strong, nonatomic) GLPGroup *selectedGroup;

@property (strong, nonatomic) EmptyMessage *emptyGroupsMessage;

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
    
    //Change the colour of the tab bar.
    self.tabBarController.tabBar.tintColor = [AppearanceHelper redGleepostColour];
    
    [AppearanceHelper setSelectedColourForTabbarItem:_groupTabbarItem withColour:[AppearanceHelper redGleepostColour]];
    
//    for (UIView *subView in self.searchBar.subviews)
//    {
//        for (UIView *secondLevelSubview in subView.subviews){
//            if ([secondLevelSubview isKindOfClass:[UITextField class]])
//            {
//                UITextField *searchBarTextField = (UITextField *)secondLevelSubview;
//                
//                //set font color here
//                [searchBarTextField setBackgroundColor:[UIColor redColor]];
//                
//                break;
//            }
//        }
//    }
    
//    [_searchBar setSearchFieldBackgroundImage:[ImageFormatterHelper generateImageWithColour:[UIColor blackColor]] forState:UIControlStateNormal];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadGroupsWithGroup:nil];
    
    [self sendViewToGAI:NSStringFromClass([self class])];
    
    [self sendViewToFlurry:NSStringFromClass([self class])];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self configNavigationBar];
    
    [self configureNavigationButton];
    
    //    [self setCustomBackgroundToTableView];
}


//- (void)viewWillDisappear:(BOOL)animated
//{
//    //Make the navigation bar invisible before going to the view group VC
//    //in order to avoid problems with navigation bar during transition.
//    
////    [self.navigationController.navigationBar invisible];
//    
//
//    
//    [super viewWillDisappear:animated];
//}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPGroupUploaded" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_NEW_GROUP_CREATED object:nil];
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

//    _emptyGroupsMessage = [[EmptyMessage alloc] initWithText:@"You have no groups" withPosition:EmptyMessagePositionCenter andTableView:self.tableView];
    
}

- (void)configNavigationBar
{
    //Change the format of the navigation bar.
    
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:NO];
    [self.navigationController.navigationBar setFontFormatWithColour:kBlack];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)configureNavigationButton
{
    [self.navigationController.navigationBar setButton:kRight withImage:@"new_group" withButtonSize:CGSizeMake(22.5, 22.5) withSelector:@selector(popUpIntroView:) withTarget:self andNavigationItem:_navItem];
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
}

- (void)registerViews
{
    [self.collectionView registerNib:[UINib nibWithNibName:@"GroupCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"GroupCell"];
    
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"GLPSearchBar" owner:self options:nil];
    
    GLPSearchBar *view = [array lastObject];
    [view setDelegate:self];
    
    [view setPlaceholderWithText:@"Search for groups on campus"];
    
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
    int remoteKey = [GLPGroupManager parseNotification:notification withGroupsArray:_groups];
    
    if(remoteKey == -1)
    {
        return;
    }
    
//    [self.collectionView reloadData];
    
    NSIndexPath *indexPath = [GLPGroupManager findIndexPathForGroupRemoteKey:remoteKey inGroups:_groups];
    
    DDLogDebug(@"Reload with index path: %d", indexPath.row);
    
    
    //TODO: Reload specific rows in the collection view.
    
//    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
    
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

//- (BOOL)isSearchBarFirstResponder
//{
//    GLPSearchBar *view = nil;
//    
//    for(UIView *v in _searchBarView.subviews)
//    {
//        if(v.tag == 101)
//        {
//            view = (GLPSearchBar *)v;
//        }
//    }
//    
//    return [view isTextFieldFirstResponder];
//}
//
//- (void)resignFirstResponder
//{
//    
//}

#pragma mark - Group Created Delegate

//TODO: Make those methods more efficient.

-(void)groupCreatedWithData:(GLPGroup *)group
{
    [self reloadNewGroupWithGroup:group];
    
    //    [self createNewGroupWithGroup:group];
}

-(void)groupCreatedWithNotification:(NSNotification *)notification
{
    NSDictionary *dictionary = [notification userInfo];
    
    GLPGroup *group = [dictionary objectForKey:@"new group"];
    
    
    [self reloadNewGroupWithGroup:group];
    
    //    [self createNewGroupWithGroup:group];
}

#pragma mark - GroupCollectionViewCellDelegate

-(void)groupDeletedWithData:(GLPGroup *)group
{
    [GLPGroupManager deleteGroup:group];
    
    //[self deleteGroupWithRemoteKey:group.remoteKey];
    
    //[self removeGroupFromCollectionViewWithRemoteKey:group.remoteKey];
    
    [self reloadNewGroupWithGroup:nil];
}

-(void)showViewOptionsWithActionSheer:(UIActionSheet *)actionSheet
{
    [actionSheet showInView:[self.view window]];
}

#pragma mark - Client methods

//TODO: This method should be changed. We shoud unified the loading
//by introducing new approach of managing pending group etc.
//See more: https://www.pivotaltracker.com/story/show/77912494

-(void)loadGroupsWithGroup:(GLPGroup *)createdGroup
{
    if(createdGroup)
    {
        //Add the new group in order to preserve it as is.
        //We are doing that because the new group has a real image
        //in order to create better user experience for the user.
    
        [_groups addObject:createdGroup];
        [_filteredGroups addObject:createdGroup];
        
        DDLogInfo(@"Load groups with pending group: %@", createdGroup);
    }
    

    [[GLPLiveGroupManager sharedInstance] loadGroupsWithPendingGroups:_groups  withLiveCallback:^(NSArray *groups) {
        _groups = groups.mutableCopy;
        _filteredGroups = groups.mutableCopy;
        
        [_collectionView reloadData];
        
    } remoteCallback:^(BOOL success, NSArray *remoteGroups) {
        
        if(success)
        {
            _groups = remoteGroups.mutableCopy;
            _filteredGroups = remoteGroups.mutableCopy;
            
            [_collectionView reloadData];
        }
        
    }];
    
    
    
    
    
    
    
//        [GLPGroupManager loadGroups:_groups withLocalCallback:^(NSArray *groups) {
//            
//            _groups = groups.mutableCopy;
//            _filteredGroups = groups.mutableCopy;
//            
//            [_collectionView reloadData];
//            
//            
//            
//        } remoteCallback:^(BOOL success, NSArray *groups) {
//            
//            if(!success)
//            {
//                return;
//            }
//            
//            _groups = groups.mutableCopy;
//            _filteredGroups = groups.mutableCopy;
//            
//            [_collectionView reloadData];
//            
//        }];
//    }
//    else
//    {

//    }


}

#pragma mark - UI loaders

//-(void)showGroups
//{
//    if(self.groups.count > 0)
//    {
//        NSDictionary *result = [GLPGroupManager processGroups:_groups];
//        
//        _groupsStr = [result objectForKey:@"GroupNames"];
//        _categorisedGroups = [result objectForKey:@"CategorisedGroups"];
//        _groupSections = [result objectForKey:@"Sections"];
//    }
//    else
//    {
//        _groupsStr = [[NSMutableArray alloc] init];
//        _categorisedGroups = [[NSMutableDictionary alloc] init];
//        _groupSections = [[NSMutableArray alloc] init];
//    }
//}

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


-(void)reloadNewGroupWithGroup:(GLPGroup *)group
{
    [self loadGroupsWithGroup:group];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
