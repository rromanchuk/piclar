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
    BaseView *baseView = [[BaseView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width,  self.view.bounds.size.height)];
    self.tableView.backgroundView = baseView;
}


@end