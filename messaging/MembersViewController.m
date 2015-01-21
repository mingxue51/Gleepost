//
//  MembersViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 8/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "MembersViewController.h"
#import "MemberCell.h"
#import "GLPMember.h"
#import "WebClient.h"
#import "GLPPrivateProfileViewController.h"
#import "ContactsManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ShapeFormatterHelper.h"
#import "GLPInviteUsersViewController.h"
#import "GLPGroupManager.h"
#import "AppearanceHelper.h"
#import "UINavigationBar+Format.h"
#import "SessionManager.h"

@interface MembersViewController () <UIActionSheetDelegate, MemberCellDelegate>

@property (weak, nonatomic) IBOutlet UIView *addNewMembersView;

@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;

@property (strong, nonatomic) NSMutableArray *members;

@property (assign, nonatomic) int selectedUserId;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIImageView *addNewMembersBg;

@property (strong, nonatomic) GLPMember *loggedInUserMember;

/** This object is used when for adding or removing member as admin. */
@property (strong, nonatomic) GLPMember *selectedMember;

@property (strong, nonatomic) NSString *addUserAsAdminText;
@property (strong, nonatomic, readonly) NSString *removeUserFromAdminText;

@end

@implementation MembersViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self configureConstantStrings];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configurateTableView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureObjects];
    
    [self configureTopView];
    
    [self loadMembers];
    
    [AppearanceHelper makeBackDefaultButton];
    
    [self configureNavigationBar];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self configureTitleNavigationBar];
    
}

#pragma mark - Configuration

-(void)configureTopView
{
    if(_group.groupImageUrl)
    {
        [_groupImageView sd_setImageWithURL:[NSURL URLWithString:_group.groupImageUrl]];
    }
    
    [_addNewMembersBg setImage:[UIImage imageNamed:@"add_members_bg"]];

    [ShapeFormatterHelper setCornerRadiusWithView:_addNewMembersView andValue:5];
    
//    [ShapeFormatterHelper setRoundedView:_groupImageView toDiameter:_groupImageView.frame.size.height];
    
    CGRect imageFrame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
    
    [ShapeFormatterHelper setTwoLeftCornerRadius:_groupImageView withViewFrame:imageFrame withValue:8];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addNewMember:)];
    [tap setNumberOfTapsRequired:1];
    
    [_addNewMembersView addGestureRecognizer:tap];
    
}

- (void)configureConstantStrings
{
    _addUserAsAdminText = @"Add user as administrator";
    _removeUserFromAdminText = @"Revoke Admin Permissions";
}

-(void)configurateTableView
{
    [self.tableView registerNib:[UINib nibWithNibName:@"MemberCell" bundle:nil] forCellReuseIdentifier:@"MemberCell"];
    
    //Remove empty cells.
    [self.tableView setTableFooterView:[[UIView alloc] init]];

}

- (void)configureTitleNavigationBar
{
    self.navigationController.navigationBar.topItem.title = @"MEMBERS";

    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    
    [self.navigationController.navigationBar setFontFormatWithColour:kBlack];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)configureNavigationBar
{
    
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:NO andView:self.view];
    
    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar_trans"]
//                                                 forBarPosition:UIBarPositionAny
//                                                     barMetrics:UIBarMetricsDefault];
    

}

- (void)configureObjects
{
    _loggedInUserMember = [[GLPMember alloc] initWithUser:[SessionManager sharedInstance].user];
    
    _selectedMember = nil;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierContact = @"MemberCell";

    MemberCell *contactCell;

    contactCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierContact forIndexPath:indexPath];
    
    GLPMember *currentMember = self.members[indexPath.row];
    
    [contactCell setMember:currentMember withGroup:_group loggedInMemberRole:_loggedInUserMember];
    
    [contactCell setDelegate:self];
    
    return contactCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CONTACT_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLPMember *member = self.members[indexPath.row];

    GLPUser *userMember = [member getUser];
    
    if([[ContactsManager sharedInstance] isLoggedInUser:userMember])
    {
        [self performSegueWithIdentifier:@"view profile" sender:self];
    }
    else
    {
        self.selectedUserId = userMember.remoteKey;
        
        [self performSegueWithIdentifier:@"view private profile" sender:self];
    }
}

