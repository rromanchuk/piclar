//
//  BaseTableView.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/18/12.
//
//

#import "BaseTableView.h"
#import "BaseView.h"

@interface BaseTableView ()

@end

@implementation BaseTableView

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundView = [[BaseView alloc] initWithFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height)];
    
    if (needsBackButton) {
        DLog(@"needs back button!!!!!");
        BaseView *baseView = [[BaseView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width,  self.view.bounds.size.height)];
        self.tableView.backgroundView = baseView;
        UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
        UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: backButtonItem, nil ];
    } else if (needsDismissButton) {
        UIImage *dismissButtonImage = [UIImage imageNamed:@"dismiss.png"];
        UIBarButtonItem *dismissButtonItem = [UIBarButtonItem barItemWithImage:dismissButtonImage target:self action:@selector(dismissModal:)];
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects: dismissButtonItem, nil]];
    }
    
    
}


@end
