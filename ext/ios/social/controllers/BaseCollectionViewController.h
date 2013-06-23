//
//  BaseCollectionViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/12/12.
//
//


@interface BaseCollectionViewController : UICollectionViewController <NSFetchedResultsControllerDelegate>
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
