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

#define ENV_FAKE_API                    NO
#define DEV                             YES
#define ENV_DEBUG                       NO
#define ENV_FAKE_LIVE_CONVERSATIONS     NO

#define ON_DEVICE       !(TARGET_IPHONE_SIMULATOR)

#define RELOAD_POSTS_INTERVAL_S             60
#define RELOAD_NOTIFICATIONS_INTERVAL_S     30
#define LONGPOLL_ERROR_TIME_INTERVAL_S      5

#define GLPNOTIFICATION_CONVERSATIONS_SYNC              @"GLPConversationsSync"
#define GLPNOTIFICATION_ONE_CONVERSATION_SYNC           @"GLPOneConversationSync"
#define GLPNOTIFICATION_NEW_NOTIFICATION                @"GLPNewNotification"
#define GLPNOTIFICATION_NEW_MESSAGE                     @"GLPNewMessage"
#define GLPNOTIFICATION_MESSAGE_SEND_UPDATE             @"GLPMessageSendUpdate"
#define GLPNOTIFICATION_NETWORK_UPDATE                  @"GLPNetworkStatusUpdate"
#define GLPNOTIFICATION_SYNCHRONIZED_WITH_REMOTE        @"GLPSynchronizedWithRemote"
#define GLPNOTIFICATION_NOT_SYNCHRONIZED_WITH_REMOTE    @"GLPNotSynchronizedWithRemote"
#define GLPNOTIFICATION_POST_DELETED                    @"GLPPostDeleted"
#define GLPNOTIFICATION_HOME_TAPPED_TWICE               @"GLPHomeTabbedTwice"

#define GLPNOTIFICATION_CONVERSATION_COUNT              @"GLPConversationCount"
#define GLPNOTIFICATION_CAMERA_LIMIT_REACHED            @"GLPCameraLimitReached"
#define GLPNOTIFICATION_CAMERA_THRESHOLD_REACHED        @"GLPCameraThresholdReached"
#define GLPNOTIFICATION_SECONDS_TEXT_TITLE              @"GLPSecondsTextTitle"

#define GLPNOTIFICATION_DISMISS_VIDEO_VC                @"GLPDismissVideoVC"
#define GLPNOTIFICATION_CONTINUE_TO_PREVIEW             @"GLPContinueToPreview"
#define GLPNOTIFICATION_SHOW_CAPTURE_VIEW               @"GLPShowCaptureView"
#define GLPNOTIFICATION_RECEIVE_VIDEO_PATH              @"GLPReceiveVideoPath"

#define GLPNOTIFICATION_NEW_GROUP_CREATED              @"GLPNewGroupCreated"

#define GLPNOTIFICATION_DISMISS_WALKTHROUGH             @"GLPDismissWalkthrough"

#define GLPNOTIFICATION_UPDATE_CATEGORY_LABEL           @"GLPUpdateCategoryLabel"

#define GLPNOTIFICATION_DISMISS_ERROR_VIEW              @"GLPDismissErrorView"
#define GLPNOTIFICATION_HIDE_ERROR_VIEW                 @"GLPHideErrorView"
#define GLPNOTIFICATION_SHOW_ERROR_VIEW                 @"GLPShowErrorView"

#define GLPNOTIFICATION_RELOAD_DATA_IN_CW               @"GLPReloadDataInCW"

#define GLPNOTIFICATION_VIDEO_PROCESSED                 @"GLPVideoProcessed"
#define GLPNOTIFICATION_VIDEO_POST_READY                @"GLPVidePostReady"

#define GLP_WEBSERVICE_VERSION                      @"1"
#define GLP_BASE_SERVER_URL                                ([NSString stringWithFormat:@"https://gleepost.com/api/v%@/", GLP_WEBSERVICE_VERSION])

#define GLP_TEST_WEBSERVICE_VERSION                 @"1"
#define GLP_TEST_SERVER_URL                                ([NSString stringWithFormat:@"https://dev.gleepost.com/api/v%@/", GLP_TEST_WEBSERVICE_VERSION])

//The url is not changed from here anymore go to GLPServerPathManager for more.
#define GLP_BASE_URL                                GLP_BASE_SERVER_URL

#define GLP_APP_FONT                                @"Khmer Sangam MN"
#define GLP_APP_FONT_BOLD                           @"Khmer UI"
#define GLP_UNIVERS_LIGHT_BOLD                      @"Univers 45 Light"
#define GLP_UNIVERS_CE_LIGHT                        @"Univers CE 45 Light"
#define GLP_CAMPUS_WALL_TITLE_FONT                  @"HelveticaNeue-Medium"
#define GLP_TITLE_FONT                              @"HelveticaNeue"
#define GLP_MESSAGE_FONT                            @"HelveticaNeue"
#define GLP_HELV_NEUE_LIGHT                         @"HelveticaNeue-Light"

#define kGLPNumberOfPosts                           20

// DDLog
#ifdef ENV_DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_ERROR;
#endif

// Google Analytics Constants
#define GLP_GAI_TRACK_ID                    @"UA-30919790-2"

// Flurry Analytics Constants
#define FLURRY_API_KEY                      @"4PV5V9P8W43WN3Y8TYGB"

#endif
