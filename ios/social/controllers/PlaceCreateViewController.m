//
//  PlaceCreateViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/11/12.
//
//

#import "PlaceCreateViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface PlaceCreateViewController ()

@end

@implementation PlaceCreateViewController
@synthesize delegate;

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
    
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:fixed, dismissButtonItem, nil]];
    
    self.nameTextField.placeholder = NSLocalizedString(@"PLACE_NAME", @"Plane name prompt");
    self.categoryLabel.text = NSLocalizedString(@"PLACE_CATEGORY", @"place category label");
    self.addressLabel.text = NSLocalizedString(@"ADDRESS", @"address label");
    self.pickPlaceLabel.text = NSLocalizedString(@"PICK_A_PLACE", @"Helper text to locate place on mapview");
    self.title = NSLocalizedString(@"PLACE_CREATE_TITLE", @"Title");
    [self.mapView.layer setCornerRadius:10.0];
    [self.mapView.layer setBorderWidth:1.0];
    [self.mapView.layer setBorderColor:RGBCOLOR(204, 204, 204).CGColor];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleGesture:)];
    lpgr.minimumPressDuration = 2.0;  //user must press for 2 seconds
    [self.mapView addGestureRecognizer:lpgr];
    
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    MapAnnotation *annotation = [[MapAnnotation alloc] initWithName:self.place.title address:self.place.address coordinate:touchMapCoordinate];
    [self.mapView addAnnotation:annotation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)dismissModal:(id)sender {
    [self.delegate didCancelPlaceCreation];
}


- (void)viewDidUnload {
    [self setNameTextField:nil];
    [self setCategoryLabel:nil];
    [self setAddressLabel:nil];
    [self setPickPlaceLabel:nil];
    [self setMapView:nil];
    [super viewDidUnload];
}
@end
