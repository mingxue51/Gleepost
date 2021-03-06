//
//  GLPShowUsersViewController.m
//  Gleepost
//
//  Created by Silouanos on 14/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPShowUsersViewController.h"
#import "UINavigationBar+Format.h"
#import "GLPUser.h"
#import "MemberCell.h"
#import "ContactsManager.h"
#import "GLPPrivateProfileViewController.h"
#import "WebClient.h"
#import "GLPTableActivityIndicator.h"
#import "FakeNavigationBarView.h"

@interface GLPShowUsersViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) NSInteger selectedUserId;

@property (strong, nonatomic) GLPTableActivityIndicator *tableActivityIndicator;

@property (strong, nonatomic) FakeNavigationBarView *fakeNavigationBar;

@end

@implementation GLPShowUsersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialiseObjects];
    [self configureView];
//    [self configureNavigationBar];
    [self configureTableView];
    [self loadAttendeesIfNeeded];
    [self showUsers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureNavigationBar];
    
}

- (void)initialiseObjects
{
    _tableActivityIndicator = [[GLPTableActivityIndicator alloc] initWithPosition:kActivityIndicatorCenter withView:_tableView];
}

- (void)configureView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)configureNavigationBar
{
    if(self.transparentNavBar)
    {
        [self.navigationController.navigationBar invisible];
        self.fakeNavigationBar = [[FakeNavigationBarView alloc] initWithTitle:_selectedTitle];
        [self.view addSubview:self.fakeNavigationBar];
    }
    else
    {
        [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
        self.navigationItem.title = self.selectedTitle;
    }

    [self.navigationController.navigationBar setFontFormatWithColour:kBlack];
}

- (void)configureTableView
{
    [_tableView registerNib:[UINib nibWithNibName:@"MemberCell" bundle:nil] forCellReuseIdentifier:@"MemberCell"];
    
    //Remove empty cells.
    [self.tableView setTableFooterView:[[UIView alloc] init]];
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
    static NSString *CellIdentifierContact = @"MemberCell";
    
    MemberCell *userCell;
    
    userCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierContact forIndexPath:indexPath];
    
    GLPUser *currentUser = _users[indexPath.row];
    
    [userCell setName:currentUser.name withImageUrl:currentUser.profileImageUrl];
    
    return userCell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CONTACT_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GLPUser *selectedUser = _users[indexPath.row];
    
    if([[ContactsManager sharedInstance] isLoggedInUser:selectedUser])
    {
        [self performSegueWithIdentifier:@"view profile" sender:self];
    }
    else
    {
        self.selectedUserId = selectedUser.remoteKey;
        [self performSegueWithIdentifier:@"view private profile" sender:self];
    }
}

#pragma mark - UI

- (void)showUsers
{
    if(_users && _users.count > 0)
    {
        [self.tableView reloadData];
    }
}

#pragma mark - Client

- (void)loadAttendeesIfNeeded
{
    if(self.postRemoteKey == 0)
    {
        return;
    }
    
    [_tableActivityIndicator startActivityIndicator];
    
    [[WebClient sharedInstance] loadAttendeesWithPostRemoteKey:self.postRemoteKey callback:^(NSArray *users, BOOL success) {
        
        [_tableActivityIndicator stopActivityIndicator];
        
        if(success)
        {
            _users = users;
            [_tableView reloadData];
        }
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"view private profile"])
    {
        GLPPrivateProfileViewController *profileViewController = segue.destinationViewController;
        profileViewController.transparentNavBar = YES;
        profileViewController.selectedUserId = self.selectedUserId;
    }
}


@end
