//
//  FoursquareHelper.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/21/12.
//
//

#import <Foundation/Foundation.h>
#import "BZFoursquare.h"

#define kClientID       @""
#define kCallbackURL    @"piclar://foursquare"
@protocol FoursquareHelperDelegate;

@interface FoursquareHelper : NSObject <BZFoursquareRequestDelegate, BZFoursquareSessionDelegate>
@property(nonatomic,readwrite,strong) BZFoursquare *foursquare;
@property(nonatomic,strong) BZFoursquareRequest *request;
@property (weak, nonatomic) id <FoursquareHelperDelegate> delegate;

+ (FoursquareHelper *)shared;
- (BOOL)sessionIsValid;
- (void)authorize;


@end

@protocol FoursquareHelperDelegate <NSObject>
- (void)fsqSessionValid:(BZFoursquare *)foursquare;

@end