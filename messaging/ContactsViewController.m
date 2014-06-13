//
//  ContactsViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 20/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ContactsViewController.h"
#import "ContactUserCell.h"
#import "GLPPrivateProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WebClient.h"
#import "SessionManager.h"
#import "WebClientHelper.h"
#import "GLPContact.h"
#import "AppearanceHelper.h"
#import "UIViewController+GAI.h"
#import "UIViewController+Flurry.h"
#import "GLPThemeManager.h"
#import "ImageFormatterHelper.h"
#import "ContactsManager.h"
#import "GLPGroup.h"
#import "GLPGroupManager.h"
#import "GroupViewController.h"
#import "CreateNewGroupCell.h"
#import "GroupCell.h"
#import "NewGroupViewController.h"
#import "GLPSearchUsersViewController.h"
#import "EmptyMessage.h"
#import "UINavigationBar+Utils.h"

@interface ContactsViewController ()

@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic) NSMutableArray *usersStr;
@property (strong, nonatomic) NSMutableDictionary *categorisedUsers;
@property (strong, nonatomic) IBOutlet UITableView *contactsTableView;
@property (strong, nonatomic) NSArray *panelSections;
@property (assign, nonatomic) int selectedUserId;

@property (strong, nonatomic) UITabBarItem *contactsTabbarItem;

//Groups attributes.
@property (assign, nonatomic) BOOL isContactsView;
@property (strong, nonatomic) NSMutableArray *groups;
@property (strong, nonatomic) NSMutableArray *groupsStr;
@property (strong, nonatomic) NSMutableDictionary *categorisedGroups;
@property (strong, nonatomic) NSArray *groupSections;
@property (strong, nonatomic) GLPGroup *selectedGroup;

@property (weak, nonatomic) IBOutlet UISegmentedControl *groupsContactsSegment;

@property (strong, nonatomic) EmptyMessage *emptyContactsMessage;
@property (strong, nonatomic) EmptyMessage *emptyGroupsMessage;

@end

@implementation ContactsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configTabbar];
    
    [self initialiseObjects];
    
    [self registerViews];
    
    [self configureTableView];
    
    [self configureSegment];
    
    [self configNotifications];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadContacts];
    [self loadGroupsWithGroup:nil];
    
    [self sendViewToGAI:NSStringFromClass([self class])];
    [self sendViewToFlurry:NSStringFromClass([self class])];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configNavigationBar];
    
    [self configureNavigationButton];


    
    //Change the colour of the tab bar.
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:75.0/255.0 green:208.0/255.0 blue:210.0/255.0 alpha:1.0];
    
    [AppearanceHelper setSelectedColourForTabbarItem:self.contactsTabbarItem withColour:[UIColor colorWithRed:75.0/255.0 green:208.0/255.0 blue:210.0/255.0 alpha:1.0]];
    
    
    
//    [self setCustomBackgroundToTableView];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    

}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPGroupUploaded" object:nil];
}


-(void)configureTableView
{
    
    [self.contactsTableView setTableFooterView:[[UIView alloc] init]];

//    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
//    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    
    
//    UIImageView *backImgView = [[UIImageView alloc] initWithImage:[UIImage  imageNamed:@"contacts_background_main"]];
//    
//    [backImgView setFrame:CGRectMake(0.0f, 0.0f, backImgView.frame.size.width, backImgView.frame.size.height)];
//    
//    [self.tableView setBackgroundColor:[UIColor whiteColor]];
//    [self.tableView setBackgroundView:backImgView];
}

-(void)setCustomBackgroundToTableView
{
    UIImageView *backImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"campus_wall_background_main"]];
    
    [backImgView setFrame:CGRectMake(0.0f, 0.0f, backImgView.frame.size.width, backImgView.frame.size.height)];
    
    [self.view setBackgroundColor:[AppearanceHelper defaultGleepostColour]];
//    [self.tableView setBackgroundView:backImgView];
}

#pragma mark - Configuration

