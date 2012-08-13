

#import "PlaceSearchViewController.h"
#import "RestPlace.h"
#import "Location.h"
#import "PlaceSearchCell.h"
#import "Place.h"
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
    [self.postcardPhoto setImage:self.filteredImage];
    self.location = [Location sharedLocation];
    self.location.delegate = self;
    // Lets start refreshing the location since the user may have moved
    [self.location update];
}

- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (void)viewDidUnload
{
    [self setPostcardPhoto:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchResults];
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
    Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.placeTitleLabel.text = place.title;
    cell.placeTypeLabel.text = place.type;
    return cell;
}

- (void)didGetLocation
{
    NSLog(@"PlaceSearch#didGetLocation");
    [self fetchResults];
}


- (void)fetchResults {
    [RestPlace searchByLat:self.location.latitude
                        andLon:self.location.longitude
                        onLoad:^(id object) {
                            NSLog(@"");
                        } onError:^(NSString *error) {
                            NSLog(@"");
                        }];
}

@end
