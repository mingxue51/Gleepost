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
#import "NSNotificationCenter+Utils.h"
#import "GLPPrivateProfileViewController.h"

@interface NewGroupMessageViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) GLPConversation *conversation;

@property (weak, nonatomic) IBOutlet UIButton *addSelectedButton;


@end

@implementation NewGroupMessageViewController

const NSString *FIXED_BUTTON_TITLE = @"Add selected ";
const NSString *FIXED_BUTTON_ONE_USER_TITLE = @"Begin conversation ";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerTableViewCells];
    
    [self initiliaseObjects];
    
    [self configureTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureNavigationBar];
    
    [self hideNetworkErrorViewIfNeeded];
}

- (void)initiliaseObjects
{
    [super initialiseObjects];
    
    [super setDelegate:self];
}

- (void)registerTableViewCells
{
    [self.tableView registerNib:[UINib nibWithNibName:@"GLPCheckNameCell" bundle:nil] forCellReuseIdentifier:@"GLPCheckNameCell"];
}

- (void)configureTableView
{
    //Remove empty cells.
    [self.tableView setTableFooterView:[[UIView alloc] init]];
}

- (void)configureNavigationBar
{
    [super configureNavigationBar];
    
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:NO];

    
    [self.navigationController.navigationBar setButton:kLeft withImageOrTitle:@"cancel" withButtonSize:CGSizeMake(19, 21) withSelector:@selector(dismissViewController) andTarget:self];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)hideNetworkErrorViewIfNeeded
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_HIDE_ERROR_VIEW object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_HIDE_ERROR_VIEW object:self userInfo:nil];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self areSelectedUsersVisible])
    {
        return self.checkedUsers.count;
    }
    else
    {
        return self.searchedUsers.count;
    }
}

#pragma mark - Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *userCellIdentifier = @"GLPCheckNameCell";
    
    GLPCheckNameCell *userCell = nil;
    
    GLPUser *currentUser = nil;
    BOOL checked = NO;
    
    if([self areSelectedUsersVisible])
    {
        currentUser = self.checkedUsers[indexPath.row];
        checked = YES;
    }
    else
    {
        currentUser = self.searchedUsers[indexPath.row];
        checked = NO;
    }
    
    
//    BOOL checked = [self isUserSelected:currentUser];
    
    userCell = [tableView dequeueReusableCellWithIdentifier:userCellIdentifier forIndexPath:indexPath];
    
    [userCell setUserData:currentUser withCheckedStatus:checked];
    
    [userCell setDelegate:self];
    
    return userCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Navigate to user's profile.
    
    GLPUser *seletedUser = nil;
    
    if([self areSelectedUsersVisible])
    {
        seletedUser = self.checkedUsers[indexPath.row];
    }
    else
    {
        seletedUser = self.searchedUsers[indexPath.row];
    }
    
    [self navigateToUser:seletedUser];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NAME_CELL_HEIGHT;
}

#pragma mark - GLPCheckNameCellDelegate

- (void)userCheckedWithUser:(GLPUser *)user
{
    [self.checkedUsers addObject:user];
    
    [super userSelected];
    
    [self updateButtonTitle];
}

- (void)userUncheckedWithUser:(GLPUser *)user
{
    NSInteger removedIndex = [super removeUser:user];
    
    [self removeCellWithIndex:removedIndex];
    
    [self updateButtonTitle];
}

#pragma mark - GLPSelectUsersViewControllerDelegate

- (void)reloadTableView
{
    [_tableView reloadData];
}


#pragma mark - Selectors

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addUsers:(id)sender
{
    if(self.checkedUsers.count == 1)
    {
        [self startConversationWithOneUser];
    }
    else
    {
        [self startGroupConversation];
    }
}

- (void)startConversationWithOneUser
{
    GLPConversation *conversation = [[GLPLiveConversationsManager sharedInstance] findOneToOneConversationWithParticipant:self.checkedUsers[0]];
    
    DDLogInfo(@"Regular conversation for participant, conversation remote key: %d", conversation.remoteKey);
    
    if(!conversation)
    {
        DDLogInfo(@"Create empty conversation");
        
        NSArray *part = [[NSArray alloc] initWithObjects:self.checkedUsers[0], [SessionManager sharedInstance].user, nil];
        conversation = [[GLPConversation alloc] initWithParticipants:part];
        
    }
    
    [self navigateToConversationViewControllerWithConversation:conversation];
}

- (void)startGroupConversation
{
    NSMutableArray *checkedUsers = [[NSMutableArray alloc] initWithArray:self.checkedUsers copyItems:YES];
    
    //Create new conversation with users.
    GLPConversation *conversation = [[GLPLiveConversationsManager sharedInstance] findGroupConversationWithParticipants:checkedUsers];
    
    DDLogInfo(@"Regular conversation with participants, conversation remote key: %d", conversation.remoteKey);
    
    if(!conversation)
    {
        DDLogInfo(@"Create empty conversation");
        
        //        NSArray *part = [[NSArray alloc] initWithObjects:user, [SessionManager sharedInstance].user, nil];
        
        [checkedUsers addObject:[SessionManager sharedInstance].user];
        
        conversation = [[GLPConversation alloc] initWithParticipants:checkedUsers];
        
    }
    
    [self navigateToConversationViewControllerWithConversation:conversation];

}

- (void)navigateToConversationViewControllerWithConversation:(GLPConversation *)conversation
{
    _conversation = conversation;
    
    
    [self performSegueWithIdentifier:@"view conversation" sender:self];
}

#pragma mark - UI changes

- (void)updateButtonTitle
{
    if(self.checkedUsers.count == 0)
    {
        [self resetAndDisableButton];
    }
    else if(self.checkedUsers.count == 1)
    {
        [self refreshEnableButtonAndAddOneToOneMessage];
    }
    else
    {
        [self refreshButtonForGroupMessage];
    }
}

- (void)refreshEnableButtonAndAddOneToOneMessage
{
    [_addSelectedButton setEnabled:YES];
    
    [_addSelectedButton setTitle:[NSString stringWithFormat:@"%@", FIXED_BUTTON_ONE_USER_TITLE] forState:UIControlStateNormal];
}

- (void)refreshButtonForGroupMessage
{
    [_addSelectedButton setEnabled:YES];
 
    [_addSelectedButton setTitle:[NSString stringWithFormat:@"%@(%d)", FIXED_BUTTON_TITLE, self.checkedUsers.count] forState:UIControlStateNormal];
}

- (void)resetAndDisableButton
{
    [_addSelectedButton setEnabled:NO];
    
    [_addSelectedButton setTitle:[NSString stringWithFormat:@"%@", FIXED_BUTTON_ONE_USER_TITLE] forState:UIControlStateNormal];
}

- (void)removeCellWithIndex:(NSInteger)index
{
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];    
}

#pragma mark - Navigation

- (void)navigateToUser:(GLPUser *)user
{
    self.selectedUserRemoteKey = user.remoteKey;
    
    [self performSegueWithIdentifier:@"view private profile" sender:self];
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
    else if ([segue.identifier isEqualToString:@"view private profile"])
    {
        GLPPrivateProfileViewController *privateUserVC = segue.destinationViewController;
        
        privateUserVC.selectedUserId = self.selectedUserRemoteKey;
    }
    
}

@end
