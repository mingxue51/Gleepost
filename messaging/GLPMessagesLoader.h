//
//  GLPMessagesLoader.h
//  Gleepost
//
//  Created by Silouanos on 15/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPMessagesLoader : NSObject

+ (GLPMessagesLoader *)sharedInstance;

-(void)loadLiveConversations;
-(void)loadConversations;
-(NSArray*)getLiveConversations;
-(NSArray*)getConversations;

@end
