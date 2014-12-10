//
//  GLPEditingModePendingPosts.h
//  
//
//  Created by Silouanos on 09/12/14.
//


#import <Foundation/Foundation.h>
@class GLPPost;

@interface GLPEditingModePendingPosts : NSObject

- (NSInteger)numberPostsInEditingMode;
- (void)addNewPost:(GLPPost *)post;
- (void)removePost:(GLPPost *)post;
- (NSMutableArray *)replacePostWithAnyPostIsEditingWithRemotePosts:(NSMutableArray *)remotePendingPosts;

@end
