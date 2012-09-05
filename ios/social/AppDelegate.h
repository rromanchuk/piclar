//
//  AppDelegate.h
//  social
//
//  Created by Ryan Romanchuk on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
@protocol ApplicationLifecyleDelegate;

@interface AppDelegate : UIResponder <UIApplicationDelegate, LocationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (weak, nonatomic) id <ApplicationLifecyleDelegate> delegate;

- (void)resetCoreData;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
@end


@protocol ApplicationLifecyleDelegate <NSObject>
@required
- (void)applicationWillExit;
@end