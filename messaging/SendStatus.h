//
//  SendStatus.h
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#ifndef Gleepost_SendStatus_h
#define Gleepost_SendStatus_h

typedef enum {
    kSendStatusLocal = 1,
    kSendStatusFailure = 2,
    kSendStatusSent = 3
} SendStatus;

#endif
