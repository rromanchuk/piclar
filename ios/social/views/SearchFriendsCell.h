//
//  SearchFriendsCell.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/27/12.
//
//

#import <UIKit/UIKit.h>
#import "ProfilePhotoView.h"
@interface SearchFriendsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *searchTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet ProfilePhotoView *searchTypePhoto;

@end
