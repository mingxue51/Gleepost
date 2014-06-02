//
//  GLPPostUploaderManager.m
//  Gleepost
//
//  Created by Silouanos on 20/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPPostUploaderManager.h"
#import "WebClient.h"
#import "GLPPostManager.h"
#import "NSNotificationCenter+Utils.h"
#import "GLPCommentDao.h"
#import "WebClientHelper.h"
#import "GLPiOS6Helper.h"

@interface GLPPostUploaderManager ()

@property (nonatomic, strong) NSMutableDictionary *readyPosts;
@property (nonatomic, strong) NSMutableArray *uploadedPosts;
@property (nonatomic, strong) NSMutableDictionary *pendingComments;
@property (strong, nonatomic) NSTimer *checkForUploadingCommentTimer;
@property (assign, nonatomic) BOOL isNetworkAvailable;
@end

@implementation GLPPostUploaderManager

@synthesize readyPosts = _readyPosts;

-(id)init
{
    self = [super init];
    
    if(self)
    {
        //Contains all the posts that are ready for uploading.
        _readyPosts = [[NSMutableDictionary alloc] init];
        
        //Contains all the posts that are already uploaded.
        _uploadedPosts = [[NSMutableArray alloc] init];
        
        //Contains all the comments that are ready for uploading,
        _pendingComments = [[NSMutableDictionary alloc] init];
        
        
        _checkForUploadingCommentTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(checkForCommentUpload:) userInfo:nil repeats:YES];
        
        if(![GLPiOS6Helper isIOS6])
        {
            [_checkForUploadingCommentTimer setTolerance:5.0f];
        }
        
        [_checkForUploadingCommentTimer fire];

        
        self.isNetworkAvailable = [WebClient sharedInstance].isNetworkAvailable;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetworkStatus:) name:@"GLPNetworkStatusUpdate" object:nil];

    }
    
    return self;
}


#pragma mark - Notification Methods

- (void)updateNetworkStatus:(NSNotification *)notification
{
    BOOL isNetwork = [notification.userInfo[@"status"] boolValue];
    DDLogCInfo(@"Background requests manager network status update POST UPLOADER: %d", isNetwork);
    
    self.isNetworkAvailable = isNetwork;
    
    //    if(isNetwork)
    //    {
    //        [self.queue setSuspended:NO];
    //        //        [self startConsuming];
    //    } else
    //    {
    //        [self.queue setSuspended:YES];
    //        //        [self suspendConsuming];
    //    }
}

#pragma mark - Getters Setters

-(NSDictionary*)pendingPosts
{
    return _readyPosts;
}

-(void)addPost:(GLPPost*)post withTimestamp:(NSDate*)timestamp
{
    [_readyPosts setObject:post forKey:timestamp];
}

-(void)removePostWithTimestamp:(NSDate*)timestamp
{
    [_readyPosts removeObjectForKey:timestamp];
}

//-(void)removeComment:(

/**
 Add comment to queue and if post is uploaded, upload comment.
 
 @param comment
 
 */
-(void)addComment:(GLPComment *)comment
{
    int postKey = comment.post.key;
    
    NSAssert(postKey != 0, @"Key post should not be 0");
    
    DDLogDebug(@"Add comment GLPPostUploaderManager: %@", comment);
    
//    int isNetworkAvailable = [WebClient sharedInstance].isNetworkAvailable;
    
    
    
    [self setCommentInQueue:comment];

    
    
    
    
//    if([self isPostInQueueWithKey:postKey] || !isNetworkAvailable)
//    {
//        //Post not yet uploaded.
//        
//        [self setCommentInQueue:comment];
//    }
//    else
//    {
//        //Post already uploaded.
//        
//        if(comment.post.remoteKey == 0)
//        {
//            //Take the post from finished posts' list.
//            GLPPost *commentPost = [self postRemoteKeyWithKey:postKey];
//            
//            NSAssert(commentPost != nil, @"Comment post should not be nil.");
//            
//            comment.post = commentPost;
//            
//            DDLogDebug(@"Add comment: %@.", comment);
//
//        }
//    
//        
//        //Upload comment.
//        [self uploadComment:comment];
//    }
    
    
}

