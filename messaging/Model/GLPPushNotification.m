//
//  GLPPushNotification.m
//  Gleepost
//
//  Created by Σιλουανός on 4/9/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPPushNotification.h"

@implementation GLPPushNotification

- (id)initWithJson:(NSDictionary *)json
{
    self = [super init];
    
    if(self)
    {
        NSString *typeOfPN = [self parseKindOfPNWithJson:json];
        [self configureKindOfPNWithKey:typeOfPN];
        [self configurePNDataWithPNData:json];
    }
    
    return self;
}

- (void)configurePNDataWithPNData:(NSDictionary *)json
{
    
    switch (_kindOfPN) {
            
        case kPNKindSendYouMessage:
            _conversationId = json[@"conv"];
            _groupId = json[@"group"];
            _kindOfPN = kPNKindSendYouGroupMessage;
            break;
            
        case kPNKindCommentedYourPost:
            _commenterId = json[@"commenter-id"];
            _postId = json[@"post-id"];
            break;
            
        case kPNKindLikedYourPost:
            _likerId = json[@"liker-id"];
            _postId = json[@"post-id"];
            break;
            
        case kPNKindAddedYouToGroup:
            _groupId = json[@"group-id"];
            break;
            
        case kPNKindNewGroupPost:
            _groupId = json[@"group-id"];
            break;
            
        case kPNKindNewAppVersion:
            _version = json[@"version"];
            break;
            
        case kPNKindPostApproved:
            _postId = json[@"post-id"];
            break;
            
        case kPNKindPostRejected:
            _postId = json[@"post-id"];
            break;
            
        case kPNKindUnknown:
            DDLogError(@"Unknown push notification.");
            break;
            
        default:
            break;
    }
    
    
}

- (void)configureKindOfPNWithKey:(NSString *)kindOfPN
{
    if(!kindOfPN)
    {
        _kindOfPN = kPNKindUnknown;
        return;
    }
    
    if([kindOfPN isEqualToString:@"MSG"])
    {
        _kindOfPN = kPNKindSendYouMessage;
    }
    else if([kindOfPN isEqualToString:@"commented"])
    {
        _kindOfPN = kPNKindCommentedYourPost;
    }
    else if([kindOfPN isEqualToString:@"liked"])
    {
        _kindOfPN = kPNKindLikedYourPost;
    }
    else if ([kindOfPN isEqualToString:@"GROUP"])
    {
        _kindOfPN = kPNKindAddedYouToGroup;
    }
    else if ([kindOfPN isEqualToString:@"group_post"])
    {
        _kindOfPN = kPNKindNewGroupPost;
    }
    else if ([kindOfPN isEqualToString:@"version"])
    {
        _kindOfPN = kPNKindNewAppVersion;
    }
    else if ([kindOfPN isEqualToString:@"approved_post"])
    {
        _kindOfPN = kPNKindPostApproved;
    }
    else if ([kindOfPN isEqualToString:@"rejected_post"])
    {
        _kindOfPN = kPNKindPostRejected;
    }
    else
    {
        _kindOfPN = kPNKindUnknown;
    }
}

- (NSString *)parseKindOfPNWithJson:(NSDictionary *)json
{
    NSDictionary *wholePN = json[@"aps"];
    
    NSDictionary *alertPN = wholePN[@"alert"];
    
    NSString *kindOfPN = alertPN[@"loc-key"];
    
    return kindOfPN;
}

@end
