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
#import "CategoryManager.h"
#import "UIImage+StackBlur.h"

@interface GLPCategoriesViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) NSMutableDictionary *categoriesImages;
@property (strong, nonatomic) NSMutableDictionary *categoriesSelectedImages;

@end

@implementation GLPCategoriesViewController

@synthesize categories = _categories;
@synthesize categoriesImages = _categoriesImages;

- (void)viewDidLoad
{
    [super viewDidLoad];
	

    
    
    [self loadCategories];
    
    [self configTableView];
    

    
//    [self.backgroundView setImage:[self.screenshot stackBlur:3.0f]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configTableView
{
    [self.tableView registerNib:[UINib nibWithNibName:@"GLPCategoryCell" bundle:nil] forCellReuseIdentifier:kGLPCategoryCell];
    
//    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"category_bg.png"]]];
    
    [self.tableView reloadData];
}

-(void)loadCategories
{
//    _categories = [[NSArray alloc] initWithObjects:[[GLPCategory alloc] initWithTag:@"test" name:@"Test category" andPostRemoteKey:0], [[GLPCategory alloc] initWithTag:@"All" name:@"All the categories" andPostRemoteKey:0], nil];
    
    _categoriesImages = [[NSMutableDictionary alloc] init];
    _categories = [NSMutableArray array];
    
//    [_categoriesImages setObject:[UIImage imageNamed:@"events_category"] forKey:@"test"];
//    [_categoriesImages setObject:[UIImage imageNamed:@"all_category"] forKey:@"All"];
    
    NSArray *catTemp = [[CategoryManager instance] getCategories];
    
    for(GLPCategory *category in catTemp)
    {
        //TODO: Remove condition when final categories decided.
        
        if([category.tag isEqualToString:@"event"] || [category.tag isEqualToString:@"for-sale"] || [category.tag isEqualToString:@"news"] || [category.tag isEqualToString:@"sports"] || [category.tag isEqualToString:@"jobs"])
        {
            [_categories addObject:category];
        }
    }
    
    [_categories addObject:[[GLPCategory alloc] initWithTag:@"All" name:@"All the categories" andPostRemoteKey:0]];
    
    [self setDefaultImages];

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
    

    
    [cell updateCategory:category withImage:[_categoriesImages objectForKey:category.tag]];
    
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


#pragma mark - Helper methods

-(void)setDefaultImages
{
    for(GLPCategory *category in _categories)
    {
        if([category.tag isEqualToString:@"event"] || [category.tag isEqualToString:@"for-sale"] || [category.tag isEqualToString:@"news"] || [category.tag isEqualToString:@"sports"] || [category.tag isEqualToString:@"jobs"])
        {
            NSString *str = [NSString stringWithFormat:@"%@_category.png",category.tag];
            
            UIImage *img = [UIImage imageNamed:str];
            
            [_categoriesImages setObject:img forKey:category.tag];
        }
//        else
//        {
//            
//            
//            [_categoriesImages setObject:[UIImage imageNamed:@"extra_category"] forKey:category.tag];
//        }
    }
    
    [_categoriesImages setObject:[UIImage imageNamed:@"all_category"] forKey:@"All"];
    
    
    GLPCategory *current = [SessionManager sharedInstance].currentCategory;
    
    //Set selected category image.
    if(current == nil)
    {
        [_categoriesImages setObject:[UIImage imageNamed:@"all_category_selected"] forKey:@"All"];
    }
//    else if([current.tag isEqualToString:@"jobs"])
//    {
//        [_categoriesImages setObject:[UIImage imageNamed:[NSString stringWithFormat:@"extra_category_selected",current.tag]] forKey:current.tag];
//    }
    else
    {
        [_categoriesImages setObject:[UIImage imageNamed:[NSString stringWithFormat:@"%@_category_selected",current.tag]] forKey:current.tag];
    }
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
