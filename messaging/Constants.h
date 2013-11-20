//
//  Constants.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#ifndef messaging_Constants_h
#define messaging_Constants_h

#ifdef __APPLE__
#include "TargetConditionals.h"
#endif

#define ON_DEVICE       !(TARGET_IPHONE_SIMULATOR)

#define ENV_FAKE_API     NO
#define DEV              YES

#define RELOAD_POSTS_INTERVAL_S             60
#define RELOAD_NOTIFICATIONS_INTERVAL_S     30
#define LONGPOLL_ERROR_TIME_INTERVAL_S      5

#endif
