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
#import "GLPGroupPostsEmptyView.h"
#import "GLPiOSSupportHelper.h"
#import "ProfileTopViewCell.h"

@interface GLPEmptyViewManager ()

@property (strong, nonatomic) GLPMessengerEmptyView *messengerEmptyView;
@property (strong, nonatomic) GLPGroupsEmptyView *groupsEmptyView;
@property (strong, nonatomic) GLPProfilePostsEmptyView *profilePostsEmptyView;
@property (strong, nonatomic) GLPGroupPostsEmptyView *groupPostsEmptyView;

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
            break;
            
        case kGroupPostsEmptyView:
//            return [self generateGroupPostsEmptyView:view];
//            break;
            
        default:
            return nil;
            break;
    }
}

- (UIView *)addEmptyGroupPostViewWithView:(UIView *)view andStartingPosition:(float)position
{
    return [self generateGroupPostsEmptyView:view andYPosition:position];
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
            
        case kGroupPostsEmptyView:
            
            if(_groupPostsEmptyView)
            {
                [_groupPostsEmptyView hideView];
                _groupPostsEmptyView = nil;
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
    
    [view setAutoresizingMask:UIViewAutoresizingNone];

    _groupsEmptyView = [[[NSBundle mainBundle] loadNibNamed:@"GLPGroupsEmptyView" owner:view options:nil] objectAtIndex:0];
    
    CGRectSetY(_groupsEmptyView, -5.0);

    
    [view addSubview:_groupsEmptyView];
    
    return _groupsEmptyView;
    
}

- (UIView *)generateMessengerEmptyViewWithView:(UIView *)view
{
    if(_messengerEmptyView)
    {
        return _messengerEmptyView;
    }
    
    [view setAutoresizingMask:UIViewAutoresizingNone];

    _messengerEmptyView = [[[NSBundle mainBundle] loadNibNamed:@"GLPMessengerEmptyView" owner:view options:nil] objectAtIndex:0];
    
    CGRectSetW(_messengerEmptyView, [GLPiOSSupportHelper screenWidth]);
    CGRectSetH(_messengerEmptyView, [GLPiOSSupportHelper screenHeight]);
    
    [view addSubview:_messengerEmptyView];
    
    return _messengerEmptyView;
}

- (UIView *)generatePostsEmptyViewWithView:(UIView *)view
{
    if(_profilePostsEmptyView)
    {
        return _profilePostsEmptyView;
    }
    
    [view setAutoresizingMask:UIViewAutoresizingNone];

    
    _profilePostsEmptyView = [[[NSBundle mainBundle] loadNibNamed:@"GLPProfilePostsEmptyView" owner:view options:nil] objectAtIndex:0];
    
    CGRectSetW(_profilePostsEmptyView, [GLPiOSSupportHelper screenWidth]);
    CGRectSetH(_profilePostsEmptyView, [GLPiOSSupportHelper screenHeight]);
    CGRectSetY(_profilePostsEmptyView, [ProfileTopViewCell profileTopViewHeight]);
    
    [view addSubview:_profilePostsEmptyView];
    
    return _profilePostsEmptyView;
}

- (UIView *)generateGroupPostsEmptyView:(UIView *)view andYPosition:(float)yPosition
{
    if(_groupPostsEmptyView)
    {
        [view addSubview:_groupPostsEmptyView];
        return _groupPostsEmptyView;
    }
    
    _groupPostsEmptyView = [[[NSBundle mainBundle] loadNibNamed:@"GLPGroupPostsEmptyView" owner:view options:nil] objectAtIndex:0];
    [_groupPostsEmptyView setYPosition:yPosition];
    
    CGRectSetW(_groupPostsEmptyView, [GLPiOSSupportHelper screenWidth]);
    CGRectSetH(_groupPostsEmptyView, [GLPiOSSupportHelper screenHeight]);
    
    [view addSubview:_groupPostsEmptyView];
    
    return _groupPostsEmptyView;
}

@end