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
#import "GLPiOSSupportHelper.h"
#import "GLPVideo.h"
#import "GLPVideoPostCWProgressManager.h"
#import "GLPLiveGroupPostManager.h"
#import "GLPPendingPostsManager.h"

@interface GLPPostUploaderManager ()

@property (nonatomic, strong) NSMutableDictionary *readyPosts;
@property (nonatomic, strong) NSMutableArray *uploadedPosts;
@property (nonatomic, strong) NSMutableDictionary *pendingComments;
@property (strong, nonatomic) NSTimer *checkForUploadingCommentTimer;
@property (assign, nonatomic) BOOL isNetworkAvailable;
@property (assign, nonatomic, getter = isVideoProcessed) BOOL videoProcessed;
@property (strong, nonatomic) NSMutableDictionary *tempVideoData;
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
        
        //If videoProcessed is YES it means that web socket received with data.
        _videoProcessed = NO;
        
        
        _checkForUploadingCommentTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(checkForCommentUpload:) userInfo:nil repeats:YES];
        
        if(![GLPiOSSupportHelper isIOS6])
        {
            [_checkForUploadingCommentTimer setTolerance:5.0f];
        }
        
        [_checkForUploadingCommentTimer fire];

        
        self.isNetworkAvailable = [WebClient sharedInstance].isNetworkAvailable;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetworkStatus:) name:@"GLPNetworkStatusUpdate" object:nil];

        _tempVideoData = [[NSMutableDictionary alloc] init];
        
    }
    
    return self;
}


#pragma mark - Notification Methods