#pragma mark - MemberCellDelegate

- (void)moreOptionsSelectedForMember:(GLPMember *)member
{
    UIActionSheet *actionSheet = nil;
    
    if(member.roleLevel == kAdministrator)
    {
        actionSheet = [[UIActionSheet alloc]initWithTitle:@"Administrator options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:_removeUserFromAdminText, nil];
    }
    else
    {
        actionSheet = [[UIActionSheet alloc]initWithTitle:@"Administrator options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:_addUserAsAdminText, nil];
    }
    
    _selectedMember = member;

    [actionSheet showInView:[self.view window]];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *selectedButtonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];

    if([selectedButtonTitle isEqualToString:_addUserAsAdminText])
    {
        //Add user as administrator.
        [self setMemberAsAdministrator:_selectedMember];
    }
    else if([selectedButtonTitle isEqualToString:_removeUserFromAdminText])
    {
        //Remove user from being administrator.
        [self removeMemberFromAdministrator:_selectedMember];
    }
}

#pragma mark - Client

-(void)loadMembers
{
    
    [GLPGroupManager loadMembersWithGroupRemoteKey:self.group.remoteKey withLocalCallback:^(NSArray *members) {
        
        self.members = members.mutableCopy;
        
        [self findRoleOfLoggedInUser];
        
        [self.tableView reloadData];
        
    } remoteCallback:^(BOOL success, NSArray *members) {
        
        if(success)
        {
            self.members = members.mutableCopy;
            
            [self findRoleOfLoggedInUser];

            [self.tableView reloadData];
            
        }
    }];
    
//    [[WebClient sharedInstance] getMembersWithGroupRemoteKey:self.group.remoteKey withCallbackBlock:^(BOOL success, NSArray *members) {
//        
//        if(success)
//        {
//            self.members = members;
//            
//            [self.tableView reloadData];
//        }
//        
//    }];
}

- (void)setMemberAsAdministrator:(GLPMember *)member
{
    [GLPGroupManager addMemberAsAdministrator:member withCallbackBlock:^(BOOL success) {
        
        if(success)
        {
            
            DDLogDebug(@"Member just become admin %@", member.roleName);
            [self updateMemberWithMember:member];
            
            [self.tableView reloadData];

        }
    }];
}

- (void)removeMemberFromAdministrator:(GLPMember *)member
{
    [GLPGroupManager removeMemberFromAdministrator:member withCallbackBlock:^(BOOL success) {
        
        if(success)
        {
            DDLogDebug(@"Member just removed from admin %@", member.roleName);
            
            [self updateMemberWithMember:member];
            
            [self.tableView reloadData];
        }
        
    }];
}

- (void)findRoleOfLoggedInUser
{
    for(GLPMember *member in _members)
    {
        if([[ContactsManager sharedInstance] isLoggedInUser:[member getUser]])
        {
            [_loggedInUserMember setRoleKey: member.roleLevel];
            [_loggedInUserMember setGroupRemoteKey:_group.remoteKey];
            
            break;
        }
    }
}

#pragma mark - Helpers

- (void)updateMemberWithMember:(GLPMember *)member
{
    int index = 0;
    
    for(int i = 0; i < _members.count; ++i)
    {
        GLPMember *currentMember = [_members objectAtIndex:i];
        
        if(currentMember.remoteKey == member.remoteKey)
        {
            index = i;
            
            break;
        }
    }
    
    [_members setObject:member atIndexedSubscript:index];
}

#pragma mark - Selectors

-(void)addNewMember:(id)sender
{
    [_addNewMembersBg setImage:[UIImage imageNamed:@"add_members_bg_press_down"]];
    
    [self performSegueWithIdentifier:@"add members" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"view private profile"])
    {
        GLPPrivateProfileViewController *profileViewController = segue.destinationViewController;
        
        profileViewController.selectedUserId = self.selectedUserId;
    }
    else if ([segue.identifier isEqualToString:@"add members"])
    {
        GLPInviteUsersViewController *suvc = segue.destinationViewController;
        suvc.alreadyMembers = _members;
        suvc.group = _group;
        suvc.needToReloadExistingMembers = NO;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
