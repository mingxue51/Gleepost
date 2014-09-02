//
//  NewMessageViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 1/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  Class not used.

#import "NewMessageViewController.h"
#import "UINavigationBar+Format.h"
#import "UINavigationBar+Utils.h"
#import "GLPSimpleNameCell.h"
#import "NSString+Utils.h"
#import "WebClient.h"
#import "GLPLiveConversationsManager.h"
#import "SessionManager.h"
#import "GLPConversationViewController.h"

@interface NewMessageViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *searchedUsers;

@property (strong, nonatomic) UITapGestureRecognizer *tap;

@property (strong, nonatomic) GLPConversation *conversation;

@end

@implementation NewMessageViewController

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
    
    [self configureNavigationBar];
}

- (void)initiliaseObjects
{
    _searchedUsers = [[NSMutableArray alloc] init];
}

- (void)registerTableViewCells
{
    [self.tableView registerNib:[UINib nibWithNibName:@"GLPSimpleNameCell" bundle:nil] forCellReuseIdentifier:@"GLPNameCell"];
}

- (void)configureGestures
{
    _tap = [[UITapGestureRecognizer alloc]
            initWithTarget:self
            action:@selector(viewTouched:)];
    
    _tap.cancelsTouchesInView = NO;
    
    [_tableView addGestureRecognizer:_tap];
}

- (void)configureNavigationBar
{
    float buttonsSize = 30.0;
    
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:NO];
    
    [self.navigationController.navigationBar setFontFormatWithColour:kBlack];
    
    
    [self.navigationController.navigationBar setButton:kLeft withImageName:@"x_red" withButtonSize:CGSizeMake(20.0, 20.0) withSelector:@selector(dismissViewController) andTarget:self];
    
    
    [self.navigationController.navigationBar setButton:kRight withImageName:@"group_button" withButtonSize:CGSizeMake(buttonsSize, buttonsSize) withSelector:@selector(navigateToGroupMessageController) andTarget:self];
    
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
    static NSString *userCellIdentifier = @"GLPNameCell";
    
    GLPSimpleNameCell *userCell = nil;
    
    userCell = [tableView dequeueReusableCellWithIdentifier:userCellIdentifier forIndexPath:indexPath];
    
    [userCell setUserData:_searchedUsers[indexPath.row]];
    
    return userCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //Start new conversation or continue if existed.
    
    [self startNewConversationWithUser:_searchedUsers[indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NAME_CELL_HEIGHT;
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

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    //We are setting a delay here because otherwise setCancelsTouchesInView is called after the touch to
    //the collection view.
    
    [_tap performSelector:@selector(setCancelsTouchesInView:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.1];
}



- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [_tap setCancelsTouchesInView:YES];
}

#pragma mark - Search users

- (void)searchUserWithName:(NSString *)userName
{
    
    if(![userName isNotBlank]) {
        return;
    }
    
    DDLogInfo(@"Start user search");
    
    
    [[WebClient sharedInstance] searchUserByName:userName callback:^(NSArray *users) {
        
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
        
        DDLogDebug(@"Searched users: %@", _searchedUsers);
        
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

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)startNewConversationWithUser:(GLPUser *)user
{
    GLPConversation *conversation = [[GLPLiveConversationsManager sharedInstance] findOneToOneConversationWithParticipant:user];
    
    DDLogInfo(@"Regular conversation for participant, conversation remote key: %d", conversation.remoteKey);
    
    if(!conversation)
    {
        DDLogInfo(@"Create empty conversation");
        
        NSArray *part = [[NSArray alloc] initWithObjects:user, [SessionManager sharedInstance].user, nil];
        conversation = [[GLPConversation alloc] initWithParticipants:part];
        
    }
    
    [self navigateToConversationViewControllerWithConversation:conversation];
}

- (void)navigateToGroupMessageController
{
    [self performSegueWithIdentifier:@"view group" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Helpers

- (BOOL)isCurrentUserFoundWithUsers:(NSArray *)users
{
    NSArray *arrayResult = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"remoteKey = %d", [SessionManager sharedInstance].user.remoteKey]];
    
    return (arrayResult.count == 1) ? YES : NO;
}

#pragma mark - Navigation

- (void)navigateToConversationViewControllerWithConversation:(GLPConversation *)conversation
{
    _conversation = conversation;
    
    [self performSegueWithIdentifier:@"view conversation" sender:self];

}



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
    else if ([segue.identifier isEqualToString:@"view group"])
    {
        
    }
}


@end
