//
//  PendingPostManager.m
//  Gleepost
//
//  Created by Σιλουανός on 14/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "PendingPostManager.h"
#import "GLPCategory.h"
#import "CategoryManager.h"
#import "GLPPost.h"
#import "GLPVideo.h"
#import "GLPLocation.h"

@interface PendingPostManager ()

@property (strong, nonatomic) NSDate *date;
/** There is an array here because in case of events we need to have 2 categories
    Event category & the selected category.
 */
@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) NSString *eventTitle;
@property (strong, nonatomic) NSString *eventDescription;
@property (strong, nonatomic) NSString *imageUrl;
@property (strong, nonatomic) NSString *videoUrl;
@property (assign, nonatomic) NSInteger pendingPostRemoteKey;
@property (strong, nonatomic) GLPLocation *location;
@property (assign, nonatomic) KindOfPost kindOfPost;
@property (assign, nonatomic, getter = arePendingData) BOOL pendingData;
@property (assign, nonatomic, getter = isGroupPost) BOOL groupPost;
@property (assign, nonatomic, getter=isEditMode) BOOL editMode;
@property (strong, nonatomic) GLPGroup *group;

@end

static PendingPostManager *instance = nil;

@implementation PendingPostManager

+ (PendingPostManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PendingPostManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        _categories = [[NSMutableArray alloc] init];
        _pendingData = NO;
        _editMode = NO;
        _eventDescription = @"";
        _eventTitle = @"";
    }
    
    return self;
}

#pragma mark - Modifiers

//- (void)setGroupPost:(BOOL)groupPost
//{
//    self.groupPost = groupPost;
//}

- (void)setDate:(NSDate *)date
{
    _pendingData = YES;

    _date = date;
}

- (void)setCategory:(GLPCategory *)category
{
    _pendingData = YES;
    
    DDLogDebug(@"Category added: %@", category.name);

    _categories = [[NSMutableArray alloc] initWithObjects:category, nil];
}

- (void)setEventTitle:(NSString *)title
{
    _pendingData = YES;

    _eventTitle = title;
}

- (void)setEventDescription:(NSString *)description
{
    _pendingData = YES;

    _eventDescription = description;
}

- (void)setKindOfPost:(KindOfPost)kindOfPost
{
    _pendingData = YES;

    _kindOfPost = kindOfPost;
}

/**
 This method is used when user wants to edit a pending post.
 It takes as parameter the pending post and sets all data to the 
 singleton where they applied.
 
 @param the pending post.
 
 */
- (void)setPendingPost:(GLPPost *)pendingPost
{
    _editMode = YES;
    
    [self findKindOfPendingPost:pendingPost];
    
    _eventTitle = pendingPost.eventTitle;
    _eventDescription = pendingPost.content;
    _categories = pendingPost.categories.mutableCopy;
    
    if(pendingPost.imagesUrls && pendingPost.imagesUrls.count > 0)
    {
        _imageUrl = pendingPost.imagesUrls[0];
    }
    
    if([pendingPost isVideoPost])
    {
        _videoUrl = pendingPost.video.url;
    }
    
    if([pendingPost location])
    {
        _location = pendingPost.location;
    }
    
    _pendingPostRemoteKey = pendingPost.remoteKey;
    _pendingData = YES;
}

- (void)findKindOfPendingPost:(GLPPost *)pendingPost
{
    if(pendingPost.eventTitle)
    {
        _kindOfPost = kEventPost;
    }
    else
    {
        _kindOfPost = kGeneralPost;
    }
}

- (void)reset
{
    instance = [[PendingPostManager alloc] init];
    
    DDLogDebug(@"PendingPostManager reseted: %@", [self description]);

}

- (void)readyToSend
{
    if(_categories.count == 1)
    {
        //An event post selected.
        [_categories addObject:[[CategoryManager sharedInstance] generateEventCategory]];
    }
    else
    {
        //It means that general post selected.
        [_categories removeAllObjects];
    }
    //TODO: When is supported by api we should include announcements.
    //      Maybe is a good idea to create a new category as such.
    
}

#pragma mark - Accessors

- (NSDate *)getDate
{
    return _date;
}

- (BOOL)isEventParty
{
    for(GLPCategory *category in self.categories)
    {
        if([category.tag isEqualToString:@"party"])
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isPostEvent
{
    return !(self.categories.count == 0);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Kind of post: %lu, Event type: %@, Title: %@, Description: %@, Date: %@", _kindOfPost, _categories, _eventTitle, _eventDescription, _date];
}

@end
