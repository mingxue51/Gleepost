//
//  GLPProfileLoader.h
//  Gleepost
//
//  Created by Silouanos on 15/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPUser;

@interface GLPProfileLoader : NSObject

+ (GLPProfileLoader *)sharedInstance;

-(void)loadUserData;
- (void)loadUsersDataWithLocalCallback:(void (^) (GLPUser *user))localCallback andRemoteCallback:(void (^) (BOOL success, BOOL updatedData, GLPUser *user))remoteCallback;
- (void)uploadAndSetNewUsersImage:(UIImage *)image withCallbackBlock:(void (^) (BOOL success, NSString *url))callback;
-(void)loadContactsImages:(NSArray*)contacts;
-(void)refreshContactsImages:(NSArray*)contacts;
-(UIImage*)contactImageWithRemoteKey:(int)remoteKey;
-(void)initialiseLoader;

@end
