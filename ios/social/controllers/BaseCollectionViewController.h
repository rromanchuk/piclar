//
//  BaseCollectionViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/1/12.
//
//

#import <UIKit/UIKit.h>

@interface BaseCollectionViewController : UICollectionViewController
{
    BOOL needsBackButton;
    BOOL needsCheckinButton;
    BOOL needsDismissButton;
}
@end
