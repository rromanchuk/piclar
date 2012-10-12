//
//  CheckinCreateViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/15/12.
//
//

#import "Place.h"
#import "PostCardImageView.h"
#import "PlaceSearchViewController.h"
#import "HPGrowingTextView.h"
#import "PhotoNewViewcontroller.h"

typedef enum {
    PersonStatusTypeActive,
    PersonStatusTypeWaitingForInvite
    
} NumberOfStars;

@protocol PlaceSearchDelegate;
@interface CheckinCreateViewController : UIViewController <PlaceSearchDelegate, HPGrowingTextViewDelegate, UITextFieldDelegate, CreateCheckinDelegate, LocationDelegate,  UIPickerViewDelegate, UIPickerViewDataSource> {
    BOOL keyboardShown;
}



@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Place *place;
@property (strong, nonatomic) UIImage *filteredImage;
@property (strong, nonatomic) NSNumber *selectedRating;


@property (weak, nonatomic) IBOutlet PostCardImageView *postCardImageView;
@property (strong, nonatomic) IBOutlet HPGrowingTextView *textView;

@property (weak, nonatomic) id <CreateCheckinDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *selectPlaceButton;
@property (weak, nonatomic) IBOutlet UIButton *selectRatingButton;
@property (weak, nonatomic) IBOutlet UIPickerView *ratingsPickerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *vkShareButton;
@property (weak, nonatomic) IBOutlet UIButton *fbShareButton;


@property (strong, nonatomic) NSString *selectedFrame;
@property (strong, nonatomic) UIFont *photoTitleFont;

- (IBAction)didPressCheckin:(id)sender;
- (void)didSelectNewPlace:(Place *)newPlace;

- (IBAction)didTapSelectPlace:(id)sender;
- (IBAction)didTapSelectRating:(id)sender;
- (IBAction)didPressFBShare:(id)sender;
- (IBAction)didPressVKShare:(id)sender;

@end
