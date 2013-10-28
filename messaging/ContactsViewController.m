//
//  ContactsViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 20/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ContactsViewController.h"
#import "ContactUserCell.h"
#import "ProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WebClient.h"
#import "SessionManager.h"
#import "WebClientHelper.h"
#import "GLPContact.h"


@interface ContactsViewController ()

@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic) NSMutableArray *usersStr;
@property (strong, nonatomic) NSMutableDictionary *categorisedUsers;
@property (strong, nonatomic) IBOutlet UITableView *contactsTableView;
@property (strong, nonatomic) NSArray *panelSections;

@end

@implementation ContactsViewController

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Init categorised users dictionary.
    self.categorisedUsers = [[NSMutableDictionary alloc] init];
    NSLog(@"Contacts View Controller : viewDidLoad");

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Add samples users.
    self.users = [[NSMutableArray alloc] init];
    self.usersStr = [[NSMutableArray alloc] init];
//    [self.users addObject:@"TestUser1"];
//    [self.users addObject:@"SampleUser1"];
//    [self.users addObject:@"TestUser2"];

    
    //self.navigationController.navigationBar = bar;
    
    //Change the format of the navigation bar.
    [self.navigationController.navigationBar setTranslucent:YES];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar2"] forBarMetrics:UIBarMetricsDefault];
    
    //self.sections = [NSMutableArray arrayWithObjects: @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", nil];
    
    self.panelSections = [NSMutableArray arrayWithObjects: @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", nil];
    
    
    

    
    [self loadContacts];

}

-(void) clearUselessSections
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
            //NSLog(@"PREVIOUS USER NAME: %@ With letter: %@",userName, letter);
            
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
            //NSLog(@"PREVIOUS USER NAME: %@ With letter: %@",userName, letter);
            
            if([firstLetter caseInsensitiveCompare:letter] == NSOrderedSame)
            {
                sectionFound = YES;
                NSLog(@"USER NAME: %@ With letter: %@",userName, letter);
                
                //Check if the dictonary has previous elements in the current key.
                NSMutableArray *currentUsers = [self.categorisedUsers objectForKey:[NSNumber numberWithInt:indexOfLetter]];
                
                if(currentUsers == nil)
                {
                    currentUsers = [[NSMutableArray alloc] init];
                    [currentUsers addObject:userName];
                }
                else
                {
                    //Add the user to the existing section.
                    [currentUsers addObject:userName];
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
    NSLog(@"SECTIONS ARRAY: %@", self.sections);
    
    NSLog(@"Dictionary: %@",[self categorisedUsers]);
}

/**
 Find the confirmed contacts and add them to the user's array in order to push them to contacts' table view.
 
 @param contactsFromServer 
                            contacts from server.
 
 */
-(void)findConfirmedContacts:(NSArray*) contactsFromServer
{
    //Created for test purposes.
//    GLPContact* c = [[GLPContact alloc] initWithUserName:@"Test" profileImage:@"" youConfirmed:YES andTheyConfirmed:YES];
//    [self.users addObject:c];
//    [self.usersStr addObject:c.user.name];
    for(GLPContact* contact in contactsFromServer)
    {
        if(contact.theyConfirmed)
        {
            [self.users addObject:contact];
            [self.usersStr addObject:contact.user.name];
        }
    }
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) navigateToProfileContact: (id)sender
{
    NSLog(@"Navigate to profile.");
    [self performSegueWithIdentifier:@"view profile" sender:self];

}

#pragma mark - Client methods

-(void) loadContacts
{
    [WebClientHelper showStandardLoaderWithTitle:@"Loading posts" forView:self.view];

    
    [[WebClient sharedInstance ] getContactsWithCallbackBlock:^(BOOL success, NSArray *contacts) {
      
        [WebClientHelper hideStandardLoaderForView:self.view];
        
        
        if(success)
        {
            //Store contacts into an array.
            NSLog(@"Contacts loaded successfully.");
            
            [self findConfirmedContacts:contacts.mutableCopy];
            
            if(self.users.count>0)
            {
                self.sections = [NSMutableArray arrayWithObjects: @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", nil];
                [self clearUselessSections];

                [self categoriseUsersByLetter];
                [self.contactsTableView reloadData];
            }
            
//            self.users = contacts.mutableCopy;
            
        }
        else
        {
            [WebClientHelper showStandardError];
        }

        
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.sections.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.panelSections;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index
{
    NSLog(@"Index: %d",index);
    
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sections objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    NSArray *sectionArray = [self.usersStr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [self.sections objectAtIndex:section]]];
    
    NSLog(@"Current Section: %d",[sectionArray count]);
    return [sectionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ContactCell";
    ContactUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
//    if (cell == nil)
//    {
		//cell = [[ContactUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//	}
    
    
    //cell = [[ContactUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    //[cell test];
    
    //PostCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    //[cell createElements];
    
    //[cell.nameUser setText: [self.users objectAtIndex:indexPath.row]];
    //NSMutableArray *currentUsers = [self.categorisedUsers objectAtIndex:indexPath.row];
    
    NSArray *currentUsers = [self.categorisedUsers objectForKey:[NSNumber numberWithInt: indexPath.section]];
    NSLog(@"CATEGORISED USERS: %@", self.categorisedUsers);
    
    NSLog(@"Index Path Section: %d with row: %d", indexPath.section, indexPath.row);
    
    [cell.nameUser setText: [currentUsers objectAtIndex:indexPath.row]];

    
 //   [cell.profileImageUser setImage:[UIImage imageNamed:@"avatar_big"]];
    
    cell.profileImageUser.clipsToBounds = YES;
    
    cell.profileImageUser.layer.cornerRadius = 20;
    
    [cell.profileImageUser setImage:[UIImage imageNamed:@"default_user_image"]];
    
    
    
//    [cell.profileImageUser setBackgroundImage:[UIImage imageNamed:@"avatar_big"] forState:UIControlStateNormal];
//    
//    [cell.profileImageUser addTarget:self action:@selector(navigateToProfileContact:) forControlEvents:UIControlEventTouchUpInside];

    
    
    NSLog(@"User Name: %@ Index path: %d Section: %d",cell.nameUser.text, indexPath.row, indexPath.section);
    
    
    
    
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
    
    //self.selectedPost = self.posts[indexPath.row];
    [self performSegueWithIdentifier:@"view profile" sender:self];
}

//Call this when there is a need to pass elements to the next controller.
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    //Hide tabbar.
//   // [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
//    
//    if([segue.identifier isEqualToString:@"view profile"])
//    {
//        
//        ProfileViewController *pvc = segue.destinationViewController;
//        //TODO: Pass any information to the ProfileViewController.
//        
//        
//    }
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 450;
//}


@end
