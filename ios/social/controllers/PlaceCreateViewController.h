//
//  PlaceCreateViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/11/12.
//
//

#import "Place.h"
#import "BaseTableView.h"
#import <MapKit/MapKit.h>
#import "MapAnnotation.h"
#import "Place+Rest.h"
#import "RestPlace.h"
#import "PlaceSelectCategoryViewController.h"
@protocol PlaceCreateDelegate;
@interface PlaceCreateViewController : BaseTableView <MKMapViewDelegate, SelectCategoryDelegate, UITextFieldDelegate>

@property (weak) id <PlaceCreateDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickPlaceLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UILabel *categoryRequiredLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressOptionalLabel;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Place *place;
@property (strong, nonatomic) RestPlace *restPlace;

@property (strong, nonatomic) MapAnnotation *currentPin;
@property (strong, nonatomic) CLGeocoder *geoCoder;
- (IBAction)hideKeyboard:(id)sender;
- (IBAction)updateTitle:(id)sender;

@end


@protocol PlaceCreateDelegate <NSObject>

@required
- (void)didCreatePlace: (Place *)place;
- (void)didCancelPlaceCreation;
@end


