//
//  GLPEditingModePendingPosts.m
//  
//
//  Created by Silouanos on 09/12/14.

//  There is an instance of this class in GLPPendingPostsManager singleton in order to manage any posts are still
//  in editing mode.

#import "GLPEditingModePendingPosts.h"
#import "GLPPost.h"

@interface GLPEditingModePendingPosts ()

@property (strong, nonatomic) NSMutableArray *editingModePosts;

@end

@implementation GLPEditingModePendingPosts

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _editingModePosts = [[NSMutableArray alloc] init];
        
    }
    return self;
}

#pragma mark - Accessors

- (NSInteger)numberPostsInEditingMode
{
    return _editingModePosts.count;
}

- (NSMutableArray *)replacePostWithAnyPostIsEditingWithRemotePosts:(NSMutableArray *)remotePendingPosts
{
    
    DDLogDebug(@"Edited posts %@", _editingModePosts);
    
    if(_editingModePosts.count == 0)
    {
        return remotePendingPosts;
    }
    
    for(GLPPost *editPost in _editingModePosts)
    {
        for(NSUInteger index = 0; index < remotePendingPosts.count; ++index)
        {
            GLPPost *post = [remotePendingPosts objectAtIndex:index];
            
            if(editPost.remoteKey == post.remoteKey)
            {
                [remotePendingPosts replaceObjectAtIndex:index withObject:editPost];
            }
        }
    }
    
    DDLogDebug(@"Remote posts after %@", remotePendingPosts);

    
    return remotePendingPosts;
}

#pragma mark - Modifiers

- (void)addNewPost:(GLPPost *)post
{
    [_editingModePosts addObject:post];
}

- (void)removePost:(GLPPost *)post
{
    NSUInteger index = 0;
    
    for(index = 0; index < _editingModePosts.count; ++index)
    {
        GLPPost *p = [_editingModePosts objectAtIndex:index];
        
        if(p.remoteKey == post.remoteKey)
        {
            break;
        }
    }
    
    DDLogDebug(@"Index found %ld", index);
    
    [_editingModePosts removeObjectAtIndex:index];
}

@end
