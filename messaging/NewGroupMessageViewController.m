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

//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
//
//@property (strong, nonatomic) NSMutableArray *searchedUsers;
//
//@property (strong, nonatomic) NSMutableArray *checkedUsers;

//@property (strong, nonatomic) UITapGestureRecognizer *tap;

@property (strong, nonatomic) GLPConversation *conversation;

@property (weak, nonatomic) IBOutlet UIButton *addSelectedButton;

@end

@implementation NewGroupMessageViewController

const NSString *FIXED_BUTTON_TITLE = @"Add selected ";
const NSString *FIXED_BUTTON_ONE_USER_TITLE = @"Start conversation with ";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerTableViewCells];
    
    [self initiliaseObjects];
    
    [self configureGestures];
    
    [self configureTableView];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [_searchBar becomeFirstResponder];

    
    [self configureNavigationBar];
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
//    float buttonsSize = 30.0;
    
    [super configureNavigationBar];
    
    [self.navigationController.navigationBar setButton:kLeft withImageOrTitle:@"cancel" withButtonSize:CGSizeMake(19, 21) withSelector:@selector(dismissViewController) andTarget:self];
    
//    [self.navigationController.navigationBar setButton:kRight withImageOrTitle:@"one_one_button" withButtonSize:CGSizeMake(buttonsSize, buttonsSize) withSelector:@selector(goBack) andTarget:self];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchedUsers.count;
}


#pragma mark - Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *userCellIdentifier = @"GLPCheckNameCell";
    
    GLPCheckNameCell *userCell = nil;
    
    
    GLPUser *currentUser = self.searchedUsers[indexPath.row];
    
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
    [self.checkedUsers addObject:user];
    
    [self updateButtonTitle];
}

- (void)userUncheckedWithUser:(GLPUser *)user
{
    [self removeUser:user];
    
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
    //Create new conversation with users.
    GLPConversation *conversation = [[GLPLiveConversationsManager sharedInstance] findGroupConversationWithParticipants:self.checkedUsers];
    
    DDLogInfo(@"Regular conversation with participants, conversation remote key: %d", conversation.remoteKey);
    
    if(!conversation)
    {
        DDLogInfo(@"Create empty conversation");
        
        //        NSArray *part = [[NSArray alloc] initWithObjects:user, [SessionManager sharedInstance].user, nil];
        
        [self.checkedUsers addObject:[SessionManager sharedInstance].user];
        
        conversation = [[GLPConversation alloc] initWithParticipants:self.checkedUsers];
        
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
    
    GLPUser *user = self.checkedUsers[0];
    
    [_addSelectedButton setTitle:[NSString stringWithFormat:@"%@%@", FIXED_BUTTON_ONE_USER_TITLE, user.name] forState:UIControlStateNormal];
}

- (void)refreshButtonForGroupMessage
{
    [_addSelectedButton setEnabled:YES];
 
    [_addSelectedButton setTitle:[NSString stringWithFormat:@"%@(%d)", FIXED_BUTTON_TITLE, self.checkedUsers.count] forState:UIControlStateNormal];
}

- (void)resetAndDisableButton
{
    [_addSelectedButton setEnabled:NO];
    
    [_addSelectedButton setTitle:[NSString stringWithFormat:@"%@", FIXED_BUTTON_TITLE] forState:UIControlStateNormal];
}

//- (void)showAndAnimateIndicator
//{
//    [_activityIndicator setHidden:NO];
//    [_activityIndicator startAnimating];
//}
//
//- (void)hideIndicator
//{
//    [_activityIndicator setHidden:YES];
//    [_activityIndicator stopAnimating];
//}

#pragma mark - Helpers

//- (BOOL)isUserSelected:(GLPUser *)user
//{
//    for(GLPUser *u in _checkedUsers)
//    {
//        if(u.remoteKey == user.remoteKey)
//        {
//            return YES;
//        }
//    }
//    
//    return NO;
//}
//
//- (void)removeUser:(GLPUser *)user
//{
//    int removeIndex = 0;
//    
//    for(int i = 0; i < _checkedUsers.count; ++i)
//    {
//        GLPUser *u = _checkedUsers[i];
//        
//        if(u.remoteKey == user.remoteKey)
//        {
//            removeIndex = i;
//            break;
//        }
//    }
//    
//    [_checkedUsers removeObjectAtIndex:removeIndex];
//}


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
