//
//  GLPQueueManager.m
//  Gleepost
//
//  Created by Silouanos on 18/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPQueueManager.h"
#import "GLPPostOperation.h"
#import "GLPImageOperation.h"

@interface GLPQueueManager ()

@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSMutableDictionary *queueStatus;
@property (strong, nonatomic) NSMutableDictionary *imagesUrls;

@property (assign, nonatomic) BOOL isOperationRunning;
@property (assign, nonatomic) BOOL isNetworkAvailable;
@property (assign, nonatomic) BOOL imageUploaded;

//@property (strong, nonatomic) GLPPostOperation *postOperation;
//@property (strong, nonatomic) GLPImageOperation *imageOperation;

//@property (strong, nonatomic) NSMutableDictionary *imagesUrls;


//@property (assign, nonatomic) viewCreator executeUrl;

@end

static GLPQueueManager *instance = nil;

@implementation GLPQueueManager
{
    void (^_readyToUploadBlock)();
}

+ (GLPQueueManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLPQueueManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    if(!self)
    {
        return nil;
    }
    
    self.queue = [[NSOperationQueue alloc] init];
//    [self.queue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    self.imagesUrls = [[NSMutableDictionary alloc] init];
    self.isOperationRunning = NO;
    self.isNetworkAvailable = NO;
    self.imageUploaded = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetworkStatus:) name:@"GLPNetworkStatusUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageUploaded:) name:@"GLPImageUploaded" object:nil];

    return self;
}

- (void)updateNetworkStatus:(NSNotification *)notification
{
    BOOL isNetwork = [notification.userInfo[@"status"] boolValue];
    NSLog(@"Background requests manager network status update: %d", isNetwork);
    
    self.isNetworkAvailable = isNetwork;
    
    if(isNetwork)
    {
        [self.queue setSuspended:NO];
//        [self startConsuming];
    } else
    {
        [self.queue setSuspended:YES];
//        [self suspendConsuming];
    }
}

-(void)uploadImage:(UIImage*)image withId:(int)key
{
    GLPImageOperation *imageOperation = [[GLPImageOperation alloc] initWithImage:image];
    
    self.imageUploaded = NO;

    [imageOperation setCompletionBlock:^{
        NSLog(@"IMAGE OPERATION END");
        

        
    }];
    
    [self.queue addOperation:imageOperation];
}

-(void)uploadPost:(GLPPost*)post withId:(int)key
{
    //__block GLPPostOperation *postOperation = [[GLPPostOperation alloc] initWithPost:post andImages:self.imagesUrls];
    
    
    
//    [postOperation setCompletionBlock:^{
//       
//        //Delete the url from dictionary.
//        
//    }];
    
//    [self.postOperation setQueuePriority:NSOperationQueuePriorityVeryHigh];
    
    if(self.imageUploaded)
    {
        //Set the url to the post.
        //Find the url using the personal id.
        
        //[self.postOperation addPostImageUrl:[self.imagesUrls objectForKey:[NSNumber numberWithInt:key]]];
        //[self.imagesUrls setObject:@"URL" forKey:[NSNumber numberWithInt:3]];

        NSLog(@"UPLOADED?");
        
        [self.queue addOperation:[self generatePostOperationWithPost:post]];
        
        self.imageUploaded = NO;
    }
    else
    {
        //Add the common block.
        NSLog(@"Dependency added.");
        

        __weak NSOperationQueue *q = self.queue;
        __weak GLPQueueManager *s = self;
        _readyToUploadBlock = ^{
            
//            [pOperation addDependency:self.imageOperation];
            
            [q addOperation:[s generatePostOperationWithPost:post]];
            
            
        };
        
    }

}


/**
 Take the image url and set image status uploaded.
 */
-(void)imageUploaded:(NSNotification*)notification
{
    
    NSDictionary *dict = notification.userInfo;
    
    
    
    [self.imagesUrls setObject:[dict objectForKey:@"imageUrl"] forKey:[NSNumber numberWithInt:1]];
    NSLog(@"Image uploaded: %@", notification.userInfo);
    
    if(_readyToUploadBlock) _readyToUploadBlock();
    
    
    self.imageUploaded = YES;

    
}

#pragma mark - Help methods

-(NSOperation*)generatePostOperationWithPost:(GLPPost*)post
{
    NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(executePost:) object:post];
    
    return theOp;
}

#pragma mark -

-(void)executePost:(id)post
{
    GLPPost *incomingPost = (GLPPost*)post;
    
    NSLog(@"Post do be executed: %@",incomingPost.content);
}

-(void)uploadComment
{
    
}

-(void)startConsuming
{
    
}

-(void)suspendConsuming
{
    
}


@end
