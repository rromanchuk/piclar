

#import "PlaceSearchViewController.h"
#import "RestPlace.h"
#import "Location.h"
#import "PlaceSearchCell.h"
#import "Place+Rest.h"
#import "UIBarButtonItem+Borderless.h"
#import "CheckinCreateViewController.h"
#import "MapAnnotation.h"
#import "Utils.h"

@interface PlaceSearchViewController ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *searchFetchedResultsController;
@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;
@property (nonatomic) BOOL beganUpdates;
@end

@implementation PlaceSearchViewController
@synthesize managedObjectContext;
@synthesize filteredImage;
@synthesize _tableView;
@synthesize searchBar;
@synthesize searchDisplayController;
@synthesize placeSearchDelegate;

@synthesize savedSearchTerm;
@synthesize savedScopeButtonIndex;
@synthesize searchWasActive;

@synthesize suspendAutomaticTrackingOfChangesInManagedObjectContext = _suspendAutomaticTrackingOfChangesInManagedObjectContext;
@synthesize beganUpdates = _beganUpdates;

- (void)viewDidLoad
{
    [super viewDidLoad];
    locationFailureCount = 0;
    
    self.title = NSLocalizedString(@"SELECT_LOCATION", @"Title for place search");
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self action:@selector(dismissModal:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:fixed, backButtonItem, nil];
    [Location sharedLocation].delegate = self;
    // Lets start refreshing the location since the user may have moved
    [[Location sharedLocation] update];
    [self fetchResults];
    
    if (self.savedSearchTerm)
    {
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
}

- (void)viewDidUnload
{
    [Location sharedLocation].delegate = nil;
    [self setMapView:nil];
    [self set_tableView:nil];
    [self setSearchBar:nil];
    [self setSearchDisplayController:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    isFetchingResults = NO;
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // Make sure location has stopped updated
    [[Location sharedLocation].locationManager stopUpdatingLocation];
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
}

- (void)didReceiveMemoryWarning
{
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
    
    fetchedResultsController_.delegate = nil;
    fetchedResultsController_  = nil;
    searchFetchedResultsController_.delegate = nil;
    searchFetchedResultsController_ = nil;
    
    [super didReceiveMemoryWarning];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (void)didGetLocation
{
    DLog(@"PlaceSearch#didGetLocation with accuracy %f", [Location sharedLocation].locationManager.location.horizontalAccuracy);
    locationFailureCount = 0;
    float currentAccuracy = [Location sharedLocation].locationManager.location.horizontalAccuracy;
    if (!isFetchingResults && currentAccuracy != lastAccuracy )
        [self fetchResults];
    
    // If our accuracy is poor, keep trying to improve
#warning Sometimes accuracy wont ever get better and this causes a constant updating which is not energy effiecient, we should give up after x tries
    if (currentAccuracy > 100.0) {
        [[Location sharedLocation] update];
    }
    lastAccuracy = currentAccuracy;
}

#warning handle this case better
- (void)failedToGetLocation:(NSError *)error
{
    DLog(@"PlaceSearch#failedToGetLocation: %@", error);
    //lets try again
    if (locationFailureCount < 5)
        [[Location sharedLocation] update];
    locationFailureCount++;
}

// Given the places in our results, update their distance based on current location. This allows our sort descriptor
// to be able to order our places from our user's current location. We don't actually save the context as we are temporarly using this
// column to sort the data. There is no way to fetch data based on transient data, we use this to get around it. 
- (void)calculateDistanceInMemory {
    for (Place *place in [self.fetchedResultsController fetchedObjects]) {
        CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude: [place.lat doubleValue] longitude:[place.lon doubleValue]];
        place.distance = [NSNumber numberWithDouble:[targetLocation distanceFromLocation:[Location sharedLocation].locationManager.location]];
        DLog(@"%@ is %f meters away", place.title, [place.distance doubleValue]);
    }
}

- (IBAction)dismissModal:(id)sender {
    DLog(@"DISMISSING MODAL");
    [self.placeSearchDelegate didSelectNewPlace:nil];
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
                            [self setupMap];
                            isFetchingResults = NO;
                        } onError:^(NSString *error) {
                            DLog(@"Problem searching places: %@", error);
                        }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"didSelectRowAtIndexPath");
    Place *place = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
    [self.placeSearchDelegate didSelectNewPlace:place];
}



- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    return tableView == self.tableView ? self.fetchedResultsController : self.searchFetchedResultsController;
}

- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController configureCell:(PlaceSearchCell *)theCell atIndexPath:(NSIndexPath *)theIndexPath
{
    // Configure the cell...
    DLog(@"There are %d objects", [[fetchedResultsController fetchedObjects] count]);
    
    Place *place = [fetchedResultsController objectAtIndexPath:theIndexPath];
    DLog(@"Got place %@", place.title);
    theCell.placeTitleLabel.text = place.title;
    theCell.placeTypeLabel.text = place.type;
    theCell.placePhoto.image = [Utils getPlaceTypeImageWithTypeId:[place.typeId integerValue]];

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56.0;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)theIndexPath
{
    PlaceSearchCell *cell = (PlaceSearchCell *)[self._tableView dequeueReusableCellWithIdentifier:@"PlaceSearchCell"];
    if (cell == nil)
    {
        cell = [[PlaceSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PlaceSearchCell"];
    }
    
    [self fetchedResultsController:[self fetchedResultsControllerForTableView:theTableView] configureCell:cell atIndexPath:theIndexPath];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[[self fetchedResultsControllerForTableView:tableView] sections] count];
    
    return count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
    NSArray *sections = fetchController.sections;
    if(sections.count > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    
    return numberOfRows;
}

#pragma mark -
#pragma mark Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope
{
    // update the filter, in this case just blow away the FRC and let lazy evaluation create another with the relevant search info
//    self.searchFetchedResultsController.delegate = nil;
//    self.searchFetchedResultsController = nil;
    searchFetchedResultsController_.delegate = nil;
    searchFetchedResultsController_ = nil;
    // if you care about the scope save off the index to be used by the serchFetchedResultsController
    //self.savedScopeButtonIndex = scope;
}


#pragma mark -
#pragma mark Search Bar
- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;
{
    // search is done so get rid of the search FRC and reclaim memory
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    DLog(@"shouldReloadTableForSearchString: %@", searchString);
    [self filterContentForSearchText:searchString
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext) {
        [tableView beginUpdates];
        self.beganUpdates = YES;
    }
}


- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext) {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    
    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)theIndexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext) {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:theIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [self fetchedResultsController:controller configureCell:(PlaceSearchCell *)[tableView cellForRowAtIndexPath:theIndexPath] atIndexPath:theIndexPath];
                break;
                
            case NSFetchedResultsChangeMove:
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:theIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
 
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    
    if (self.beganUpdates) [tableView endUpdates];
    [tableView endUpdates];
}


- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString
{
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES]];
    float latMax = [Location sharedLocation].latitude + 1;
    float latMin = [Location sharedLocation].latitude - 1;
    float lngMax = [Location sharedLocation].longitude + 1;
    float lngMin = [Location sharedLocation].longitude - 1;
    NSPredicate *filterPredicate = [NSPredicate
                                    predicateWithFormat:@"lat > %f and lat < %f and lon > %f and lon < %f",
                                    latMin, latMax, lngMin, lngMax];

    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    
    NSMutableArray *predicateArray = [NSMutableArray array];
    if(searchString.length)
    {
        DLog(@"New NFRC with search string: %@", searchString);
        // your search predicate(s) are added to this array
        [predicateArray addObject:[NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", searchString]];
        // finally add the filter predicate for this view
        if(filterPredicate)
        {
            filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:filterPredicate, [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray], nil]];
        }
        else
        {
            filterPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray];
        }
    }
    [fetchRequest setPredicate:filterPredicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:self.managedObjectContext
                                                                                                  sectionNameKeyPath:nil
                                                                                                           cacheName:nil];
    aFetchedResultsController.delegate = self;
    
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    
    if (fetchedResultsController_ != nil)
    {
        return fetchedResultsController_;
    }
    fetchedResultsController_ = [self newFetchedResultsControllerWithSearch:nil];
    return fetchedResultsController_;
}

- (NSFetchedResultsController *)searchFetchedResultsController
{
    DLog(@"wants search fetched results controller");
    if (searchFetchedResultsController_ != nil)
    {
        DLog(@"search controller is not nil");
        return searchFetchedResultsController_;
    }
    DLog(@"creating new search results controller");
    searchFetchedResultsController_ = [self newFetchedResultsControllerWithSearch:self.searchDisplayController.searchBar.text];
    return searchFetchedResultsController_;
}

- (void)setupMap {
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [Location sharedLocation].latitude;
    zoomLocation.longitude= [Location sharedLocation].longitude;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
    
    for (Place *place in [self.fetchedResultsController fetchedObjects]) {
        CLLocationCoordinate2D placeLocation;
        placeLocation.latitude = [place.lat doubleValue];
        placeLocation.longitude = [place.lon doubleValue];
        MapAnnotation *annotation = [[MapAnnotation alloc] initWithName:place.title address:place.address coordinate:placeLocation];
        [self.mapView addAnnotation:annotation];
    }
}


- (void)endSuspensionOfUpdatesDueToContextChanges
{
    _suspendAutomaticTrackingOfChangesInManagedObjectContext = NO;
}

- (void)setSuspendAutomaticTrackingOfChangesInManagedObjectContext:(BOOL)suspend
{
    if (suspend) {
        _suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;
    } else {
        [self performSelector:@selector(endSuspensionOfUpdatesDueToContextChanges) withObject:0 afterDelay:0];
    }
}


@end
