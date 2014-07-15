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
#import "GLPFacebookConnect.h"
#import "GLPFBInvitationsViewController.h"

@interface GLPSearchUsersViewController ()

@property (weak, nonatomic) IBOutlet UITextField *searchTextfield;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (strong, nonatomic) UIButton *facebookButton;

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
    
    [self configureNavigationBar];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_searchTextfield becomeFirstResponder];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:_searchTextfield selector:@selector(becomeFirstResponder) name:@"SHOW_KEYBOARD" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:_searchTextfield name:@"SHOW_KEYBOARD" object:nil];

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
    
    //TODO: Move this code from here to the EmptyMessage class that is on an other branch.
    
    if(_searchForMembers)
    {
        _facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(35.0f, 50.0f, 250.0f, 60.0f)];
        [_facebookButton setImage:[UIImage imageNamed:@"fb_invite"] forState:UIControlStateNormal];
        [_facebookButton setHidden:YES];
        [_facebookButton addTarget:self action:@selector(inviteFriendsToFB:) forControlEvents:UIControlEventTouchUpInside];
        [self.tableView insertSubview:_facebookButton aboveSubview:self.tableView];
    }
    

}

-(void)configureButtons
{
    [_submitButton setImage:[UIImage imageNamed:@"search_users_enabled_save_button"] forState:UIControlStateNormal];
    [_submitButton setImage:[UIImage imageNamed:@"search_users_disabled_save_button"] forState:UIControlStateDisabled];
    _submitButton.enabled = NO;
}

-(void)configureNavigationBar
{
    //Add navigation buttons to let the user to invite friends from facebook.
//    UIBarButtonItem *inviteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(inviteFriendsToFB:)];
//    
//    self.navigationItem.rightBarButtonItem = inviteButton;
    
}

-(void)configureUI
{
    if(!_searchForMembers)
    {
        [_submitButton setHidden:YES];
    }
        
}

# pragma mark - Facebook

-(void)inviteFriendsToFB:(id)sender
{
    [_searchTextfield resignFirstResponder];

//    [[GLPFacebookConnect sharedConnection] inviteFriendsViaFBToGroupWithRemoteKey:_group.remoteKey];
    [self showInvitationsViewController];
}

-(void)showInvitationsViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    GLPFBInvitationsViewController *fbVC = [storyboard instantiateViewControllerWithIdentifier:@"GLPFBInvitationsViewController"];
    fbVC.group = self.group;
    [self presentViewController:fbVC animated:YES completion:nil];
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
        
        //Filter already members users.
        users = [self filterUsersWithFoundUsers:users];
        
        DDLogInfo(@"Final users: %@", users);
        
        
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


-(NSArray *)filterUsersWithFoundUsers:(NSArray *)foundUsers
{
    NSMutableArray *finalUsers = foundUsers.mutableCopy;
    
//    NSMutableArray *deleteUsers = [[NSMutableArray alloc] init];
    
//    for(GLPUser *user in foundUsers)
//    {
//        for(GLPUser *member in _alreadyMembers)
//        {
//            if(user.remoteKey == member.remoteKey)
//            {
//                [deleteUsers addObject:user];
//            }
//        }
//    }
    
    for(int i = 0; i<foundUsers.count; ++i)
    {
        for(int j = 0; j<_alreadyMembers.count; ++j)
        {
            GLPUser *fUser = [foundUsers objectAtIndex:i];
            
            GLPUser *allUser = [_alreadyMembers objectAtIndex:j];
            
            if(fUser.remoteKey == allUser.remoteKey)
            {
                [finalUsers removeObjectAtIndex:i];
            }
        }
    }
    
    return finalUsers;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_searchForMembers)
    {
        if(_users.count == 0)
        {
            //Show facebook button to invite friends.
            [_facebookButton setHidden:NO];
        }
        else
        {
            //Hide facebook button.
            [_facebookButton setHidden:YES];
        }
    }
    

    
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
    _viewProfileUserRemoteKey = user.remoteKey;
    
    //TODO: Sil, i copy pasted this from GLPConversationViewController
    // but it's the profile VC that should manage the access,
    // or some independant class called GLPAccessManager or something like that

    [self performSegueWithIdentifier:@"view private profile" sender:self];
 
    
    
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
    CGRectSetXY(_countLabel, 220, _submitButton.frame.origin.y+13);
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
