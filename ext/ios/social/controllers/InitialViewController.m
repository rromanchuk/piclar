//
//  InitialViewController.m
//  Piclar
//
//  Created by Ryan Romanchuk on 6/12/13.
//
//

#import "InitialViewController.h"

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
       
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
