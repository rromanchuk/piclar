//
//  NoResultscontrollerViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/24/12.
//
//

#import "NoResultscontrollerViewController.h"
#import "PhotoNewViewController.h"
@interface NoResultscontrollerViewController ()

@end

@implementation NoResultscontrollerViewController

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
    self.noResultsLabel.text = NSLocalizedString(@"NO_RESULTS", nil);
	// Do any additional setup after loading the view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if ([[segue identifier] isEqualToString:@"Checkin"]) {
        UINavigationController *nc = (UINavigationController *)[segue destinationViewController];
        [Flurry logAllPageViews:nc];
        PhotoNewViewController *vc = (PhotoNewViewController *)((UINavigationController *)[segue destinationViewController]).topViewController;
        vc.managedObjectContext = self.presentingViewController;
        vc.delegate = self;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setNoResultsLabel:nil];
    [self setNoResultsCheckinButton:nil];
    [super viewDidUnload];
}

- (IBAction)didPressCheckin:(id)sender {
    [self.delegate userClickedCheckin];
}
@end
