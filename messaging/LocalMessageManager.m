//
//  LocalMessageManager.m
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "LocalMessageManager.h"
#import "LocalMessage.h"
#import "MessageProcessingOperation.h"

@interface LocalMessageManager()

@property (strong, nonatomic) NSOperationQueue *queue;
@property (assign, nonatomic) BOOL isProcessRunning;
@property (assign, nonatomic) BOOL shouldProcessAgain;

@end

@implementation LocalMessageManager

static LocalMessageManager *instance = nil;

+ (LocalMessageManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LocalMessageManager alloc] init];
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
    self.shouldProcessAgain = NO;
    
    return self;
}

- (void)process
{
    if(self.isProcessRunning) {
        self.shouldProcessAgain = YES;
        return;
    }
    
    self.isProcessRunning = YES;
    
    MessageProcessingOperation *operation = [[MessageProcessingOperation alloc] init];
    
    // completion block that restart the process if needed
    [operation setCompletionBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"Message processing operation completion block");
            self.isProcessRunning = NO;
            
            if(self.shouldProcessAgain) {
                NSLog(@"Should process again");
                self.shouldProcessAgain = NO;
                
                [self process];
            }
        }];
    }];
    
    [self.queue addOperation:operation];
}


@end
