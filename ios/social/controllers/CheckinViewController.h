//
//  CheckinViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/19/12.
//
//

#import "FeedItem.h"
#import "CheckinPhoto.h"
#import "ProfilePhotoView.h"
#import "TTTAttributedLabel.h"
#import "HPGrowingTextView.h"
#import "BaseViewController.h"
#import "NewUserViewController.h"
#import "LikersBanner.h"
@interface CheckinViewController : BaseViewController <HPGrowingTextViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) BOOL suspendAutomaticTrackingOfChangesInManagedObjectContext;
@property BOOL debug;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) FeedItem *feedItem;
@property (nonatomic, strong) Notification *notification;
@property (nonatomic, strong) Checkin *checkin;

@property (nonatomic, strong) User *currentUser;

@property (nonatomic, weak) HPGrowingTextView *commentView;


@property (weak, nonatomic) IBOutlet CheckinPhoto *checkinPhoto;
@property (weak, nonatomic) IBOutlet ProfilePhotoView *profileImage;
@property (weak, nonatomic) IBOutlet UIImageView *placeTypeImage;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;


@property (weak, nonatomic) IBOutlet UIImageView *star1;
@property (weak, nonatomic) IBOutlet UIImageView *star2;
@property (weak, nonatomic) IBOutlet UIImageView *star3;
@property (weak, nonatomic) IBOutlet UIImageView *star4;
@property (weak, nonatomic) IBOutlet UIImageView *star5;

@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet LikersBanner *likersView;
@property (weak, nonatomic) IBOutlet UIImageView *disclosureIndicator;


- (IBAction)didLike:(id)sender event:(UIEvent *)event;
- (IBAction)didClickLikers:(id)sender;

@end
