//
//  CheckinViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/19/12.
//
//

#import "CoreDataTableViewController.h"
#import "FeedItem.h"
#import "CheckinPhoto.h"
#import "ProfilePhotoView.h"
#import "TTTAttributedLabel.h"

@interface CheckinViewController : CoreDataTableViewController
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) FeedItem *feedItem;
@property (nonatomic, strong) Notification *notification;


@property (weak, nonatomic) IBOutlet CheckinPhoto *checkinPhoto;
@property (weak, nonatomic) IBOutlet ProfilePhotoView *profileImage;
@property (weak, nonatomic) IBOutlet UIImageView *placeTypeImage;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewLabel;


@property (weak, nonatomic) IBOutlet UIImageView *star1;
@property (weak, nonatomic) IBOutlet UIImageView *star2;
@property (weak, nonatomic) IBOutlet UIImageView *star3;
@property (weak, nonatomic) IBOutlet UIImageView *star4;
@property (weak, nonatomic) IBOutlet UIImageView *star5;


@end
