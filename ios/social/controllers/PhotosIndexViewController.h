#import "Place.h"

@interface PhotosIndexViewController : UIViewController <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) NSNumber *numberOfPages;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) NSMutableArray *imageViews;
@property (weak, nonatomic) NSArray *photos;
@property (weak, nonatomic) Place *place;

@property NSUInteger selectedPhotoIndex;


@property BOOL pageControlUsed;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (IBAction)changePage:(id)sender;
@end
