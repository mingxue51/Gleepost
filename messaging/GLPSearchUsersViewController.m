//
//  GLPSearchUsersViewController.m
//  Gleepost
//
//  Created by Lukas on 3/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPSearchUsersViewController.h"
#import "GLPSearchUserCell.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "NSString+Utils.h"

#import "ContactsManager.h"
#import "SessionManager.h"
#import "GLPPrivateProfileViewController.h"

@interface GLPSearchUsersViewController ()

@property (weak, nonatomic) IBOutlet UITextField *searchTextfield;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic) NSMutableDictionary *checkedUsers;
@property (assign, nonatomic) NSInteger checkUsersCount;
@property (assign, nonatomic) NSInteger requestsCount;
@property (assign, nonatomic) BOOL shouldAnimateEndLoading;
@property (assign, nonatomic) NSInteger viewProfileUserRemoteKey;

- (IBAction)searchButtonClick:(id)sender;
- (IBAction)searchTextFieldChanged:(id)sender;
- (IBAction)submitButtonClick:(id)sender;

@end

@implementation GLPSearchUsersViewController

static NSString * const kCellIdentifier = @"CellIdentifier";
static NSString *const INVITE_GROUP_MEMBERS_STR = @"Invite Group Members";
static NSString *const SEARCH_USERS_STR = @"Search";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initialiseObjects];
    
    [self configureButtons];
    
    [self configureUI];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_searchTextfield becomeFirstResponder];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}

# pragma mark - Configuration

-(void)initialiseObjects
{
    
    if(_searchForMembers)
    {
        self.title = INVITE_GROUP_MEMBERS_STR;
    }
    else
    {
        self.title = SEARCH_USERS_STR;
    }
    
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _users = [NSMutableArray array];
    _checkedUsers = [NSMutableDictionary dictionary];
    _checkUsersCount = 0;
    _requestsCount = 0;
    _shouldAnimateEndLoading = NO;
    
    _activityIndicator.hidden = YES;
}

-(void)configureButtons
{
    [_submitButton setImage:[UIImage imageNamed:@"search_users_enabled_save_button"] forState:UIControlStateNormal];
    [_submitButton setImage:[UIImage imageNamed:@"search_users_disabled_save_button"] forState:UIControlStateDisabled];
    _submitButton.enabled = NO;
}

-(void)configureUI
{
    if(!_searchForMembers)
    {
        [_submitButton setHidden:YES];
    }
        
}

# pragma mark - Searching

- (void)searchUsers
{
    NSString *name = _searchTextfield.text;
    
    if(![name isNotBlank]) {
        return;
    }
    
    DDLogInfo(@"Start user search");
    
    if(_requestsCount == 0) {
        _searchButton.hidden = YES;
        _activityIndicator.hidden = NO;
        [_activityIndicator startAnimating];
    }
    
    _requestsCount++;
    
    [[WebClient sharedInstance] searchUserByName:name callback:^(NSArray *users) {
        _requestsCount--;
        
        if(_requestsCount == 0) {
            _activityIndicator.hidden = YES;
            [_activityIndicator stopAnimating];
            _searchButton.hidden = NO;
        }
        
        if(!users) {
            return;
        }
        
        NSLog(@"Search users by name count: %d", users.count);
        
        for(GLPUser *user in users) {
            NSNumber *index = [user remoteKeyNumber];
            if(!_checkedUsers[index]) {
                _checkedUsers[index] = [NSNumber numberWithBool:NO];
            }
        }
        
        _users = [users mutableCopy];
        [_tableView reloadData];
    }];
}

