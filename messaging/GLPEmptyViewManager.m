//
//  GLPEmptyView.m
//  Gleepost
//
//  Created by Silouanos on 23/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This class manages all view that should be presented when a content in a view controller is empty.
//  (like when Messenger is empty - there are no conversations yet etc).
//  TODO: Delete this class when the empty views are implemented.

#import "GLPEmptyViewManager.h"
#import "GLPMessengerEmptyView.h"
#import "GLPGroupsEmptyView.h"
#import "GLPProfilePostsEmptyView.h"

@interface GLPEmptyViewManager ()

@property (strong, nonatomic) GLPMessengerEmptyView *messengerEmptyView;
@property (strong, nonatomic) GLPGroupsEmptyView *groupsEmptyView;
@property (strong, nonatomic) GLPProfilePostsEmptyView *profilePostsEmptyView;

@end

static GLPEmptyViewManager *instance = nil;

@implementation GLPEmptyViewManager

+ (GLPEmptyViewManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        instance = [[GLPEmptyViewManager alloc] init];
        
    });
    
    return instance;
}

- (UIView *)addEmptyViewWithKindOfView:(EmptyViewKind)emptyViewKind withView:(UIView *)view
{
    switch (emptyViewKind)
    {
        case kMessengerEmptyView:
            return [self generateMessengerEmptyViewWithView:view];
            break;
            
        case kGroupsEmptyView:
            return [self generateGroupsEmptyViewWithView:view];
            break;
            
        case kProfilePostsEmptyView:
            return [self generatePostsEmptyViewWithView:view];
            return nil;
            break;
            
        default:
            return nil;
            break;
    }
}

/**
 This method, basically, destroys the view to preserve memory efficient.
 
 @param viewKind the kind of the view.
 
 */
- (void)hideViewWithKind:(EmptyViewKind)viewKind
{
    switch (viewKind)
    {
        case kMessengerEmptyView:
            if(_messengerEmptyView)
            {
                [_messengerEmptyView hideView];
                _messengerEmptyView = nil ;
            }
            break;
            
        case kGroupsEmptyView:
            if(_groupsEmptyView)
            {
                [_groupsEmptyView hideView];
                _groupsEmptyView = nil;
            }
            break;
            
        case kProfilePostsEmptyView:
            if(_profilePostsEmptyView)
            {
                [_profilePostsEmptyView hideView];
                _profilePostsEmptyView = nil;
            }
            break;
            
        default:
            break;
    }
}

- (UIView *)generateGroupsEmptyViewWithView:(UIView *)view
{
    if(_groupsEmptyView)
    {
        return _groupsEmptyView;
    }
    
    _groupsEmptyView = [[[NSBundle mainBundle] loadNibNamed:@"GLPGroupsEmptyView" owner:view options:nil] objectAtIndex:0];
    
    [view addSubview:_groupsEmptyView];
    
    return _groupsEmptyView;
    
}

- (UIView *)generateMessengerEmptyViewWithView:(UIView *)view
{
    if(_messengerEmptyView)
    {
        return _messengerEmptyView;
    }
    
    _messengerEmptyView = [[[NSBundle mainBundle] loadNibNamed:@"GLPMessengerEmptyView" owner:view options:nil] objectAtIndex:0];
    
    [view addSubview:_messengerEmptyView];
    
    return _messengerEmptyView;
}

- (UIView *)generatePostsEmptyViewWithView:(UIView *)view
{
    if(_profilePostsEmptyView)
    {
        return _profilePostsEmptyView;
    }
    
    _profilePostsEmptyView = [[[NSBundle mainBundle] loadNibNamed:@"GLPProfilePostsEmptyView" owner:view options:nil] objectAtIndex:0];
    
    [view addSubview:_profilePostsEmptyView];
    
    return _profilePostsEmptyView;
}

@end
