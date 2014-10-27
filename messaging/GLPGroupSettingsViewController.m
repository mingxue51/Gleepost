//
//  GLPGroupSettingsViewController.m
//  Gleepost
//
//  Created by Silouanos on 30/09/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPGroupSettingsViewController.h"
#import "UINavigationBar+Utils.h"
#import "UINavigationBar+Format.h"
#import "SettingCell.h"
#import "TableViewHelper.h"
#import "MembersViewController.h"
#import "ImageSelectorViewController.h"

typedef NS_ENUM(NSUInteger, SettingsItem) {
    kImageSetting = 0,
    kDescriptionSetting,
    kRequestToVerifiedSetting,
    kGroupMembersSetting = 1,
    kChangeGroupPrivacySetting
};


@interface GLPGroupSettingsViewController () <ImageSelectorViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *settingsItems;

@end

@implementation GLPGroupSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationItems];
    
    [self configureTableView];
    
    [self configureSettingsItems];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureNavigationBarAppearance];
}

- (void)configureNavigationBarAppearance
{
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
    [self.navigationController.navigationBar setFontFormatWithColour:kBlack];
}

- (void)configureNavigationItems
{
    self.title = @"GROUP SETTINGS";
    
    
    [self.navigationController.navigationBar setButton:kLeft withImageName:@"verification_minimize" withButtonSize:CGSizeMake(20.0, 20.0) withSelector:@selector(dismissModalView) andTarget:self];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)configureSettingsItems
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"Group image", [NSNumber numberWithInteger:kImageSetting], nil]];
    
//    [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"Group description", [NSNumber numberWithInteger:kDescriptionSetting], nil]];
    
//    [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"Request to be verified", [NSNumber numberWithInteger:kRequestToVerifiedSetting], nil]];

    [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"Group members", [NSNumber numberWithInteger:kGroupMembersSetting], nil]];

//    [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"Change group privacy", [NSNumber numberWithInteger:kChangeGroupPrivacySetting], nil]];

    
    //    [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:kInviteFriendsSetting], @"Name", nil]];
    
    _settingsItems = array.mutableCopy;
    
    [_tableView reloadData];
}

- (void)configureTableView
{
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingCell" bundle:nil] forCellReuseIdentifier:@"SettingCell"];
    
    _tableView.tableFooterView = [UIView new];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"GROUP DETAILS";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _settingsItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingCell";
    
    NSDictionary *dictionary = [_settingsItems objectAtIndex:indexPath.row];
    
    NSString *title = [dictionary objectForKey:[NSNumber numberWithInt:indexPath.row]];
    
    SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell setTitle:title];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self navigateToViewControllerWithIndex:indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SETTING_CELL_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [TableViewHelper generateHeaderViewWithTitle:@"GROUP DETAILS" andBottomLine:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

#pragma mark - ImageSelectorViewControllerDelegate

- (void)takeImage:(UIImage *)image
{
    [_delegate takeImage:image];
}

#pragma mark - Selectors

- (void)dismissModalView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (void)navigateToViewControllerWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            [self performSegueWithIdentifier:@"pick image" sender:self];
            break;
            
        case 1:
            [self performSegueWithIdentifier:@"view members" sender:self];
            break;
            
        default:
            break;
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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"pick image"])
    {
        ImageSelectorViewController *imgSelectorVC = segue.destinationViewController;
        
        imgSelectorVC.fromGroupViewController = NO;
        [imgSelectorVC setDelegate:self];
    }
    else if ([segue.identifier isEqualToString:@"view members"])
    {
        MembersViewController *mvc = segue.destinationViewController;
        
        mvc.group = _group;
    }
}


@end
