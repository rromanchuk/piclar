

#import "PlaceSearchViewController.h"
#import "RestPlace.h"
#import "Location.h"
#import "PlaceSearchCell.h"
#import "Place+Rest.h"
#import "UIBarButtonItem+Borderless.h"
#import "CheckinCreateViewController.h"
#import "MapAnnotation.h"
#import "Utils.h"
#import "PlaceSearchLoadingCell.h"
#import "AddPlaceCell.h"
#import "BaseView.h"
#import "BaseSearchBar.h"
#import "WarningBannerView.h"
@interface PlaceSearchViewController ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *searchFetchedResultsController;
@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, strong) WarningBannerView *warningBanner;
@property (nonatomic) BOOL beganUpdates;
@property (nonatomic) BOOL desiredLocationFound;
@property (nonatomic) BOOL resultsFound;

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
@synthesize desiredLocationFound;
@synthesize resultsFound;

- (void)viewDidLoad
{
    [super viewDidLoad];
    locationFailureCount = 0;
    
    
    self._tableView.backgroundView = [[BaseView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width,  self.view.bounds.size.height)];;
    
    self.title = NSLocalizedString(@"SELECT_LOCATION", @"Title for place search");
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
    UIImage *addPlaceImage = [UIImage imageNamed:@"add-place.png"];

    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self action:@selector(dismissModal:)];
    UIBarButtonItem *addPlaceItem = [UIBarButtonItem barItemWithImage:addPlaceImage target:self action:@selector(didSelectCreatePlace:)];

    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    
    [self.searchBar setShowsScopeBar:NO];
    //[[UIButton appearanceWhenContainedIn:[self.searchBar, nil] setBackgroundImage:[UIImage imageNamed:@"enter-button.png"] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:fixed, backButtonItem, nil];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:fixed, addPlaceItem, nil];
    [Location sharedLocation].delegate = self;
    
    
    if (self.savedSearchTerm)
    {
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
    
    self.suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;
    [[Location sharedLocation] resetDesiredLocation];
    [[Location sharedLocation] updateUntilDesiredOrTimeout:5.0];
    [self._tableView setScrollEnabled:NO];
    isFetchingResults = NO;
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
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    if (![CLLocationManager locationServicesEnabled]) {
        self.warningBanner = [[WarningBannerView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30) andMessage:NSLocalizedString(@"NO_LOCATION_SERVICES", @"User needs to have location services turned for this to work")];
        [self.view addSubview:self.warningBanner];
    }

    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[Location sharedLocation] stopUpdatingLocation:@"Stopping any location updates"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
    [self.warningBanner removeFromSuperview];
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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PlaceCreate"]) {
        PlaceCreateViewController *vc = (PlaceCreateViewController *)((UINavigationController *)[segue destinationViewController]).topViewController;
        vc.delegate = self;
        vc.managedObjectContext = self.managedObjectContext;
    }
}
#pragma mark - LocationDelegate methods


- (void)didGetBestLocationOrTimeout {
    DLog(@"did get best location");
    if (!isFetchingResults)
        [self fetchResults];
    [Flurry logEvent:@"DID_GET_DESIRED_LOCATION_ACCURACY_PLACE_SEARCH"];
}

- (void)locationStoppedUpdatingFromTimeout {
    DLog(@"did timeout");
    if (!isFetchingResults && !self.desiredLocationFound)
        [self fetchResults];

    [Flurry logEvent:@"FAILED_TO_GET_DESIRED_LOCATION_ACCURACY_PLACE_SEARCH"];
}

- (void)failedToGetLocation:(NSError *)error
{
    
    DLog(@"PlaceSearch#failedToGetLocation: %@", error);
    [self ready];
    [Flurry logEvent:@"FAILED_TO_GET_ANY_LOCATION"];
    self.warningBanner = [[WarningBannerView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30) andMessage:NSLocalizedString(@"NO_LOCATION_SERVICES", @"User needs to have location services turned for this to work")];
    [self.tableView  addSubview:self.warningBanner];
}



#pragma mark - PlaceCreateDelegate methods
- (void)didCreatePlace:(Place *)place {
    // make sure location still has someone to send messages to
    //[Location sharedLocation].delegate = self;
    //[self dismissModalViewControllerAnimated:YES];
    [self.placeSearchDelegate didSelectNewPlace:place];
}

