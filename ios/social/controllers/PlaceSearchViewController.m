

#import "PlaceSearchViewController.h"
#import "RestPlace.h"
#import "Location.h"
#import "PlaceSearchCell.h"
#import "Place+Rest.h"
#import "UIBarButtonItem+Borderless.h"
#import "PlaceRatingController.h"
@interface PlaceSearchViewController ()

@end

@implementation PlaceSearchViewController
@synthesize managedObjectContext;
@synthesize location;
@synthesize filteredImage;
@synthesize postcardPhoto;

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = backButtonItem;

    [self.postcardPhoto setImage:self.filteredImage];
    self.location = [Location sharedLocation];
    self.location.delegate = self;
    // Lets start refreshing the location since the user may have moved
    [self.location update];
}

- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    float latMax = self.location.latitude + 1;
    float latMin = self.location.latitude - 1;
    float lngMax = self.location.longitude + 1;
    float lngMin = self.location.longitude - 1;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PlaceRateAndReview"])
    {
        PlaceRatingController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath];
        vc.place = place;
    }
}


- (void)viewDidUnload
{
    [self setPostcardPhoto:nil];
    self.location.delegate = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self fetchResults];
    self.title = @"Выбор места";
    [self setupFetchedResultsController];
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
    NSLog(@"PlaceSearch#didGetLocation");
    [self calculateDistanceInMemory];
    [self fetchResults];
}

#warning handle this case better
- (void)failedToGetLocation:(NSError *)error
{
    NSLog(@"PlaceSearch#failedToGetLocation: %@", error);
}


// Given the places in our results, update their distance based on current location. This allows our sort descriptor
// to be able to order our places from our user's current location. We don't actually save the context as we are temporarly using this
// column to sort the data. There is no way to fetch data based on transient data, we use this to get around it. 
- (void)calculateDistanceInMemory {
    for (Place *place in [self.fetchedResultsController fetchedObjects]) {
        CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude: [place.lat doubleValue] longitude:[place.lon doubleValue]];
        place.distance = [NSNumber numberWithDouble:[targetLocation distanceFromLocation:self.location.locationManager.location]];
        NSLog(@"%@ is %f meters away", place.title, [place.distance doubleValue]);
    }
}

- (IBAction)dismissModal:(id)sender {
    NSLog(@"DISMISSING MODAL");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissModal" object:self];
}

- (void)fetchResults {
    [RestPlace searchByLat:self.location.latitude
                        andLon:self.location.longitude
                        onLoad:^(NSSet *places) {
                            for (RestPlace *restPlace in places) {
                                [Place placeWithRestPlace:restPlace inManagedObjectContext:self.managedObjectContext];
                            }
                            [self calculateDistanceInMemory];
                        } onError:^(NSString *error) {
                            NSLog(@"Problem searching places: %@", error);
                        }];
}

@end
