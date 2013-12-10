//
//  GLPPrivateProfileViewController.m
//  Gleepost
//
//  Created by Silouanos on 09/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPPrivateProfileViewController.h"
#import "TransitionDelegateViewImage.h"
#import "ContactsManager.h"
#import "PostCell.h"
#import "ProfileAboutTableViewCell.h"
#import "ProfileTableViewCell.h"
#import "ProfileButtonsTableViewCell.h"
#import "ProfileMutualTableViewCell.h"
#import "WebClient.h"
#import "WebClientHelper.h"

@interface GLPPrivateProfileViewController ()

@property (assign, nonatomic) int numberOfRows;

@property (strong, nonatomic) GLPUser *profileUser;

@property (strong, nonatomic) TransitionDelegateViewImage *transitionViewImageController;

@end

@implementation GLPPrivateProfileViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        //Register the 5 cell table views.
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerTableViewCells];

    
    [self initialiseObjects];
    
    //If no, check in database if the user is already requested.
    
    //If yes change the button of add user to user already requested.
    
    if([[ContactsManager sharedInstance] isContactWithIdRequested:self.selectedUserId])
    {
        NSLog(@"PrivateProfileViewController : User already requested by you.");
        [self setContactAsRequested];
        
    }
    else if ([[ContactsManager sharedInstance]isContactWithIdRequestedYou:self.selectedUserId])
    {
        NSLog(@"PrivateProfileViewController : User requested you.");
        
        [self setAcceptRequestButton];
        
    }
    else
    {
        //If not show the private profile view as is.
        NSLog(@"PrivateProfileViewController : Private profile as is.");
    }
    
    self.navigationItem.title = @"User name";
    
    //Initialise rows with 3 because About cell is presented first.
    self.numberOfRows = 2;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Configuration


-(void)initialiseObjects
{
    //Load user's details from server.
    [self loadAndSetUserDetails];
    
    self.transitionViewImageController = [[TransitionDelegateViewImage alloc] init];
    
    [[ContactsManager sharedInstance] loadContactsFromDatabase];


}

-(void)registerTableViewCells
{
    //Register nib files in table view.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileViewTableViewCell" bundle:nil] forCellReuseIdentifier:@"ProfileCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileViewButtonsTableViewCell" bundle:nil] forCellReuseIdentifier:@"ButtonsCell"];
    
    //Register posts.
    [self.tableView registerNib:[UINib nibWithNibName:@"PostImageCellView" bundle:nil] forCellReuseIdentifier:@"ImageCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTextCellView" bundle:nil] forCellReuseIdentifier:@"TextCell"];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileViewAboutTableViewCell" bundle:nil] forCellReuseIdentifier:@"AboutCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileViewMutualTableViewCell" bundle:nil] forCellReuseIdentifier:@"MutualCell"];
}

#pragma mark - Client methods

-(void)loadAndSetUserDetails
{
    [[WebClient sharedInstance] getUserWithKey:self.selectedUserId callbackBlock:^(BOOL success, GLPUser *user) {
        
        if(success)
        {
            self.profileUser = user;
            
            [self.tableView reloadData];
        }
        else
        {
            [WebClientHelper showStandardError];
        }
    }];
}


#pragma mark - UI Changes

-(void)setContactAsRequested
{
    
}

-(void)setAcceptRequestButton
{
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierWithImage = @"ImageCell";
    static NSString *CellIdentifierWithoutImage = @"TextCell";
    static NSString *CellIdentifierProfile = @"ProfileCell";
    static NSString *CellIdentifierButtons = @"ButtonsCell";
    static NSString *CellIdentifierAbout = @"AboutCell";
    static NSString *CellIdentifierMutual = @"MutualCell";
    
    
    PostCell *postViewCell;
    
    ProfileButtonsTableViewCell *buttonsView;
    ProfileTableViewCell *profileView;
    
    NSLog(@"Index path row: %d",indexPath.row);
    
    if(indexPath.row == 0)
    {
        profileView = [tableView dequeueReusableCellWithIdentifier:CellIdentifierProfile forIndexPath:indexPath];
        
        [profileView initialiseElementsWithUserDetails:self.profileUser];
        profileView.selectionStyle = UITableViewCellSelectionStyleNone;

        return profileView;

    }
    else if (indexPath.row == 1)
    {
        buttonsView = [tableView dequeueReusableCellWithIdentifier:CellIdentifierButtons forIndexPath:indexPath];
        buttonsView.selectionStyle = UITableViewCellSelectionStyleNone;

        return buttonsView;
    }
    else if (indexPath.row == 2)
    {
        //See what to load.
        
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        return 320.0f;
    }
    else if(indexPath.row == 1)
    {
        return 50.0f;
    }
    
    return 50.0f;
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
