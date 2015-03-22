//
//  GLPGPPostImageLoader.m
//  Gleepost
//
//  Created by Silouanos on 22/01/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPGPPostImageLoader.h"
#import "GLPGroup.h"

@implementation GLPGPPostImageLoader

@synthesize nsNotificationName = _nsNotificationName;

static GLPGPPostImageLoader *instance = nil;

+ (GLPGPPostImageLoader *)sharedInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[GLPGPPostImageLoader alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        _nsNotificationName = GLPNOTIFICATION_GROUP_IMAGE_LOADED;
    }
    
    return self;
}

- (void)addGroups:(NSArray *)groups
{
    NSArray *imageObjects = [self convertGroupsToImageObjects:[self imageGroups:groups]];
    [super addImageObjects:imageObjects];
}

- (NSArray *)convertGroupsToImageObjects:(NSArray *)groups
{
    NSMutableArray *imageObjects = [[NSMutableArray alloc] init];
    
    for(GLPGroup *group in groups)
    {
        [imageObjects addObject:[[ImageObject alloc] initWithRemoteKey:group.remoteKey andImageUrl:group.groupImageUrl]];
    }
    
    return imageObjects;
}

#pragma mark - Helpers

- (NSArray *)imageGroups:(NSArray *)groups
{
    return [groups filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"groupImageUrl != nil"]];
}

@end