- (void)didCancelPlaceCreation {
    [Location sharedLocation].delegate = self;
    DLog(@"got dismiss from place search");
    [self dismissModalViewControllerAnimated:YES];
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

- (void)ready {
    DLog(@"Preparing ready state with %d", [[self.fetchedResultsController fetchedObjects] count]);
    fetchedResultsController_ = nil;
    searchFetchedResultsController_ = nil;
    self.suspendAutomaticTrackingOfChangesInManagedObjectContext = NO;
    self.desiredLocationFound = YES;
    isFetchingResults = NO;
    [self calculateDistanceInMemory];
    [self setupMap];
    [self._tableView setScrollEnabled:YES];
    [self._tableView reloadData];
 
}

- (void)fetchResults {
    isFetchingResults = YES;
    [RestPlace searchByLat:[Location sharedLocation].latitude
                        andLon:[Location sharedLocation].longitude
                        onLoad:^(NSSet *places) {
                            for (RestPlace *restPlace in places) {
                                [Place placeWithRestPlace:restPlace inManagedObjectContext:self.managedObjectContext];
                            }
                            
                            [self ready];
                        } onError:^(NSString *error) {
                            DLog(@"Problem searching places: %@", error);
                            [self ready];
                        }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"didSelectRowAtIndexPath");
    if (self.resultsFound) {
        Place *place = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
        [self.placeSearchDelegate didSelectNewPlace:place];
    } else {
        [self didSelectCreatePlace:self];
    }
    
}

- (IBAction)didSelectCreatePlace:(id)sender {
    [Location sharedLocation].delegate = self;
    [self performSegueWithIdentifier:@"PlaceCreate" sender:self];
}



- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    return tableView == self.tableView ? self.fetchedResultsController : self.searchFetchedResultsController;
}

- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController configureCell:(PlaceSearchCell *)theCell atIndexPath:(NSIndexPath *)theIndexPath
{
    DLog(@"There are %d objects", [[fetchedResultsController fetchedObjects] count]);
    
    Place *place = [fetchedResultsController objectAtIndexPath:theIndexPath];
    DLog(@"Got place %@", place.title);
    theCell.placeTitleLabel.text = place.title;
    theCell.placeTypeLabel.text = place.type;
    theCell.placePhoto.image = [Utils getPlaceTypeImageWithTypeId:[place.typeId integerValue]];

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.desiredLocationFound) {
        return 56.0;
    } else {
        return 350;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)theIndexPath
{
    if (self.desiredLocationFound && self.resultsFound) {
        DLog(@"Desired location found");
        PlaceSearchCell *cell = (PlaceSearchCell *)[self._tableView dequeueReusableCellWithIdentifier:@"PlaceSearchCell"];
        if (cell == nil)
        {
            cell = [[PlaceSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PlaceSearchCell"];
        }
        
        [self fetchedResultsController:[self fetchedResultsControllerForTableView:theTableView] configureCell:cell atIndexPath:theIndexPath];
        return cell;
    } else if (!self.resultsFound && self.desiredLocationFound) {
        AddPlaceCell *cell = (AddPlaceCell *)[self._tableView dequeueReusableCellWithIdentifier:@"AddPlaceCell"];
        if (cell == nil)
        {
            cell = [[AddPlaceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PlaceSearchCell"];
        }
        return cell;
    }
    else {
        DLog(@"Desired location NOT found");
        PlaceSearchLoadingCell *cell = (PlaceSearchLoadingCell *)[theTableView dequeueReusableCellWithIdentifier:@"PlaceSearchLoadingCell"];
        if (cell == nil) {
            cell = [[PlaceSearchLoadingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PlaceSearchLoadingCell"];
        }
        cell.loadingText.text = NSLocalizedString(@"LOADING_PLACES", nil);
        [cell.activityIndicator startAnimating];
        cell.userInteractionEnabled = NO;
        
        return cell;
    }    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[[self fetchedResultsControllerForTableView:tableView] sections] count];
    
    return count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if (self.desiredLocationFound) {
        NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
        NSArray *sections = fetchController.sections;
        if(sections.count > 0)
        {
            id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
            numberOfRows = [sectionInfo numberOfObjects];
        }
        
        if (numberOfRows == 0) {
            self.resultsFound = NO;
            numberOfRows = 1;
        } else {
            self.resultsFound = YES;
        }
           

    } else {
        DLog(@"Setting number of rows to 1");
        numberOfRows = 1;
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

#pragma mark MKMapViewDelegate methods
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString *identifier = @"MyLocation";
    if ([annotation isKindOfClass:[MapAnnotation class]]) {
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            
            UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            annotationView.rightCalloutAccessoryView = disclosureButton;
            

        } else {
            annotationView.annotation = annotation;
            [(UIImageView *)annotationView.leftCalloutAccessoryView setImage:nil];
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        //annotationView.image=[UIImage imageNamed:@"arrest.png"];//here we use a nice image instead of the default pins
        
        return annotationView;
    }
    
    return nil;    
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    DLog(@"in did select");
    MapAnnotation *annotation = (MapAnnotation *)view.annotation;
    [self.placeSearchDelegate didSelectNewPlace:annotation.place];
}

- (void)mapView:(MKMapView *)sender didSelectAnnotationView:(MKAnnotationView *)aView {
    
    UIImageView *imageView = (UIImageView *)aView.leftCalloutAccessoryView;
    imageView.image = [UIImage imageNamed:@"type-hotel.png"];
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
        annotation.place = place;
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
