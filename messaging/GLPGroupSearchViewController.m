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

@interface GLPGroupSearchViewController () <GLPSearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *searchBarView;

@property (strong, nonatomic) NSArray *searchedGroups;

@property (strong, nonatomic) GLPSearchBar *glpSearchBar;

@property (strong, nonatomic) GLPGroup *selectedGroup;

@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

@end

@implementation GLPGroupSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationBar];
    
    [self registerTableViewCells];
    
    [self configureSearchBar];

}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogDebug(@"Table view height %f", _glpSearchBar.frame.origin.x);
    
    [super viewDidAppear:animated];
    
    [self configureNotifications];
    
    [_glpSearchBar becomeTextFieldFirstResponder];

    
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

- (void)dealloc
{
}

- (void)registerTableViewCells
{
    [_tableView registerNib:[UINib nibWithNibName:@"SearchGroupCell" bundle:nil] forCellReuseIdentifier:@"SearchGroupCell"];
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
    
    //    CGRectSetX(view, 10);
    
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
    
    [self performSegueWithIdentifier:@"view group" sender:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SEARCH_GROUP_CELL_HEIGHT;
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
    
    DDLogDebug(@"Keyboard will show");
    
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"view group"])
    {
        GroupViewController *gvc = segue.destinationViewController;
        
        gvc.group = self.selectedGroup;
    }

}


@end
