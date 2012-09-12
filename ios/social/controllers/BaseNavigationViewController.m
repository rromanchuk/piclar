
#import "BaseNavigationViewController.h"
#import "UIBarButtonItem+Borderless.h"
#import <QuartzCore/QuartzCore.h>

@interface BaseNavigationViewController ()

@end

@implementation BaseNavigationViewController
@synthesize wantsBackButtonToDismissModal;
@synthesize notificationOnDismiss;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Remove the default black bottom border
    UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];
    [overlayView setBackgroundColor:RGBCOLOR(223.0, 223.0, 223.0)];
    [self.navigationBar addSubview:overlayView]; // navBar is your UINavigationBar instance
        
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
