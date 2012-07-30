
#import "CheckinsIndexViewController.h"
#import "PostCardCell.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>
#import "Utils.h"
#import "UIBarButtonItem+Borderless.h"
#import "PlaceShowViewController.h"
#import "CommentNewViewController.h"
#import "RestCheckin.h"
#import "RestPlace.h"
#import "Checkin+Rest.h"
@interface CheckinsIndexViewController ()

@end

@implementation CheckinsIndexViewController
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
    //[self setupFetchedResultsController];
    UIImage *checkinImage = [UIImage imageNamed:@"checkin.png"];
    UIImage *profileImage = [UIImage imageNamed:@"profile.png"];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem barItemWithImage:profileImage target:self action:@selector(didSelectSettings:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barItemWithImage:checkinImage target:self action:@selector(didCheckIn:)];
    [self fetchResults];
      	// Do any additional setup after loading the view.
    
    [RestCheckin createCheckinWithPlace:[NSNumber numberWithInt:1786] 
                               andPhoto:[UIImage imageNamed:@"sample-photo1-show"] 
                             andComment:@"This is a test comment" 
                                 onLoad:^(RestCheckin *checkin) {
                                     NSLog(@"");
                                 } 
                                onError:^(NSString *error) {
                                    NSLog(@"");
                                }];

}

- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Checkin"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupFetchedResultsController];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PlaceShow"])
    {
        PlaceShowViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        //NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        //Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath];
        //vc.place = place;
        
        [RestPlace loadByIdentifier:1708 
                             onLoad:^(RestPlace *place) {
                                 NSLog(@"%@", place);
                                 [vc.tableView reloadData];
                             } onError:^(NSString *error) {
                                 NSLog(error);
                             }];
        
        
    } else if ([[segue identifier] isEqualToString:@"Checkin"]) {
        
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CheckinCell";
    PostCardCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[PostCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    Checkin *checkin = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"GOT CHECKIN FROM FETCHED RESULTS %@", checkin);
    cell.commentLabel.text = checkin.comment; 
    UIImage *newImage = [UIImage imageNamed:@"profile-demo.png"];
    //cell.profilePhoto.image = [newImage thumbnailImage:[Utils sizeForDevice:33.0] transparentBorder:2 cornerRadius:30 interpolationQuality:kCGInterpolationHigh];
    cell.profilePhoto.image = newImage;

    
    //    CALayer *layer = cell.profilePhoto.layer;
//    [layer setCornerRadius:16];
//    [layer setBorderWidth:1];
//    [layer setMasksToBounds:YES];
//    layer.borderColor = [[UIColor grayColor] CGColor];
    //[layer setShadowColor:[UIColor blackColor].CGColor];
    //[layer setShadowOpacity:0.8];
    //[layer setShadowRadius:3.0];
    //[layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    //cell.profilePhoto.image = profilePhoto;
    //UIImage *newImage = [UIImage imageNamed:@"profile-demo.png"];
    //cell.profilePhoto.image = [newImage thumbnailImage:33 transparentBorder:1 cornerRadius:1 interpolationQuality:1];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return 282;
}


- (void)fetchResults {
    [RestCheckin loadIndex:^(NSArray *checkins) 
                {
                    for (RestCheckin *checkin in checkins) {
                        NSLog(@"FindOrCreate Checkin: %@", checkin);
                        [Checkin checkinWithRestCheckin:checkin inManagedObjectContext:self.managedObjectContext];
                    }
                }
                onError:^(NSString *error) {
                    [SVProgressHUD showErrorWithStatus:error duration:1.0];
                }
                withPage:1];

}

     
- (IBAction)didSelectSettings:(id)sender {
    NSLog(@"did select settings");
    [self performSegueWithIdentifier:@"UserShow" sender:self];
}

- (IBAction)didCheckIn:(id)sender {
    NSLog(@"did checkin");
    [self performSegueWithIdentifier:@"Checkin" sender:self];
}

@end
