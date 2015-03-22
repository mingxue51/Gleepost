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
#import "GLPSearchBar.h"
#import "WebClient.h"
#import "GroupViewController.h"
#import "GLPPrivateGroupPopUpViewController.h"
#import "TDPopUpAfterGoingView.h"
#import "GLPThemeManager.h"
#import "GLPLiveGroupManager.h"
#import "GLPGroupCell.h"

@interface GLPGroupSearchViewController () <GLPSearchBarDelegate, GroupViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *searchBarView;

@property (strong, nonatomic) GLPSearchBar *glpSearchBar;

@property (strong, nonatomic) TDPopUpAfterGoingView *privateGroupPopUp;

@property (assign, nonatomic) BOOL readyToDismissViewController;

@end

@implementation GLPGroupSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
            
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

- (void)initialiseObjects
{
    [super initialiseObjects];
    _privateGroupPopUp = [[TDPopUpAfterGoingView alloc] init];
}

- (void)configureTableView
{
    [super configureSearchGroupsTableView];
}

- (void)configureNavigationBar
{
    [super configureNavigationBar];
    [self.navigationController.navigationBar setButton:kLeft specialButton:kQuit withImage:@"cancel" withButtonSize:CGSizeMake(19, 21) withSelector:@selector(dismissModalView) withTarget:self andNavigationItem:self.navItem];
}

- (void)configureSearchBar
{
    [_searchBarView setAutoresizingMask:UIViewAutoresizingNone];

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newGroupsFetched:)
                                                 name:GLPNOTIFICATION_GROUPS_FECTHED_AFTER_QUERY
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_GROUPS_FECTHED_AFTER_QUERY object:nil];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLPGroup *selectedGroup = [super groupWithIndexPath:indexPath];
    
    if(selectedGroup.privacy == kPrivateGroup)
    {
        DDLogDebug(@"Group is private!");
        
        GLPGroupCell *cell = (GLPGroupCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        [self showPrivatePopUpViewWithGroupImage:[cell groupImage]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    [super navigateToGroup:selectedGroup];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ScrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    DDLogDebug(@"GLPGroupSearchViewController : scrollViewWillBeginDragging");
    
    [_glpSearchBar resignTextFieldFirstResponder];
}

#pragma mark - Client

- (void)searchForGroupWithName:(NSString *)groupName
{
    [_glpSearchBar startActivityIndicator];
    [[GLPLiveGroupManager sharedInstance] searchGroupsWithQuery:groupName];
}

#pragma mark - NSNotifications

- (void)newGroupsFetched:(NSNotification *)notification
{
    [_glpSearchBar stopActivityIndicator];
    
    NSArray *groups = notification.userInfo[@"groups"];
    BOOL success = [notification.userInfo[@"success"] boolValue];
    NSString *query = notification.userInfo[@"query"];
    
    if(![self isSearchedTextSameAsSearchBar:query])
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
        [super reloadTableViewWithGroups:groups];
    }
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
        [super reloadTableViewWithGroups:[[NSArray alloc] init]];
        
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)showPrivatePopUpViewWithGroupImage:(UIImage *)image
{
    //Show the pop up view.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone_ipad" bundle:nil];
    GLPPrivateGroupPopUpViewController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"GLPPrivateGroupPopUpViewController"];
    
    [cvc setGroupImage:image];
    
    cvc.modalPresentationStyle = UIModalPresentationCustom;
    
    [cvc setTransitioningDelegate:self.privateGroupPopUp];
    
    [self presentViewController:cvc animated:YES completion:nil];
}

@end
