

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "RestCheckin.h"
#import "RestClient.h"
#import <FacebookSDK/FacebookSDK.h>
#import "RestSettings.h"
#import "Config.h"
#import "FacebookHelper.h"
#import "UAPush.h"
#import "UAirship.h"
#import <Crashlytics/Crashlytics.h>

#import "NotificationHandler.h"
#import "ThreadedUpdates.h"
#import "FoursquareHelper.h"
#import "CheckinViewController.h"
#import "InitialViewController.h"
#import <FlurrySDK/Flurry.h>

@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize privateWriterContext = __privateWriterContext;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Config sharedConfig];
    [TestFlight takeOff:@"7919882d-ee86-4d6d-8eff-79e5907b2eb9"];
    [Flurry startSession:@"M3PMPPG8RS75H53HKQRK"];
    
    
    
    NSMutableDictionary *takeOffOptions = [[NSMutableDictionary alloc] init];
    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
    
    NSMutableDictionary *airshipConfigOptions = [[NSMutableDictionary alloc] init];
    
    [airshipConfigOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
    
    [airshipConfigOptions setValue:[Config sharedConfig].airshipKeyDev forKey:@"DEVELOPMENT_APP_KEY"];
    [airshipConfigOptions setValue:[Config sharedConfig].airshipSecretDev forKey:@"DEVELOPMENT_APP_SECRET"];
    [airshipConfigOptions setValue:[Config sharedConfig].airshipKeyProd  forKey:@"PRODUCTION_APP_KEY"];
    [airshipConfigOptions setValue:[Config sharedConfig].airshipSecretProd  forKey:@"PRODUCTION_APP_SECRET"];
    
#ifdef DEBUG
    [airshipConfigOptions setValue:@"NO" forKey:@"APP_STORE_OR_AD_HOC_BUILD"];
#else
    [airshipConfigOptions setValue:@"YES" forKey:@"APP_STORE_OR_AD_HOC_BUILD"];
#endif
    
    [takeOffOptions setValue:airshipConfigOptions forKey:UAirshipTakeOffOptionsAirshipConfigKey];
    
    [UAirship takeOff:takeOffOptions];
    
    ALog(@"Take off options %@", takeOffOptions);
    // Populate AirshipConfig.plist with your app's info from https://go.urbanairship.com
    [UAirship takeOff:takeOffOptions];
    
    // Set the icon badge to zero on startup (optional)
    [[UAPush shared] resetBadge];
    
    // Register for remote notfications with the UA Library. This call is required.
    [[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeSound |
                                                         UIRemoteNotificationTypeAlert)];
    
//    // Handle any incoming incoming push notifications.
//    // This will invoke `handleBackgroundNotification` on your UAPushNotificationDelegate.
//    [[UAPush shared] handleNotification:[launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey]
//                       applicationState:application.applicationState];
    
    
    [UAPush shared].delegate = [NotificationHandler shared];
    [[UAPush shared] setAutobadgeEnabled:YES];

    [self setupTheme];
    // Do not try to load the managed object context directly from the application delegate. It should be 
    // handed off to the next controllre during prepareForSegue
    
    [self setupSettingsFromServer];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [Crashlytics startWithAPIKey:@"cbbca2d940f872c4617ddb67cf20ec9844d036ea"];
    
    [FBSettings publishInstall:[Config sharedConfig].fbAppId];
    
    InitialViewController *vc = (InitialViewController *)self.window.rootViewController;
    vc.managedObjectContext = self.managedObjectContext;
    self.currentUser = [User currentUser:self.managedObjectContext];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    DLog(@"Application WILL RESIGN");
    [self writeToDisk];
    [self.delegate applicationWillExit];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    DLog(@"Application GOES BACKGROUND");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{ 
    
    DLog(@"AppDelegate#applicationDidBecomeActive");
    [FBSession.activeSession handleDidBecomeActive];
    [ThreadedUpdates shared].managedObjectContext = self.managedObjectContext;
    

    [self.delegate applicationWillWillStart];
    [Location sharedLocation].delegate = self;
    [[Location sharedLocation] updateUntilDesiredOrTimeout:15.0];
    
    // Reset badge count
    [[UAPush shared] resetBadge];
    DLog(@"current user token %@",[RestUser currentUserToken] );
    DLog(@"current user id %@", [RestUser currentUserId] );
    
    [NotificationHandler shared].currentUser = self.currentUser;
    [NotificationHandler shared].managedObjectContext = self.managedObjectContext;
    DLog(@"Got user %@", self.currentUser);
    DLog(@"User status %d", self.currentUser.registrationStatus.intValue);
    
    // Since the user is already logged in, this fires a call back to the server to verify that the user's token is still valid
    // It also updates the user's settings from the server. 
    if ([RestUser currentUserToken]) {
        //[SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING", @"Loading dialog")];
        // Verify the user's access token is still valid
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            DLog(@"FACEBOOK SESSION DETECTED");
            //[lc fbLoginPressed:self];
        } else {
            [self.managedObjectContext performBlock:^{
                [RestUser reload:^(RestUser *restUser) {
                    
                    self.currentUser = [User findOrCreateUserWithRestUser:restUser inManagedObjectContext:self.managedObjectContext];
                    [self.currentUser updateUserSettings];
                                        
                    [[ThreadedUpdates shared] loadNotificationsPassivelyForUser:self.currentUser];
                    [[ThreadedUpdates shared] loadFeedPassively];
                }
                onError:^(NSError *error) {
                    if (error.code == 401)
                        //[lc didLogout];
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                }];
            }];
        }
        
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    DLog(@"Application WILL TERMINTE");
    [UAirship land];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)resetCoreData {
    LoginViewController *lc = ((LoginViewController *) self.window.rootViewController);
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Piclar.sqlite"];
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
    __persistentStoreCoordinator = nil;
    __managedObjectContext = nil;
    __managedObjectModel = nil;
    __privateWriterContext = nil;
    lc.managedObjectContext = self.managedObjectContext;
    
}

- (void)writeToDisk {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.privateWriterContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            [Flurry logError:@"FAILED_CONTEXT_SAVE" message:[error description] error:error];
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }

}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            [Flurry logError:@"FAILED_CONTEXT_SAVE" message:[error description] error:error];
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}


