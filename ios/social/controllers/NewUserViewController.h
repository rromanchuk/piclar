//
//  NewUserViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/6/12.
//
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"
#import "User.h"
#import "User+Rest.h"
#import "UserProfileHeader.h"

#import "BaseCollectionViewController.h"
@protocol ProfileShowDelegate;
@interface NewUserViewController : BaseCollectionViewController <NSFetchedResultsControllerDelegate>


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) User *currentUser;
@property (strong, nonatomic)  UserProfileHeader *headerView;
@property (strong, nonatomic) IBOutlet PSUICollectionView *collectionView;


- (IBAction)didFollowUnfollowUser:(id)sender;
- (IBAction)didSwitchLayout:(id)sender;
- (IBAction)didTapFollowers:(id)sender;
- (IBAction)didTapFollowing:(id)sender;

@end


