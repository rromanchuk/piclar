//
//  UserProfileCollectionController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/1/12.
//
//

#import <UIKit/UIKit.h>
#import "CoreDataCollectionViewController.h"
#import "User.h"
@protocol ProfileShowDelegate;

@interface UserProfileCollectionController : CoreDataCollectionViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) User *currentUser;
@property (weak, nonatomic) id <ProfileShowDelegate> delegate;

@end


@protocol ProfileShowDelegate <NSObject>
@required
- (void)didDismissProfile;

@end