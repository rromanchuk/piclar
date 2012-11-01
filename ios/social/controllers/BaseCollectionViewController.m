//
//  BaseCollectionViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/1/12.
//
//

#import "BaseCollectionViewController.h"
#import "BaseView.h"
@interface BaseCollectionViewController ()

@end

@implementation BaseCollectionViewController

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
    if (needsBackButton) {
        DLog(@"needs back button!!!!!");
        UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
        UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: backButtonItem, nil ];
    } else if (needsDismissButton) {
        UIImage *dismissButtonImage = [UIImage imageNamed:@"dismiss.png"];
        UIBarButtonItem *dismissButtonItem = [UIBarButtonItem barItemWithImage:dismissButtonImage target:self action:@selector(dismissModal:)];
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects: dismissButtonItem, nil]];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
