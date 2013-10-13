//
//  NSNumber+Enums.h
//  Gleepost
//
//  Created by Lukas on 10/13/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendStatus.h"

@interface NSNumber (Enums)

+ (NSNumber *)numberWithSendStatus:(SendStatus)sendStatus;
- (SendStatus)sendStatusValue;

@end
