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
#import "GLPApplicationHelper.h"
#import "UIApplication+SimulatorRemoteNotifications.h"
#import "GLPTabBarController.h"
#import "MessagesViewController.h"
#import "GLPConversationViewController.h"
#import "GLPNotificationManager.h"
#import "NSNotificationCenter+Utils.h"
#import "GLPPushManager.h"
#import "GLPFacebookConnect.h"
#import "GroupsViewController.h"
#import "GroupViewController.h"
#import "GLPPrivateProfileViewController.h"
#import "GLPProfileViewController.h"
#import "ContactsManager.h"
#import "FBAppCall.h"
#import "ViewPostViewController.h"
#import "GLPPostManager.h"
#import "AppearanceHelper.h"

static NSString * const kCustomURLScheme    = @"gleepost";
static NSString * const kCustomURLHost      = @"verify";
static NSString * const kCustomURLViewPost  = @"viewpost";

static int pnTestVariable = 0;

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
    
    if(!loggedIn && [GLPLoginManager shouldAutoLogin]) {
        UIViewController *signInVC = [storyboard instantiateViewControllerWithIdentifier:@"GLPSingInViewController"];
        [initVC presentViewController:signInVC animated:NO completion:nil];
    }

    
//    UIImage *backButtonImage = [[UIImage imageNamed:@"tabbar_tab"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 100, 0, 0)];
//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage  forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-10, backButtonImage.size.height/2) forBarMetrics:UIBarMetricsDefault];
        
    //That changes the default back button image.
    [AppearanceHelper makeBackDefaultButton];

    
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
        [[GLPNetworkManager sharedInstance] restartNetworkOperations];
    }

    
    // activate or reactivate web client
    //[[WebClient sharedInstance] activate];
    
    [[GLPFacebookConnect sharedConnection] handleDidBecomeActive];
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
    [[GLPPushManager sharedInstance] savePushToken:deviceToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Fail to register to push on Apple servers, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    DDLogInfo(@"Receive remote notification, current app state: %@", [GLPApplicationHelper applicationStateToString:application.applicationState]);
    
    pnTestVariable++;
    
    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPPNCount" object:self userInfo:@{@"pnCount": @(pnTestVariable)}];
    
    if(application.applicationState == UIApplicationStateInactive) {
        [self receivePushNotification:userInfo];
    }
}

