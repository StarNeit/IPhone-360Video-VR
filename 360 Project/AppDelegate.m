//
//  AppDelegate.m
//  360 Project
//
//  Created by Hitaishin Technologies on 12/5/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//
//com.creativeinnovations.360mea
#import "AppDelegate.h"
#import "VIDVideoPlayerViewController.h"
#import "InfoViewController.h"
#import "WBTabBarController.h"
#import "PlayViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAILogger.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Branch.h"

@interface AppDelegate ()
@end


LoadingView *loadingView;
#define APP_NAME @"360 VUZ"

@implementation AppDelegate
@synthesize downloadFlag;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize arrVideos;
@synthesize strDeviceToken,isDownloading;

@synthesize session;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-77322417-1"];
    
    [Fabric with:@[[Crashlytics class]]];
    
    [[NSURLCache sharedURLCache] setMemoryCapacity:(20*1024*1024)];
    [[NSURLCache sharedURLCache] setDiskCapacity:(200*1024*1024)];
    isDownloading = @"NO";
    
    ///// New code
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
#ifdef __IPHONE_8_0
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert
                                                                                             | UIUserNotificationTypeBadge
                                                                                             | UIUserNotificationTypeSound) categories:nil];
        [application registerUserNotificationSettings:settings];
#endif
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    
    // ****************************************************************************
    // Your Facebook application id is configured in Info.plist.
    // ****************************************************************************
    // Whenever a person opens the app, check for a cached session
    
    
    // Create a LoginUIViewController instance where we will put the login button
   // InitialViewController *customLoginViewController = [[InitialViewController alloc] init];
    //self.customLoginViewController = customLoginViewController;
    
    // Set loginUIViewController as root view controller
    //[[self window] setRootViewController:customLoginViewController];
    
    
    
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        NSLog(@"Found a cached session");
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *fsession, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:fsession state:state error:error];
                                      }];
        
        // If there's no cached session, we will show a login button
    } else {
       // UIButton *loginButton = [self.customLoginViewController loginButton];
        //[loginButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
        
        NSLog(@"Please login");
    }
    
    
    Branch *branch = [Branch getInstance];
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        if (!error) {
            // params are the deep linked params associated with the link that the user clicked -> was re-directed to this app
            // params will be empty if no data found
            // ... insert custom logic here ...
            NSLog(@"params: %@", params.description);
        }
    }];
    
//    [branch accountForFacebookSDKPreventingAppLaunch];
    
    return YES;
}


/// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        [self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            //[self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                //[self showMessage:alertText withTitle:alertTitle];
                
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                //[self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}

// Show the user the logged-out UI
- (void)userLoggedOut
{
    // Set the button title as "Log in with Facebook"
    //UIButton *loginButton = [self.shareViewController loginButton];
   // [loginButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
    
    // Confirm logout message
    //[self showMessage:@"You're now logged out" withTitle:@""];
}

// Show the user the logged-in UI
- (void)userLoggedIn
{
    // Set the button title as "Log out"
   // UIButton *loginButton = self.shareViewController.loginButton;
    //[loginButton setTitle:@"Log out" forState:UIControlStateNormal];
    
    // Welcome message
   // [self showMessage:@"You're now logged in" withTitle:@"Welcome!"];
    
}

