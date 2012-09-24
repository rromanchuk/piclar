

#import "AppDelegate.h"
#import "RestPlace.h"
#import "User+Rest.h"
#import "LoginViewController.h"
#import "RestCheckin.h"
#import "RestClient.h"
#import "BaseSearchBar.h"
#import <FacebookSDK/FacebookSDK.h>
#import "RestSettings.h"
#import "Config.h"
@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"48dccbefa39c7003d1e60d9d502b9700_MTA2OTk5MjAxMi0wNy0wNSAwMToyMzozMi4zOTY4Mzc"];
    [Flurry startSession:@"M3PMPPG8RS75H53HKQRK"];
    [self setupTheme];
    // Do not try to load the managed object context directly from the application delegate. It should be 
    // handed off to the next controllre during prepareForSegue
    ((LoginViewController *) self.window.rootViewController).managedObjectContext = self.managedObjectContext;
    
    [self setupSettingsFromServer];
        
        
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    DLog(@"");
    [self saveContext];
    [self.delegate applicationWillExit];
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
    
    DLog(@"AppDelegate#applicationDidBecomeActive");
    [self.delegate applicationWillWillStart];
    Location *location = [Location sharedLocation];
    location.delegate  = self;
    [location updateUntilDesiredOrTimeout:5.0];
    
    LoginViewController *lc = ((LoginViewController *) self.window.rootViewController);
    DLog(@"current user token %@",[RestUser currentUserToken] );
    DLog(@"current user id %@", [RestUser currentUserId] );

    if([RestUser currentUserId]) {
        lc.currentUser = [User userWithExternalId:[RestUser currentUserId] inManagedObjectContext:self.managedObjectContext];
        DLog(@"Got user %@", lc.currentUser);
        if(lc.currentUser)
            [lc performSegueWithIdentifier:@"CheckinsIndex" sender:lc];
    }
    
        
    if ([RestUser currentUserToken]) {
        //[SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING", @"Loading dialog")];
        // Verify the user's access token is still valid
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            DLog(@"FACEBOOK SESSION DETECTED");
            [lc openSession];
        } else {
            [RestUser reload:^(RestUser *restUser) {
                [lc.currentUser setManagedObjectWithIntermediateObject:restUser];
                [lc.currentUser updateWithRestObject:restUser];
                [Flurry setUserID:[NSString stringWithFormat:@"%@", lc.currentUser.externalId]];
                if ([lc.currentUser.gender boolValue]) {
                    [Flurry setGender:@"m"];
                } else {
                    [Flurry setGender:@"f"];
                }
                
            }
                     onError:^(NSString *error) {
#warning LOG USER OUT IF UNAUTHORIZED
                         
                     }];
 
        }
        
    }
}

- (void)setupTheme {
    //Navigation bar
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    [navigationBarAppearance setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
    navigationBarAppearance.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue" size:18.0], UITextAttributeFont,
                                                   RGBACOLOR(242.0, 95.0, 144.0, 1.0), UITextAttributeTextColor,
                                                   [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset, nil];
    
    //Tool bar
    UIToolbar *toolBarAppearance = [UIToolbar appearance];
    [toolBarAppearance setBackgroundImage:[UIImage imageNamed:@"toolbar.png"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    
    //Search bar
    UISearchBar *searchBarAppearance = [UISearchBar appearance];
    [searchBarAppearance setBackgroundImage:[UIImage imageNamed:@"search-bar.png"]];
    
    UIBarButtonItem *barButtonItemAppearance = [UIBarButtonItem appearance];
    [barButtonItemAppearance setTintColor:RGBCOLOR(244, 244, 244)];
    [barButtonItemAppearance setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue" size:13.0], UITextAttributeFont, RGBCOLOR(242.0, 95.0, 144.0), UITextAttributeTextColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset, nil] forState:UIControlStateNormal];
    [barButtonItemAppearance setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue" size:13.0], UITextAttributeFont, RGBCOLOR(242.0, 95.0, 144.0), UITextAttributeTextColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset, nil] forState:UIControlStateDisabled];
    //Search bar cancel button
    //[[UIButton appearanceWhenContainedIn:[BaseSearchBar class], nil] setBackgroundImage:[UIImage imageNamed:@"enter-button.png"] forState:UIControlStateNormal];
    //[[SearchCancelButtonView appearanceWhenContainedIn:[PlaceSearchViewController class], nil] setBackgroundImage:[UIImage imageNamed:@"enter-button-pressed.png"] forState:UIControlStateHighlighted]
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)resetCoreData {
    LoginViewController *lc = ((LoginViewController *) self.window.rootViewController);
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Explorer.sqlite"];
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
    __persistentStoreCoordinator = nil;
    __managedObjectContext = nil;
    __managedObjectModel = nil;
    lc.managedObjectContext = self.managedObjectContext;
    
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
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
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
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Explorer" withExtension:@"momd"];
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
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Explorer.sqlite"];
    
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

// LocationDelegate

#pragma mark LocationDelegate methods

- (void)locationStoppedUpdatingFromTimeout 
{
    [Flurry logEvent:@"FAILED_TO_GET_DESIRED_LOCATION_ACCURACY_APP_LAUNCH"];
}

#warning start fetching results from server on low prioirty thread
- (void)didGetBestLocationOrTimeout
{
    DLog(@"Best location found");
    [Flurry logEvent:@"DID_GET_DESIRED_LOCATION_ACCURACY_APP_LAUNCH"];
}

- (void)failedToGetLocation:(NSError *)error
{
    DLog(@"PlaceSearch#failedToGetLocation: %@", error);
    [Flurry logEvent:@"FAILED_TO_GET_ANY_LOCATION_APP_LAUNCH"];
}



- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)setupSettingsFromServer {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *vkScopes = [defaults objectForKey:@"vkScopes"];
    NSString *vkClientId =  [defaults objectForKey:@"vkClientId"];
    NSString *vkUrl =  [defaults objectForKey:@"vkUrl"];
    DLog(@"saved settings %@, %@, %@", vkScopes, vkClientId, vkUrl);
    if (!vkScopes || !vkClientId || !vkUrl) {
        RestSettings *restSettings = [RestSettings loadSettings];
        if (restSettings) {
            vkScopes = restSettings.vkScopes;
            vkClientId = restSettings.vkClientId;
            vkUrl = restSettings.vkUrl;
            [defaults setObject:vkScopes forKey:@"vkScopes"];
            [defaults setObject:vkClientId forKey:@"vkClientId"];
            [defaults setObject:vkUrl forKey:@"vkUrl"];
            [defaults synchronize];
            [[Config sharedConfig] updateWithServerSettings];
        }
    }
}

#pragma mark LogoutDelegate methods

- (void)didLogout {
    
    LoginViewController *lc = ((LoginViewController *) self.window.rootViewController);
    [lc didLogout];
    [self resetCoreData];
}
@end
