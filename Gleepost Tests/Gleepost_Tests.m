//
//  Gleepost_Tests.m
//  Gleepost Tests
//
//  Created by Silouanos on 23/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "GLPThemeManager.h"
#import "GLPReviewHistoryDao.h"
#import "GLPReviewHistory.h"
#import "GLPPost.h"
#import "GLPPostManager.h"
#import "GLPPoll.h"
#import "GLPPollDao.h"
#import "GLPLiveSummaryDao.h"
#import "GLPLiveSummary.h"

@interface Gleepost_Tests : XCTestCase

@end

@implementation Gleepost_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFindPollDb {
    
    
}

- (void)testLiveSummaryOperations
{
    GLPLiveSummary *liveSummary = [self setUpLiveSummary];
    XCTAssert([GLPLiveSummaryDao saveLiveSummary:liveSummary], @"Failed to save live summary");
    XCTAssert([GLPLiveSummaryDao findCurrentLiveSummary], @"Failed to find live summary");
}

- (GLPLiveSummary *)setUpLiveSummary
{
    NSMutableDictionary *liveDictionary = [[NSMutableDictionary alloc] init];
    
    [liveDictionary setObject:@(43) forKey:@"party"];
    [liveDictionary setObject:@(12) forKey:@"sports"];
    [liveDictionary setObject:@(68) forKey:@"food"];
    
    return [[GLPLiveSummary alloc] initWithTotalPosts:100 andByCategoryData:liveDictionary.mutableCopy];
}

- (void)testPollDbOperations
{
    GLPPoll *poll = [self setUpPoll];
    poll.key = 1;
    
    XCTAssert([GLPPollDao saveOrUpdatePoll:poll withPostRemoteKey:99999991], @"Failed to save or update poll");
    
    [poll.votes setObject:@(232) forKey:@"Hellas Cyprus"];
    
    XCTAssert([GLPPollDao saveOrUpdatePoll:poll withPostRemoteKey:99999991], @"Failed to save or update poll");
    
    XCTAssert([GLPPollDao findPollWithPostRemoteKey:99999991], @"Failed to find poll");
    
    XCTAssert([GLPPollDao deletePollWithPostRemoteKey:99999991], @"Failed to delete poll");
}

- (GLPPoll *)setUpPoll
{
    GLPPoll *poll = [[GLPPoll alloc] init];
    poll.expirationDate = [NSDate date];
    
    poll.options = @[@"Hillary Clinton", @"Hellas Cyprus"];
    [poll setVotes: @{@"Hillary Clinton" : @(1)}.mutableCopy];
    poll.usersVote = @"Hillary Clinton";
    
    return poll;
}

- (void)testThemeManager
{
    NSString *stringMessageAppName = [[GLPThemeManager sharedInstance] appNameWithString:@"%@"];
    
    if([stringMessageAppName rangeOfString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]].length != 0)
    {
        NSLog(@"%@", stringMessageAppName);
        XCTAssert(YES, @"Pass");
    }
    else
    {
        NSLog(@"%@", stringMessageAppName);
        XCTAssert(NO, @"Failed");
    }
    
    NSString *lowerCaseAppName = [[GLPThemeManager sharedInstance] lowerCaseAppName];
    
    if(lowerCaseAppName)
    {
        NSLog(@"%@", lowerCaseAppName);
        XCTAssert(YES, @"Pass");
    }
    else
    {
        NSLog(@"%@", lowerCaseAppName);
        XCTAssert(NO, @"Failed");
    }
}

- (void)testThemeManagerColours
{
//    [[GLPThemeManager sharedInstance] setNetwork:@"University of Leeds"];
    
    UIImage *image = [[GLPThemeManager sharedInstance] navigationBarImage];
    
    if(image)
    {
        NSLog(@"Nav bar image %@", image);
        
        XCTAssert(YES, @"Pass");
    }
    else
    {
        XCTAssert(NO, @"Failed");
    }
}

- (void)testReviewHistoryLocalDatabaseInteractions
{
    GLPPost *post = [[GLPPost alloc] initWithRemoteKey:2145];
    
    GLPReviewHistory *reviewHistoryEx1 = [[GLPReviewHistory alloc] initWithActionString:@"rejected" withDateHappened:[NSDate date] reason:@"This post is stupid" andUser:nil];
    
    reviewHistoryEx1.remoteKey = 232;
    
    GLPReviewHistory *reviewHistoryEx2 = [[GLPReviewHistory alloc] initWithActionString:@"approved" andDateHappened:[NSDate date]];
    
    reviewHistoryEx2.remoteKey = 22312332;

    
//    [GLPReviewHistoryDao saveReviewHistory:reviewHistoryEx1 withPost:post];
//    [GLPReviewHistoryDao saveReviewHistory:reviewHistoryEx2 withPost:post];
    
    NSArray *reviewHistories = [GLPReviewHistoryDao findReviewHistoryWithPostRemoteKey:post.remoteKey];
    
    [GLPReviewHistoryDao removeReviewHistoryWithPost:post];
    
    
    [GLPPostManager updatePostPending:post];
    
    NSLog(@"Review histories %@", reviewHistories);

    XCTAssert(YES, @"Pass");
}

//- (void)testReadWriteOnPlistFile
//{
//    NSString* filename = @"/var/mobile/Library/Preferences/Gleepost-Info.plist";
//    
//    
//    NSMutableDictionary* prefs = [[NSMutableDictionary alloc] initWithContentsOfFile: filename];
//    
//    NSLog(@"PREFS %@", prefs);
//
//    NSString* hostnamePref = (NSString*)[prefs valueForKey: @"FacebookDisplayName"];
//    
//    if(hostnamePref)
//    {
//        XCTAssert(YES, @"Pass");
//        NSLog(@"current hostname is %@", hostnamePref);
//
//    }
//    else
//    {
//        XCTAssert(NO, @"Failed");
//    }
//    
//}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