-(void)configNavigationBar
{
    //Change the format of the navigation bar.
    
    //[AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar2" forBarMetrics:UIBarMetricsDefault];
    
    [AppearanceHelper setNavigationBarColour:self];
    
    //[AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"chat_background_default" forBarMetrics:UIBarMetricsDefault];
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, nil]];
    [AppearanceHelper setNavigationBarFontFor:self];
    
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    
    

    //    [self.navigationController.navigationBar setShadowImage:[ImageFormatterHelper generateOnePixelHeightImageWithColour:tabColour]];
}

-(void)configureNavigationButton
{
    if(_isContactsView)
    {
        [self configureSearchContactButton];
    }
    else
    {
        [self configureCreateGroupButton];
    }
}


-(void)configureCreateGroupButton
{
    [self.navigationController.navigationBar setSystemButton:kRight withBarButtonSystemItem:UIBarButtonSystemItemAdd withSelector:@selector(popUpCreateView:) andTarget:self];
}

-(void)configureSearchContactButton
{
    [self.navigationController.navigationBar setSystemButton:kRight withBarButtonSystemItem:UIBarButtonSystemItemSearch withSelector:@selector(searchForNewContacts:) andTarget:self];
}

-(void)configureSegment
{
    
    //http://stackoverflow.com/questions/19138252/uisegmentedcontrol-bounds
    
//    [self.groupsContactsSegment setTintColor:[UIColor blackColor]];
//    [self.groupsContactsSegment setBackgroundColor:[AppearanceHelper defaultGleepostColour]];
    
//    self.groupsContactsSegment.layer.cornerRadius = 5;
//    CAShapeLayer* mask = [[CAShapeLayer alloc] init];
//    mask.frame = CGRectMake(0, 0, self.groupsContactsSegment.bounds.size.width, self.groupsContactsSegment.bounds.size.height);
//    mask.path = [[UIBezierPath bezierPathWithRoundedRect:mask.frame cornerRadius:4] CGPath];
//    self.groupsContactsSegment.layer.mask = mask;
    
//    [self.groupsContactsSegment setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, nil] forState:UIControlStateSelected];
//    
//    [self.groupsContactsSegment setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor lightGrayColor], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
    
    [AppearanceHelper setSegmentFontWithSegment:_groupsContactsSegment];
    
    
    
    
//    UIColor *newSelectedTintColor = [UIColor lightGrayColor];
//    [[[self.groupsContactsSegment subviews] objectAtIndex:1] setTintColor:[AppearanceHelper defaultGleepostColour]];
//    [[[self.groupsContactsSegment subviews] objectAtIndex:1] setBackgroundColor:newSelectedTintColor];
    
    
    
//    [self.groupsContactsSegment setTintColor:[AppearanceHelper defaultGleepostColour]];
//    
//    [self.groupsContactsSegment setBackgroundColor:newSelectedTintColor];
    
//    [self.groupsContactsSegment setBackgroundImage:[UIImage imageNamed:@"uselected_segment"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
//    [self.groupsContactsSegment setBackgroundImage:[UIImage imageNamed:@"selected_segment"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//
//    [self.groupsContactsSegment setDividerImage:[[UIImage alloc] init] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

-(void)configTabbar
{
    NSArray *items = self.tabBarController.tabBar.items;
    
    self.contactsTabbarItem = [items objectAtIndex:3];
}

-(void)configNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroupRemoteKeyAndImage:) name:@"GLPGroupUploaded" object:nil];

}

#pragma mark - Notifications

-(void)updateGroupRemoteKeyAndImage:(NSNotification *)notification
{
    int remoteKey = [GLPGroupManager parseNotification:notification withGroupsArray:_groups];
    
    if(remoteKey == -1)
    {
        return;
    }
    
    if(_isContactsView)
    {
        return;
    }
    
//    [self.tableView reloadData];
    
    NSIndexPath *indexPath = [GLPGroupManager findIndexPathForGroupRemoteKey:remoteKey withCategorisedGroups:_categorisedGroups];
    
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
}


