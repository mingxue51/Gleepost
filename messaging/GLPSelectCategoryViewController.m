//
//  GLPSelectCategoryViewController.m
//  Gleepost
//
//  Created by Silouanos on 27/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPSelectCategoryViewController.h"
#import "AppearanceHelper.h"
#import "ATNavigationCategories.h"
#import "GLPCategoryCell.h"
#import "SetEventInformationCell.h"
#import "CategoryManager.h"
#import "TableViewHelper.h"

@interface GLPSelectCategoryViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *categories;

@property (strong, nonatomic) NSMutableDictionary *categoriesImages;

@property (strong, nonatomic) GLPCategory *selectedCategory;

@property (assign, nonatomic, getter = isActionCellVisible) BOOL actionCellVisible;

@property (strong, nonatomic) NSIndexPath *actionCellIndexPath;

@end

@implementation GLPSelectCategoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationBar];
    
    [self registerCells];
    
    [self initialiseObjects];
    
    [self loadCategories];

}

-(void)registerCells
{
    [self.tableView registerNib:[UINib nibWithNibName:@"GLPCategoryCell" bundle:nil] forCellReuseIdentifier:kGLPCategoryCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"SetEventInformationCell" bundle:nil] forCellReuseIdentifier:kGLPSetInformationCell];
    
}

-(void)initialiseObjects
{
    _categories = [[NSMutableArray alloc] init];
    _categoriesImages = [[NSMutableDictionary alloc] init];
    _selectedCategory = nil;
    _actionCellIndexPath = nil;
    _actionCellVisible = NO;
}

-(void)configureNavigationBar
{
//    [self.navigationBar setBackgroundColor:[UIColor clearColor]];
    
    self.navigationBar.tag = 1;
    
    [AppearanceHelper setNavigationBarFontForNavigationBar:_navigationBar];

}

-(void)loadCategories
{
    NSArray *catTemp = [[CategoryManager instance] getCategories];
    
    for(GLPCategory *category in catTemp)
    {
        [_categories addObject:category];
    }
    
    [_categories addObject:[[GLPCategory alloc] initWithTag:@"all" name:@"All" andPostRemoteKey:0]];
    
    for(GLPCategory *category in _categories)
    {
        NSString *str = [NSString stringWithFormat:@"%@_category.png",category.tag];
        
        UIImage *img = [UIImage imageNamed:str];
        
        [_categoriesImages setObject:img forKey:category.tag];
    }
    
    [self.tableView reloadData];
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
    
    GLPCategory *category = _categories[indexPath.row];

    if([category.tag isEqualToString:@"action cell"])
    {
        SetEventInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:kGLPSetInformationCell forIndexPath:indexPath];
        
        [cell initialiseElements];
        
        return cell;
    }
    

    
    
    GLPCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:kGLPCategoryCell forIndexPath:indexPath];
    
    
    
    
    [cell updateCategory:category withImage:[_categoriesImages objectForKey:category.tag]];
    
    

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Depending on kind of notification navigate to the appropriate view.
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];

    if([self isActionCellVisible])
    {
        //Remove cell.
        _actionCellVisible = NO;
        
        [_categories removeObjectAtIndex:_actionCellIndexPath.row];
        
        [indexPaths addObject:_actionCellIndexPath];
        
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        //Add cell.
        
        [_categories insertObject:[[GLPCategory alloc] initWithTag:@"action cell" name:@"" andPostRemoteKey:0] atIndex:indexPath.row + 1];
        
        _actionCellIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
        
        _actionCellVisible = YES;
        
        [indexPaths addObject: _actionCellIndexPath];
        
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    }
    


}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if([self isActionCellVisible])
//    {
//        return 200.0f;
//    }
//    else
//    {
    
    GLPCategory *c = _categories[indexPath.row];
    
    if([c.tag isEqualToString:@"action cell"])
    {
        return INFORMATION_CELL_HEIGHT;
    }
    else
    {
        return 50.0f;
    }
    
//    }
}


#pragma mark - Selectors

- (IBAction)goBack:(id)sender
{
//    DDLogDebug(@"GO back!");
//    ATNavigationCategories *t = [self.transitioningDelegate animationControllerForDismissedController:self];
//    

    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
