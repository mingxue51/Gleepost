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
#define GLPNOTIFICATION_READ_RECEIPT_RECEIVED           @"GLPReadReceiptReceived"

#define GLPNOTIFICATION_SELECTED_IMAGES                 @"GLPSelectedImages"
#define GLPNOTIFICATION_UPLOADING_IMAGE_CHANGED_STATUS  @"GLPUploadingImageChangedStatus"
#define GLPNOTIFICATION_CHAT_IMAGE_UPLOADED             @"GLPChatImageUploaded"

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
#define GLPNOTIFICATION_NEW_GROUP_TO_BE_CREATED        @"GLPNewGroupToBeCreated"
#define GLPNOTIFICATION_NEW_GROUP_IMAGE_PROGRESS       @"GLPNewGroupImageProgress"

#define GLPNOTIFICATION_DISMISS_WALKTHROUGH             @"GLPDismissWalkthrough"

#define GLPNOTIFICATION_UPDATE_CATEGORY_LABEL           @"GLPUpdateCategoryLabel"

#define GLPNOTIFICATION_DISMISS_ERROR_VIEW              @"GLPDismissErrorView"
#define GLPNOTIFICATION_HIDE_ERROR_VIEW                 @"GLPHideErrorView"
#define GLPNOTIFICATION_SHOW_ERROR_VIEW                 @"GLPShowErrorView"

#define GLPNOTIFICATION_RELOAD_DATA_IN_CW               @"GLPReloadDataInCW"
#define GLPNOTIFICATION_RELOAD_DATA_IN_GVC              @"GLPReloadDataInGVC"
#define GLPNOTIFICATION_NEW_PENDING_POST                @"GLPNewPendingPostInGVC"


//#define GLPNOTIFICATION_VIDEO_PROCESSED                 @"GLPVideoProcessed"
#define GLPNOTIFICATION_VIDEO_POST_READY                @"GLPVidePostReady"
#define GLPNOTIFICATION_GROUP_VIDEO_POST_READY          @"GLPGroupVideoPostReady"
#define GLPNOTIFICATION_POST_EDITED                     @"GLPPostEdited"
#define GLPNOTIFICATION_POST_STARTED_EDITING            @"GLPPostIsBeingEdited"

#define GLPNOTIFICATION_VIDEO_PROGRESS_UPDATE           @"GLPVideoProgressUpdated"
#define GLPNOTIFICATION_VIDEO_PROGRESS_UPLOADING_COMPLETED  @"GLPVideoProgressUploadingCompleted"
#define GLPNOTIFICATION_GROUP_VIDEO_PROGRESS_UPDATE     @"GLPGroupVideoProgressUpdated"
#define GLPNOTIFICATION_PROGRESS_BAR_VISIBILITY         @"GLPProgressBarVisibility"
#define GLPNOTIFICATION_IMAGE_PROGRESS_UPDATE           @"GLPImageProgressUpdate"
#define GLPNOTIFICATION_PENDING_VIDEO_PROGRESS_UPDATE   @"GLPPendingVideoProgressUpdate"
#define GLPNOTIFICATION_CAMPUS_LIVE_IMAGE_LOADED         @"GLPCampusLiveImageLoaded"

#define GLPNOTIFICATION_VIDEO_READY                     @"GLPVideoReady"
#define GLPNOTIFICATION_VIDEO_LOADED                    @"GLPVideoLoaded"

#define GLPNOTIFICATION_SHOW_MORE_OPTIONS               @"GLPShowMoreOptions"
#define GLPNOTIFICATION_POST_CELL_VIEWS_UPDATE          @"GLPPostCellViewsUpdate"

#define GLPNOTIFICATION_REFRESH_PROFILE_CELL            @"GLPRefreshProfileCell"

#define GLPNOTIFICATION_CHANGE_IMAGE_PROGRESS           @"GLPChangeImageProgress"
#define GLPNOTIFICATION_CHANGE_GROUP_IMAGE_PROGRESS     @"GLPChangeGroupImageProgress"
#define GLPNOTIFICATION_CHANGE_GROUP_IMAGE_FINISHED     @"GLPChangeGroupImageFinished"

