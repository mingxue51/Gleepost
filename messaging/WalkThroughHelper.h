//
//  WalkThroughHelper.h
//  Gleepost
//
//  Created by Silouanos on 12/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatViewAnimationController.h"

@interface WalkThroughHelper : NSObject

+(void)showCampusWallMessage;
+(BOOL)showRandomChatMessageWithDelegate:(ChatViewAnimationController *)delegate;


@end
