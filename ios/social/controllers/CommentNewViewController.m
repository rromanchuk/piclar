//
//  CommentNewViewController.m
//  explorer
//
//  Created by Ryan Romanchuk on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommentNewViewController.h"
#import "UIBarButtonItem+Borderless.h"
#import "NewCommentFieldCell.h"
#import "NewCommentPlaceDetailCell.h"
@interface CommentNewViewController ()

@end

@implementation CommentNewViewController
@synthesize backButton;
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
    self.navigationItem.hidesBackButton = YES;
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
    self.backButton = backButtonItem;
    self.navigationItem.leftBarButtonItem = self.backButton;
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupFetchedResultsController];
}


- (void)viewDidUnload
{
    [self setBackButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Comment"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        if (indexPath.row == 0) {
            NSLog(@"NewCommentPlaceDetailCell");
            NSString *identifier = @"NewCommentPlaceDetailCell";
            NewCommentPlaceDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[NewCommentPlaceDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            NSLog(@"%@", cell);
            return cell;
        } else if (indexPath.row == 1) {
            NSLog(@"NewCommentFieldCell");
            NSString *identifier = @"NewCommentFieldCell"; 
            NewCommentFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[NewCommentFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            return cell;
        }
                    
    } else {
        NSLog(@"IN DIFFERENT SECTION");
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        return cell;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"inside num rows in section");
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.row == 0) {
        return 60;
    } else if (indexPath.row == 1) {
        return 200; 
    } 
} 


- (UIButton *) makeDetailDisclosureButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *disclosureArrow = [UIImage imageNamed:@"disclosure-indicator.png"];
    button.frame = CGRectMake(0, 0, 30.0, 30.0);
    [button setBackgroundImage:disclosureArrow forState:UIControlStateNormal];
    [button addTarget: self
               action: @selector(accessoryButtonTapped:withEvent:)
     forControlEvents: UIControlEventTouchUpInside];
    
    return button ;
}


- (void) accessoryButtonTapped: (UIControl *) button withEvent: (UIEvent *) event
{
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if ( indexPath == nil )
        return;
    
    [self.tableView.delegate tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
}

@end
