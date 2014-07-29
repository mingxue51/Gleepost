//
//  MembersViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 8/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "MembersViewController.h"
#import "ContactUserCell.h"
#import "GLPUser.h"
#import "WebClient.h"
#import "GLPPrivateProfileViewController.h"
#import "ContactsManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ShapeFormatterHelper.h"
#import "GLPSearchUsersViewController.h"
#import "GLPGroupManager.h"

@interface MembersViewController ()

@property (weak, nonatomic) IBOutlet UIView *addNewMembersView;

@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;

@property (strong, nonatomic) NSArray *members;

@property (assign, nonatomic) int selectedUserId;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *addNewMembersBg;

@end

@implementation MembersViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configurateTableView];
    
    [self configurateView];
    
    [self configureNavigationBar];
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureTopView];
    
    [self loadMembers];
}

#pragma mark - Configuration

-(void)configurateView
{
    self.title = @"MEMBERS";
}

-(void)configureTopView
{
    if(_group.groupImageUrl)
    {
        [_groupImageView setImageWithURL:[NSURL URLWithString:_group.groupImageUrl]];
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

-(void)configurateTableView
{
    [self.tableView registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
    
    //Remove empty cells.
    [self.tableView setTableFooterView:[[UIView alloc] init]];

}

- (void)configureNavigationBar
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
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
    static NSString *CellIdentifierContact = @"ContactCell";

    ContactUserCell *contactCell;

    contactCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierContact forIndexPath:indexPath];
    
    GLPUser *currentMember = self.members[indexPath.row];
    
    [contactCell setMember:currentMember withGroup:_group];
    
    return contactCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CONTACT_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLPUser *member = self.members[indexPath.row];

    
    if([[ContactsManager sharedInstance] isLoggedInUser:member])
    {
        [self performSegueWithIdentifier:@"view profile" sender:self];
    }
    else
    {
        self.selectedUserId = member.remoteKey;
        
        [self performSegueWithIdentifier:@"view private profile" sender:self];
    }
}

#pragma mark - Client

-(void)loadMembers
{
    
    [GLPGroupManager loadMembersWithGroupRemoteKey:self.group.remoteKey withLocalCallback:^(NSArray *members) {
        
        self.members = members;
        
        [self.tableView reloadData];
        
    } remoteCallback:^(BOOL success, NSArray *members) {
        
        if(success)
        {
            self.members = members;
            
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
        GLPSearchUsersViewController *suvc = segue.destinationViewController;
        suvc.searchForMembers = YES;
        suvc.group = _group;
        suvc.alreadyMembers = _members;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