/**
 Cancels the pending post (if post exist) with all its comments (if comments exist).
 
 @param postKey the post's local database key.
 
 @return nil if post does not exist, otherwise returns the post with the timestamp in an NSDictionary.
 
 */
-(NSDate *)cancelPendingPostWithKey:(int)postKey
{
    NSDictionary *postTimestamp = [self isPostInQueueWithKey:postKey];
    
    if(!postTimestamp)
    {
        return nil;
    }
    
    GLPPost *post = [postTimestamp objectForKey:@"Post"];
    NSDate *timestamp = [postTimestamp objectForKey:@"Timestamp"];
    
    
    //Remove post from queue.
    [self removePostWithTimestamp:timestamp];
    
    //Remove post from local database.
    [GLPPostManager deletePostWithPost:post];
    
    //Remove comments from queue.
    [self removeCommentsWithPostKey:postKey];
    
    return timestamp;
}

/**
 Returns an NSDictionary that contains post and timestamp.
 
 @param postKey the post's local database key.
 
 @return NSDictionary.
 
 */
-(NSDictionary *)isPostInQueueWithKey:(int)postKey
{
    for(NSDate *timestamp in _readyPosts)
    {
        GLPPost *post = [_readyPosts objectForKey:timestamp];
        
        if(post.key == postKey)
        {
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:post,  @"Post", timestamp, @"Timestamp", nil];
            
            return dictionary;
        }
    }
    
    return nil;
}

-(void)setCommentInQueue:(GLPComment *)comment
{
    NSArray *comments = [_pendingComments objectForKey:[NSNumber numberWithInt:comment.post.key]];
    
    NSMutableArray *mutableComments = [[NSMutableArray alloc] init];
    
    if(comments)
    {
        //Set already exist comments array to a temporary array.
        mutableComments = comments.mutableCopy;
        
    }
    else
    {
        DDLogInfo(@"First comment with key: %d", comment.key);
    }
    
    [mutableComments addObject:comment];
    
    [_pendingComments setObject:mutableComments forKey:[NSNumber numberWithInt:comment.post.key]];
    
    DDLogDebug(@"PENDING COMMENTS: %@", _pendingComments);
}

-(void)removeCommentFromQueue:(GLPComment *)comment
{
    NSArray *comments = [_pendingComments objectForKey:[NSNumber numberWithInt:comment.post.key]];

    if(!comments)
    {
        return;
    }
    
    if(comments.count == 1)
    {
        [_pendingComments removeObjectForKey:[NSNumber numberWithInt:comment.post.key]];
    }
    else
    {
        int commentToBeRemoved = 0;
        
        NSMutableArray *commentsMutable = comments.mutableCopy;
        
        for(GLPComment *inComment in comments)
        {
            if(inComment.key == comment.key)
            {
                break;
            }
            
            ++commentToBeRemoved;
        }
        
        [commentsMutable removeObjectAtIndex:commentToBeRemoved];
        
        comments = commentsMutable;
        
        //Add back to pending comments.
        [_pendingComments setObject:comments forKey:[NSNumber numberWithInt:comment.post.key]];
        
        
    }
}

/**
 This method is called in case user cancel the post uploading.
 
 @param postKey the post's local database key.
 
 */
-(void)removeCommentsWithPostKey:(int)postKey
{
    [_pendingComments removeObjectForKey:[NSNumber numberWithInt:postKey]];
}

/**
 This method is called each time a post is uploaded to check if there are pending comments.
 If there are some with the same post key then upload comment.
 
 @param postKey post's key.
 
 */
-(void)checkForPendingCommentsWithPostkey:(int)postKey andPostRemoteKey:(int)postRemoteKey
{
    NSArray *currentComments = [_pendingComments objectForKey: [NSNumber numberWithInt:postKey]];
    
    for (GLPComment *comment in currentComments)
    {
        comment.post.remoteKey = postRemoteKey;
        [self uploadComment:comment];

    }
    
}

-(GLPPost *)postRemoteKeyWithKey:(int)postKey
{
    for(GLPPost *post in _uploadedPosts)
    {
        if(postKey == post.key)
        {
            return post;
        }
    }
    
    return nil;
}

-(NSArray *)getPendingCommentsWithPostKey:(int)postKey
{
    return [_pendingComments objectForKey:[NSNumber numberWithInt:postKey]];
}

