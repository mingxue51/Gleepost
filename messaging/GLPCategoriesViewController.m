//
//  GLPCategoriesViewController.m
//  Gleepost
//
//  Created by Silouanos on 22/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPCategoriesViewController.h"
#import "GLPCategoryCell.h"
#import "GLPCategory.h"
#import "SessionManager.h"

@interface GLPCategoriesViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *categories;

@end

@implementation GLPCategoriesViewController

@synthesize categories = _categories;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self loadCategories];
    
    [self configTableView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configTableView
{
    [self.tableView registerNib:[UINib nibWithNibName:@"GLPCategoryCell" bundle:nil] forCellReuseIdentifier:kGLPCategoryCell];
}

-(void)loadCategories
{
    _categories = [[NSArray alloc] initWithObjects:[[GLPCategory alloc] initWithTag:@"test" name:@"Test category" andPostRemoteKey:0], [[GLPCategory alloc] initWithTag:@"All" name:@"All the categories" andPostRemoteKey:0], nil];
    
    
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLPCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:kGLPCategoryCell forIndexPath:indexPath];
    
    
    GLPCategory *category = _categories[indexPath.row];
    

    
    [cell updateCategory:category];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    //Depending on kind of notification navigate to the appropriate view.
    
    GLPCategory *selectedCategory = [_categories objectAtIndex:indexPath.row];
    
    if([selectedCategory.tag isEqualToString:@"All"])
    {
        [[SessionManager sharedInstance] setCurrentCategory:nil];
    }
    else
    {
        [[SessionManager sharedInstance] setCurrentCategory:[_categories objectAtIndex:indexPath.row]];
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [UIView animateWithDuration:0.25 animations:^{
        
        //Inform campus wall that
        [self.delegate refreshPostsWithNewCategory];
        self.view.alpha = 0;
        
    } completion:^(BOOL b){
        
        [self dismissViewControllerAnimated:NO completion:^{
        }];
    }];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}


- (IBAction)hideViewController:(id)sender
{
    [UIView animateWithDuration:0.25 animations:^{
        
        self.view.alpha = 0;
        
    } completion:^(BOOL b){
        
        //        self.view.alpha = 1;
        [self dismissViewControllerAnimated:NO completion:^{
        }];
    }];
}


@end
