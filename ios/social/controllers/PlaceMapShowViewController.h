//
//  PlaceMapShowViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/20/12.
//
//

#import "Place.h"
#import <MapKit/MapKit.h>

@interface PlaceMapShowViewController : UIViewController
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Place *place;
@property (weak, nonatomic) IBOutlet MKMapView *mapkitView;

@end
