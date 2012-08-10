//
//  PhotosIndexViewController.m
//  explorer
//
//  Created by Ryan Romanchuk on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotosIndexViewController.h"
#import "UIBarButtonItem+Borderless.h"
@interface PhotosIndexViewController ()

@end

@implementation PhotosIndexViewController
@synthesize backButton;
@synthesize scrollView;
@synthesize numberOfPages; 
@synthesize pageControl;
@synthesize imageViews;
@synthesize pageControlUsed;
@synthesize managedObjectContext;
@synthesize photos;

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
    self.navigationItem.hidesBackButton = YES;
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
    self.backButton = backButtonItem;
    self.navigationItem.leftBarButtonItem = self.backButton;
	
    
    self.imageViews = [NSArray arrayWithObjects:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sample-photo1-show.png"]], [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sample-photo1-show.png"]], [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sample-photo1-show.png"]], nil];
    
    self.numberOfPages = [NSNumber numberWithInt:[self.imageViews count]];
    self.pageControl.numberOfPages = [self.numberOfPages intValue];
    self.scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * [self.numberOfPages floatValue], scrollView.frame.size.height);
    self.pageControl.currentPage = 0;
    
    CGRect cRect = self.scrollView.bounds;
    for (UIImageView *view in self.imageViews) {
        view.frame = cRect;
        [self.scrollView addSubview:view];
        cRect.origin.x += cRect.size.width;
    }
    self.scrollView.contentSize = CGSizeMake(cRect.origin.x, scrollView.bounds.size.height);
    scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0); //should be the center page in a 3 page setup
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (self.pageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
	
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender {
    int page = self.pageControl.currentPage;
	
	// update the scroll view to the appropriate page
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}


- (void)viewDidUnload
{
    [self setBackButton:nil];
    [self setScrollView:nil];
    [self setPageControl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
