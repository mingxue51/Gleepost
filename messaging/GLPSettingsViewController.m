//
//  GLPSettingsViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 12/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPSettingsViewController.h"
#import "UINavigationBar+Utils.h"
#import "UINavigationBar+Format.h"
#import "SettingCell.h"
#import "AppearanceHelper.h"
#import "ShapeFormatterHelper.h"
#import "GLPLoginManager.h"
#import "ChangePasswordViewController.h"
#import "TableViewHelper.h"

@interface GLPSettingsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *settingsItems;
//@property (assign, nonatomic) BOOL isPassWordChanged;
@property (assign, nonatomic) SettingsItem changeSettingItem;

@end

@implementation GLPSettingsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationBar];
    
    [self configureTableView];

    [self configureSettingsItems];
}

- (void)configureNavigationBar
{
    self.title = @"SETTINGS";
    
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
    [self.navigationController.navigationBar setFontFormatWithColour:kBlack];
    
    [self.navigationController.navigationBar setButton:kLeft specialButton:kQuit withImageName:@"cancel" withButtonSize:CGSizeMake(19.0, 21.0) withSelector:@selector(dismissModalView) andTarget:self];
        
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)configureSettingsItems
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"Name", [NSNumber numberWithInteger:kNameSetting], nil]];
    
    [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"Password", [NSNumber numberWithInteger:kPasswordSetting], nil]];
    
    [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"Tagline", [NSNumber numberWithInteger:kTaglineSetting], nil]];
    
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
    return @"MY ACCOUNT";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _settingsItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingCell";
    
    NSDictionary *dictionary = [_settingsItems objectAtIndex:indexPath.row];
    
    NSString *title = [dictionary objectForKey:[NSNumber numberWithInteger:indexPath.row]];
    
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
    return [TableViewHelper generateHeaderViewWithTitle:@"MY ACCOUNT" andBottomLine:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

#pragma mark - Selectors

- (void)dismissModalView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)logOut:(id)sender
{
    //Pop up a bottom menu.
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Are you sure you want to logout?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Logout", nil];
    
    [actionSheet showInView:[self.view window]];
}

#pragma mark - Action Sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [GLPLoginManager logout];
        [self.navigationController popViewControllerAnimated:YES];
        [self performSegueWithIdentifier:@"start" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)navigateToViewControllerWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            [self navigateToChangeNameView];
            break;
            
        case 1:
            [self navigateToChangePasswordView];
            break;
            
            case 2:
            [self navigateToChangeTaglineView];
            
        default:
            break;
    }
}

-(void)navigateToChangePasswordView
{
//    _isPassWordChanged = YES;
    _changeSettingItem = kPasswordSetting;
    [self performSegueWithIdentifier:@"pass view" sender:self];
}

-(void)navigateToChangeNameView
{
//    _isPassWordChanged = NO;
    _changeSettingItem = kNameSetting;
    [self performSegueWithIdentifier:@"pass view" sender:self];
}

- (void)navigateToChangeTaglineView
{
    _changeSettingItem = kTaglineSetting;
    [self performSegueWithIdentifier:@"pass view" sender:self];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"pass view"])
    {
        ChangePasswordViewController *change = segue.destinationViewController;
        
        change.selectedSettingsItem = _changeSettingItem;
    }
}


@end