#pragma mark - Operations

-(void)checkForCommentUpload:(id)sender
{
    
//    if(!self.isNetworkAvailable)
//    {
//        
//        DDLogDebug(@"Network not available.");
//        
//        return;
//    }
    
//    if(_pendingComments.count == 0)
//    {
//        return;
//    }
    
    self.isNetworkAvailable = [WebClient sharedInstance].isNetworkAvailable;

    
//    if(self.isNetworkAvailable)
//    {
        for(NSNumber *postKey in _pendingComments)
        {
            NSArray *comments = [_pendingComments objectForKey:postKey];
            
            if([self isPostInQueueWithKey:[postKey integerValue]])
            {
                continue;
            }
            else
            {
                //Upload comment.
                for(GLPComment *comment in comments)
                {
                    
                    if(comment.sendStatus != kSendStatusSent)
                    {
                        DDLogDebug(@"Comment to upload: %@", comment);

                        [self uploadComment:comment];
                    }
                    
                }
            }
        }
//    }
//    else
//    {
//        //[WebClientHelper commentWillUploadedLater];
//    }
    

    
}

#pragma mark - Client

-(void)uploadComment:(GLPComment *)comment
{
    [[WebClient sharedInstance] createComment:comment callbackBlock:^(BOOL success) {
        
        if(success) {
            
            //Remove comment from the pending comments array.
            
            
            //Increase the number of comments to the post.
//            ++self.post.commentsCount;
            
            //            [self loadCommentsWithScrollToTheEnd:YES];
            
            //TODO: Notify timeline view controller.
            
//            [GLPPostNotificationHelper updatePostWithNotifiationName:@"GLPPostUpdated" withObject:self remoteKey:self.post.remoteKey numberOfLikes:self.post.likes andNumberOfComments:self.post.commentsCount];
            
            DDLogInfo(@"Comment uploaded with content: %@ and remote key: %d", comment.content, comment.remoteKey);
            comment.sendStatus = kSendStatusSent;
            
            //Update local database.
            [GLPCommentDao updateCommentSendingData:comment];
            
            //Remove from pending array.
            [self removeCommentFromQueue:comment];
            
        } else {
            
//            [WebClientHelper showStandardError];
        }
    }];
}

-(void)uploadTextPost:(GLPPost *)textPost
{
    
    [GLPPostManager createLocalPost:textPost];

    //Post ready to be uploaded.
    
    void (^_uploadContentBlock)(GLPPost*);
    
    
    @synchronized(_readyPosts)
    {
        _uploadContentBlock = ^(GLPPost* post){
            
            //Notify GLPTimelineViewController after finish.
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPPostUploaded" object:nil userInfo:@{@"remoteKey":[NSNumber numberWithInt:post.remoteKey],
                                                                                                                            @"imageUrl":@"",
                                                                                                                            @"key":[NSNumber numberWithInt:post.key]}];
        };
    }
    
    
    DDLogInfo(@"Text post uploading task started with post content: %@.",textPost.content);
    
    
    [[WebClient sharedInstance] createPost:textPost callbackBlock:^(BOOL success, int remoteKey) {
        
        
        textPost.sendStatus = success ? kSendStatusSent : kSendStatusFailure;
        textPost.remoteKey = success ? remoteKey : 0;
        
        DDLogInfo(@"Text post uploaded with success: %d and post remoteKey: %d", success, textPost.remoteKey);
        
        
        [GLPPostManager updatePostAfterSending:textPost];
        
        _uploadContentBlock(textPost);
        
    }];

}

-(void)uploadPostWithTimestamp:(NSDate*)timestamp andImageUrl:(NSString*)url
{
    
    //Post ready to be uploaded.
    
    void (^_uploadImageContentBlock)(GLPPost*);
    
    GLPPost *post = nil;
    
    @synchronized(_readyPosts)
    {
        post = [_readyPosts objectForKey:timestamp];
        post.imagesUrls = [[NSArray alloc] initWithObjects:url, nil];
        
        _uploadImageContentBlock = ^(GLPPost* post){
            
            NSLog(@"Into uploadImageContentBlock");
            
            //Notify GLPTimelineViewController after finish.
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPPostUploaded" object:nil userInfo:@{@"remoteKey":[NSNumber numberWithInt:post.remoteKey],
                                                                                                                            @"imageUrl":[post.imagesUrls objectAtIndex:0],
                                                                                                                            @"key":[NSNumber numberWithInt:post.key]}];
        };
    }
    

    NSLog(@"Post uploading task started with post content: %@ and image url: %@.",post.content, [post.imagesUrls objectAtIndex:0]);
    
    
