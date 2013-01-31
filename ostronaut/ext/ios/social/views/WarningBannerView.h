//
//  WarningBannerView.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/4/12.
//
//

#import <UIKit/UIKit.h>

@interface WarningBannerView : UIView
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UIImageView *warningImage;

- (id)initWithFrame:(CGRect)frame andMessage:(NSString *)message;

@end
