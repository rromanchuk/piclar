
#import "BaseNavigationViewController.h"
#import "UIBarButtonItem+Borderless.h"
#import <QuartzCore/QuartzCore.h>

@interface BaseNavigationViewController ()

@end

@implementation BaseNavigationViewController
@synthesize wantsBackButtonToDismissModal;
@synthesize notificationOnDismiss;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar.png"]
                                 forBarMetrics:UIBarMetricsDefault];
    }
    
    self.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue" size:20.0], UITextAttributeFont, RGBACOLOR(204.0, 204.0, 204.0, 1.0), UITextAttributeTextColor, nil];
    
    
    [self setViewCorners];            
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)dismissModalTo:(id)sender {
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:self.notificationOnDismiss
     object:self];
}

- (void)setViewCorners {
    CALayer *layer = self.view.layer;
    //layer.frame = self.view.frame;
    layer.cornerRadius = 10.0;
    layer.masksToBounds = YES;
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    //gradientLayer.frame = self.view.frame;
    
    UIColor *colorOne = RGBACOLOR(239.0, 239.0, 239.0, 1.0);
    UIColor *colorTwo = RGBACOLOR(249.0, 249.0, 249.0, 1.0);
    
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    gradientLayer.colors = colors;
    [layer addSublayer:gradientLayer];

}

@end