//
//  GLPSelectUsersViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 30/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This class is used for just as a parent class of View Controllers that have
//  the functionality of selecting users.
//  This class is used ONLY as a super class.

//  Current children classes: GLPInviteUsersViewController, NewGroupMessageViewController.


#import "GLPSelectUsersViewController.h"
#import "UINavigationBar+Format.h"
#import "GLPUser.h"
#import "SessionManager.h"
#import "NSString+Utils.h"
#import "WebClient.h"

@interface GLPSelectUsersViewController ()


@end

@implementation GLPSelectUsersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureSearchBar];
}

- (void)initialiseObjects
{    
    _searchedUsers = [[NSMutableArray alloc] init];
    _checkedUsers = [[NSMutableArray alloc] init];
    
    if(!_alreadyMembers)
    {
        _alreadyMembers = [[NSArray alloc] init];
    }
    
    _selectedUsersVisible = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
    
    [_glpSearchBar becomeTextFieldFirstResponder];

}

- (void)configureNavigationBar
{
//    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:NO];
    [self.navigationController.navigationBar setFontFormatWithColour:kBlack];
}

#pragma mark - Helpers

- (BOOL)isUserSelected:(GLPUser *)user
{
    for(GLPUser *u in _checkedUsers)
    {
        if(u.remoteKey == user.remoteKey)
        {
            return YES;
        }
    }
    
    return NO;
}

- (NSInteger)removeUser:(GLPUser *)user
{
    int removeIndex = 0;
    
    for(int i = 0; i < _checkedUsers.count; ++i)
    {
        GLPUser *u = _checkedUsers[i];
        
        if(u.remoteKey == user.remoteKey)
        {
            removeIndex = i;
            
            break;
        }
    }
    

    [_checkedUsers removeObjectAtIndex:removeIndex];
    
    return removeIndex;
}

//TODO: DEPRECATED.
- (BOOL)isCurrentUserFoundWithUsers:(NSArray *)users
{
    NSArray *arrayResult = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"remoteKey = %d", [SessionManager sharedInstance].user.remoteKey]];
    
    return (arrayResult.count == 1) ? YES : NO;
}

/**
 Removes the logged in user from the users array if logged in user exist.
 This method also works when in the users list are more than one user, logged in user included.
 
 @param users the searched users.
 @return the filtered users.
 
 */
- (NSArray *)removeCurrentUserIfExistInUsers:(NSArray *)users
{
    NSArray *arrayResult = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"remoteKey = %d", [SessionManager sharedInstance].user.remoteKey]];
    
    if(arrayResult.count == 0)
    {
        //User don't exist in the user's list.
        return users;
    }
 
    return [self removeCurrentUserFromUsers:users];
}

- (NSArray *)removeCurrentUserFromUsers:(NSArray *)users
{
    NSArray *arrayResult = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"remoteKey != %d", [SessionManager sharedInstance].user.remoteKey]];
    
    return arrayResult;
}

- (NSArray *)getCheckedUsersRemoteKeys
{
    NSMutableArray *remoteKeys = [[NSMutableArray alloc] init];
    
    for(GLPUser *user in _checkedUsers)
    {
        [remoteKeys addObject:[NSNumber numberWithInteger:user.remoteKey]];
    }
    
    return remoteKeys.mutableCopy;
}

- (NSArray *)filterUsersWithFoundUsers:(NSArray *)foundUsers
{
    NSMutableArray *finalUsers = foundUsers.mutableCopy;
    
    for(int i = 0; i<foundUsers.count; ++i)
    {
        for(int j = 0; j<_alreadyMembers.count; ++j)
        {
            GLPUser *fUser = [foundUsers objectAtIndex:i];
            
            GLPUser *allUser = [_alreadyMembers objectAtIndex:j];
            
            if(fUser.remoteKey == allUser.remoteKey)
            {
                [finalUsers removeObjectAtIndex:i];
            }
        }
    }
    
    return finalUsers;
}

- (void)userSelected
{
    [_glpSearchBar addEmptyText];
    
    _selectedUsersVisible = YES;
    
    [_searchedUsers removeAllObjects];
    
    [_delegate reloadTableView];
}

#pragma mark - GLPSearchBarDelegate

- (void)textChanged:(NSString *)searchText
{
    //IMPORTANT: A synchronized block added in order to avoid multible access from different threads
    //on the same data structure.
    
    @synchronized(_searchedUsers)
    {
        // remove all data that belongs to previous search
        
        [_searchedUsers removeAllObjects];
    }
    

    
    //If searchText is empty then just reload table view.
    if(![searchText isNotBlank])
    {
        //All selected users should be visible.
        _selectedUsersVisible = YES;

        [_delegate reloadTableView];
        
        return;
    }

    _selectedUsersVisible = NO;

    
    [self searchUserWithName:searchText];
}

#pragma mark - Search users

- (void)searchUserWithName:(NSString *)userName
{
    
    if(![userName isNotBlank]) {
        return;
    }
    
    DDLogInfo(@"Start user search");
    [_glpSearchBar startActivityIndicator];
    
    [[WebClient sharedInstance] searchUserByName:userName callback:^(NSArray *users) {
        
        [_glpSearchBar stopActivityIndicator];

        
        if(!users) {
            return;
        }
        
        
//        if([self isCurrentUserFoundWithUsers:users])
//        {
//            return;
//        }
        
        users = [self removeCurrentUserIfExistInUsers:users];
        
        users = [self filterUsersWithFoundUsers:users];
        
        if(users.count == 0)
        {
            return;
        }
        
        DDLogDebug(@"Users after filtering: %@", users);
        
        DDLogInfo(@"Search users by name count: %lu", (unsigned long)users.count);
        
    
        _searchedUsers = [users mutableCopy];
        
        [_delegate reloadTableView];
    }];
}

- (void)resignFirstResponderOfGlpSearchBar
{
    [_glpSearchBar resignTextFieldFirstResponder];
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
