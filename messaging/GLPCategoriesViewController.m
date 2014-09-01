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
#import "GLPiOS6Helper.h"
#import "SKBounceAnimation.h"

@interface GLPCategoriesViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) NSMutableDictionary *categoriesImages;
@property (strong, nonatomic) NSMutableDictionary *categoriesSelectedImages;
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (strong, nonatomic) GLPCategory *selectedCategory;
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
    

//    [self.backgroundView setImage:[self.screenshot stackBlur:3.0f]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self hideNetworkErrorViewIfNeeded];
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
    if([GLPiOS6Helper isIOS6])
    {
        [_topImageView setBackgroundColor:[UIColor clearColor]];
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
    
    NSArray *catTemp = [[CategoryManager instance] getCategories];
    
    
    for(GLPCategory *category in catTemp)
    {
        //TODO: For now remove the Other category.
        if(![category.name isEqualToString:@"Other"])
        {
            DDLogDebug(@"Category: %@", category);
            [_categories addObject:category];
        }
    
    }
    
    [_categories addObject:[[GLPCategory alloc] initWithTag:@"no" name:@"All" andPostRemoteKey:0]];
    
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
    
    if([selectedCategory.tag isEqualToString:@"no"])
    {
        [[SessionManager sharedInstance] setCurrentCategory:nil];
    }
    else
    {
        [[SessionManager sharedInstance] setCurrentCategory:[_categories objectAtIndex:indexPath.row]];
    }
    
    [self informCampusLiveWithCategory:selectedCategory];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.delegate refreshPostsWithNewCategory];

    
//    NSString *keyPath = @"position.y";
//    id finalValue = [NSNumber numberWithFloat:0];
//    
//    SKBounceAnimation *bounceAnimation = [SKBounceAnimation animationWithKeyPath:keyPath];
//    bounceAnimation.fromValue = [NSNumber numberWithFloat:self.view.center.x];
//    bounceAnimation.toValue = finalValue;
//    bounceAnimation.duration = 3.5f;
//    bounceAnimation.numberOfBounces = 4;
//    bounceAnimation.stiffness = SKBounceAnimationStiffnessLight;
//    bounceAnimation.shouldOvershoot = YES;
//    
//    [self.view.layer addAnimation:bounceAnimation forKey:@"someKey"];
//    
//    [self.view.layer setValue:finalValue forKeyPath:keyPath];

    
    [self hideViewController:nil];
    
    

    
//    [UIView animateWithDuration:1.0 animations:^{
//        
//        //Inform campus wall that
//        [self.delegate refreshPostsWithNewCategory];
//        self.view.alpha = 0;
//        
//    } completion:^(BOOL b){
//        
//        [self dismissViewControllerAnimated:NO completion:^{
//        }];
//    }];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
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
        NSString *str = [NSString stringWithFormat:@"%@_category.png",category.tag];
        
        UIImage *img = [UIImage imageNamed:str];
        
        [_categoriesImages setObject:img forKey:category.tag];
    }
    
//    [_categoriesImages setObject:[UIImage imageNamed:@"all_category"] forKey:@"All"];
    
    
    GLPCategory *current = [SessionManager sharedInstance].currentCategory;
    
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
            if([cat.tag isEqualToString:@"no"])
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
    
    
    [UIView animateWithDuration:0.1 animations:firstAnimation
     
                     completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:1 animations:secondAnimation completion:^(BOOL finished) {
                             
                             
                             //            [UIView animateWithDuration:0.5 animations:thirdAnimation];
                             
                             [self dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
                         
                     }];
    
    
//    [UIView animateWithDuration:0.25 animations:^{
//        
//        self.view.alpha = 0;
//        
//    } completion:^(BOOL b){
//        
//        //        self.view.alpha = 1;
//        [self dismissViewControllerAnimated:NO completion:^{
//        }];
//    }];
}


@end
