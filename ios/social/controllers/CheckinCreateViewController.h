//
//  CheckinCreateViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/15/12.
//
//

#import "Place.h"
#import "PlaceSearchViewController.h"
#import "HPGrowingTextView.h"
#import "PhotoNewViewcontroller.h"
#import "BaseViewController.h"
#import "CheckinPhoto.h"
@protocol PlaceSearchDelegate;
@interface CheckinCreateViewController : BaseViewController <PlaceSearchDelegate, HPGrowingTextViewDelegate, UITextFieldDelegate, CreateCheckinDelegate, LocationDelegate > {
    BOOL keyboardShown;
}



@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Place *place;
@property (strong, nonatomic) UIImage *filteredImage;
@property (strong, nonatomic) UIImage *processedImage;

@property (strong, nonatomic) NSNumber *selectedRating;


@property (weak, nonatomic) IBOutlet UIImageView *postCardImageView;
@property (strong, nonatomic) IBOutlet HPGrowingTextView *textView;

@property (weak, nonatomic) id <CreateCheckinDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *selectPlaceButton;
@property (weak, nonatomic) IBOutlet UIButton *vkShareButton;
@property (weak, nonatomic) IBOutlet UIButton *fbShareButton;
@property (weak, nonatomic) IBOutlet UIButton *star1;
@property (weak, nonatomic) IBOutlet UIButton *star2;
@property (weak, nonatomic) IBOutlet UIButton *star3;
@property (weak, nonatomic) IBOutlet UIButton *star4;
@property (weak, nonatomic) IBOutlet UIButton *star5;
@property (weak, nonatomic) IBOutlet UIButton *checkinButton;


@property (strong, nonatomic) NSString *selectedFrame;
@property BOOL isFirstTimeOpen;
@property (strong, nonatomic) UIFont *photoTitleFont;

- (IBAction)didPressCheckin:(id)sender;
- (void)didSelectNewPlace:(Place *)newPlace;

- (IBAction)didTapSelectPlace:(id)sender;
- (IBAction)didTapSelectRating:(id)sender;
- (IBAction)didPressFBShare:(id)sender;
- (IBAction)didPressVKShare:(id)sender;

@end
