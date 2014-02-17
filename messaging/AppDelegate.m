//
//  AppDelegate.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//


#import "AppDelegate.h"
#import "AFHTTPRequestOperationLogger.h"
#import "SessionManager.h"
#import "GLPLoginManager.h"
#import "GLPBackgroundRequestsManager.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "Flurry.h"
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "GLPNetworkManager.h"
#import "NSUserDefaults+GLPAdditions.h"
#import "GLPLoginManager.h"
#import "DCIntrospect.h"
#import "GLPCommonHelper.h"
#import "UIApplication+SimulatorRemoteNotifications.h"
#import "GLPTabBarController.h"
#import "MessagesViewController.h"
#import "GLPConversationViewController.h"

static NSString * const kCustomURLScheme    = @"gleepost";
static NSString * const kCustomURLHost      = @"verify";

@implementation AppDelegate

@synthesize tabBarController=_tabBarController;

// hello, boy
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupLogging];
    [self setupGoogleAnalytics];
    [self setupFlurryAnalytics];
    [self setupPush];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
    
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];

    BOOL loggedIn = [GLPLoginManager performAutoLogin];
    
    UIViewController *initVC;
    if(loggedIn) {
        
//        // check for push
//        if (launchOptions != nil) {
//            NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//            if (dictionary != nil) {
//                DDLogInfo(@"Application started from push notification");
//                [self receivePushNotification:dictionary];
//            }
//        }
        
        initVC = [storyboard instantiateViewControllerWithIdentifier:@"MainTabBarController"];
    } else {
        initVC = [storyboard instantiateInitialViewController];
    }


    self.window.rootViewController = initVC;
    [self.window makeKeyAndVisible];

#if TARGET_IPHONE_SIMULATOR
    [[DCIntrospect sharedIntrospector] start];
#endif

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    DDLogInfo(@"Application will become inactive");
    if([[SessionManager sharedInstance] isLogged]) {
        [[GLPNetworkManager sharedInstance] stopNetworkOperations];
    }
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    DDLogInfo(@"Application active");
    DDLogInfo(@"Application badge number: %d", application.applicationIconBadgeNumber);
    
    if([[SessionManager sharedInstance] isLogged]) {
        [[WebClient sharedInstance] markNotificationsRead:^(BOOL success) {
            if(success) {
                application.applicationIconBadgeNumber = 0;
            }
        }];
        [[GLPNetworkManager sharedInstance] restartNetworkOperations];
    }
    
    // activate or reactivate web client
    //[[WebClient sharedInstance] activate];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
}


# pragma mark - Push

- (void)setupPush
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"Push token registered on Apple servers: %@", deviceToken);
    [[SessionManager sharedInstance] registerPushToken:deviceToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Fail to register to push on Apple servers, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    DDLogInfo(@"Receive remote notification, current app state: %@", [GLPCommonHelper applicationStateToString:application.applicationState]);
    
    if(application.applicationState == UIApplicationStateInactive) {
        [self receivePushNotification:userInfo];
    }
}

