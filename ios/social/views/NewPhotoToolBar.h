//
//  NewPhotoToolBar.h
//  explorer
//
//  Created by Ryan Romanchuk on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewPhotoToolBar : UIToolbar
@property (nonatomic, weak) IBOutlet UIBarButtonItem *fromLibrary;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *takePicture;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *takeVideo;

@end
