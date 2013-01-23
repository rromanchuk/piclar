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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.noResultsLabel.text = NSLocalizedString(@"NO_RESULTS", nil);

	// Do any additional setup after loading the view.
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
