//
//  GLPTestViewController.m
//  Gleepost
//
//  Created by Lukas on 10/21/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPTestViewController.h"
#import "GLPTestCell.h"
#import "UIImageView+JMImageCache.h"

@interface GLPTestViewController ()

@property (strong, nonatomic) NSArray *test;

@end

@implementation GLPTestViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.test = [NSArray arrayWithObjects:@"https://gleepost.com/uploads/7911970371089d6d59a8a056fe6580a0.jpg", @"https://gleepost.com/uploads/3cdcbfbb3646709450d0fb25132ba681.jpg",@"https://gleepost.com/uploads/7911970371089d6d59a8a056fe6580a0.jpg", @"https://gleepost.com/uploads/3cdcbfbb3646709450d0fb25132ba681.jpg",@"https://gleepost.com/uploads/7911970371089d6d59a8a056fe6580a0.jpg", @"https://gleepost.com/uploads/3cdcbfbb3646709450d0fb25132ba681.jpg", @"https://gleepost.com/uploads/7911970371089d6d59a8a056fe6580a0.jpg", @"https://gleepost.com/uploads/3cdcbfbb3646709450d0fb25132ba681.jpg",@"https://gleepost.com/uploads/7911970371089d6d59a8a056fe6580a0.jpg", @"https://gleepost.com/uploads/3cdcbfbb3646709450d0fb25132ba681.jpg",@"https://gleepost.com/uploads/7911970371089d6d59a8a056fe6580a0.jpg", @"https://gleepost.com/uploads/3cdcbfbb3646709450d0fb25132ba681.jpg", nil];
    

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.test.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    GLPTestCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:self.test[indexPath.row]] placeholder:[UIImage imageNamed:@"default_user_image"]];
    
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 300;
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