//    _incomingPost.imagesUrls = [[NSArray alloc] initWithObjects:[self.urls objectForKey:[NSNumber numberWithInt:1]], nil];
    
    [[WebClient sharedInstance] createPost:post callbackBlock:^(BOOL success, int remoteKey) {
        
        
        post.sendStatus = success ? kSendStatusSent : kSendStatusFailure;
        post.remoteKey = success ? remoteKey : 0;
        
        NSLog(@"!!Post uploaded with success: %d and post remoteKey: %d", success, post.remoteKey);

        
        [GLPPostManager updatePostAfterSending:post];
        
//        self.incomingKey = _incomingPost.key;
//        self.incomingRemoteKey = remoteKey;
        //self.imageUrl = [_incomingPost.imagesUrls objectAtIndex:0];
//        self.imageUrl = [self.urls objectForKey:[NSNumber numberWithInt:1]];
        
//        NSLog(@"IMAGE URL BEFORE INFORMATION: %@",self.imageUrl);
        
        
        if(success)
        {
            _uploadImageContentBlock(post);

            [self checkForPendingCommentsWithPostkey:post.key andPostRemoteKey:post.remoteKey];
            
            //Add post to uploaded posts.
            [_uploadedPosts addObject:post];
            
            //Remove post from the NSDictionary.
            [self removePostWithTimestamp:timestamp];
        }
        
        //        [self cleanUpPost];
    }];

}

-(void)uploadPostWithTimestamp:(NSDate*)timestamp andVideoUrl:(NSString*)url
{
    //Post ready to be uploaded.
    
    void (^_uploadVideoContentBlock)(GLPPost*);
    
    GLPPost *post = nil;
    
    @synchronized(_readyPosts)
    {
        post = [_readyPosts objectForKey:timestamp];
        post.videosUrls = [[NSArray alloc] initWithObjects:url, nil];
        
        _uploadVideoContentBlock = ^(GLPPost* post){
            
            //Notify GLPTimelineViewController after finish.
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPPostUploaded" object:nil userInfo:@{@"remoteKey":[NSNumber numberWithInt:post.remoteKey],
                                                                                                                            @"videoUrl":@"",
                                                                                                                            @"key":[NSNumber numberWithInt:post.key]}];
        };
    }
    
    
    NSLog(@"Post uploading task started with post content: %@ and video url: %@.",post.content, [post.videosUrls objectAtIndex:0]);
    
    
    //    _incomingPost.imagesUrls = [[NSArray alloc] initWithObjects:[self.urls objectForKey:[NSNumber numberWithInt:1]], nil];
    
    [[WebClient sharedInstance] createPost:post callbackBlock:^(BOOL success, int remoteKey) {
        
        
        post.sendStatus = success ? kSendStatusSent : kSendStatusFailure;
        post.remoteKey = success ? remoteKey : 0;
        
        NSLog(@"Video Post uploaded with success: %d and post remoteKey: %d", success, post.remoteKey);
        
        
        [GLPPostManager updatePostAfterSending:post];
        
        //        self.incomingKey = _incomingPost.key;
        //        self.incomingRemoteKey = remoteKey;
        //self.imageUrl = [_incomingPost.imagesUrls objectAtIndex:0];
        //        self.imageUrl = [self.urls objectForKey:[NSNumber numberWithInt:1]];
        
        //        NSLog(@"IMAGE URL BEFORE INFORMATION: %@",self.imageUrl);
        
        
        if(success)
        {
            _uploadVideoContentBlock(post);
            
            [self checkForPendingCommentsWithPostkey:post.key andPostRemoteKey:post.remoteKey];
            
            //Add post to uploaded posts.
            [_uploadedPosts addObject:post];
            
            //Remove post from the NSDictionary.
            [self removePostWithTimestamp:timestamp];
        }
        
        //        [self cleanUpPost];
    }];
}


@end
