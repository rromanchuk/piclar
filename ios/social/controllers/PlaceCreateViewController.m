//
//  PlaceCreateViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/11/12.
//
//

#import "PlaceCreateViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AddressBookUI/AddressBookUI.h>
#import "PlaceSelectCategoryViewController.h"
#import "RestPlace.h"
#import "Utils.h"
@interface PlaceCreateViewController ()
@end

@implementation PlaceCreateViewController
@synthesize delegate;
@synthesize restPlace = _restPlace;
@synthesize managedObjectContext;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *dismissButtonImage = [UIImage imageNamed:@"dismiss.png"];
    UIBarButtonItem *dismissButtonItem = [UIBarButtonItem barItemWithImage:dismissButtonImage target:self action:@selector(dismissModal:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    
    self.geoCoder = [[CLGeocoder alloc] init];
    self.restPlace = [[RestPlace alloc] init];
    
    self.doneButton.enabled = NO;
    [self.doneButton setTitle:NSLocalizedString(@"DONE", @"done button")];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:fixed, dismissButtonItem, nil];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:fixed, self.doneButton, nil];
    
    self.nameTextField.placeholder = NSLocalizedString(@"REQUIRED", @"Plane name prompt");
    if (self.name) {
        self.nameTextField.text = self.name;
        self.restPlace.title = self.name;
    }
    
    self.nameLabel.text = NSLocalizedString(@"PLACE_NAME", @"Place title label");
    
    self.categoryLabel.text = NSLocalizedString(@"PLACE_CATEGORY", @"place category label");
    self.categoryRequiredLabel.text = NSLocalizedString(@"REQUIRED", @"required label");
    
    self.addressLabel.text = NSLocalizedString(@"ADDRESS", @"address label");
    self.addressOptionalLabel.text = NSLocalizedString(@"OPTIONAL", @"Optional label");
    
    self.pickPlaceLabel.text = NSLocalizedString(@"PICK_A_PLACE", @"Helper text to locate place on mapview");
    self.title = NSLocalizedString(@"PLACE_CREATE_TITLE", @"Title");
    [self.mapView.layer setCornerRadius:10.0];
    [self.mapView.layer setBorderWidth:1.0];
    [self.mapView.layer setBorderColor:RGBCOLOR(204, 204, 204).CGColor];
    
    UITapGestureRecognizer *lpgr = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleGesture:)];
    [self.mapView addGestureRecognizer:lpgr];
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SelectCategory"]) {
        PlaceSelectCategoryViewController *vc = (PlaceSelectCategoryViewController *)segue.destinationViewController;
        vc.delegate = self;
    } else if ([segue.identifier isEqualToString:@"SelectAddress"]) {
        PlaceSelectAddressViewController *vc = (PlaceSelectAddressViewController *)segue.destinationViewController;
        vc.delegate = self;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.nameTextField resignFirstResponder];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupMap];
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded)
        return;
    [self.mapView removeAnnotation:self.currentPin];
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    self.currentPin = [[MapAnnotation alloc] initWithName:self.place.title address:self.place.address coordinate:touchMapCoordinate];
    [self.mapView addAnnotation:self.currentPin];
    self.restPlace.lat = self.currentPin.coordinate.latitude;
    self.restPlace.lon = self.currentPin.coordinate.longitude;
    [self validate];
    [self.geoCoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:self.currentPin.coordinate.latitude longitude:self.currentPin.coordinate.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            self.restPlace.address = ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES);
            DLog(@"got address %@", self.restPlace.address);
        }
    }];
}

- (void)setupMap {
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [Location sharedLocation].latitude;
    zoomLocation.longitude= [Location sharedLocation].longitude;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)dismissModal:(id)sender {
    [self.delegate didCancelPlaceCreation];
}

#pragma mark SelectCategoryDelegate methods
- (void)didSelectCategory:(NSInteger)categoryId {
    self.restPlace.typeId = categoryId;
    self.categoryRequiredLabel.text = [Utils getPlaceTypeWithTypeId:categoryId];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self validate];
}

#pragma mark SelectAddressDelegate methods
- (void)didSelectAddress:(NSDictionary *)address {
    self.restPlace.address = ABCreateStringWithAddressDictionary(address, YES);
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)createPlace:(id)sender {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.restPlace.title, @"title", [NSString stringWithFormat:@"%u", self.restPlace.typeId], @"type", [NSString stringWithFormat:@"%f", self.restPlace.lat], @"lat", [NSString stringWithFormat:@"%f", self.restPlace.lon], @"lng", self.addressAsString, @"address", nil];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"CREATING_PLACE", @"Loading new place creation") maskType:SVProgressHUDMaskTypeGradient];
    [RestPlace create:params onLoad:^(RestPlace *restPlace) {
        Place *place = [Place placeWithRestPlace:restPlace inManagedObjectContext:self.managedObjectContext];
        DLog(@"place is %@", place);
        [SVProgressHUD dismiss];
        [self.delegate didCreatePlace:place];
    } onError:^(NSString *error) {
        DLog(@"%@", error);
        
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"PLACE_CREATE_ERROR", @"Place create error")];
    }];
}


- (void)validate {
    ALog(@"validating %f %@ %u", self.restPlace.lat, self.restPlace.title, self.restPlace.typeId);
    if (self.restPlace.lat && self.restPlace.title && self.restPlace.typeId) {
        DLog(@"it is valid");
        self.doneButton.enabled = YES;
    }
}

#pragma mark UITextFieldDelegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    DLog(@"did begin editing");
    [self validate];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    [self validate];
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    [self.nameTextField resignFirstResponder];
    [self validate];
    DLog(@"did end editing");

}
- (void)viewDidUnload {
    [self setNameTextField:nil];
    [self setCategoryLabel:nil];
    [self setAddressLabel:nil];
    [self setPickPlaceLabel:nil];
    [self setMapView:nil];
    [self setNameLabel:nil];
    [self setCategoryRequiredLabel:nil];
    [self setAddressOptionalLabel:nil];
    [self setDoneButton:nil];
    [super viewDidUnload];
}
- (IBAction)hideKeyboard:(id)sender {
    [self.nameTextField resignFirstResponder];
}

- (IBAction)updateTitle:(id)sender {
    DLog(@"title updated %@", ((UITextField *)sender).text);
    self.restPlace.title = ((UITextField *)sender).text;
    [self validate];
}
@end
