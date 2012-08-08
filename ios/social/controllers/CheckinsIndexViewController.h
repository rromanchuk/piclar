//
//  CheckinsIndexViewController.h
//  explorer
//
//  Created by Ryan Romanchuk on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseNavigationViewController.h"
#import "PostCardContentView.h"
#import "CoreDataTableViewController.h"
#import "PostCardCell.h"
@interface CheckinsIndexViewController : CoreDataTableViewController <UITableViewDelegate, UITableViewDataSource> {
    UIFont *userCommentFont; 
    UIFont *commentFont; 
    CGSize userCommentLabelSize;
    CGSize commentsLabelSize;
}
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) IBOutlet PostCardCell *sampleCell;
@property (nonatomic, weak) UIImage *placeHolderImage;

- (IBAction)didSelectSettings:(id)sender;
- (IBAction)didCheckIn:(id)sender;
- (IBAction)didLike:(id)sender event:(UIEvent *)event;
- (IBAction)didPressComment:(id)sender event:(UIEvent *)event;

@end