# pragma mark - Facebook methdos
- (void)logoutFromFb
{
    FBSession* fbSession = self.session;
    [fbSession closeAndClearTokenInformation];
    [FBSession.activeSession closeAndClearTokenInformation];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isUserLogIn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* facebookCookies = [cookies cookiesForURL:[NSURL URLWithString:@"http://login.facebook.com"]];
    
    for (NSHTTPCookie* cookie in facebookCookies) {
        [cookies deleteCookie:cookie];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return __persistentStoreCoordinator;
}
/*
#pragma mark - Application's Documents directory
- (BOOL)application:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray * _Nullable))restorationHandler {
    
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        //NSURL *url = userActivity.webpageURL;
        //[self handleUniversalLink:url application:application];
    }
//    else if ([userActivity.activityType isEqualToString:CSSearchableItemActionType]) {
//        
//        NSString *searchIndexUniqueId = userActivity.userInfo[CSSearchableItemActivityIdentifier];
//        
//        if(searchIndexUniqueId)
//        {
//            if ([searchIndexUniqueId isEqualToString:@"help.php"]) {
//                //[self startHelpMenu];
//            }
//            else if ([searchIndexUniqueId isEqualToString:@"user_profile.php"]) {
//                //[self startUserProfile];
//            }
//            else if ([searchIndexUniqueId isEqualToString:@"upgrade.php"]) {
//                //[self startUpgradeMenu];
//            }
//            
//            //[Tune applicationDidOpenURL:searchIndexUniqueId
//             //         sourceApplication:@"spotlight"];
//        }
//    }
    return true;
}
//-(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler{
//    if ([userActivity.activityType isEqualToString: NSUserActivityTypeBrowsingWeb])
//    {
//        NSURL *url = userActivity.webpageURL;
//        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        UINavigationController *navigationController = (UINavigationController *)_window.rootViewController;
//        if ([url.pathComponents containsObject:@"home"]) {
//            [navigationController pushViewController:[storyBoard instantiateViewControllerWithIdentifier:@"HomeScreenId"] animated:YES];
//        }else if ([url.pathComponents containsObject:@"about"]){
//            [navigationController pushViewController:[storyBoard instantiateViewControllerWithIdentifier:@"AboutScreenId"] animated:YES];
//        }
//    }
//    return YES;
//}
 */
- (BOOL)application:(UIApplication *)application  openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // pass the url to the handle deep link call
    [[Branch getInstance] handleDeepLink:url];
    
    if ([url.scheme isEqualToString: @"mea"]) {
        // check our `host` value to see what screen to display
        //TODO you can also pass parameters - e.g. birdland://home?refer=twitter
       
        //NSString *v_id = [[url absoluteString] substringFromIndex: [[url absoluteString] length] - 2];
        NSArray *myArray = [[url absoluteString] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
        NSString *v_id = myArray[1];
        NSLog(@"%@",v_id);
        [self goForVideoPlay:v_id];
    } else {
        NSLog(@"We were not opened with mea.");
        return [FBSession.activeSession handleOpenURL:url];
    }
    
    BOOL urlWasHandled =
    [FBAppCall handleOpenURL:url sourceApplication:sourceApplication  fallbackHandler:
     ^(FBAppCall *call) {
         // Parse the incoming URL to look for a target_url parameter
         NSString *query = [url query];
         NSDictionary *params = [self parseURLParams:query];
         // Check if target URL exists
         NSString *appLinkDataString = [params valueForKey:@"al_applink_data"];
         if (appLinkDataString) {
             NSError *error = nil;
             NSDictionary *applinkData =
             [NSJSONSerialization JSONObjectWithData:[appLinkDataString dataUsingEncoding:NSUTF8StringEncoding]
                                             options:0  error:&error];
             if (!error &&
                 [applinkData isKindOfClass:[NSDictionary class]] &&
                 applinkData[@"target_url"]) {
                 self.refererAppLink = applinkData[@"referer_app_link"];
                 NSString *targetURLString = applinkData[@"target_url"];
                 // Show the incoming link in an alert
                 // Your code to direct the user to the
                 // appropriate flow within your app goes here
                 [[[UIAlertView alloc] initWithTitle:@"Received link:"
                                             message:targetURLString
                                            delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil] show];
             }
         }
     }];
    
    //return [self.session handleOpenURL:url];
    return urlWasHandled;
}


// Respond to Universal Links
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    BOOL handledByBranch = [[Branch getInstance] continueUserActivity:userActivity];
    
    return handledByBranch;
}



// A function for parsing URL parameters
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1]
                         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        NSString *message= [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
        
        UIAlertView *alert11 = [[UIAlertView alloc] initWithTitle:@"360 VUZ" message:message delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil,nil];
        [alert11 show];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationRecieved" object:nil];
    }
}
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    //gettiing and parsing device token.
    NSString* deviceTokenApple = [[[[deviceToken description]
                                    stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                   stringByReplacingOccurrencesOfString: @">" withString: @""]
                                  stringByReplacingOccurrencesOfString: @" " withString: @""];
    //
//        UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"360 App" message:deviceTokenApple delegate:nil cancelButtonTitle:@"Dismise"otherButtonTitles:nil,nil];
//        [alert1 show];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    // saving an NSString
    [prefs setValue:deviceTokenApple forKey:@"deviceToken"];
    [prefs synchronize];
    strDeviceToken=[NSString stringWithString:deviceTokenApple];

}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    
    if ([identifier isEqualToString:@"declineAction"]){
        
    }
    else if ([identifier isEqualToString:@"answerAction"]){
        
    }
}
#endif

