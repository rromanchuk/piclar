//
//  FoursquareHelper.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/21/12.
//
//

#import <Foundation/Foundation.h>
#import "BZFoursquare.h"

#define kClientID       @"***REMOVED***"
#define kCallbackURL    @"ostronaut://foursquare"

@interface FoursquareHelper : NSObject <BZFoursquareRequestDelegate, BZFoursquareSessionDelegate>
@property(nonatomic,readwrite,strong) BZFoursquare *foursquare;
@property(nonatomic,strong) BZFoursquareRequest *request;

+ (FoursquareHelper *)shared;
- (BOOL)sessionIsValid;
- (void)authorize;


@end
