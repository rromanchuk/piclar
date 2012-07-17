//
//  CheckinsIndexViewController.h
//  explorer
//
//  Created by Ryan Romanchuk on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseNavigationViewController.h"
#import "PostCardContentView.h"

@interface CheckinsIndexViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;


- (IBAction)didSelectSettings:(id)sender;
- (IBAction)didCheckIn:(id)sender;

@end
