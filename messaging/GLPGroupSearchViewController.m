//
//  GLPGroupSearchViewController.m
//  Gleepost
//
//  Created by Silouanos on 17/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPGroupSearchViewController.h"
#import "UINavigationBar+Format.h"
#import "UINavigationBar+Utils.h"
#import "SearchGroupCell.h"
#import "GLPSearchBar.h"
#import "WebClient.h"
#import "GroupViewController.h"
#import "GLPPrivateGroupPopUpViewController.h"
#import "TDPopUpAfterGoingView.h"

@interface GLPGroupSearchViewController () <GLPSearchBarDelegate, GroupViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *searchBarView;

@property (strong, nonatomic) NSArray *searchedGroups;

@property (strong, nonatomic) GLPSearchBar *glpSearchBar;

@property (strong, nonatomic) GLPGroup *selectedGroup;

@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

@property (strong, nonatomic) TDPopUpAfterGoingView *privateGroupPopUp;

@property (assign, nonatomic) BOOL keyboardShouldShow;

@property (assign, nonatomic) BOOL readyToDismissViewController;

@end

@implementation GLPGroupSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initialiseObjects];
    
    [self configureNavigationBar];
    
    [self configureTableView];
    
    [self registerTableViewCells];
    
    [self configureSearchBar];

    [self configureNotifications];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_glpSearchBar becomeTextFieldFirstResponder];
    
    if(_readyToDismissViewController)
    {
        [self dismissModalView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)configureTableView
{
    [self.tableView setTableFooterView:[[UIView alloc] init]];
    
    [self registerTableViewCells];
}

- (void)registerTableViewCells
{
    [_tableView registerNib:[UINib nibWithNibName:@"SearchGroupCell" bundle:nil] forCellReuseIdentifier:@"SearchGroupCell"];
}

- (void)initialiseObjects
{
    _privateGroupPopUp = [[TDPopUpAfterGoingView alloc] init];
    _keyboardShouldShow = YES;
}

- (void)configureNavigationBar
{
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:NO];
    [self.navigationController.navigationBar setFontFormatWithColour:kBlack];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    [self.navigationController.navigationBar setButton:kLeft withImage:@"cancel" withButtonSize:CGSizeMake(19, 21) withSelector:@selector(dismissModalView) withTarget:self andNavigationItem:_navItem];
}

- (void)configureSearchBar
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"GLPSearchBar" owner:self options:nil];
    
    GLPSearchBar *view = [array lastObject];
    [view setDelegate:self];
    
    [view setPlaceholderWithText:@"Search Campus Directory"];
    
    view.tag = 101;
    
    _glpSearchBar = view;
    
    [_searchBarView addSubview:view];
}

- (void)configureNotifications
{
    // keyboard management
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

#pragma mark - Selectors

- (void)dismissModalView
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma  mark - GLPSearchBarDelegate

- (void)glpSearchBarDidBeginEditing:(UITextField *)textField
{
    DDLogDebug(@"glpSearchBarDidBeginEditing %@", textField.text);
}

- (void)glpSearchBarDidEndEditing:(UITextField *)textField
{
    DDLogDebug(@"glpSearchBarDidEndEditing %@", textField.text);
}

- (void)textChanged:(NSString *)text
{
    DDLogDebug(@"textChanged %@", text);
    
    [self searchForGroupWithName:text];
}

#pragma mark - GroupViewControllerDelegate

- (void)dismissTheWholeViewController
{
//    [self dismissViewControllerAnimated:YES completion:nil];
    
    _readyToDismissViewController = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _searchedGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchGroupCell";
    
    SearchGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell setGroupData:_searchedGroups[indexPath.row]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedGroup = _searchedGroups[indexPath.row];
    
    if(_selectedGroup.privacy == kPrivateGroup)
    {
        SearchGroupCell *cell = (SearchGroupCell *)[tableView cellForRowAtIndexPath:indexPath];

        [self showPrivatePopUpViewWithGroupImage:[cell groupImage]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    [self performSegueWithIdentifier:@"view group" sender:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLPGroup *group = _searchedGroups[indexPath.row];
    
    return [SearchGroupCell getCellHeightWithGroup:group];
}

#pragma mark - Client

- (void)searchForGroupWithName:(NSString *)groupName
{
    [_glpSearchBar startActivityIndicator];
    
    [[WebClient sharedInstance] searchGroupsWithName:groupName callback:^(BOOL success, NSArray *groups) {
      
        [_glpSearchBar stopActivityIndicator];
        
        if(![self isSearchedTextSameAsSearchBar:groupName])
        {
            //Don't do anything, the result is invalid.
            return;
        }

        if([self cleanTableViewIfNeeded])
        {
            return;
        }
        
       if(success)
       {
           _searchedGroups = groups;
           
           [self.tableView reloadData];
       }
    }];
}

#pragma mark - Helpers

/**
 Cleans the table view if the text field is empty.
 
 @return YES if is needed, otherwise NO.
 */
- (BOOL)cleanTableViewIfNeeded
{
    if([_glpSearchBar isTextFieldEmpty])
    {
        _searchedGroups = [[NSArray alloc] init];
        
        [self.tableView reloadData];
        
        return YES;
    }
    
    return NO;
}

/**
 Checks if the text the web client just searched is the same in search bar.
 There are some situations where the text is not requested any more from user,
 and the method in the WebClient still executing. With this method we avoid
 such problems.
 
 @param searchedText
 
 @param returns NO is the search bar is not equal with the text in search bar,
        otherwise returns YES.
 
 */
- (BOOL)isSearchedTextSameAsSearchBar:(NSString *)searchedText
{
    if([searchedText isEqualToString:[_glpSearchBar currentText]])
    {
        return YES;
    }
    
    DDLogDebug(@"Not equal should return.");
    
    return NO;
}

#pragma mark - form management

- (void)keyboardWillShow:(NSNotification *)note{
    
    if(!_keyboardShouldShow)
    {
        return;
    }
    
    _keyboardShouldShow = NO;
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curve.intValue;
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.height -= keyboardBounds.size.height;
    
    DDLogDebug(@"Keyboard will show table view new height %f, keboard height %f", tableViewFrame.size.height, keyboardBounds.size.height);
    
    [UIView animateWithDuration:[duration doubleValue] delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|(animationCurve << 16)) animations:^{
        
        self.tableView.frame = tableViewFrame;
        
    } completion:^(BOOL finished) {
        
        [self.tableView setNeedsLayout];
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)showPrivatePopUpViewWithGroupImage:(UIImage *)image
{
    //Show the pop up view.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    GLPPrivateGroupPopUpViewController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"GLPPrivateGroupPopUpViewController"];
    
    [cvc setGroupImage:image];
    
    cvc.modalPresentationStyle = UIModalPresentationCustom;
    
    [cvc setTransitioningDelegate:self.privateGroupPopUp];
    
    [self presentViewController:cvc animated:YES completion:nil];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"view group"])
    {
        GroupViewController *gvc = segue.destinationViewController;
        
        gvc.group = self.selectedGroup;
        gvc.delegate = self;
    }

}


@end
