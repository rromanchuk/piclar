//
//  CheckinCreateViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/15/12.
//
//

#import "Place.h"
#import "PostCardImageView.h"
@interface CheckinCreateViewController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Place *place;
@property (strong, nonatomic) UIImage *filteredImage;
@property (strong, nonatomic) NSNumber *selectedRating;

@property (weak, nonatomic) IBOutlet PostCardImageView *postCardImageView;
@property (weak, nonatomic) IBOutlet UITextField *reviewTextField;
@property (weak, nonatomic) IBOutlet UIButton *star1Button;
@property (weak, nonatomic) IBOutlet UIButton *star2Button;
@property (weak, nonatomic) IBOutlet UIButton *star3Button;
@property (weak, nonatomic) IBOutlet UIButton *star4Button;
@property (weak, nonatomic) IBOutlet UIButton *star5Button;

@property (weak, nonatomic) IBOutlet UIView *placeView;
@property (weak, nonatomic) IBOutlet UIImageView *placeTypeImage;
@property (weak, nonatomic) IBOutlet UILabel *placeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeAddressLabel;

@property (weak, nonatomic) IBOutlet UIButton *checkinButton;

- (IBAction)didPressCheckin:(id)sender;
- (IBAction)didPressRating:(id)sender;

@end