#define GLPNOTIFICATION_GROUP_IMAGE_LOADED              @"GLPGroupImageLoaded"
#define GLPNOTIFICATION_GROUPS_LOADED                   @"GLPGroupsLoaded"
#define GLPNOTIFICATION_POST_IMAGE_LOADED               @"GLPPostImageLoaded"

#define GLPNOTIFICATION_CAMPUS_LIVE_POSTS_FETCHED       @"GLPCampusLivePostsFetched"
#define GLPNOTIFICATION_CAMPUS_LIVE_SUMMARY_FETCHED     @"GLPCampusLiveSummaryFetched"
#define GLPNOTIFICATION_COMMENTS_FETCHED                @"GLPCommentsFetched"
#define GLPNOTIFICATION_CL_IMAGE_SHOULD_VIEWED          @"GLPCLImageShouldViewed"
#define GLPNOTIFICATION_CL_SHOW_MORE_OPTIONS            @"GLPCLShowMoreOptions"
#define GLPNOTIFICATION_CL_COMMENT_BUTTON_TOUCHED       @"GLPCLCommentButtonTouched"

#define GLPNOTIFICATION_CL_SHOW_SHARE_OPTIONS           @"GLPCLShowShareOptions"
#define GLPNOTIFICATION_RELOAD_CL_COMMENTS_LIKES        @"GLPReloadCLCommentsLikes"
#define GLPNOTIFICATION_CL_POST_TOUCHED                 @"GLPCLPostTouched"


#define GLPNOTIFICATION_GROUPS_FECTHED_AFTER_QUERY      @"GLPGroupsFetchedAfterQuery"
#define GLPNOTIFICATION_USER_GROUPS_LOADED              @"GLPUserGroupsLoaded"

#define GLPNOTIFICATION_GOING_BUTTON_TOUCHED            @"GLPGoingButtonTouched"
#define GLPNOTIFICATION_GOING_BUTTON_UNTOUCHED          @"GLPGoingButtonUntouched"

#define GLPNOTIFICATION_SEARCH_FOR_GROUPS               @"GLPSearchForGroups"

//GLPAttendingPostsManager
#define GLPNOTIFICATION_ATTENDING_POSTS_FETCHED         @"GLPAttendingPostsFetched"
#define GLPNOTIFICATION_ATTENDING_PREVIOUS_POSTS_FETCHED    @"GLPAttendingPreviousPostsFecthed"

//ProfileManager
#define GLPNOTIFICATION_USERS_POSTS_FETCHED             @"GLPUsersPostsFetched"
#define GLPNOTIFICATION_USERS_PREVIOUS_POSTS_FETCHED    @"GLPUsersPreviousPostsFetched"
#define GLPNOTIFICATION_USERS_DATA_FETCHED              @"GLPUsersDataFetched"
#define GLPNOTIFICATION_LOGGED_IN_USERS_DATA_FETCHED    @"GLPLoggedInUsersDataFetched"

//NSNotification name that removes all the NSNotifications observers from view controllers. (Usually after logout).
#define GLPNOTIFICATION_REMOVE_VC_NOTIFICATIONS         @"GLPRemoveVCNotifications"

//NSNotification name that is used for the messages between the GLPPollOperationManager and other poll objects.
#define GLPNOTIFICATION_POLL_VIEW_STATUS_CHANGED        @"GLPPollViewStatusChanged"

#define GLPNOTIFICATION_UPDATE_EMAIL_TO_VERIFICATION_VIEW   @"GLPUpdateEmailToVerificationView"

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
#define GLP_HELV_NEUE_MEDIUM                        @"HelveticaNeue-Medium"
//#define GLP_HELV_NEUE_BOLD                          @"HelveticaNeue-Bold"

#define kGLPNumberOfPosts                           20

// DDLog
#ifdef ENV_DEBUG
static const NSUInteger ddLogLevel = DDLogLevelVerbose;
#else
static const NSUInteger ddLogLevel = DDLogLevelError;
#endif

// Google Analytics Constants
#define GLP_GAI_TRACK_ID                    @"UA-30919790-2"

// Flurry Analytics Constants
#define FLURRY_API_KEY                      @"4PV5V9P8W43WN3Y8TYGB"

#endif
