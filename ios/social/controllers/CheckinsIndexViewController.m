
#import "CheckinsIndexViewController.h"
#import "PostCardCell.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>
#import "User.h"
@interface CheckinsIndexViewController ()

@end

@implementation CheckinsIndexViewController

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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"inside num rows in section");
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"IN DEQUEUE");
    static NSString *CellIdentifier = @"CheckinCell";
    
    
    PostCardCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[PostCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UIImage *newImage = [UIImage imageNamed:@"profile-demo.png"];
    cell.profilePhoto.image = [newImage thumbnailImage:30 transparentBorder:1 cornerRadius:15 interpolationQuality:kCGInterpolationHigh];
    CALayer *layer = cell.profilePhoto.layer;
    [layer setCornerRadius:15];
    [layer setBorderWidth:1];
    [layer setMasksToBounds:YES];
    layer.borderColor = [[UIColor grayColor] CGColor];
    [layer setShadowColor:[UIColor blackColor].CGColor];
    [layer setShadowOpacity:0.8];
    [layer setShadowRadius:3.0];
    [layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    //cell.profilePhoto.image = profilePhoto;
    //UIImage *newImage = [UIImage imageNamed:@"profile-demo.png"];
    //cell.profilePhoto.image = [newImage thumbnailImage:33 transparentBorder:1 cornerRadius:1 interpolationQuality:1];
    return cell;
}



@end
