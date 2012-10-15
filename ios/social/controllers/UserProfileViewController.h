//
//  UserProfileViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/15/12.
//
//

#import <UIKit/UIKit.h>
#import "ProfilePhotoView.h"

@interface UserProfileViewController : UIViewController
@property (weak, nonatomic) IBOutlet ProfilePhotoView *profilePhoto;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *numPostcardsLabel;

@end
