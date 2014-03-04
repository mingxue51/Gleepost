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

@end

@implementation ContactsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configTabbar];
    
    [self initialiseObjects];
    
    [self configNavigationBar];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadContacts];
    [self loadGroups];
    
    [self sendViewToGAI:NSStringFromClass([self class])];
    [self sendViewToFlurry:NSStringFromClass([self class])];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Change the colour of the tab bar.
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:75.0/255.0 green:208.0/255.0 blue:210.0/255.0 alpha:1.0];
    
    [AppearanceHelper setSelectedColourForTabbarItem:self.contactsTabbarItem withColour:[UIColor colorWithRed:75.0/255.0 green:208.0/255.0 blue:210.0/255.0 alpha:1.0]];
    
    
    
    [self.contactsTableView setTableFooterView:[[UIView alloc] init]];

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
    
    
    //    [self.navigationController.navigationBar setShadowImage:[ImageFormatterHelper generateOnePixelHeightImageWithColour:tabColour]];
}

-(void)configTabbar
{
    NSArray *items = self.tabBarController.tabBar.items;
    
    self.contactsTabbarItem = [items objectAtIndex:3];
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
}

-(void) navigateToProfileContact: (id)sender
{
    [self performSegueWithIdentifier:@"view profile" sender:self];

}

#pragma mark - Client methods

-(void) loadContacts
{

    [ContactsManager loadContactsWithLocalCallback:^(NSArray *contacts) {
        
        NSDictionary *allContacts = [[ContactsManager sharedInstance] findConfirmedContacts];
        
//        if(allContacts != nil)
//        {
            [self showContacts:allContacts];
//        }
        
    } remoteCallback:^(BOOL success, NSArray *contacts) {
        
        
        NSDictionary *allContacts = [[ContactsManager sharedInstance] findConfirmedContactsTemp:contacts];
        
        [self showContacts:allContacts];

        
    }];
    
    
//    NSDictionary *allContacts = [[ContactsManager sharedInstance] findConfirmedContacts];
//    
//    
//    
//    self.users = [allContacts objectForKey:@"Contacts"];
//    self.usersStr = [allContacts objectForKey:@"ContactsUserNames"];
//    
//    if(self.users.count>0)
//    {
//        self.sections = [NSMutableArray arrayWithObjects: @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", nil];
//        [self clearUselessSections];
//        
//        [self categoriseUsersByLetter];
//        [self.contactsTableView reloadData];
//    }
    
    
//    [[WebClient sharedInstance ] getContactsWithCallbackBlock:^(BOOL success, NSArray *contacts) {
//        
//        if(success)
//        {
//            //Store contacts into an array.
//            [self findConfirmedContacts:contacts.mutableCopy];
//            
//            if(self.users.count>0)
//            {
//                self.sections = [NSMutableArray arrayWithObjects: @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", nil];
//                [self clearUselessSections];
//
//                [self categoriseUsersByLetter];
//                [self.contactsTableView reloadData];
//            }
//            
////            self.users = contacts.mutableCopy;
//            
//        }
//        else
//        {
//            [WebClientHelper showStandardError];
//        }
//
//        
//    }];
}

//TODO: When it will be supported by serve we need to change the method from getGroup to getGroups.

-(void)loadGroups
{
    int networkKey = [SessionManager sharedInstance].user.networkId;
    
    [[WebClient sharedInstance] getGroupDescriptionWithId:networkKey withCallbackBlock:^(BOOL success, GLPGroup *group) {
       
        if(success)
        {
            _groups = [[NSMutableArray alloc] initWithObjects:group, nil];
            
            [self showGroups];
            
            [self.contactsTableView reloadData];
        }
        else
        {
            [WebClientHelper showStandardError];
        }
        
        
    }];
}

#pragma mark - Selectors

- (IBAction)barSegmentTouched:(id)sender
{
    UISegmentedControl *segment = sender;
    
    _isContactsView = segment.selectedSegmentIndex;
    
    [self.tableView reloadData];
    
}


#pragma mark - UI loaders

-(void)showContacts:(NSDictionary*)categorisedContacts
{
    self.users = [categorisedContacts objectForKey:@"Contacts"];
    self.usersStr = [categorisedContacts objectForKey:@"ContactsUserNames"];
    
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
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    if (_isContactsView)
    {
        return self.sections.count;
    }
    else
    {
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
        return self.panelSections;
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
        NSArray *sectionArray = [self.groupsStr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [self.groupSections objectAtIndex:section]]];
        
        return [sectionArray count];
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ContactCell";
    ContactUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(_isContactsView)
    {
        NSArray *currentUsers = [self.categorisedUsers objectForKey:[NSNumber numberWithInt: indexPath.section]];
        
        GLPContact *currentContact = [currentUsers objectAtIndex:indexPath.row];
        
        [cell setName:currentContact.user.name withImageUrl:currentContact.user.profileImageUrl];
        
    }
    else
    {
        NSArray *currentGroups = [self.categorisedGroups objectForKey:[NSNumber numberWithInt: indexPath.section]];
        
        GLPGroup *currentGroup = [currentGroups objectAtIndex:indexPath.row];
        
        [cell setName:currentGroup.name withImageUrl:@""];
        

    }
    

    return cell;
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
        NSArray *currentGroups = [self.categorisedGroups objectForKey:[NSNumber numberWithInt:indexPath.section]];
        
        self.selectedGroup = [currentGroups objectAtIndex:indexPath.row];
        
        [self performSegueWithIdentifier:@"view group" sender:self];
    }
    

}



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
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 450;
//}


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
