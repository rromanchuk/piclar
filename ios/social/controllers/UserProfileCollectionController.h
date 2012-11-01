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
#import "UserProfileHeader.h"

@protocol ProfileShowDelegate;

@interface UserProfileCollectionController : CoreDataCollectionViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) User *currentUser;
@property (weak, nonatomic) id <ProfileShowDelegate> delegate;
@property (weak, nonatomic) IBOutlet UserProfileHeader *headerView;
- (IBAction)didFollowUnfollowUser:(id)sender;
- (IBAction)didSwitchLayout:(id)sender;
- (IBAction)didTapFollowers:(id)sender;
- (IBAction)didTapFollowing:(id)sender;

@end


@protocol ProfileShowDelegate <NSObject>
@required
- (void)didDismissProfile;

@end