- (void)receivePushNotification:(NSDictionary *)json
{
    DDLogInfo(@"Receive push notification: %@", json);
    
    if(!json[@"conv"]) {
        DDLogError(@"Converstion id does not exist, abort");
        return;
    }
    
    GLPConversation *conversation = [[GLPConversation alloc] initFromPushNotificationWithRemoteKey:[json[@"conv"] integerValue]];
    
//    GLPTabBarController *tabVC = nil;
//    
//    DDLogInfo(@"Root VC: %@", NSStringFromClass([self.window.rootViewController class]));
//    if([self.window.rootViewController isKindOfClass:[GLPTabBarController class]]) {
//        tabVC = (GLPTabBarController *)self.window.rootViewController;
//    } else {
//        UINavigationController *rootNavVC = (UINavigationController *)self.window.rootViewController;
//        for(UIViewController *vc in rootNavVC.viewControllers) {
//            DDLogInfo(@"Child VC: %@", NSStringFromClass([vc class]));
//            if([vc isKindOfClass:[GLPTabBarController class]]) {
//                tabVC = (GLPTabBarController *) vc;
//            }
//        }
//    }
    
    if(!_tabBarController) {
        DDLogError(@"Cannot find tab bar VC, abort");
        return;
    }
    
    if(_tabBarController.selectedIndex != 1) {
        UINavigationController *currentNavigationVC = (UINavigationController *) _tabBarController.selectedViewController;
        [currentNavigationVC popToRootViewControllerAnimated:NO];
        [_tabBarController setSelectedIndex:1];
    }
    
    DDLogInfo(@"Nav VC: %@", NSStringFromClass([_tabBarController.viewControllers[1] class]));
    UINavigationController *navVC = _tabBarController.viewControllers[1];
    
    DDLogInfo(@"Messages VC: %@", NSStringFromClass([navVC.viewControllers[0] class]));
    MessagesViewController *messagesVC = navVC.viewControllers[0];
    
    GLPConversationViewController *conversationVC = [_tabBarController.storyboard instantiateViewControllerWithIdentifier:@"ViewTopicViewController"];
    conversationVC.conversation = conversation;
    conversationVC.hidesBottomBarWhenPushed = YES;
    
    [navVC setViewControllers:@[messagesVC, conversationVC] animated:NO];
}


# pragma mark - Handle custom URL Scheme (gleepost://)

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL canHandleURLScheme = NO;
    
    if ([[url scheme] isEqualToString:kCustomURLScheme] && [[url host] isEqualToString:kCustomURLHost]) {
        canHandleURLScheme = YES;
        NSLog(@"handle URL : %@", url);
        
        NSString *relativePath = [url relativePath];
        if (relativePath) {
            NSString *token = [relativePath substringFromIndex:1];
            __weak AppDelegate *weakSelf = self;
            
            [WebClientHelper showStandardLoaderWithTitle:@"Verifying" forView:self.window.rootViewController.view];
            
            [[WebClient sharedInstance] verifyUserWithToken:token callback:^(BOOL success) {
                [WebClientHelper hideStandardLoaderForView:weakSelf.window.rootViewController.view];
                
                if (success) {
                    [WebClientHelper showStandardLoaderWithTitle:@"Logging in" forView:self.window.rootViewController.view];
                    
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [GLPLoginManager loginWithIdentifier:[userDefaults authParameterName] andPassword:[userDefaults authParameterPass] callback:^(BOOL success) {
                        [WebClientHelper hideStandardLoaderForView:weakSelf.window.rootViewController.view];
                        
                        if (success) {
                            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
                            UIViewController *initVC = [storyboard instantiateViewControllerWithIdentifier:@"MainTabBarController"];
                            
                            weakSelf.window.rootViewController = initVC;
                        } else {
                            [WebClientHelper showStandardErrorWithTitle:@"Error" andContent:@"An error occurred while logging in"];
                        }
                    }];
                } else {
                    [WebClientHelper showStandardErrorWithTitle:@"Error" andContent:@"An error occurred while verifying user account"];
                }
            }];
        }
    } else {
        [WebClientHelper showStandardErrorWithTitle:@"Error" andContent:@"An error occurred while handling the URL"];
    }
    
    return canHandleURLScheme;
}

# pragma mark - Setup Analytics

- (void)setupGoogleAnalytics {
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];
}

- (void)setupFlurryAnalytics {
    [Flurry setCrashReportingEnabled:NO];
    [Flurry setDebugLogEnabled:NO];
    [Flurry startSession:FLURRY_API_KEY];
}


# pragma mark - Logging
- (void)setupLogging
{
    [[AFHTTPRequestOperationLogger sharedLogger] startLogging];
    //[DDLog addLogger:[DDASLLogger sharedInstance]];
    
    DDTTYLogger *ttyLogger = [DDTTYLogger sharedInstance];
    [ttyLogger setColorsEnabled:YES];
    [DDLog addLogger:ttyLogger];
}


+ (UIBarButtonItem *)customBackButtonWithTarget:(id)target {
    UIButton *backButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:target action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(0, 0, 13, 21)];
    return [[UIBarButtonItem alloc] initWithCustomView:backButton];
}
@end