- (void)updateNetworkStatus:(NSNotification *)notification
{
    BOOL isNetwork = [notification.userInfo[@"status"] boolValue];
    DDLogInfo(@"Background requests manager network status update POST UPLOADER: %d", isNetwork);
    
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
-(NSDictionary *)isPostInQueueWithKey:(NSInteger)postKey
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
-(void)checkForPendingCommentsWithPostkey:(NSInteger)postKey andPostRemoteKey:(NSInteger)postRemoteKey
{
    NSArray *currentComments = [_pendingComments objectForKey: [NSNumber numberWithInteger:postKey]];
    
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
    
    DDLogDebug(@"Text post sending status before sending %d", textPost.sendStatus);
    

    //Post ready to be uploaded.
    
    void (^_uploadContentBlock)(GLPPost*);
    
    
    @synchronized(_readyPosts)
    {
        _uploadContentBlock = ^(GLPPost *post){
            
            if(post.isPending)
            {
                //Notify GLPPendingPostView and GLPPendingPostsVC after edit.
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_POST_EDITED object:nil userInfo:@{@"post_edited": post}];
            }
            else
            {
                //Notify GLPTimelineViewController after finish.
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPPostUploaded" object:nil userInfo:@{@"remoteKey":[NSNumber numberWithInteger:post.remoteKey], @"key":[NSNumber numberWithInteger:post.key]}];
            }
        };
    }
    
    
    DDLogInfo(@"Text post uploading task started with post content: %@.",textPost.content);
    
    if(textPost.pending)
    {
//        [[GLPPendingPostsManager sharedInstance] updatePendingPostBeforeEdit:textPost];

        
        //There is no need to send nsnotification once the editing started. There is no need for now.
        
        [[WebClient sharedInstance] editPost:textPost callbackBlock:^(BOOL success, GLPPost *updatedPost) {
            
            if(!success)
            {
                DDLogError(@"Failed to edit the post");
                textPost.sendStatus = kSendStatusFailure;
                [GLPPostManager updatePostAfterSending:textPost];
                return;
            }
            
            updatedPost.sendStatus = kSendStatusSent;
            
            DDLogInfo(@"Text post edited with success: %d and post event date: %@", success, updatedPost.dateEventStarts);
            
//            [GLPPostManager updatePostAfterSending:updatedPost];
            
            [[GLPPendingPostsManager sharedInstance] updatePendingPostAfterEdit:updatedPost];
            
            _uploadContentBlock(updatedPost);
            
        }];
    }
    else
    {
        [GLPPostManager createLocalPost:textPost];

        [[WebClient sharedInstance] createPost:textPost callbackBlock:^(BOOL success, int remoteKey) {
            
            textPost.sendStatus = success ? kSendStatusSent : kSendStatusFailure;
            textPost.remoteKey = success ? remoteKey : 0;
            
            DDLogInfo(@"Text post uploaded with success: %d and post remoteKey: %d", success, textPost.remoteKey);
            
            [GLPPostManager updatePostAfterSending:textPost];
            
            _uploadContentBlock(textPost);
            
        }];
    }
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
    }
    
    _uploadImageContentBlock = ^(GLPPost* post){
        
        if(post.pending)
        {
            
            DDLogDebug(@"Pending post edited");
            
            //Notify GLPPendingPostView and GLPPendingPostsVC after edit.
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_POST_EDITED object:nil userInfo:@{@"post_edited": post}];
        }
        else
        {
            //Notify GLPTimelineViewController after finish.
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPPostUploaded" object:nil userInfo:@{@"remoteKey":[NSNumber numberWithInteger:post.remoteKey], @"imageUrl":[post.imagesUrls objectAtIndex:0], @"key":[NSNumber numberWithInteger:post.key]}];
        }
        
    };
    

    NSLog(@"Post uploading task started with post content: %@ and image url: %@.",post.content, [post.imagesUrls objectAtIndex:0]);
    
    if(post.pending)
    {
//        [[GLPPendingPostsManager sharedInstance] updatePendingPostBeforeEdit:post];
        
        [[WebClient sharedInstance] editPost:post callbackBlock:^(BOOL success, GLPPost *updatedPost) {
           
            if(!success)
            {
                DDLogError(@"Failed to edit the post");
                post.sendStatus = kSendStatusFailure;
                [GLPPostManager updatePostAfterSending:post];
                return;
            }
            
            updatedPost.sendStatus = kSendStatusSent;
            updatedPost.key = post.key;
            
            DDLogInfo(@"!!Post edited with success: %d and post image url %@ and content: %@", success, updatedPost.imagesUrls[0], updatedPost.content);
    
            [GLPPostManager updateImagePostAfterSending:updatedPost];
            
            [[GLPPendingPostsManager sharedInstance] updatePendingPostAfterEdit:updatedPost];
            
            _uploadImageContentBlock(updatedPost);
            
            [self checkForPendingCommentsWithPostkey:post.key andPostRemoteKey:post.remoteKey];
            
            //Add post to uploaded posts.
            [_uploadedPosts addObject:post];
            
            //Remove post from the NSDictionary.
            [self removePostWithTimestamp:timestamp];

        }];
    }
    else
    {
        [[WebClient sharedInstance] createPost:post callbackBlock:^(BOOL success, int remoteKey) {
            
            post.sendStatus = success ? kSendStatusSent : kSendStatusFailure;
            post.remoteKey = success ? remoteKey : 0;
            
            NSLog(@"!!Post uploaded with success: %d and post remoteKey: %d", success, post.remoteKey);

            [GLPPostManager updateImagePostAfterSending:post];

            if(success)
            {
                _uploadImageContentBlock(post);
                
                [self checkForPendingCommentsWithPostkey:post.key andPostRemoteKey:post.remoteKey];
                
                //Add post to uploaded posts.
                [_uploadedPosts addObject:post];
                
                //Remove post from the NSDictionary.
                [self removePostWithTimestamp:timestamp];
            }
        }];
    }
}

