//
//  NewGroupMessageViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 2/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "NewGroupMessageViewController.h"
#import "GLPConversation.h"
#import "UINavigationBar+Format.h"
#import "UINavigationBar+Utils.h"
#import "NSString+Utils.h"
#import "WebClient.h"
#import "GLPConversationViewController.h"
#import "GLPLiveConversationsManager.h"
#import "SessionManager.h"

@interface NewGroupMessageViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *searchedUsers;

@property (strong, nonatomic) NSMutableArray *checkedUsers;

//@property (strong, nonatomic) UITapGestureRecognizer *tap;

@property (strong, nonatomic) GLPConversation *conversation;

@property (weak, nonatomic) IBOutlet UIButton *addSelectedButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation NewGroupMessageViewController

const NSString *FIXED_BUTTON_TITLE = @"Add selected ";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerTableViewCells];
    
    [self initiliaseObjects];
    
    [self configureGestures];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_searchBar becomeFirstResponder];

    
    [self configureNavigationBar];
}

- (void)initiliaseObjects
{
    _searchedUsers = [[NSMutableArray alloc] init];
    _checkedUsers = [[NSMutableArray alloc] init];
}

- (void)registerTableViewCells
{
    [self.tableView registerNib:[UINib nibWithNibName:@"GLPCheckNameCell" bundle:nil] forCellReuseIdentifier:@"GLPCheckNameCell"];
}

- (void)configureGestures
{
//    _tap = [[UITapGestureRecognizer alloc]
//            initWithTarget:self
//            action:@selector(viewTouched:)];
//    
//    _tap.cancelsTouchesInView = NO;
//    
//    [_tableView addGestureRecognizer:_tap];
}

- (void)configureNavigationBar
{
    float buttonsSize = 30.0;
    
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:NO];
    
    [self.navigationController.navigationBar setFontFormatWithColour:kBlack];
    
    [self.navigationController.navigationBar setButton:kLeft withImageOrTitle:@"x_red" withButtonSize:CGSizeMake(20.0, 20.0) withSelector:@selector(goBack) andTarget:self];
    
    [self.navigationController.navigationBar setButton:kRight withImageOrTitle:@"one_one_button" withButtonSize:CGSizeMake(buttonsSize, buttonsSize) withSelector:@selector(goBack) andTarget:self];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _searchedUsers.count;
}


#pragma mark - Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *userCellIdentifier = @"GLPCheckNameCell";
    
    GLPCheckNameCell *userCell = nil;
    
    
    GLPUser *currentUser = _searchedUsers[indexPath.row];
    
    BOOL checked = [self isUserSelected:currentUser];
    
    userCell = [tableView dequeueReusableCellWithIdentifier:userCellIdentifier forIndexPath:indexPath];
    
    [userCell setUserData:currentUser withCheckedStatus:checked];
    
    [userCell setDelegate:self];
    
    return userCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //Start new conversation or continue if existed.
    
//    [self startNewConversationWithUser:_searchedUsers[indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NAME_CELL_HEIGHT;
}

#pragma mark - GLPCheckNameCellDelegate

- (void)userCheckedWithUser:(GLPUser *)user
{
    [_checkedUsers addObject:user];
    
    [self updateButtonTitle];
}

- (void)userUncheckedWithUser:(GLPUser *)user
{
    [self removeUser:user];
    
    [self updateButtonTitle];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // remove all data that belongs to previous search
    
    [_searchedUsers removeAllObjects];
    
    if(![searchText isNotBlank])
    {
        [_tableView reloadData];
        
        return;
    }
    
    
    [self searchUserWithName:searchText];
    
}

//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
//{
//    //We are setting a delay here because otherwise setCancelsTouchesInView is called after the touch to
//    //the collection view.
//    
//    [_tap performSelector:@selector(setCancelsTouchesInView:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.1];
//}
//
//
//
//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
//{
//    [_tap setCancelsTouchesInView:YES];
//}

#pragma mark - Search users

