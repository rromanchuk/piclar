//
//  MoveAndScalePhotoViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/20/12.
//
//

@protocol MoveAndScaleDelegate;
@interface MoveAndScalePhotoViewController : UIViewController <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageFromLibrary;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImage *image;
@property (weak, nonatomic) id <MoveAndScaleDelegate> delegate;
- (IBAction)didCancel:(id)sender;
- (IBAction)didAcceptChanges:(id)sender;
@end

@protocol MoveAndScaleDelegate <NSObject>
@required
- (void)didResizeImage:(UIImage *)image;
- (void)didCancelResizeImage;

@end