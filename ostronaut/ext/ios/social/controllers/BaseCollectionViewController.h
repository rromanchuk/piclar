//
//  BaseCollectionViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/12/12.
//
//

#import <UIKit/UIKit.h>

@interface BaseCollectionViewController : PSUICollectionViewController <NSFetchedResultsControllerDelegate> 
{
    BOOL needsBackButton;
    BOOL needsCheckinButton;
    BOOL needsDismissButton;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property BOOL pauseUpdates;
@property BOOL debug;

@end
