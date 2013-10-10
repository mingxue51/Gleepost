//
//  RemoteMessage+Additions.h
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "RemoteMessage.h"
#import "SendStatus.h"

@interface RemoteMessage (Additions)

- (BOOL)followsPreviousMessage:(RemoteMessage *)message;

@end