+ (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if ([downloadFlag isEqualToString:@"yes"] ) {
       // return UIInterfaceOrientationMaskPortrait;
    //}else{
        
   // UINavigationController *nav=((UINavigationController*)((WBTabBarController*)[AppDelegate topMostController]).selectedViewController);

//      if(/*[[nav.viewControllers lastObject] isKindOfClass:[InfoViewController class]]|*/[[nav.viewControllers lastObject] isKindOfClass:[PlayViewController class]]){
        
        return UIInterfaceOrientationMaskLandscapeLeft;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}




// fatch data from server after redirecting via App Linking

 
-(void)goForVideoPlay:(NSString *)v_id{
 
 
 self.dataResponse=[NSMutableData data];
 
 NSMutableDictionary *dictPost=[NSMutableDictionary new];
 
 [dictPost setObject:v_id forKey:@"video_id"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictPost
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
 
 NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
 NSData *jsonDataNew = [jsonString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
 
 NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@app_single_video",Default_URL]];
 
 NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonDataNew length]];
 
 NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
 [request setHTTPMethod:@"POST"];
 [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
 [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
 [request setHTTPBody:jsonDataNew];
    
 if ([Global isReachable]) {
 loadingView = [LoadingView loadingViewInView:self.window withText:@"Please Wait...."];
 [NSURLConnection connectionWithRequest:request delegate:self];
 }else{
 [Global showAlertMessageWithOkButtonAndTitle:@"360 VUZ" andMessage:@"Internet is not connected!!"];
 }
 
 }
 #pragma mark Connetion Delegate
 - (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
 {
 NSLog(@"didReceiveResponse %s##### response  %@",__FUNCTION__,response);
 [self.dataResponse setLength:0];
 //[resData setLength:0];
 }
 
 - (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
 {
 [self.dataResponse appendData:data];
 
 }
 
 - (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
 {
 @try {
 NSLog(@"didFailWithError %s   --- %@ ",__FUNCTION__,[error description]);
 [Global showAlertMessageWithOkButtonAndTitle:APP_NAME andMessage:[(NSString*)[error userInfo] valueForKey:@"NSLocalizedDescription"]];
 [loadingView removeView];
 }
 @catch (NSException *exception) {
 NSLog(@"didFailWithError %s   --- %@ ",__FUNCTION__,exception);
 [Global showAlertMessageWithOkButtonAndTitle:APP_NAME andMessage:[exception reason]];
 [loadingView removeView];
 }
 @finally {
 
 }
 }
 
 
 - (void)connectionDidFinishLoading:(NSURLConnection *)connection
 {
 NSLog(@"connectionDidFinishLoading %s",__FUNCTION__);
 [loadingView removeView];
 
 NSMutableDictionary *dict=[[[NSJSONSerialization JSONObjectWithData:self.dataResponse options:0 error:nil]valueForKey:@"result"]  mutableCopy];
 arrVideos =[dict objectForKey:@"videos"];
 
 if (arrVideos.count>0) {

 // redirect to video player page
     //PlayViewController *pc = [[PlayViewController alloc] init];
     NSDictionary *dictionary = [arrVideos objectAtIndex:0];
     NSString* stringURL =[dictionary  objectForKey:@"video_link"];
     NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
     [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
     self.downloadFlag=@"yes";
     
     /*[self.window.rootViewController presentViewController:pc
                                                  animated:NO
                                                completion:nil];
     
     */
     //self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"videoPlayer"];
     
     UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                              bundle: nil];
     PlayViewController *pc = (PlayViewController *)[mainStoryboard                                                                 instantiateViewControllerWithIdentifier:@"videoPlayer"];
     pc.videoPath=stringURL;
     pc.flagPath=@"server";
     pc.videoDict = dictionary;
     pc.isComingFromDeepLinking = @"true";
     self.window.rootViewController = pc;
     
     
     
 }else{
 UILabel *recordNotFound=[[UILabel alloc]initWithFrame:CGRectMake(60, 350, 200,60)];
 recordNotFound.text=@"No Videos Available";
 recordNotFound.textColor=[UIColor whiteColor];
 recordNotFound.textAlignment=NSTextAlignmentCenter;
 recordNotFound.font=[UIFont fontWithName:@"MyriadPro-Semibold" size:22.0f];
 
 [self.window addSubview:recordNotFound];
 }
 }

@end
