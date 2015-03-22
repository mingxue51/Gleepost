//
//  GLPApprovalManager.m
//  Gleepost
//
//  Created by Silouanos on 24/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPApprovalManager.h"
#import "WebClient.h"

@interface GLPApprovalManager ()

@property (strong, nonatomic) GLPApproveLevel *currentApproveLevel;

@end

@implementation GLPApprovalManager

static GLPApprovalManager *instance = nil;

+ (GLPApprovalManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[GLPApprovalManager alloc] init];
    });
    
    return instance;
}

-(id)init
{
    self = [super init];
    
    if(self)
    {
        [self reloadApprovalLevel];
    }
    
    return self;
}

#pragma mark - Accessors

- (ApproveLevel)currentApprovalLevel
{
    return self.currentApproveLevel.approveLevel;
}

/**
 Checks the approval level and the kind of post user already selected.
 If the kind of post needs to be approved this method returns YES, otherwise NO.
 */
- (BOOL)shouldPostBeVisible:(GLPPost *)post
{
    if([post isGroupPost])
    {
        return YES;
    }
    else
    {
        switch (self.currentApprovalLevel)
        {
            case kNone:
                DDLogInfo(@"NewPostViewController : Approval level off.");
                return YES;
                break;
                
            case kOnlyParties:
                if([post isParty])
                {
                    DDLogInfo(@"NewPostViewController : Approval level on parties.");
                    return NO;
                }
                else
                {
                    return YES;
                }
                break;
                
            case kAllEvents:
                DDLogInfo(@"NewPostViewController : Approval level on all events.");
                return ![post isEvent];
                break;
                
            case kAll:
                DDLogInfo(@"NewPostViewController : Approval level on all posts.");
                return NO;
                break;
                
            default:
                break;
        }
        
    }
    
    return NO;
}

#pragma mark - Client

- (void)reloadApprovalLevel
{
    [[WebClient sharedInstance] getApprovalStatusCallbackBlock:^(BOOL success, NSInteger level) {
       
        if(success)
        {
            DDLogDebug(@"Approval level loaded %ld", (long)level);
            
            self.currentApproveLevel = [[GLPApproveLevel alloc] initWithApproveLevel:level];
        }
        else
        {
            DDLogDebug(@"Approval level faild to be loaded %ld", (long)level);

            if(!self.currentApproveLevel)
            {
                self.currentApproveLevel = [[GLPApproveLevel alloc] initWithApproveLevel:0];
            }
        }
    }];
}

- (void)getApprovalLevelWithCallback:(void (^) (BOOL success, BOOL approveOn))callbackBlock
{
    [[WebClient sharedInstance] getApprovalStatusCallbackBlock:^(BOOL success, NSInteger level) {
        
        if(success)
        {
            self.currentApproveLevel = [[GLPApproveLevel alloc] initWithApproveLevel:level];
            
            callbackBlock(YES, (level == 0) ? NO : YES);
        }
        else
        {
            if(!self.currentApproveLevel)
            {
                self.currentApproveLevel = [[GLPApproveLevel alloc] initWithApproveLevel:0];
            }
            
            callbackBlock(NO, self.currentApproveLevel.approveLevel == 0 ? NO : YES);
        }
        
    }];
}

@end
