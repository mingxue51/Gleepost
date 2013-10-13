//
//  LocalMessageManager.m
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "MessagesSendingProcessor.h"
#import "LocalMessage.h"
#import "MessageProcessingOperation.h"
#import "Message.h"

@interface MessagesSendingProcessor()

@property (strong, nonatomic) NSOperationQueue *queue;
@property (assign, nonatomic) BOOL isProcessRunning;

@end

@implementation MessagesSendingProcessor

static MessagesSendingProcessor *instance = nil;

+ (MessagesSendingProcessor *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MessagesSendingProcessor alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    self.queue = [NSOperationQueue new];
    self.isProcessRunning = NO;
    
    return self;
}

- (void)processMessages
{
    NSLog(@"Process messages");
    if(self.isProcessRunning) {
        NSLog(@"Processing already in progress, wait to finish");
        return;
    }
    
    self.isProcessRunning = YES;
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    
    NSArray *messages = [Message MR_findByAttribute:@"sendStatus" withValue:[NSNumber numberWithSendStatus:kSendStatusLocal] andOrderBy:@"date" ascending:YES];
    
    if(messages.count == 0) {
        NSLog(@"No message to process, exit");
        self.isProcessRunning = NO;
        return;
    }
    
    MessageProcessingOperation *operation = [[MessageProcessingOperation alloc] init];
    operation.messages = messages;
    
    // completion block that restart the process if needed
    [operation setCompletionBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                self.isProcessRunning = NO;
                [self processMessages];
            }];
        }];
    }];
    
    [self.queue addOperation:operation];
}

@end