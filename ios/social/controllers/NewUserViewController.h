//
//  NewUserViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/6/12.
//
//


#import "PSTCollectionView.h"
#import "User.h"
#import "User+Rest.h"
#import "UserProfileHeader.h"

#import "BaseCollectionViewController.h"

@interface NewUserViewController : BaseCollectionViewController <NSFetchedResultsControllerDelegate, PSTCollectionViewDataSource, PSTCollectionViewDelegate, PSTCollectionViewDelegateFlowLayout>


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) User *currentUser;
@property (strong, nonatomic)  UserProfileHeader *headerView;


- (IBAction)didFollowUnfollowUser:(id)sender;
- (IBAction)didSwitchLayout:(id)sender;
- (IBAction)didTapFollowers:(id)sender;
- (IBAction)didTapFollowing:(id)sender;

@end

