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

    
    DDLogDebug(@"Search bar view: %@ : %@", _searchBarView, _glpSearchBar);
}

- (void)configureNavigationBar
{
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:NO];
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

- (void)removeUser:(GLPUser *)user
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
}


- (BOOL)isCurrentUserFoundWithUsers:(NSArray *)users
{
    NSArray *arrayResult = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"remoteKey = %d", [SessionManager sharedInstance].user.remoteKey]];
    
    return (arrayResult.count == 1) ? YES : NO;
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

#pragma mark - GLPSearchBarDelegate

- (void)textChanged:(NSString *)searchText
{
    // remove all data that belongs to previous search
    
    [_searchedUsers removeAllObjects];
    
    if(![searchText isNotBlank])
    {
        [_delegate reloadTableView];
        
        return;
    }
    
    
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
        
        if([self isCurrentUserFoundWithUsers:users])
        {
            return;
        }
        
        users = [self filterUsersWithFoundUsers:users];
        
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
