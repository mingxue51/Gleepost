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

static NSString * const kCustomURLScheme    = @"gleepost";
static NSString * const kCustomURLHost      = @"verify";

@implementation AppDelegate

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
        initVC = [storyboard instantiateViewControllerWithIdentifier:@"MainTabBarController"];
    } else {
        initVC = [storyboard instantiateInitialViewController];
    }
    
    self.window.rootViewController = initVC;
    [self.window makeKeyAndVisible];
        
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    DDLogInfo(@"Application will become inactive");
    [[WebClient sharedInstance] stopWebSocket];
    [[GLPNetworkManager sharedInstance] stopNetworkOperations];
    
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
    
    if([[SessionManager sharedInstance] isLogged]) {
        [[WebClient sharedInstance] startWebSocket];
        [[GLPNetworkManager sharedInstance] startNetworkOperations];
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
                            [WebClientHelper showStandardErrorWithTitle:@"Error" andContent:@"An error occurred while logging in."];
                        }
                    }];
                } else {
                    [WebClientHelper showStandardErrorWithTitle:@"Error" andContent:@"An error occurred while verifying user account."];
                }
            }];
        }
    } else {
        [WebClientHelper showStandardErrorWithTitle:@"Error" andContent:@"An error occurred while handling the URL."];
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

@end
