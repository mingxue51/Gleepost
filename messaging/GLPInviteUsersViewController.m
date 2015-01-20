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
#import "GLPPrivateProfileViewController.h"
#import <TAPKeyboardPop/UIViewController+TAPKeyboardPop.h>
#import "GLPFacebookConnect.h"
#import "GLPGroupManager.h"

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
    
//    [self configureNavigationBar];
    
    [self configureTableView];
    
    [self registerTableViewCells];
    
    [self initialiseObjects];
    
    [self configureFacebookInvitationButton];
    
    [self loadExistingMembers];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureNavigationBar];
}

#pragma mark - Configuration

- (void)configureNavigationBar
{
    [super configureNavigationBar];
    
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
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

- (void)loadExistingMembers
{
    if([self doesNeedToReloadExistingMembers])
    {
        //Load existing members.
        [GLPGroupManager loadMembersWithGroupRemoteKey:self.group.remoteKey withLocalCallback:^(NSArray *members) {
            

            [super setAlreadyMembers:self.alreadyMembers];
            
            
        } remoteCallback:^(BOOL success, NSArray *members) {
            
            [super setAlreadyMembers:self.alreadyMembers];
        }];

    }
    else
    {
        [super setAlreadyMembers:self.alreadyMembers];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    [self showOrHideFacebookButton];
    
    if([self areSelectedUsersVisible])
    {
        return self.checkedUsers.count;
    }
    else
    {
        return self.searchedUsers.count;
    }
    
//    return self.searchedUsers.count;
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

- (void)removeCellWithIndex:(NSInteger)index
{
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)showOrHideFacebookButton
{
    if(super.searchedUsers.count == 0 && super.checkedUsers.count == 0)
    {
        //Show facebook button to invite friends.
        [_facebookButton setHidden:NO];
        
        DDLogDebug(@"Show facebook");
    }
    else
    {
        //Hide facebook button.
        [_facebookButton setHidden:YES];
        
        DDLogDebug(@"Hide facebook");
        
    }
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
    
    [[WebClient sharedInstance] addUsers:userKeys toGroup:_group callback:^(BOOL success, GLPGroup *updatedGroup) {
        
        [WebClientHelper hideStandardLoaderForView:self.view];
        
        if(!success) {
            [WebClientHelper failedToAddUsers];
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
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
//    GLPFBInvitationsViewController *fbVC = [storyboard instantiateViewControllerWithIdentifier:@"GLPFBInvitationsViewController"];
//    fbVC.group = self.group;
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:fbVC];
//    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
//    [self presentViewController:navigationController animated:YES completion:nil];
    
    [[GLPFacebookConnect sharedConnection] showDefaultFacebookInvitationScreenWithCompletionCallback:^(NSString *status) {
        
        if([status isEqualToString:@"error"])
        {
            [WebClientHelper showProblemLoadingFBFriends];
        }
        else if ([status isEqualToString:@"sent"])
        {
            //Show the name of users invited.
            [WebClientHelper showSuccessfullyInvitedFriends:@""];
        }
        else
        {
            //User canceled the view.
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        
    }];
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

#pragma mark - Keyboard management

- (void)keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curve.intValue;
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    //Change the position of the button depending on the size of the keyboard.
    float buttonYValue = [self findNewPositionOfTheButton:_addSelectedButton.frame withKeboardFrame:keyboardBounds];
    
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.height = buttonYValue - tableViewFrame.origin.y;
    
    [UIView animateWithDuration:[duration doubleValue] delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|(animationCurve << 16)) animations:^{
        
        self.tableView.frame = tableViewFrame;
        
        CGRectSetY(_addSelectedButton, buttonYValue);
        
    } completion:^(BOOL finished) {
        
        [self.tableView setNeedsLayout];
        
    }];
}

- (float)findNewPositionOfTheButton:(CGRect)buttonFrame withKeboardFrame:(CGRect)keyboardFrame
{
    float keyboardY = keyboardFrame.origin.y;
    
    //We are substracting with 125 because without it the position is wrong.
    //So if we don't substract with that number the position of the button will be wrong.
    
    return keyboardY - buttonFrame.size.height - 5 - 125;
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
    
    if ([segue.identifier isEqualToString:@"view private profile"])
    {
        GLPPrivateProfileViewController *privateUserVC = segue.destinationViewController;
        
        privateUserVC.selectedUserId = self.selectedUserRemoteKey;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
