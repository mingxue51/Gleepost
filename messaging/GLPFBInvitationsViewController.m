//
//  GLPFBInvitationsViewController.m
//  Gleepost
//
//  Created by Silouanos on 08/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPFBInvitationsViewController.h"
#import "GLPUser.h"
#import "GLPFacebookConnect.h"
#import "WebClientHelper.h"
#import "AppearanceHelper.h"

@interface GLPFBInvitationsViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

/** This will hold only the filtered facebook friends */
@property (strong, nonatomic) NSMutableArray *facebookFriends;

/** This will hold all facebook friends */
@property (strong, nonatomic) NSArray *constantFacebookFriends;

@property (strong, nonatomic) NSMutableArray *checkedFriends;

@property (assign, nonatomic) NSInteger checkedFriendsCount;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *inviteButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation GLPFBInvitationsViewController

static NSString * const kCellIdentifier = @"CellIdentifier";


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initialiseObjects];
    
    [self configureNavigationBar];
    
    [self fetchFacebookFriends];
}

-(void)initialiseObjects
{
    _facebookFriends = [[NSMutableArray alloc] init];
    
    _checkedFriends = [[NSMutableArray alloc] init];
    
    _checkedFriendsCount = 0;
}

-(void)configureNavigationBar
{
    CGRectSetY(_navigationBar, 0.0f);
    
    CGRectAddH(_navigationBar, 21.0f);
    
    [AppearanceHelper setNavigationBarFontForNavigationBar:_navigationBar];
    
}

-(void)fetchFacebookFriends
{
    [WebClientHelper showStandardLoaderWithTitle:@"Loading facebook friends" forView:self.view];
    
    [[GLPFacebookConnect sharedConnection] inviteFriendsViaFBToGroupWithRemoteKey:self.group completionHandler:^(BOOL success, NSArray *fbFriends) {
        
        [WebClientHelper hideStandardLoaderForView:self.view];
        
        if(success)
        {
            _facebookFriends = fbFriends.mutableCopy;
            _constantFacebookFriends = fbFriends;
            
            [self.tableView reloadData];
        }
        else
        {
            //Pop up error.
            [WebClientHelper showProblemLoadingFBFriends];
        }
        
        
    }];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dismissModalView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)inviteFriends:(id)sender
{
    DDLogDebug(@"Invited users: %@", _checkedFriends);
    

    
    [[GLPFacebookConnect sharedConnection] sendRequestToFriendWithFriendsIds:[self facebookFriendsKeys] withCompletionCallback:^(NSString *status) {
        
        if([status isEqualToString:@"error"])
        {
            [WebClientHelper showProblemLoadingFBFriends];
        }
        else if ([status isEqualToString:@"sent"])
        {
            //Show the name of users invited.
            [WebClientHelper showSuccessfullyInvitedFriends:[self facebookFriendsNames]];
        }
        else
        {
            //User canceled the view.
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];

        
        
    }];
}

-(IBAction)tableViewClicked:(id)sender
{
    [self hideKeyboardFromSearchBarIfNeeded];
}

-(void)hideKeyboardFromSearchBarIfNeeded
{
    if([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
}

#pragma mark - UIScrollViewDelegate Methods


//TODO: That not works. Never called.
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideKeyboardFromSearchBarIfNeeded];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _facebookFriends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    GLPUser *user = _facebookFriends[indexPath.row];
//    BOOL check = [_checkedUsers[[user remoteKeyNumber]] boolValue];
    
    GLPSearchUserCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    BOOL checked = [self isFriendChecked:user];

    [cell configureWithUser:user checked:checked];

    cell.delegate = self;
    
    return cell;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // remove all data that belongs to previous search
    
    [_facebookFriends removeAllObjects];
    
    if([searchText isEqualToString:@""] || searchText == nil)
    {
        _facebookFriends = _constantFacebookFriends.mutableCopy;
        
        [self.tableView reloadData];
        return;
    }
    
    for(GLPUser *user in _constantFacebookFriends)
    {
        NSRange r = [user.name rangeOfString:searchText options:NSCaseInsensitiveSearch];
        
        if(r.location != NSNotFound)
        {
            //that is we are checking only the start of the names.
            
            if(r.location== 0)
            {
                [_facebookFriends addObject:user];
            }
        }
    }
    
    [self.tableView reloadData];
}


#pragma mark - GLPSearchUserCellDelegate

- (void)checkButtonClickForUser:(GLPUser *)user
{
    [self checkOrUncheckUser:user];
}

- (void)overlayViewClickForUser:(GLPUser *)user
{
    [self checkOrUncheckUser:user];
}

-(void)checkOrUncheckUser:(GLPUser *)user
{
    //If user is checked then remove him from the array else add him.
    
    BOOL checked = ![self isFriendChecked:user];
    
    if(checked)
    {
        [_checkedFriends addObject:user];
    }
    else
    {
        [_checkedFriends removeObject:user];
    }
    
    _checkedFriendsCount += checked ? 1 : -1;
    
    NSUInteger index = [_facebookFriends indexOfObject:user];
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    if(_checkedFriendsCount > 0) {
        _inviteButton.enabled = YES;
        //        _countLabel.hidden = NO;
        //        _countLabel.text = [NSString stringWithFormat:@"(%d)", _checkUsersCount];
    } else {
        _inviteButton.enabled = NO;
        //        _countLabel.hidden = YES;
    }
}

-(BOOL)isFriendChecked:(GLPUser *)friend
{
    for(GLPUser *fbUser in _checkedFriends)
    {
        if(fbUser.key  == friend.key)
        {
            return YES;
        }
    }
    
    return NO;
}

-(NSArray *)facebookFriendsKeys
{
    NSMutableArray *fbFriendsKeys = [[NSMutableArray alloc] init];
    
    for(GLPUser *friend in _checkedFriends)
    {
        [fbFriendsKeys addObject:[NSNumber numberWithInteger:friend.key]];
    }
    
    return fbFriendsKeys;
}

-(NSString *)facebookFriendsNames
{
//    NSString *friendsNames = @"";
//    
//    for(GLPUser *friend in _checkedFriends)
//    {
//        friendsNames = [friendsNames stringByAppendingString:[NSString stringWithFormat:@"%@,",friend.name]];
//        
//        
//    }
    
    NSString * result = [[_checkedFriends valueForKey:@"name"] componentsJoinedByString:@", "];
    
    return result;

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