- (void)performEndLoadingAnimation
{
    _searchButton.hidden = NO;
    _searchButton.alpha = 0;
    
    [UIView animateWithDuration:0.3 animations:^{
        _activityIndicator.alpha = 0;
        _searchButton.alpha = 1;
    } completion:^(BOOL finished) {
        [_activityIndicator stopAnimating];
        _activityIndicator.hidden = YES;
        _searchButton.hidden = NO;
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLPUser *user = _users[indexPath.row];
    BOOL check = [_checkedUsers[[user remoteKeyNumber]] boolValue];
    
    GLPSearchUserCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    if(_searchForMembers)
    {
        [cell configureWithUser:user checked:check];
    }
    else
    {
        [cell configureWithUser:user];
    }
    
    cell.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 43;
}


# pragma mark - GLPSearchUserCellDelegate

- (void)checkButtonClickForUser:(GLPUser *)user
{
    BOOL checked = ![_checkedUsers[[user remoteKeyNumber]] boolValue];
    _checkedUsers[[user remoteKeyNumber]] = [NSNumber numberWithBool:checked];
    _checkUsersCount += checked ? 1 : -1;

    NSUInteger index = [_users indexOfObject:user];
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    if(_checkUsersCount > 0) {
        _submitButton.enabled = YES;
        _countLabel.hidden = NO;
        _countLabel.text = [NSString stringWithFormat:@"(%d)", _checkUsersCount];
    } else {
        _submitButton.enabled = NO;
        _countLabel.hidden = YES;
    }
}

- (void)overlayViewClickForUser:(GLPUser *)user
{
    DDLogInfo(@"click");
    _viewProfileUserRemoteKey = user.remoteKey;
    
    //TODO: Sil, i copy pasted this from GLPConversationViewController
    // but it's the profile VC that should manage the access,
    // or some independant class called GLPAccessManager or something like that
    if(user.remoteKey == [[SessionManager sharedInstance]user].remoteKey) {
        [self performSegueWithIdentifier:@"view profile" sender:self];
    }
    else if([[ContactsManager sharedInstance] navigateToUnlockedProfileWithSelectedUserId:user.remoteKey]) {
        [self performSegueWithIdentifier:@"view private profile" sender:self];
    }
    else {
        [self performSegueWithIdentifier:@"view private profile" sender:self];
    }
}


# pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self searchUsers];
    return YES;
}

# pragma mark - Actions

- (IBAction)searchButtonClick:(id)sender
{
    [self searchUsers];
}

- (IBAction)searchTextFieldChanged:(id)sender
{
    if(_searchTextfield.text.length > 2) {
        [self searchUsers];
    }
    else if(_users.count > 0) {
        [_users removeAllObjects];
        [_tableView reloadData];
    }
}

- (IBAction)submitButtonClick:(id)sender
{
    UIView *view = [[UIApplication sharedApplication] windows][1];
    [WebClientHelper showStandardLoaderWithTitle:@"Adding members" forView:view];
    
    NSMutableArray *userKeys = [NSMutableArray array];
    for(NSNumber *remoteKey in _checkedUsers) {
        if([_checkedUsers[remoteKey] boolValue]) {
            [userKeys addObject:remoteKey];
        }
    }
    
    [[WebClient sharedInstance] addUsers:userKeys toGroup:_group callback:^(BOOL success) {
        [WebClientHelper hideStandardLoaderForView:view];
        
        if(!success) {
            [WebClientHelper showStandardErrorWithTitle:@"Request failed" andContent:@"Something went wrong. Please check your internet connection and retry."];
            return;
        }
        
        NSString *desc = userKeys.count > 1 ? [NSString stringWithFormat:@"%d members were added to the group!", (int)userKeys.count] : @"The member was added to the group!";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Members added successfully"
                                                        message:desc
                                                       delegate:self
                                              cancelButtonTitle:@"Finish"
                                              otherButtonTitles:nil];
        [alert show];
    }];
}


# pragma mark - Keyboard

- (void) keyboardDidShow:(NSNotification*)notification {
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIWindow *window = [[[UIApplication sharedApplication] windows]objectAtIndex:0];
    CGRect keyboardFrameConverted = [self.view convertRect:keyboardFrame fromView:window];
    
    CGRectSetY(_submitButton, keyboardFrameConverted.origin.y - 6 - _submitButton.frame.size.height);
    CGRectSetXY(_countLabel, 220, _submitButton.frame.origin.y);
    CGRectSetH(_tableView, _submitButton.frame.origin.y - 5 - _tableView.frame.origin.y);
}


# pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"view private profile"]) {
        GLPPrivateProfileViewController *ppvc = segue.destinationViewController;
        ppvc.selectedUserId = _viewProfileUserRemoteKey;
        
    }
    else if([segue.identifier isEqualToString:@"view profile"]) {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    }
}


# pragma mark - Alert view

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