-(void)uploadPostWithTimestamp:(NSDate*)timestamp withVideoData:(NSDictionary *)videoData
{
    //Post ready to be uploaded.
    
    void (^_uploadVideoContentBlock)(GLPPost*);
    
    GLPPost *post = nil;
    
    @synchronized(_readyPosts)
    {
        post = [_readyPosts objectForKey:timestamp];
        
        NSAssert(post.video, @"Post video data should not be nil");
        
        post.video.url = videoData[@"mp4"];
        NSArray *thumbnails = videoData[@"thumbnails"];
        post.video.thumbnailUrl = thumbnails[0];
        
    }
    
    
    _uploadVideoContentBlock = ^(GLPPost *post){
        DDLogDebug(@"Post video data before notify Campus Wall: %@", post.video);
        [self notifyTheRightViewControllerWithPost:post];
        [self videoPostReadyToUpload];
    };

    NSLog(@"Post uploading task started with post content: %@ and video url: %@, pending %d.",post.content, post.video.url, post.pending);
    
    if(post.pending)
    {
        [[WebClient sharedInstance] editPost:post callbackBlock:^(BOOL success, GLPPost *editedPost) {
            
            post.sendStatus = success ? kSendStatusSent : kSendStatusFailure;
            post.remoteKey = success ? editedPost.remoteKey : 0;
            
            DDLogInfo(@"Video Post edited with success: %d and post remoteKey: %ld", success, (long)post.remoteKey);
            
            [GLPPostManager updateVideoPostAfterSending:post];
            
            if(success)
            {
                _uploadVideoContentBlock(post);
                
                [self checkForPendingCommentsWithPostkey:post.key andPostRemoteKey:post.remoteKey];
                
                //Add post to uploaded posts.
                [_uploadedPosts addObject:post];
                
                //Remove post from the NSDictionary.
                [self removePostWithTimestamp:timestamp];
            }
        }];
    }
    else
    {
        [[WebClient sharedInstance] createPost:post callbackBlock:^(BOOL success, int remoteKey) {
            
            post.sendStatus = success ? kSendStatusSent : kSendStatusFailure;
            post.remoteKey = success ? remoteKey : 0;
            
            DDLogInfo(@"Video Post uploaded with success: %d and post remoteKey: %ld", success, (long)post.remoteKey);
            
            
            [GLPPostManager updateVideoPostAfterSending:post];
            
            if(success)
            {
                _uploadVideoContentBlock(post);
                
                [self checkForPendingCommentsWithPostkey:post.key andPostRemoteKey:post.remoteKey];
                
                //Add post to uploaded posts.
                [_uploadedPosts addObject:post];
                
                //Remove post from the NSDictionary.
                [self removePostWithTimestamp:timestamp];
            }
        }];
    }
}

/**
 This method is ONLY used after the app finds that there are pending video posts.
 
 Once the server response the video data this method is called to create the post.
 
 @param videoPost the post with the video data included.
 */
- (void)uploadVideoPost:(GLPPost *)videoPost
{
    //Post ready to be uploaded.
    
    void (^_uploadVideoContentBlock)(GLPPost*);
    
    
    _uploadVideoContentBlock = ^(GLPPost *post){
        
        //TODO: Create the new post to the campus wall dynamically.
        //TODO: Make that to work for group video posts too.
        
        DDLogDebug(@"Pending Post video data before notify Campus Wall: %@", post.video);
        
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_VIDEO_POST_READY object:self userInfo:@{@"final_post": post}];
    };
    
    DDLogInfo(@"Post uploading task started with post content: %@ and video url: %@.",videoPost.content, videoPost.video.url);
    
    if(videoPost.pending)
    {
        [[WebClient sharedInstance] editPost:videoPost callbackBlock:^(BOOL success, GLPPost *editedPost) {
            
            videoPost.sendStatus = success ? kSendStatusSent : kSendStatusFailure;
            videoPost.remoteKey = success ? editedPost.remoteKey : 0;
            
            DDLogInfo(@"Pending Video Post edited with success: %d and post remoteKey: %ld", success, (long)videoPost.remoteKey);
            
            [GLPPostManager updateVideoPostAfterSending:videoPost];
            
            if(success)
            {
                _uploadVideoContentBlock(videoPost);
            }
        }];
    }
    else
    {
        [[WebClient sharedInstance] createPost:videoPost callbackBlock:^(BOOL success, int remoteKey) {
            
            videoPost.sendStatus = success ? kSendStatusSent : kSendStatusFailure;
            videoPost.remoteKey = success ? remoteKey : 0;
            
            DDLogInfo(@"Pending Video Post uploaded with success: %d and post remoteKey: %ld", success, (long)videoPost.remoteKey);
            
            [GLPPostManager updateVideoPostAfterSending:videoPost];
            
            if(success)
            {
                _uploadVideoContentBlock(videoPost);
            }
            
        }];
    }
    

}

