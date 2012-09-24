//
//  CheckinsIndexViewController.h
//  explorer
//
//  Created by Ryan Romanchuk on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseNavigationViewController.h"
#import "CoreDataTableViewController.h"
#import "PostCardCell.h"
#import "User.h"
#import "PhotoNewViewController.h"
#import "UserShowViewController.h"
#import "RestClient.h"
#import "NoResultscontrollerViewController.h"
@interface CheckinsIndexViewController : CoreDataTableViewController <UITableViewDelegate, UITableViewDataSource, CreateCheckinDelegate, ProfileShowDelegate, NetworkReachabilityDelegate, NoResultsModalDelegate> {
    
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) User *currentUser;

@property (nonatomic, weak) UIImage *placeHolderImage;
@property (nonatomic, weak) UIImage *star1;
@property (nonatomic, weak) UIImage *star2;
@property (nonatomic, weak) UIImage *star3;
@property (nonatomic, weak) UIImage *star4;
@property (nonatomic, weak) UIImage *star5;

- (void)networkReachabilityDidChange:(BOOL)connected;
- (IBAction)didSelectSettings:(id)sender;
- (IBAction)didCheckIn:(id)sender;
- (IBAction)didLike:(id)sender event:(UIEvent *)event;
- (IBAction)didPressComment:(id)sender event:(UIEvent *)event;
- (IBAction)didPressProfilePhoto:(id)sender;
- (IBAction)didTapPostCard:(id)sender;
@end
