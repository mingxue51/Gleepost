//
//  GLPCategoriesViewController.m
//  Gleepost
//
//  Created by Silouanos on 22/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  TODO: This class is deprecated because we are using the new design with the new approach in GLPNewCategoriesViewController.
//  Delete that class and rename the new one with that name. Do the same thing in storyboard.

#import "GLPCategoriesViewController.h"
#import "GLPCategoryCell.h"
#import "GLPCategory.h"
#import "CategoryManager.h"
#import "UIImage+StackBlur.h"
#import "GLPiOSSupportHelper.h"
#import "SKBounceAnimation.h"

@interface GLPCategoriesViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) NSMutableDictionary *categoriesImages;
@property (strong, nonatomic) NSMutableDictionary *categoriesSelectedImages;
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (strong, nonatomic) GLPCategory *selectedCategory;

@property (nonatomic, retain) IBOutletCollection(NSLayoutConstraint) NSArray *tableViewsHeights;

@end

@implementation GLPCategoriesViewController

@synthesize categories = _categories;
@synthesize categoriesImages = _categoriesImages;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadCategories];
    [self configTableView];
    [self configAppearance];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self hideNetworkErrorViewIfNeeded];
    [self configureTableViewHeightDependingOnConstrains];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self showNetworkErrorViewIfNeeded];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configAppearance
{
    if([GLPiOSSupportHelper isIOS6])
    {
        [_topImageView setBackgroundColor:[UIColor clearColor]];
    }
}

- (void)configureTableViewHeightDependingOnConstrains
{
    CGFloat tableViewHeight = _categories.count * [GLPCategoryCell height] + [GLPCategoryCell bottomPadding];
    
    for(NSLayoutConstraint *constraint in self.tableViewsHeights)
    {
        constraint.constant = tableViewHeight;
    }
}

-(void)configTableView
{
    [self.tableView registerNib:[UINib nibWithNibName:@"GLPCategoryCell" bundle:nil] forCellReuseIdentifier:kGLPCategoryCell];
    
//    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"category_bg.png"]]];
    
    [self.tableView reloadData];
}

-(void)loadCategories
{
    self.selectedCategory = nil;
//    _categories = [[NSArray alloc] initWithObjects:[[GLPCategory alloc] initWithTag:@"test" name:@"Test category" andPostRemoteKey:0], [[GLPCategory alloc] initWithTag:@"All" name:@"All the categories" andPostRemoteKey:0], nil];
    
    _categoriesImages = [[NSMutableDictionary alloc] init];
    _categories = [NSMutableArray array];
    
//    [_categoriesImages setObject:[UIImage imageNamed:@"events_category"] forKey:@"test"];
//    [_categoriesImages setObject:[UIImage imageNamed:@"all_category"] forKey:@"All"];
    
    _categories = [[CategoryManager sharedInstance] getCategoriesForFilteringView];
    
//    for(GLPCategory *category in catTemp)
//    {
//        //Remove the Other category.
//        if(![category.name isEqualToString:@"Other"])
//        {
//            DDLogDebug(@"Category: %@", category);
//            [_categories addObject:category];
//        }
//    
//    }
    
//    [_categories addObject:[[GLPCategory alloc] initWithTag:@"other" name:@"All" andPostRemoteKey:0]];
    
    [self setDefaultImages];

}

- (void)hideNetworkErrorViewIfNeeded
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_HIDE_ERROR_VIEW object:self userInfo:nil];
}

- (void)showNetworkErrorViewIfNeeded
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_SHOW_ERROR_VIEW object:self userInfo:@{@"comingFromClass": [NSNumber numberWithBool:YES]}];
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
    
    if([selectedCategory.tag isEqualToString:@"all"])
    {
        [[CategoryManager sharedInstance] setSelectedCategory:nil];
    }
    else
    {
        [[CategoryManager sharedInstance] setSelectedCategory:[_categories objectAtIndex:indexPath.row]];
    }
    
    [self informCampusLiveWithCategory:selectedCategory];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.delegate refreshPostsWithNewCategory];

    [self hideViewController:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [GLPCategoryCell height];
}


#pragma mark - Post notifications

- (void)informCampusLiveWithCategory:(GLPCategory *)category
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_UPDATE_CATEGORY_LABEL object:nil userInfo:@{@"Category": category.name}];
}

#pragma mark - Helper methods

-(void)setDefaultImages
{
    for(GLPCategory *category in _categories)
    {
        NSString *str = [NSString stringWithFormat:@"kind_of_event_%@.png",category.tag];
        
        UIImage *img = [UIImage imageNamed:str];
        
        [_categoriesImages setObject:img forKey:category.tag];
    }
    
//    [_categoriesImages setObject:[UIImage imageNamed:@"all_category"] forKey:@"All"];
    
    
    GLPCategory *current = [[CategoryManager sharedInstance] selectedCategory];
    
    //Set selected category image.
    if(current == nil)
    {
//        [_categoriesImages setObject:[UIImage imageNamed:@"all_category_selected"] forKey:@"All"];
        _selectedCategory = nil;
    }
    else
    {
//        [_categoriesImages setObject:[UIImage imageNamed:[NSString stringWithFormat:@"%@_category_selected",current.tag]] forKey:current.tag];
        _selectedCategory = current;
    }
    

    
    for(GLPCategory *cat in _categories)
    {
        if(!_selectedCategory)
        {
            if([cat.tag isEqualToString:@"all"])
            {
                cat.uiSelected = YES;
            }
            else
            {
                cat.uiSelected = NO;
            }
        }
        else if([_selectedCategory.tag isEqualToString:cat.tag])
        {
            cat.uiSelected = YES;
            
        }
        else
        {
            cat.uiSelected = NO;
        }
    }
}

-(void)setImageToTopImage:(UIImage *)image
{
    [_topImageView setImage:image];
}

- (IBAction)hideViewController:(id)sender
{
    
    typedef void (^AnimationBlock)();
    
    
    AnimationBlock firstAnimation = ^{
        
        [self.view setCenter: CGPointMake(self.view.center.x, self.view.center.y+50)];
        
        
    };
    AnimationBlock secondAnimation = ^{
        
        [self.view setCenter: CGPointMake(self.view.center.x, self.view.center.y-950)];
        
        
    };
    
    [UIView animateWithDuration:0.1 animations:firstAnimation completion:^(BOOL finished) {
        
        [UIView animateWithDuration:1 animations:secondAnimation completion:^(BOOL finished) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }];
        
    }];
    
    
}


@end
