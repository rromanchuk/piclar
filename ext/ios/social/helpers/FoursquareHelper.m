//
//  FoursquareHelper.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/21/12.
//
//

#import "FoursquareHelper.h"
#import "RestUser.h"

@implementation FoursquareHelper
+ (FoursquareHelper *)shared
{
    static FoursquareHelper *foursquareHelper;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        foursquareHelper = [[FoursquareHelper alloc] init];
    });
    
    return foursquareHelper;
}

- (id)init {
    self = [super init];
    if (self) {
        self.foursquare = [[BZFoursquare alloc] initWithClientID:kClientID callbackURL:kCallbackURL];
        self.foursquare.sessionDelegate = self;
    }
    return self;
}

- (BOOL)sessionIsValid {
    return [self.foursquare isSessionValid];
}

- (void)authorize {
    [self.foursquare startAuthorization];
}

- (void)deauthorize {
    [self.foursquare invalidateSession];
}
#pragma mark -
#pragma mark BZFoursquareRequestDelegate

- (void)requestDidFinishLoading:(BZFoursquareRequest *)request {

}

- (void)request:(BZFoursquareRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[[error userInfo] objectForKey:@"errorDetail"] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
    [alertView show];
}

#pragma mark -
#pragma mark BZFoursquareSessionDelegate

- (void)foursquareDidAuthorize:(BZFoursquare *)foursquare {
    [self.delegate fsqSessionValid:foursquare];
}

- (void)foursquareDidNotAuthorize:(BZFoursquare *)foursquare error:(NSDictionary *)errorInfo {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, errorInfo);
}

@end