#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __privateWriterContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [__privateWriterContext setPersistentStoreCoordinator:coordinator];
        
        // create main thread MOC
        __managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        __managedObjectContext.parentContext = __privateWriterContext;
        
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Piclar" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Piclar.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
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
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        [__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
        [Flurry logError:@"FAILED_PERSISTENT_STORE" message:[error description] error:error];
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark LocationDelegate methods

- (void)locationStoppedUpdatingFromTimeout
{
    [[ThreadedUpdates shared] loadPlacesPassivelyWithCurrentLocation];

//    [Flurry logEvent:@"FAILED_TO_GET_DESIRED_LOCATION_ACCURACY_APP_LAUNCH"];
}

- (void)didGetBestLocationOrTimeout
{
    ALog(@"");
    [[ThreadedUpdates shared] loadPlacesPassivelyWithCurrentLocation];
//    [Flurry logEvent:@"DID_GET_DESIRED_LOCATION_ACCURACY_APP_LAUNCH"];
}

- (void)failedToGetLocation:(NSError *)error
{
    DLog(@"%@", error);
//    [Flurry logEvent:@"FAILED_TO_GET_ANY_LOCATION_APP_LAUNCH"];
}


#pragma mark - Facebook callback for web based authentication
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    ALog(@"sourceApplication  is %@ url %@, %@annotation", sourceApplication, url, annotation);
    
    if ([[url absoluteString] rangeOfString:@"foursquare"].location != NSNotFound) {
        // stringToSearch is present in myString
        ALog(@"handling foursquare");
        return [[FoursquareHelper shared].foursquare handleOpenURL:url];
    } else {
        return [FBSession.activeSession handleOpenURL:url];
    }
    
}

- (void)setupSettingsFromServer {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *vkScopes = [defaults objectForKey:@"vkScopes"];
    NSString *vkClientId =  [defaults objectForKey:@"vkClientId"];
    NSString *vkUrl =  [defaults objectForKey:@"vkUrl"];
    DLog(@"saved settings %@, %@, %@", vkScopes, vkClientId, vkUrl);
    if (!vkScopes || !vkClientId || !vkUrl) {
        RestSettings *restSettings = [RestSettings loadSettings];
        DLog(@"restSettings %@", restSettings);
        if (restSettings) {
            [defaults setObject:restSettings.vkScopes forKey:@"vkScopes"];
            [defaults setObject:restSettings.vkClientId forKey:@"vkClientId"];
            [defaults setObject:restSettings.vkUrl forKey:@"vkUrl"];
            [defaults synchronize];
            [[Config sharedConfig] updateWithServerSettings];
        }
    }
}

#pragma mark - Appearance settings
// You can set styles for any UI element that implements the appearance delegate
- (void)setupTheme {
    //Navigation bar
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    [navigationBarAppearance setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
    navigationBarAppearance.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue" size:18.0], UITextAttributeFont,
                                                   RGBACOLOR(212, 82, 88, 1.0), UITextAttributeTextColor,
                                                   [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset, nil];
    
    //Tool bar
    UIToolbar *toolBarAppearance = [UIToolbar appearance];
    [toolBarAppearance setBackgroundImage:[UIImage imageNamed:@"toolbar.png"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    
    //Search bar
    UISearchBar *searchBarAppearance = [UISearchBar appearance];
    [searchBarAppearance setBackgroundImage:[UIImage imageNamed:@"search-bar.png"]];
    
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor grayColor]];
    
//    UIBarButtonItem *barButtonItemAppearance = [UIBarButtonItem appearance];
//    [barButtonItemAppearance setTintColor:RGBCOLOR(244, 244, 244)];
//    [barButtonItemAppearance setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue" size:13.0], UITextAttributeFont, RGBCOLOR(242.0, 95.0, 144.0), UITextAttributeTextColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset, nil] forState:UIControlStateNormal];
//    [barButtonItemAppearance setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue" size:13.0], UITextAttributeFont, RGBCOLOR(242.0, 95.0, 144.0), UITextAttributeTextColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset, nil] forState:UIControlStateDisabled];
    
    
    //Search bar cancel button
    //[[UIButton appearanceWhenContainedIn:[BaseSearchBar class], nil] setBackgroundImage:[UIImage imageNamed:@"enter-button.png"] forState:UIControlStateNormal];
    //[[SearchCancelButtonView appearanceWhenContainedIn:[PlaceSearchViewController class], nil] setBackgroundImage:[UIImage imageNamed:@"enter-button-pressed.png"] forState:UIControlStateHighlighted]
}



#pragma mark LogoutDelegate methods

- (void)didLogout {
    
    LoginViewController *lc = ((LoginViewController *) self.window.rootViewController);
    [lc didLogout];
}

#pragma mark - UrbanAirship configuration
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Updates the device token and registers the token with UA
    // FYI: Notifcations do now work with ios simulator
    ALog(@"deviceToken %@", deviceToken);
    [[UAPush shared] registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    ALog(@"Received remote notification: %@", userInfo);
    
    [[UAPush shared] handleNotification:userInfo applicationState:application.applicationState];
    [[UAPush shared] resetBadge]; // zero badge after push received
}



@end