- (void)searchUserWithName:(NSString *)userName
{
    
    if(![userName isNotBlank]) {
        return;
    }
    
    DDLogInfo(@"Start user search");
    [_activityIndicator setHidden:NO];
    
    [[WebClient sharedInstance] searchUserByName:userName callback:^(NSArray *users) {
        
        [_activityIndicator setHidden:YES];
        //        if(_requestsCount == 0) {
        //            _activityIndicator.hidden = YES;
        //            [_activityIndicator stopAnimating];
        //            _searchButton.hidden = NO;
        //        }
        
        if(!users) {
            return;
        }
        
        if([self isCurrentUserFoundWithUsers:users])
        {
            return;
        }
        
        DDLogInfo(@"Search users by name count: %d", users.count);
        
        
        //        for(GLPUser *user in users)
        //        {
        //            NSNumber *index = [user remoteKeyNumber];
        //
        //            if(!_checkedUsers[index])
        //            {
        //                _checkedUsers[index] = [NSNumber numberWithBool:NO];
        //            }
        //        }
        
        _searchedUsers = [users mutableCopy];
        
        [_tableView reloadData];
    }];
}

#pragma mark - Keyboard management

- (void)viewTouched:(id)sender
{
    [self hideKeyboardFromSearchBarIfNeeded];
}

-(void)hideKeyboardFromSearchBarIfNeeded
{
    if([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
}


#pragma mark - Selectors

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addUsers:(id)sender
{
    //Create new conversation with users.
    GLPConversation *conversation = [[GLPLiveConversationsManager sharedInstance] findGroupConversationWithParticipants:_checkedUsers];
        
    DDLogInfo(@"Regular conversation for participant, conversation remote key: %d", conversation.remoteKey);
    
    if(!conversation)
    {
        DDLogInfo(@"Create empty conversation");
        
//        NSArray *part = [[NSArray alloc] initWithObjects:user, [SessionManager sharedInstance].user, nil];
        
        [_checkedUsers addObject:[SessionManager sharedInstance].user];
        
        conversation = [[GLPConversation alloc] initWithParticipants:_checkedUsers];
        
    }
    
    _conversation = conversation;

    
    [self performSegueWithIdentifier:@"view conversation" sender:self];
}

#pragma mark - UI changes

- (void)updateButtonTitle
{
    if(_checkedUsers.count == 0)
    {
        [self resetAndDisableButton];
    }
    else if(_checkedUsers.count > 1)
    {
        [self refreshAndEnableButton];
    }
}

- (void)refreshAndEnableButton
{
    [_addSelectedButton setEnabled:YES];
 
    [_addSelectedButton setTitle:[NSString stringWithFormat:@"%@(%d)", FIXED_BUTTON_TITLE, _checkedUsers.count] forState:UIControlStateNormal];
}

- (void)resetAndDisableButton
{
    [_addSelectedButton setEnabled:NO];
    
    [_addSelectedButton setTitle:[NSString stringWithFormat:@"%@", FIXED_BUTTON_TITLE] forState:UIControlStateNormal];
}

- (void)showAndAnimateIndicator
{
    [_activityIndicator setHidden:NO];
    [_activityIndicator startAnimating];
}

- (void)hideIndicator
{
    [_activityIndicator setHidden:YES];
    [_activityIndicator stopAnimating];
}

#pragma mark - Helpers

- (BOOL)isUserSelected:(GLPUser *)user
{
    for(GLPUser *u in _checkedUsers)
    {
        if(u.remoteKey == user.remoteKey)
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)removeUser:(GLPUser *)user
{
    int removeIndex = 0;
    
    for(int i = 0; i < _checkedUsers.count; ++i)
    {
        GLPUser *u = _checkedUsers[i];
        
        if(u.remoteKey == user.remoteKey)
        {
            removeIndex = i;
            break;
        }
    }
    
    [_checkedUsers removeObjectAtIndex:removeIndex];
}


- (BOOL)isCurrentUserFoundWithUsers:(NSArray *)users
{
    NSArray *arrayResult = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"remoteKey = %d", [SessionManager sharedInstance].user.remoteKey]];
    
    return (arrayResult.count == 1) ? YES : NO;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"view conversation"])
    {
        //        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        
        GLPConversationViewController *vt = segue.destinationViewController;
        vt.conversation = _conversation;
    }
}


@end
