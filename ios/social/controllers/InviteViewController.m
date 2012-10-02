//
//  InviteViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/2/12.
//
//

#import "InviteViewController.h"

@interface InviteViewController ()

@end

@implementation InviteViewController
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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setEnterCodeLabel:nil];
    [self setCodeTextField:nil];
    [self setEnterButton:nil];
    [self setCheckinLabel:nil];
    [self setCheckinButton:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

# pragma mark - CreateCheckinDelegate
- (void)didFinishCheckingIn {
    [self dismissModalViewControllerAnimated:YES];
}

@end
