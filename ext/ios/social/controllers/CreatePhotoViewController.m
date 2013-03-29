//
//  CreatePhotoViewController.m
//  Piclar
//
//  Created by Ryan Romanchuk on 3/28/13.
//
//

#import "CreatePhotoViewController.h"

@interface CreatePhotoViewController ()

@end

@implementation CreatePhotoViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.pageScrollView setContentSize:CGSizeMake(640, self.view.frame.size.height)];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

//#pragma mark ApplicationLifecycleDelegate
//- (void)applicationWillExit {
//    DLog(@"TURNING OFF CAMERA");
//    // If the user is in UIImagePicker controller, dismiss this modal before terminating.
//    // It casues problems with gpuimage reinitializing when the app resumes active.
//    if ([self.modalViewController isKindOfClass:[UIImagePickerController class]]) {
//        [self dismissModalViewControllerAnimated:NO];
//    }
//    [self.camera stopCameraCapture];
//}
//
//- (void)applicationWillWillStart {
//    DLog(@"INSIDE APPLICATION WILL START");
//    self.applicationDidJustStart = YES;
//    if(!self.previewImageView.image)
//        [self setupInitialCameraState:self];
//}


- (void)viewDidUnload {
    [self setPageScrollView:nil];
    [super viewDidUnload];
}
@end
