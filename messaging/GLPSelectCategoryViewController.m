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
#import "PendingPost.h"
#import "WebClientHelper.h"

@interface GLPSelectCategoryViewController ()<SetEventInformationCellDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *categories;

@property (strong, nonatomic) NSMutableDictionary *categoriesImages;

@property (strong, nonatomic) GLPCategory *selectedCategory;

@property (assign, nonatomic, getter = isActionCellVisible) BOOL actionCellVisible;

@property (strong, nonatomic) NSIndexPath *actionCellIndexPath;

@property (assign, nonatomic, getter = isDatePickerVisible) BOOL datePickerVisible;

@property (strong, nonatomic) PendingPost *pendingPost;

@end

@implementation GLPSelectCategoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationBar];
    
    [self registerCells];
    
    [self initialiseObjects];
    
    [self loadCategories];
    
    [self initialiseNotifications];

}

//-(void)viewWillDisappear:(BOOL)animated
//{
//    [self unregisterNotifications];
//
//    
//    [self viewWillDisappear:animated];
//
//    
//}

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
    _datePickerVisible = NO;
    _pendingPost = [[PendingPost alloc] init];
}

-(void)configureNavigationBar
{
    self.navigationBar.tag = 1;

    [AppearanceHelper setNavigationBarFormatForNewPostViews:_navigationBar];
}

-(void)loadCategories
{
    NSArray *catTemp = [[CategoryManager instance] getCategories];
    
    for(GLPCategory *category in catTemp)
    {
        [_categories addObject:category];
    }
    
    [_categories addObject:[[GLPCategory alloc] initWithTag:@"no" name:@"No Category" andPostRemoteKey:0]];
    
    for(GLPCategory *category in _categories)
    {
        NSString *str = [NSString stringWithFormat:@"%@_category.png",category.tag];
        
        UIImage *img = [UIImage imageNamed:str];
        
        [_categoriesImages setObject:img forKey:category.tag];
    }
    
    [self.tableView reloadData];
}

-(void)initialiseNotifications
{
    // keyboard management
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)unregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
        
        [cell initialiseElementsWithDelegate:self withPendingPost:_pendingPost.copy];
//        [cell setHiddenToDatePicker:[self isDatePickerVisible]];
//        [cell initialiseElementsWithDelegate:self];
        
        return cell;
    }

    
    GLPCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:kGLPCategoryCell forIndexPath:indexPath];
    
    [cell updateCategory:category withImage:[_categoriesImages objectForKey:category.tag]];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    //If No category is selected then go back to the main new post view.
    if(indexPath.row == _categories.count-1)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        
        return;
    }
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];

    if([self isActionCellVisible])
    {
        //Remove cell.
        _actionCellVisible = NO;
        
        _datePickerVisible = NO;
        
        [_pendingPost resetFields];
        
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
    GLPCategory *c = _categories[indexPath.row];
    
    if([c.tag isEqualToString:@"action cell"] && ![self isDatePickerVisible])
    {
        return INFORMATION_CELL_HEIGHT;
    }
    else if ([c.tag isEqualToString:@"action cell"] && [self isDatePickerVisible])
    {
        return INFORMATION_DATE_PICKER_HEIGHT;
    }
    else
    {
        return 50.0f;
    }
}
#pragma mark - SetEventInformationCellDelegate

-(void)showDatePickerWithPendingPost:(PendingPost *)post withHiddenDatePicker:(BOOL)hidden
{
    _pendingPost = post;
    
    _datePickerVisible = !hidden;
    
    [self.tableView reloadRowsAtIndexPaths:@[_actionCellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}

-(void)datePickerUpdatedWithPendingPost:(PendingPost *)pendingPost
{
    _pendingPost = pendingPost;
}

-(void)eventTextViewUpdatedWithPendingPost:(PendingPost *)pendingPost
{
    _pendingPost = pendingPost;
}

#pragma mark - Selectors

- (IBAction)goBack:(id)sender
{
    [self unregisterNotifications];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)eventTitleDateDone:(id)sender
{
    if([self checkFields])
    {
        [self dismissViewControllerAnimated:YES completion:^{
           
            [_delegate eventPostReadyWith:_pendingPost.eventTitle andEventDate:_pendingPost.currentDate];
            
        }];
    }
}


#pragma mark - form management

- (void)keyboardWillShow:(NSNotification *)notification
{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curve.intValue;
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = CGRectMake(10.0f, 34.0f, 300.0f, 80.0f);
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
	CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.height = keyboardBounds.origin.y - self.tableView.frame.origin.y;
    
    [UIView animateWithDuration:[duration doubleValue] delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|(animationCurve << 16)) animations:^{
//        self.formView.frame = containerFrame;
        self.tableView.frame = tableViewFrame;

        
        [self.tableView setContentOffset:CGPointMake(0, 65.0f)];

        
    } completion:^(BOOL finished) {
        

        
        [self.tableView setNeedsLayout];
    }];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curve.intValue;
	
	// get a rect for the textView frame
	CGRect containerFrame = CGRectMake(10.0f, 34.0f, 300.0f, 80.0f);
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
	CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.height = 487.0f;
    
    [UIView animateWithDuration:[duration doubleValue] delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|(animationCurve << 16)) animations:^{
        self.tableView.frame = tableViewFrame;
        
    } completion:^(BOOL finished) {
        [self.tableView setNeedsLayout];
    }];
}

#pragma mark - Helper methods

-(BOOL)checkFields
{
    GLPPendingPostReady pendingPostStatus = [_pendingPost isPostReady];
    
    if(pendingPostStatus == kPostReady)
    {
        return YES;
    }
    else if (pendingPostStatus == kTitleMissing)
    {
        [WebClientHelper showStandardErrorWithTitle:@"Oops!" andContent:@"Please type event title to continue"];
        
        return NO;
    }
    else
    {
        [WebClientHelper showStandardErrorWithTitle:@"Oops!" andContent:@"Please select date of your event to continue"];
     
        return NO;
    }
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
