

#import "RestPlace.h"
#import "AFJSONRequestOperation.h"
#import "RestClient.h"
#import "RestPhoto.h"
#import "RestUser.h"
#import "RestCheckin.h"
@implementation RestPlace

static NSString *RESOURCE = @"api/v1/place";
@synthesize title; 
@synthesize desc;
@synthesize address;
@synthesize createdAt;
@synthesize updatedAt;
@synthesize photos;
@synthesize type;
@synthesize rating;

+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"title", @"title",
            @"type", @"type_text",
            @"desc", @"description",
            @"address", @"address",
            @"externalId", @"id",
            @"rating", @"rate",
            //[RestCheckin mappingWithKey:@"checkins" mapping:[RestCheckin mapping]], @"checkins",
            [RestPhoto mappingWithKey:@"photos" mapping:[RestPhoto mapping]], @"photos",
            [NSDate mappingWithKey:@"createdAt"
                  dateFormatString:@"yyyy-MM-dd'T'hh:mm:ssZ"], @"create_date",
            [NSDate mappingWithKey:@"updatedAt"
                  dateFormatString:@"yyyy-MM-dd'T'hh:mm:ssZ"], @"modified_date",
            nil];
}

+ (void)loadByIdentifier:(NSInteger)identifier
                  onLoad:(void (^)(id object))onLoad
                 onError:(void (^)(NSString *error))onError {
    
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [RESOURCE stringByAppendingString:[NSString stringWithFormat:@"/%d.json", identifier]];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"GET" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" path:path parameters:[RestClient defaultParametersWithParams:params]];
    
    NSLog(@"PLACE IDENTIFER REQUEST %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSLog(@"LOAD PLACE JSON %@", JSON);
                                                                                            RestPlace *place = [RestPlace objectFromJSONObject:JSON mapping:[RestPlace mapping]];
                                                                                            if (onLoad)
                                                                                                onLoad(place);
                                                                                        } 
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSString *message = [JSON objectForKey:@"message"];
                                                                                            NSLog(@"Load place by id: %@", message);
                                                                                            if (onError)
                                                                                                onError(message);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

}

+ (void)searchByLat:(float)lat
             andLon:(float)lon
             onLoad:(void (^)(id object))onLoad 
            onError:(void (^)(NSString *error))onError {
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [RESOURCE stringByAppendingString:@"/search.json"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f", lat], @"lat", [NSString stringWithFormat:@"%f", lon], @"lng", nil];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" path:path parameters:[RestClient defaultParametersWithParams:params]];
    
    NSLog(@"SEARCH PLACES REQUEST %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSLog(@"SEARCH PLACES JSON %@", JSON);
                                                                                            RestPlace *place = [RestPlace objectFromJSONObject:JSON mapping:[RestPlace mapping]];
                                                                                            if (onLoad)
                                                                                                onLoad(place);
                                                                                        } 
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSString *message = [JSON objectForKey:@"message"];
                                                                                            NSLog(@"Search places error: %@", message);
                                                                                            if (onError)
                                                                                                onError(message);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

}

+ (void)loadReviewsWithPlaceId:(NSNumber *)placeId
             onLoad:(void (^)(NSSet *reviews))onLoad
            onError:(void (^)(NSString *error))onError {
    
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [RESOURCE stringByAppendingFormat:@"/%@/reviews.json", placeId];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"GET" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" path:path parameters:[RestClient defaultParametersWithParams:params]];
    
    
    NSLog(@"lOAD REVIEWS %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSLog(@"REVIEWS JSON %@", JSON);
                                                                                            NSMutableSet *checkins = [[NSMutableSet alloc] init];
                                                                                            for (id checkinItem in JSON) {
                                                                                                RestCheckin *checkin = [RestCheckin objectFromJSONObject:checkinItem mapping:[RestCheckin mapping]];
                                                                                                [checkins addObject:checkin];
                                                                                            }
                                                                            
                                                                                            if (onLoad)
                                                                                                onLoad(checkins);
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSString *message = [JSON objectForKey:@"message"];
                                                                                            NSLog(@"Search places error: %@", message);
                                                                                            if (onError)
                                                                                                onError(message);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

}

- (NSString *) description {
    return [NSString stringWithFormat:@"EXTERNAL_ID: %d\nTITLE: %@\nDESCRIPTION: %@\nADDRESS:\nCREATED AT: %@\n MODIFIED AT: %@\n",
            self.externalId, self.title, self.desc, self.address, self.createdAt];
}
@end
