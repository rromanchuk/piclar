//
//  CreatePhotoViewController.h
//  Piclar
//
//  Created by Ryan Romanchuk on 3/28/13.
//
//

#import "ApplicationLifecycleDelegate.h"
#import "Location.h"
#import "User+Rest.h"

@protocol CreateCheckinDelegate;
@interface CreatePhotoViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationDelegate, ApplicationLifecycleDelegate>
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) User *currentUser;
@property (weak, nonatomic) id <CreateCheckinDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIScrollView *pageScrollView;

@end