/**
 Adds to the local database the key of the video and if the video is already processed
 it uploads directly the post.
 
 @param timestamp the timestamp of the post.
 @param videoId the id of the video.
 
 */
- (void)prepareVideoPostForUploadWithTimestamp:(NSDate *)timestamp andVideoId:(NSNumber *)videoId
{
    GLPPost *post = nil;

    @synchronized(_readyPosts)
    {
        post = [_readyPosts objectForKey:timestamp];
        post.video = [[GLPVideo alloc] initWithPendingKey:videoId];
        post.sendStatus = kSendStatusLocal;
    }
    
    //Update video to database. (In order to know video id).
    [GLPPostManager updateVideoPostBeforeSending:post];

    if([self isVideoProcessed])
    {
        DDLogDebug(@"Video processed ready: %@", _tempVideoData);
        
        NSDictionary *actualVideoData = _tempVideoData[videoId];
        
        if(!actualVideoData)
        {
            return;
        }
        
        [self uploadPostWithTimestamp:timestamp withVideoData:actualVideoData];
//        [self videoPostReadyToUpload];
    }
    
}
/**
 Uploads the video post if the post exists in the ready posts dictionary.
 
 @param videoData processed video data from web socket.
 
 @return YES if the video posted, otherwise NO.
 
 */

- (void)uploadPostWithVideoData:(NSDictionary *)videoData
{
    NSNumber *videoKey = [NSNumber numberWithInteger:[videoData[@"id"] integerValue]];
    [self videoPostWithId:videoKey alreadyProcessedWithVideoData:videoData];
    
    DDLogDebug(@"uploadPostWithVideoData: %@, Key: %@", videoData, videoKey);
    
    for(NSDate *timestamp in _readyPosts)
    {
        GLPPost *p = [_readyPosts objectForKey:timestamp];
        
        if([p.video.pendingKey isEqualToNumber:videoKey])
        {
            DDLogDebug(@"FOUND post with timestamp: %@ and video key: %@", timestamp, videoKey);
            
            [self uploadPostWithTimestamp:timestamp withVideoData:videoData];
//            [self videoPostReadyToUpload];
            
        }
    }
    
}

- (void)videoPostWithId:(NSNumber *)videoId alreadyProcessedWithVideoData:(NSDictionary *)videoData
{
    _videoProcessed = YES;
    
    [_tempVideoData setObject:videoData forKey:videoId];
    
//    _tempVideoData = videoData;
}

- (void)notifyTheRightViewControllerWithPost:(GLPPost *)post
{
    DDLogDebug(@"Group post? %@", post.group);
    
    if(post.pending)
    {
        //TODO: Notify pending posts view controller.
        
        //TODO: Remove that and replace it with other kind of progress bar.
        [[GLPVideoPostCWProgressManager sharedInstance] progressFinished];

        return;
    }
    
    if(post.group)
    {
        [[GLPLiveGroupPostManager sharedInstance] progressFinished];
        
        NSString *notificationName = [NSString stringWithFormat:@"%@_%ld", GLPNOTIFICATION_GROUP_VIDEO_POST_READY, (long)post.group.remoteKey];

        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:notificationName object:self userInfo:@{@"final_post": post}];
    }
    else
    {
        [[GLPVideoPostCWProgressManager sharedInstance] progressFinished];
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_VIDEO_POST_READY object:self userInfo:@{@"final_post": post}];
    }

}

- (void)videoPostReadyToUpload
{
    _videoProcessed = NO;
    [_tempVideoData removeAllObjects];
}


@end
