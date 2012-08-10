
@interface PhotosIndexViewController : UIViewController <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) NSNumber *numberOfPages;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) NSArray *imageViews;
@property (weak, nonatomic) NSSet *photos;

@property BOOL pageControlUsed;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (IBAction)changePage:(id)sender;
@end
