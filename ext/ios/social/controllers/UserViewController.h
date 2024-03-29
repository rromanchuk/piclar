//
//  UserViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/6/12.
//
//


#import "User.h"
#import "User+Rest.h"
#import "UserProfileHeader.h"
#import "CheckinViewController.h"
#import "BaseCollectionViewController.h"

@interface UserViewController : BaseCollectionViewController <NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, DeletionHandler>


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) User *currentUser;
@property (strong, nonatomic) UserProfileHeader *headerView;

- (IBAction)didFollowUnfollowUser:(id)sender;
- (IBAction)didSwitchLayout:(id)sender;
- (IBAction)didTapFollowers:(id)sender;
- (IBAction)didTapFollowing:(id)sender;

@end


