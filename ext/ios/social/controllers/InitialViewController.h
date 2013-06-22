//
//  InitialViewController.h
//  Piclar
//
//  Created by Ryan Romanchuk on 6/12/13.
//
//

#import "IIViewDeckController.h"
#import "User+Rest.h"
#import "LeftViewController.h"
@interface InitialViewController : IIViewDeckController <LeftViewDelegate>
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) User *currentUser;

@end


