//
//  AppDelegate.h
//  social
//
//  Created by Ryan Romanchuk on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "ApplicationLifecycleDelegate.h"
#import "UserSettingsController.h"
#import "NotificationHandler.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, LocationDelegate, LogoutDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *privateWriterContext;

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (weak, nonatomic) id <ApplicationLifecycleDelegate> delegate;
@property (strong, nonatomic) NotificationHandler *notificationHandler;
- (void)resetCoreData;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
@end


