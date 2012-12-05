//
//  LikersBanner.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/19/12.
//
//

#import <UIKit/UIKit.h>

@interface LikersBanner : UIView
@property (strong) UIImageView *disclosureIndicator;
@property (strong) NSSet *likers;


- (void)layoutViewForLikers:(NSSet *)likers;
@end
