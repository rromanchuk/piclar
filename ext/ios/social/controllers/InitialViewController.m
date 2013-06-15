//
//  InitialViewController.m
//  Piclar
//
//  Created by Ryan Romanchuk on 6/12/13.
//
//

#import "InitialViewController.h"
#import "ApplicatonNavigationController.h"
@interface InitialViewController ()

@end

@implementation InitialViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    self = [super initWithCenterViewController:[storyboard instantiateViewControllerWithIdentifier:@"middleViewController"]
                            leftViewController:[storyboard instantiateViewControllerWithIdentifier:@"leftViewController"]];
    if (self) {
        // Add any extra init code here
        ((LeftViewController *)((ApplicatonNavigationController *)self.leftController).topViewController).delegate = self;

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    ((LeftViewController *)self.leftController).delegate = self;
}


- (void)doesNeedSegueFor:(NSString *)identifier sender:(id)sender {
    [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
        //controller.centerController = [UIViewController alloc] init];
        // ...
    }];
    [self.viewDeckController toggleLeftViewAnimated:YES];

    ALog(@"did press segue for %@", identifier);
}

@end
