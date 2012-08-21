//
//  PlaceMapShowViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/20/12.
//
//

#import "PlaceMapShowViewController.h"
#import "UIBarButtonItem+Borderless.h"
#import "Location.h"
#import "MapAnnotation.h"
@interface PlaceMapShowViewController ()

@end

@implementation PlaceMapShowViewController
@synthesize mapkitView;
@synthesize place;
@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 10;

    self.navigationItem.leftBarButtonItems = [[NSArray alloc] initWithObjects: fixed, backButtonItem, nil];
    self.mapkitView.zoomEnabled = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupMap];
}

- (void)viewDidUnload
{
    [self setMapkitView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setupMap {
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude  = [self.place.lat doubleValue];
    zoomLocation.longitude = [self.place.lon doubleValue];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.mapkitView regionThatFits:viewRegion];
    [self.mapkitView setRegion:adjustedRegion animated:YES];
    
    
    CLLocationCoordinate2D placeLocation;
    placeLocation.latitude = [place.lat doubleValue];
    placeLocation.longitude = [place.lon doubleValue];
    MapAnnotation *annotation = [[MapAnnotation alloc] initWithName:place.title address:place.address coordinate:placeLocation];
    [self.mapkitView addAnnotation:annotation];
   
}


@end