- (void)receivePushNotification:(NSDictionary *)json
{
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
    
    
    
    DDLogInfo(@"Receive push notification: %@", json);
    
    if(!json[@"conv"] && !json[@"group-id"] && !json[@"adder-id"] && !json[@"accepter-id"] && !json[@"version"] && !json[@"liker-id"] && !json[@"commenter-id"]) {
        
        DDLogError(@"Converstion id or group id or added user or accepted user does not exist, abort");
        return;
    }
    
    if(json[@"conv"])
    {
        [self navigateToConversationWithJson:json];
    }
    else if(json[@"group-id"])
    {
        [self navigateToGroupWithJson:json];
    }
    else if(json[@"adder-id"])
    {
        [self navigateToUsersProfileWithJson:json withRemoteKey:[json[@"adder-id"] integerValue]];
    }
    else if (json[@"accepter-id"])
    {
        [self navigateToUsersProfileWithJson:json withRemoteKey:[json[@"accepter-id"] integerValue]];
    }
    else if (json[@"version"])
    {
        NSString *jsonVersion = json[@"version"];
        
        NSString *actualVersion = [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
        
        if(![jsonVersion isEqualToString:actualVersion])
        {
            [self navigateToGleepostApp];

        }
    }
    else if (json[@"liker-id"])
    {
        [self navigateToPostWithJson:json];
    }
    else if (json[@"commenter-id"])
    {
        [self navigateToPostWithJson:json];
    }
}

# pragma mark - Navigation from push notifications


-(void)navigateToPostWithJson:(NSDictionary *)json
{
    NSInteger postRemoteKey = [json[@"post-id"] integerValue];
    
    if(!_tabBarController) {
        DDLogError(@"Cannot find tab bar VC, abort");
        return;
    }
    
    if(_tabBarController.selectedIndex != 4) {
        UINavigationController *currentNavigationVC = (UINavigationController *) _tabBarController.selectedViewController;
        [currentNavigationVC popToRootViewControllerAnimated:NO];

        [_tabBarController setSelectedIndex:4];
    }
    
    
    DDLogInfo(@"Nav VC: %@", NSStringFromClass([_tabBarController.viewControllers[3] class]));
    UINavigationController *navVC = _tabBarController.viewControllers[3];
    
    DDLogInfo(@"Profile VC: %@", NSStringFromClass([navVC.viewControllers[0] class]));
    GLPProfileViewController *profileVC = navVC.viewControllers[0];
    
    [WebClientHelper showStandardLoaderWithTitle:@"Loading" forView:profileVC.view];

    
    //Navigate to notifications.
    profileVC.fromPushNotification = YES;
    
    ViewPostViewController *viewPostVC = [_tabBarController.storyboard instantiateViewControllerWithIdentifier:@"ViewPostViewController"];
    
    viewPostVC.isViewPostNotifications = YES;
    
    
    DDLogDebug(@"Post Remote Key push notification: %d", (int)postRemoteKey);

    [self navigateToPostWithPostRemoteKey:postRemoteKey withProfileVC:profileVC withViewPostVC:viewPostVC andBasicVC:navVC];
    
}

-(void)navigateToPostWithPostRemoteKey:(NSInteger)remoteKey withProfileVC:(GLPProfileViewController *)profileVC withViewPostVC:(ViewPostViewController *)viewPostVC andBasicVC:(UINavigationController *)basicVC
{
    
    //Load post.
    
    [GLPPostManager loadPostWithRemoteKey:remoteKey callback:^(BOOL success, GLPPost *post) {
        
        [WebClientHelper hideStandardLoaderForView:profileVC.view];
        
        if(success)
        {
            viewPostVC.post = post;
            //Add loaded post to view post VC.
            [viewPostVC setHidesBottomBarWhenPushed:YES];
            [basicVC setViewControllers:@[profileVC, viewPostVC] animated:YES];
        }
        else
        {
            [WebClientHelper showStandardErrorWithTitle:@"Failed to load post" andContent:@"Check your internet connection and try again"];
        }
    }];
    


}

-(void)navigateToGleepostApp
{
//    UINavigationController *currentNavigationVC = (UINavigationController *) _tabBarController.selectedViewController;
    
//    DDLogInfo(@"Nav VC: %@", NSStringFromClass([_tabBarController.viewControllers[_tabBarController.selectedIndex] class]));
//    UINavigationController *navVC = _tabBarController.viewControllers[_tabBarController.selectedIndex];
//    
//    DDLogInfo(@"Private Profile VC: %@", NSStringFromClass([navVC.viewControllers[0] class]));
//    UINavigationController *currentVC = navVC.viewControllers[0];
    
    [NSThread detachNewThreadSelector:@selector(openUrl:) toTarget:self withObject:nil];
}

-(void)openUrl:(id)sender
{
    //Navigate to the user in AppStore.
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/gb/app/gleepost/id820569024?mt=8&uo=4"]];
}

-(void)navigateToUsersProfileWithJson:(NSDictionary *)json withRemoteKey:(NSInteger)remoteKey
{
//    DDLogDebug(@"JSON: %@", json);
    
//    int remoteKey = [json[@"adder-id"] integerValue];
    
    if(!_tabBarController) {
        DDLogError(@"Cannot find tab bar VC, abort");
        return;
    }
    
    if(_tabBarController.selectedIndex != 3) {
        UINavigationController *currentNavigationVC = (UINavigationController *) _tabBarController.selectedViewController;
        [currentNavigationVC popToRootViewControllerAnimated:NO];
        [_tabBarController setSelectedIndex:3];
    }
    
    DDLogInfo(@"Nav VC: %@", NSStringFromClass([_tabBarController.viewControllers[3] class]));
    UINavigationController *navVC = _tabBarController.viewControllers[3];
    
    DDLogInfo(@"Private Profile VC: %@", NSStringFromClass([navVC.viewControllers[0] class]));
    GLPProfileViewController *profileVC = navVC.viewControllers[0];
    
    GLPPrivateProfileViewController *privateProfileVC = [_tabBarController.storyboard instantiateViewControllerWithIdentifier:@"GLPPrivateProfileViewController"];
    
    DDLogDebug(@"Remote Key push notification: %d", remoteKey);
    
    privateProfileVC.selectedUserId = remoteKey;
    
    [[ContactsManager sharedInstance] refreshContacts];
    
//    groupVC.group = group;
//    groupVC.fromPushNotification = YES;
    
    [navVC setViewControllers:@[profileVC, privateProfileVC] animated:NO];
    
}

-(void)navigateToGroupWithJson:(NSDictionary *)json
{
//    GLPGroup *group = [[GLPGroup alloc] initFromPushNotificationWithRemoteKey:[json[@"group-id"] integerValue]];
    
    if(!_tabBarController) {
        DDLogError(@"Cannot find tab bar VC, abort");
        return;
    }
    
    if(_tabBarController.selectedIndex != 3) {
        UINavigationController *currentNavigationVC = (UINavigationController *) _tabBarController.selectedViewController;
        [currentNavigationVC popToRootViewControllerAnimated:NO];
        [_tabBarController setSelectedIndex:3];
    }
    
//    DDLogInfo(@"Nav VC: %@", NSStringFromClass([_tabBarController.viewControllers[3] class]));
//    UINavigationController *navVC = _tabBarController.viewControllers[3];
//    
//    DDLogInfo(@"Contacts VC: %@", NSStringFromClass([navVC.viewControllers[0] class]));
//    ContactsViewController *contactsVC = navVC.viewControllers[0];
//    
//    GroupViewController *groupVC = [_tabBarController.storyboard instantiateViewControllerWithIdentifier:@"GroupViewController"];
//    groupVC.group = group;
//    groupVC.fromPushNotification = YES;
    
    
    DDLogInfo(@"Nav VC: %@", NSStringFromClass([_tabBarController.viewControllers[3] class]));
    UINavigationController *navVC = _tabBarController.viewControllers[3];
    
    DDLogInfo(@"Profile VC: %@", NSStringFromClass([navVC.viewControllers[0] class]));
    GLPProfileViewController *profileVC = navVC.viewControllers[0];
    
    //Navigate to notifications.
    profileVC.fromPushNotification = YES;
    
    
    [navVC setViewControllers:@[profileVC] animated:NO];

//    [navVC setViewControllers:@[contactsVC, groupVC] animated:NO];
}

-(void)navigateToConversationWithJson:(NSDictionary *)json
{
    GLPConversation *conversation = [[GLPConversation alloc] initFromPushNotificationWithRemoteKey:[json[@"conv"] integerValue]];
    
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL canHandleURLScheme = NO;
    
    DDLogInfo(@"URL scheme: %@",[url scheme]);
    
    
    //Handle navigate to post in case user shared post event.
    
//    if([[url scheme] isEqualToString:kCustomURLViewPost])
//    {
//        //Navigate to post.
//        [self navigateToPostWithUrl:url];
//        
//        canHandleURLScheme = YES;
//    }
    
    canHandleURLScheme = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication fallbackHandler:^(FBAppCall *call) {
        if([[call appLinkData] targetURL] != nil) {
            // get the object ID string from the deep link URL
            // we use the substringFromIndex so that we can delete the leading '/' from the targetURL
            NSString *objectId = [[[call appLinkData] targetURL].path substringFromIndex:1];
            
            // now handle the deep link
            // write whatever code you need to show a view controller that displays the object, etc.
            
            [self navigateToPostWithContent:objectId];
            
        } else {
            //
            DDLogInfo(@"%@",[NSString stringWithFormat:@"Unhandled deep link: %@", [[call appLinkData] targetURL]]);
        }
    }];
    
    
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
                    [GLPLoginManager loginWithIdentifier:[userDefaults authParameterName] andPassword:[userDefaults authParameterPass] shouldRemember:NO callback:^(BOOL success, NSString *errorMessage) {
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
        
//        [WebClientHelper showStandardErrorWithTitle:@"Error" andContent:@"An error occurred while handling the URL"];
    }
    
    //TODO: See if that is the appropriate way to do it. Possible it's bad way to do it.
    
    BOOL canHandleFBUrl = [[GLPFacebookConnect sharedConnection] handleOpenURL:url];
    
    DDLogDebug(@"Handle urls fb: %d - scheme: %d", canHandleFBUrl, canHandleURLScheme);

    
    
    return canHandleURLScheme || canHandleFBUrl;
}

-(void)navigateToPostWithContent:(NSString *)postUrlContent
{
    if([[SessionManager sharedInstance] isLogged])
    {
        NSArray* foo = [postUrlContent componentsSeparatedByString: @"/"];
        NSString* postRemoteKey = [foo objectAtIndex: 3];
        
        DDLogDebug(@"Post remote key: %@", postRemoteKey);
        
        [self navigateToPostWithRemoteKey:[postRemoteKey integerValue]];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Failed to load post from facebook"
                                    message:@"You need to be logged in, to see gleepost post"
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    
}

-(void)navigateToPostWithRemoteKey:(NSInteger)remoteKey
{
    if(!_tabBarController) {
        DDLogError(@"Cannot find tab bar VC, abort");
        return;
    }
    
//    if(_tabBarController.selectedIndex != 1) {
//        UINavigationController *currentNavigationVC = (UINavigationController *) _tabBarController.selectedViewController;
//        [currentNavigationVC popToRootViewControllerAnimated:NO];
//        [_tabBarController setSelectedIndex:1];
//    }
    
    UINavigationController *currentNavigationVC = (UINavigationController *) _tabBarController.selectedViewController;
    
//    DDLogInfo(@"Nav VC: %@", NSStringFromClass([_tabBarController.viewControllers[1] class]));
//    UINavigationController *navVC = _tabBarController.viewControllers[1];
    
    DDLogInfo(@"Current VC: %@", NSStringFromClass([currentNavigationVC class]));
    ViewPostViewController *viewPostVC = [_tabBarController.storyboard instantiateViewControllerWithIdentifier:@"ViewPostViewController"];

    
    [WebClientHelper showStandardLoaderWithTitle:@"Loading post" forView:currentNavigationVC.view];
    
    [GLPPostManager loadPostWithRemoteKey:remoteKey callback:^(BOOL sucess, GLPPost *post) {
        
        [WebClientHelper hideStandardLoaderForView:currentNavigationVC.view];
        
        if(sucess)
        {
            
            viewPostVC.post = post;
            viewPostVC.isFromCampusLive = YES;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewPostVC];
            navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            [currentNavigationVC presentViewController:navigationController animated:YES completion:nil];
        }
        else
        {
            [WebClientHelper showStandardErrorWithTitle:@"Failed to load post" andContent:@"Check your internet connection and try again"];
        }
    }];
    
    
}

# pragma mark - Facebook login handling
//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//    return [[GLPFacebookConnect sharedConnection] handleOpenURL:url];
//}

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
