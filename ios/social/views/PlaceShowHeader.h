//
//  PlaceShowHeader.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/12/12.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PlaceShowHeader : PSUICollectionReusableView
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *typeImage;
@property (weak, nonatomic) IBOutlet UIButton *switchLayoutButton;

@end
