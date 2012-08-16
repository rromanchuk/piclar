

#import "PlaceSearchViewController.h"
#import "RestPlace.h"
#import "Location.h"
#import "PlaceSearchCell.h"
#import "Place+Rest.h"
#import "UIBarButtonItem+Borderless.h"
#import "CheckinCreateViewController.h"

@interface PlaceSearchViewController ()

@end

@implementation PlaceSearchViewController
@synthesize managedObjectContext;
@synthesize filteredImage;
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = backButtonItem;

    [Location sharedLocation].delegate = self;
    // Lets start refreshing the location since the user may have moved
    [[Location sharedLocation] update];
}

- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    float latMax = [Location sharedLocation].latitude + 1;
    float latMin = [Location sharedLocation].latitude - 1;
    float lngMax = [Location sharedLocation].longitude + 1;
    float lngMin = [Location sharedLocation].longitude - 1;
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"lat > %f and lat < %f and lon > %f and lon < %f",
                              latMin, latMax, lngMin, lngMax];
    NSLog(@"lat > %f and lat < %f and lon > %f and lon < %f", latMin, latMax, lngMin, lngMax);
    request.predicate = predicate;
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}


- (void)viewDidUnload
{
    [Location sharedLocation].delegate = nil;
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    isFetchingResults = NO;
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self fetchResults];
    self.title = @"Выбор места";
    [self setupFetchedResultsController];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // Make sure location has stopped updated
    [[Location sharedLocation].locationManager stopUpdatingLocation];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlaceSearchCell";
    PlaceSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PlaceSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    NSLog(@"There are %d objects", [[self.fetchedResultsController fetchedObjects] count]);
    Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.placeTitleLabel.text = place.title;
    cell.placeTypeLabel.text = place.type;
    return cell;
}

- (void)didGetLocation
{
    NSLog(@"PlaceSearch#didGetLocation with accuracy %f", [Location sharedLocation].locationManager.location.horizontalAccuracy);
    float currentAccuracy = [Location sharedLocation].locationManager.location.horizontalAccuracy;
    if (!isFetchingResults && currentAccuracy != lastAccuracy )
        [self fetchResults];
    
    // If our accuracy is poor, keep trying to improve
#warning Sometimes accuracy wont ever get better and this causes a constant updating which is not energy effiecient, we should give up after x tries
    if (currentAccuracy > 100.0) {
        [[Location sharedLocation] update];
    }
    lastAccuracy = currentAccuracy;
    [self calculateDistanceInMemory];
}

#warning handle this case better
- (void)failedToGetLocation:(NSError *)error
{
    NSLog(@"PlaceSearch#failedToGetLocation: %@", error);
    //lets try again
    [[Location sharedLocation] update];
}


// Given the places in our results, update their distance based on current location. This allows our sort descriptor
// to be able to order our places from our user's current location. We don't actually save the context as we are temporarly using this
// column to sort the data. There is no way to fetch data based on transient data, we use this to get around it. 
- (void)calculateDistanceInMemory {
    for (Place *place in [self.fetchedResultsController fetchedObjects]) {
        CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude: [place.lat doubleValue] longitude:[place.lon doubleValue]];
        place.distance = [NSNumber numberWithDouble:[targetLocation distanceFromLocation:[Location sharedLocation].locationManager.location]];
        NSLog(@"%@ is %f meters away", place.title, [place.distance doubleValue]);
    }
}

- (IBAction)dismissModal:(id)sender {
    NSLog(@"DISMISSING MODAL");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissModal" object:self];
}

- (void)fetchResults {
    isFetchingResults = YES;
    [RestPlace searchByLat:[Location sharedLocation].latitude
                        andLon:[Location sharedLocation].longitude
                        onLoad:^(NSSet *places) {
                            for (RestPlace *restPlace in places) {
                                [Place placeWithRestPlace:restPlace inManagedObjectContext:self.managedObjectContext];
                            }
                            [self calculateDistanceInMemory];
                            isFetchingResults = NO;
                        } onError:^(NSString *error) {
                            NSLog(@"Problem searching places: %@", error);
                        }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath");
    Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.delegate didSelectNewPlace:place];
}

@end
