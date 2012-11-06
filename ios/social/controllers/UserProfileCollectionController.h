//
//  UserProfileCollectionController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/1/12.
//
//

#import <UIKit/UIKit.h>
#import "CoreDataCollectionBaseViewController.h"
#import "User.h"
#import "UserProfileHeader.h"

@protocol ProfileShowDelegate;

@interface UserProfileCollectionController : CoreDataCollectionBaseViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) User *currentUser;
@property (weak, nonatomic) id <ProfileShowDelegate> delegate;
@property (weak, nonatomic) IBOutlet UserProfileHeader *headerView;
@property (strong, nonatomic) UICollectionView *collectionView;

- (IBAction)didFollowUnfollowUser:(id)sender;
- (IBAction)didSwitchLayout:(id)sender;
- (IBAction)didTapFollowers:(id)sender;
- (IBAction)didTapFollowing:(id)sender;
- (void)setupFetchedResultsController;
@end


@protocol ProfileShowDelegate <NSObject>
@required
- (void)didDismissProfile;

@end