-(void) clearContactsUselessSections
{
    BOOL sectionFound = NO;
    NSMutableArray *deletedSections = [[NSMutableArray alloc] init];

    for(NSString* letter in self.sections)
    {
        for(GLPContact* contact in self.users)
        {
            NSString* userName = contact.user.name;
            //Get the first letter of the user.
            NSString* firstLetter = [userName substringWithRange: NSMakeRange(0, 1)];
            
            if([firstLetter caseInsensitiveCompare:letter] == NSOrderedSame)
            {
                sectionFound = YES;
            }
        }
        
        //Delete a section if it is not necessary.
        if(!sectionFound)
        {
            [deletedSections addObject:letter];
        }
        else
        {
            sectionFound = NO;
        }
    }
    
    //Remove sections.
    for(NSString* letter in deletedSections)
    {
        [self.sections removeObject:letter];
    }
}

-(void)registerViews
{
    [self.tableView registerNib:[UINib nibWithNibName:@"CreateGroupCell" bundle:nil] forCellReuseIdentifier:@"CreateGroupCellIdentifier"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GroupCell" bundle:nil] forCellReuseIdentifier:@"GroupCellIdentifier"];

}

-(void)initialiseObjects
{
    //Init categorised users dictionary.
    self.categorisedUsers = [[NSMutableDictionary alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Add samples users.
    self.users = [[NSMutableArray alloc] init];
    self.usersStr = [[NSMutableArray alloc] init];
    
    
    self.panelSections = [NSMutableArray arrayWithObjects: @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", nil];
    
    self.isContactsView = NO;
    _groups = [[NSMutableArray alloc] init];
    self.groupsStr = [[NSMutableArray alloc] init];
    
    _emptyContactsMessage = [[EmptyMessage alloc] initWithText:@"You have no contacts" withPosition:EmptyMessagePositionCenter andTableView:self.tableView];
    
    _emptyGroupsMessage = [[EmptyMessage alloc] initWithText:@"You have no groups" withPosition:EmptyMessagePositionCenter andTableView:self.tableView];
    

}


-(void) categoriseUsersByLetter
{
    int indexOfLetter = 0;
    BOOL sectionFound = NO;
    NSMutableArray *deletedSections = [[NSMutableArray alloc] init];
    //NSNumber* indexOfLetter = [[NSNumber alloc] initWithInt:0];
    
    for(NSString* letter in self.sections)
    {
        for(GLPContact* contact in self.users)
        {
            NSString* userName = contact.user.name;
            //Get the first letter of the user.
            NSString* firstLetter = [userName substringWithRange: NSMakeRange(0, 1)];

            if([firstLetter caseInsensitiveCompare:letter] == NSOrderedSame)
            {
                sectionFound = YES;
                
                //Check if the dictonary has previous elements in the current key.
                NSMutableArray *currentUsers = [self.categorisedUsers objectForKey:[NSNumber numberWithInt:indexOfLetter]];
                
                if(currentUsers == nil)
                {
                    currentUsers = [[NSMutableArray alloc] init];
                    [currentUsers addObject:contact];
                }
                else
                {
                    //Add the user to the existing section.
                    [currentUsers addObject:contact];
                }
                
                [self.categorisedUsers setObject:currentUsers forKey:[NSNumber numberWithInt:indexOfLetter]];
                
            }
        }
        
        //Delete a section if it is not necessary.
        if(!sectionFound)
        {
            [deletedSections addObject:letter];
        }
        else
        {
            sectionFound = NO;
        }
    
        ++indexOfLetter;
    }
    
    //Remove sections.
    for(NSString* letter in deletedSections)
    {
        [self.sections removeObject:letter];
    }
}

/**
 Find the confirmed contacts and add them to the user's array in order to push them to contacts' table view.
 
 @param contactsFromServer 
                            contacts from server.
 
 */
-(void)findConfirmedContacts:(NSArray*) contactsFromServer
{
    //Created for test purposes.

    [self.users removeAllObjects];
    [self.usersStr removeAllObjects];
    
    for(GLPContact* contact in contactsFromServer)
    {
        if(contact.youConfirmed && contact.theyConfirmed)
        {
            [self.users addObject:contact];
            [self.usersStr addObject:contact.user.name];
        }
    }
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
    DDLogInfo(@"Received memory warning. ContactsViewController.");
}

-(void) navigateToProfileContact: (id)sender
{
    [self performSegueWithIdentifier:@"view profile" sender:self];

}

#pragma mark - Client methods

-(void) loadContacts
{

    [[ContactsManager sharedInstance] loadContactsWithLocalCallback:^(NSArray *contacts) {
        
        NSDictionary *allContacts = [[ContactsManager sharedInstance] findConfirmedContacts];
        
        
        //TODO: Find the issue and fix it.
        
        if(allContacts != nil)
        {
            [self showContacts:allContacts];
        }
        
    } remoteCallback:^(BOOL success, NSArray *contacts) {
        
        
        NSDictionary *allContacts = [[ContactsManager sharedInstance] findConfirmedContactsTemp:contacts];
        
        [self showContacts:allContacts];

    }];
    
}

-(void)loadGroupsWithGroup:(GLPGroup *)createdGroup
{
    if(createdGroup)
    {
        //Add the new group in order to preserve it as is.
        //We are doing that because the new group has a real image
        //in order to create better user experience for the user.
        
        [_groups addObject:createdGroup];
    }

    
    [GLPGroupManager loadGroups:_groups withLocalCallback:^(NSArray *groups) {
       
        _groups = groups.mutableCopy;

        [self showGroups];
        
        
        [self.contactsTableView reloadData];
        
    } remoteCallback:^(BOOL success, NSArray *groups) {
        
        if(!success)
        {
            return;
        }
        
        _groups = groups.mutableCopy;
        
        [self showGroups];
        
        
        [self.contactsTableView reloadData];
        
    }];
}

//-(void)createNewGroupWithGroup:(GLPGroup *)group
//{
//    [[WebClient sharedInstance] createGroupWithGroup:group callback:^(BOOL success, GLPGroup* group) {
//        
//        if(success)
//        {
//            DDLogInfo(@"Group with name: %@ created.", group.name);
//            
//            [self reloadNewGroupWithGroup:group];
//        }
//        else
//        {
//            DDLogInfo(@"Fail to create group with name: %@.", group.name);
//        }
//        
//    }];
//}

#pragma mark - Selectors

- (IBAction)barSegmentTouched:(id)sender
{
    UISegmentedControl *segment = sender;
    
    _isContactsView = segment.selectedSegmentIndex;
    
    if(!_isContactsView)
    {
        self.tableView.separatorColor = [UIColor clearColor];
        
    }
    else
    {
        self.tableView.separatorColor = [AppearanceHelper colourForTableViewSeparatorLines];
    }

    
    [self configureNavigationButton];
    
//    for (int i=0; i<[segment.subviews count]; i++)
//    {
//        if ([[segment.subviews objectAtIndex:i]isSelected] )
//        {
//            UIColor *tintcolor=[AppearanceHelper defaultGleepostColour];
//            [[segment.subviews objectAtIndex:i] setTintColor:tintcolor];
//        }
//        else
//        {
//            [[segment.subviews objectAtIndex:i] setTintColor:[UIColor lightGrayColor]];
//        }
//    }
    
    
    
    [self.tableView reloadData];
    
}


#pragma mark - UI loaders

-(void)showContacts:(NSDictionary*)categorisedContacts
{
    self.users = [categorisedContacts objectForKey:@"Contacts"];
    self.usersStr = [categorisedContacts objectForKey:@"ContactsUserNames"];
    
    [self.categorisedUsers removeAllObjects];
    
    if(self.users.count>0)
    {
        self.sections = [NSMutableArray arrayWithObjects: @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", nil];
        
        [self clearContactsUselessSections];
        
        [self categoriseUsersByLetter];
        [self.contactsTableView reloadData];
    }
}

-(void)showGroups
{    
    if(self.groups.count > 0)
    {
        NSDictionary *result = [GLPGroupManager processGroups:_groups];
        
        _groupsStr = [result objectForKey:@"GroupNames"];
        _categorisedGroups = [result objectForKey:@"CategorisedGroups"];
        _groupSections = [result objectForKey:@"Sections"];
    }
    else
    {
        _groupsStr = [[NSMutableArray alloc] init];
        _categorisedGroups = [[NSMutableDictionary alloc] init];
        _groupSections = [[NSMutableArray alloc] init];
    }
}

-(void)reloadNewGroupWithGroup:(GLPGroup *)group
{
    [self loadGroupsWithGroup:group];
}


//TODO: Do that later.
/**
 We need to delete first number of sections and then rows (?).
 */
-(void)deleteGroupWithRemoteKey:(int)remoteKey
{
//    NSIndexPath *indexPath = [GLPGroupManager findIndexPathForGroupRemoteKey:remoteKey withCategorisedGroups:_categorisedGroups];
//    DDLogDebug(@"IndexPath: %d : %d", indexPath.row, indexPath.section);
//    
//    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationRight];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    if (_isContactsView)
    {
        
        [_emptyGroupsMessage hideEmptyMessageView];
        
        if(_users.count == 0)
        {
            [_emptyContactsMessage showEmptyMessageView];
        }
        else
        {
            [_emptyContactsMessage hideEmptyMessageView];
        }
        
        
        return self.sections.count;
    }
    else
    {
        
        [_emptyContactsMessage hideEmptyMessageView];
        
        if(_groups.count == 0)
        {
            [_emptyGroupsMessage showEmptyMessageView];
        }
        else
        {
            [_emptyGroupsMessage hideEmptyMessageView];
        }
        
        
        return _groupSections.count;
    }
    
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (_isContactsView)
    {
        return self.panelSections;
    }
    else
    {
//        NSMutableArray *panelSec = self.panelSections.mutableCopy;
//        [panelSec setObject:@"-" atIndexedSubscript:0];
        
        //return self.panelSections;
        
        //We don't need index section in the right for groups.
        
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index
{
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_isContactsView)
    {
        return [NSString stringWithFormat:@"  %@", [[self.sections objectAtIndex:section] uppercaseString]];
    }
    else
    {
//        if(section == 0)
//        {
//            return nil;
//        }
        
        return [NSString stringWithFormat:@"  %@", [[_groupSections objectAtIndex:section] uppercaseString]];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if(_isContactsView)
    {

        NSArray *sectionArray = [self.usersStr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [self.sections objectAtIndex:section]]];
        
        return [sectionArray count];
    }
    else
    {
//        if(section == 0)
//        {
//            return 1;
//        }
//        else
//        {
            NSArray *sectionArray = [self.groupsStr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [self.groupSections objectAtIndex:section]]];

            return [sectionArray count];
//        }
        
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ContactCell";
//    static NSString *CreateGroupCellIdentifier = @"CreateGroupCellIdentifier";
    static NSString *GroupCellIdentifier = @"GroupCellIdentifier";
    
    if(_isContactsView)
    {
        ContactUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

        
        NSArray *currentUsers = [self.categorisedUsers objectForKey:[NSNumber numberWithInt: indexPath.section]];
        
        GLPContact *currentContact = [currentUsers objectAtIndex:indexPath.row];
        
        [cell setName:currentContact.user.name withImageUrl:currentContact.user.profileImageUrl];
        
        return cell;

    }
    else
    {
//        if(indexPath.row == 0 && indexPath.section == 0)
//        {
//            CreateNewGroupCell *groupCell = [tableView dequeueReusableCellWithIdentifier:CreateGroupCellIdentifier forIndexPath:indexPath];
//            
//            [groupCell setDelegate:self];
//            
//            
//            return groupCell;
//        }
//        else
//        {
        
            GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:GroupCellIdentifier forIndexPath:indexPath];
            
//            ContactUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

            [cell setDelegate:self];
            
            NSArray *currentGroups = [self.categorisedGroups objectForKey:[NSNumber numberWithInt: indexPath.section]];
            
            GLPGroup *currentGroup = [currentGroups objectAtIndex:indexPath.row];
            
            [cell setGroupData:currentGroup];
            
            [self addSeparatorLineToCell:cell];
            
            return cell;

//        }

        

    }
    

    return nil;
}

-(void)addSeparatorLineToCell:(GroupCell *)cell
{
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 47.0f, 320, 1)];
    line.backgroundColor = [AppearanceHelper colourForTableViewSeparatorLines];
    [cell addSubview:line];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    if(_isContactsView)
    {
        NSArray *currentUsers = [self.categorisedUsers objectForKey:[NSNumber numberWithInt: indexPath.section]];
        
        self.selectedUserId = [[currentUsers objectAtIndex:indexPath.row] remoteKey];
        
        [self performSegueWithIdentifier:@"view profile" sender:self];
    }
    else
    {
//        if(indexPath.row == 0 && indexPath.section == 0)
//        {
//            return;
//        }
        
        NSArray *currentGroups = [self.categorisedGroups objectForKey:[NSNumber numberWithInt:indexPath.section]];
        
        self.selectedGroup = [currentGroups objectAtIndex:indexPath.row];
        
        [self performSegueWithIdentifier:@"view group" sender:self];
    }
    

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if(indexPath.row == 0 && indexPath.section == 0)
//    {
//        return NEW_GROUP_CELL_HEIGHT;
//    }
    
    return 48.0f;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    
//}


#pragma mark - Group Created Delegate

//TODO: Make those methods more efficient.

-(void)groupCreatedWithData:(GLPGroup *)group
{
    [self reloadNewGroupWithGroup:group];
    
//    [self createNewGroupWithGroup:group];
}


-(void)groupDeletedWithData:(GLPGroup *)group
{
    [GLPGroupManager deleteGroup:group];

//    [self deleteGroupWithRemoteKey:group.remoteKey];
    
    [self reloadNewGroupWithGroup:nil];
}

#pragma mark - Navigation

//Call this when there is a need to pass elements to the next controller.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Hide tabbar.
    // [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    
    if([segue.identifier isEqualToString:@"view profile"])
    {
        GLPPrivateProfileViewController *pvc = segue.destinationViewController;
        
        pvc.selectedUserId = self.selectedUserId;
    }
    else if([segue.identifier isEqualToString:@"view group"])
    {
        GroupViewController *gvc = segue.destinationViewController;
        
        gvc.group = self.selectedGroup;
    }
    else if ([segue.identifier isEqualToString:@"search contacts"])
    {
        GLPSearchUsersViewController *suvc = segue.destinationViewController;
        
        suvc.searchForMembers = NO;
    }
}

-(void)popUpCreateView:(id)sender
{
    //Pop up the creation view.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    NewGroupViewController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"NewGroupViewController"];
    
    //    [cvc.view setBackgroundColor:[UIColor colorWithPatternImage:[image stackBlur:10.0f]]];
    //    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:cvc];
    //    [navigationController setNavigationBarHidden:YES];
    //    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [cvc setDelegate:self];
    
    [self presentViewController:cvc animated:YES completion:nil];
}

-(void)searchForNewContacts:(id)sender
{
    [self performSegueWithIdentifier:@"search contacts" sender:self];
}

/**
 
 Not used.
 
 */
- (UIImage *)resizeImageToSize:(CGSize)targetSize withImage:(UIImage*) incImage
{
    UIImage *sourceImage = incImage;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // make image center aligned
        //        if (widthFactor < heightFactor)
        //        {
        //            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        //        }
        //        else if (widthFactor > heightFactor)
        //        {
        //            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        //        }
    }
    
    UIGraphicsBeginImageContext(targetSize);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    return newImage ;
}

@end
