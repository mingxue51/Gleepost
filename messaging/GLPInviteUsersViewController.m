//
//  GLPInviteUsersViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 30/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPInviteUsersViewController.h"
#import "WebClientHelper.h"
#import "WebClient.h"
#import "GLPFBInvitationsViewController.h"

@interface GLPInviteUsersViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *addSelectedButton;

@property (strong, nonatomic) UIButton *facebookButton;

@end

@implementation GLPInviteUsersViewController

const NSString *FIXED_BUTTON_TLT = @"Add selected ";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationBar];
    
    [self configureTableView];
    
    [self registerTableViewCells];
    
    [self initialiseObjects];
    
    [self configureFacebookInvitationButton];
    
    [super setAlreadyMembers:self.alreadyMembers];
}

#pragma mark - Configuration

- (void)configureNavigationBar
{
    [super configureNavigationBar];
}

- (void)configureTableView
{
    //Remove empty cells.
    [self.tableView setTableFooterView:[[UIView alloc] init]];
}

- (void)registerTableViewCells
{
    [self.tableView registerNib:[UINib nibWithNibName:@"GLPCheckNameCell" bundle:nil] forCellReuseIdentifier:@"GLPCheckNameCell"];
}

- (void)initialiseObjects
{
    [super initialiseObjects];
    
    [super setDelegate:self];
}

- (void)configureFacebookInvitationButton
{
    _facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(35.0f, 50.0f, 250.0f, 60.0f)];
    [_facebookButton setImage:[UIImage imageNamed:@"fb_invite"] forState:UIControlStateNormal];
    [_facebookButton setHidden:YES];
    [_facebookButton addTarget:self action:@selector(inviteFriendsToFB:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.tableView insertSubview:_facebookButton aboveSubview:self.tableView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.searchedUsers.count == 0)
    {
        //Show facebook button to invite friends.
        [_facebookButton setHidden:NO];
    }
    else
    {
        //Hide facebook button.
        [_facebookButton setHidden:YES];
    }
    
    return self.searchedUsers.count;
}


#pragma mark - Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *userCellIdentifier = @"GLPCheckNameCell";
    
    GLPCheckNameCell *userCell = nil;
    
    GLPUser *currentUser = self.searchedUsers[indexPath.row];
    
    BOOL checked = [super isUserSelected:currentUser];
    
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
    [super removeUser:user];
    
    [self updateButtonTitle];
}

#pragma mark - UI changes

- (void)updateButtonTitle
{
    if(super.checkedUsers.count == 0)
    {
        [self resetAndDisableButton];
    }
    else
    {
        [self refreshButton];
    }
}

- (void)refreshButton
{
    [_addSelectedButton setEnabled:YES];
    
    [_addSelectedButton setTitle:[NSString stringWithFormat:@"%@(%lu)", FIXED_BUTTON_TLT, (unsigned long)super.checkedUsers.count] forState:UIControlStateNormal];
}

- (void)resetAndDisableButton
{
    [_addSelectedButton setEnabled:NO];
    
    [_addSelectedButton setTitle:[NSString stringWithFormat:@"%@", FIXED_BUTTON_TLT] forState:UIControlStateNormal];
}

#pragma mark - GLPSelectUsersViewControllerDelegate

- (void)reloadTableView
{
    [_tableView reloadData];
}

#pragma mark - Selectors

- (IBAction)addUsers:(id)sender
{
    [WebClientHelper showStandardLoaderWithTitle:@"Sending invitaions" forView:self.view];
    
    NSArray *userKeys = [super getCheckedUsersRemoteKeys];
    
    [[WebClient sharedInstance] addUsers:userKeys toGroup:_group callback:^(BOOL success) {
        
        [WebClientHelper hideStandardLoaderForView:self.view];
        
        if(!success) {
            [WebClientHelper showStandardErrorWithTitle:@"Request failed" andContent:@"Something went wrong. Please check your internet connection and retry."];
            return;
        }
        
        NSString *desc = [self generateAddedMessageWithUserKeys:userKeys];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Members added successfully"
                                                        message:desc
                                                       delegate:self
                                              cancelButtonTitle:@"Finish"
                                              otherButtonTitles:nil];
        [alert show];
    }];

}

#pragma mark - Facebook

-(void)inviteFriendsToFB:(id)sender
{
    [super resignFirstResponderOfGlpSearchBar];
    
    [self showInvitationsViewController];
}

-(void)showInvitationsViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    GLPFBInvitationsViewController *fbVC = [storyboard instantiateViewControllerWithIdentifier:@"GLPFBInvitationsViewController"];
    fbVC.group = self.group;
    [self presentViewController:fbVC animated:YES completion:nil];
}

#pragma mark - Helpers

- (NSString *)generateAddedMessageWithUserKeys:(NSArray *)userKeys
{
    return userKeys.count > 1 ? [NSString stringWithFormat:@"%d members were added to the group!", (int)userKeys.count] : @"The member was added to the group!";
}

#pragma mark - Alert view

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
