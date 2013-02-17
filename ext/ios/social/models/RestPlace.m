

#import "RestPlace.h"
#import "AFJSONRequestOperation.h"
#import "RestPhoto.h"
#import "RestUser.h"
#import "RestCheckin.h"
#import "RailsRestClient.h"

@implementation RestPlace

static NSString *RESOURCE = @"places";

+ (NSDictionary *)mapping {
    return [self mapping:FALSE];
}

+ (NSDictionary *)mapping:(BOOL)is_nested {
    NSMutableDictionary *map = [NSMutableDictionary dictionaryWithObjectsAndKeys:
     @"title", @"title",
     //@"cityName", @"city_name",
     //@"countryName", @"country_name",
     @"type", @"type_text",
     @"typeId", @"type",
     //@"desc", @"description",
     @"address", @"address",
     @"externalId", @"id",
     @"foursquareId", @"foursquare_id",
     //@"rating", @"rate",
     @"lat", @"latitude",
     @"lon", @"longitude",

     //[RestPhoto mappingWithKey:@"photos" mapping:[RestPhoto mapping]], @"photos",
     [NSDate mappingWithKey:@"createdAt"
           dateFormatString:@"yyyy-MM-dd'T'hh:mm:ssZ"], @"create_date",
     [NSDate mappingWithKey:@"updatedAt"
           dateFormatString:@"yyyy-MM-dd'T'hh:mm:ssZ"], @"modified_at",
                         nil];
//    if (!is_nested) {
//        [map setObject:[RestCheckin mappingWithKey:@"checkins" mapping:[RestCheckin mapping]] forKey:@"checkins"];
//
//    }
    return map;
}

+ (void)loadByIdentifier:(NSNumber *)identifier
                  onLoad:(void (^)(RestPlace *restPlace))onLoad
                 onError:(void (^)(NSError *error))onError {
    
    RailsRestClient *restClient = [RailsRestClient sharedClient];
    NSString *path = [RESOURCE stringByAppendingString:[NSString stringWithFormat:@"/%@.json", identifier]];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSMutableURLRequest *request = [restClient signedRequestWithMethod:@"GET" path:path parameters:params];
    
    DLog(@"PLACE IDENTIFER REQUEST %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            DLog(@"LOAD PLACE JSON %@", JSON);
                                                                                            
                                                                                            RestPlace *place = [RestPlace objectFromJSONObject:JSON mapping:[RestPlace mapping]];
                                                                                            DLog(@"place is %@", place);
                                                                                            if (onLoad)
                                                                                                onLoad(place);
                                                                                        } 
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                             NSError *customError = [RestObject customError:error withServerResponse:response andJson:JSON];
                                                                                            if (onError)
                                                                                                onError(customError);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

}

+ (void)searchByLat:(double)lat
             andLon:(double)lon
             onLoad:(void (^)(NSSet *places))onLoad
            onError:(void (^)(NSError *error))onError
           priority:(NSOperationQueuePriority)priority
{
    //RestClient *restClient = [RestClient sharedClient];
    //NSString *path = [RESOURCE stringByAppendingString:@"/search.json"];
    
    RailsRestClient *railsRestClient = [RailsRestClient sharedClient];
    NSString *path = [RESOURCE stringByAppendingString:@"/search.json"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%g", lat], @"lat", [NSString stringWithFormat:@"%g", lon], @"lng", nil];
    
//    if ([RestUser currentUserToken]) {
//        NSString *signature = [RestClient signatureWithMethod:@"GET" andParams:params andToken:[RestUser currentUserToken]];
//        [params setValue:signature forKey:@"auth"];
//    }
//
//    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" path:path parameters:[RestClient defaultParametersWithParams:params]];
    
    NSMutableURLRequest *request = [railsRestClient signedRequestWithMethod:@"GET" path:path parameters:params];
    
    ALog(@"SEARCH PLACES REQUEST %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            //ALog(@"SEARCH PLACES JSON %@", JSON);
                                                                                            
                                                                                            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                                                // Add code here to do background processing
                                                                                                NSMutableSet *places = [[NSMutableSet alloc] init];
                                                                                                for (id placeData in JSON) {
                                                                                                    RestPlace *restPlace = [RestPlace objectFromJSONObject:placeData mapping:[RestPlace mapping]];
                                                                                                    [places addObject:restPlace];
                                                                                                }
                                                                                                DLog(@"found %d places", [places count]);

                                                                                                dispatch_async( dispatch_get_main_queue(), ^{
                                                                                                    // Add code here to update the UI/send notifications based on the
                                                                                                    // results of the background processing
                                                                                                    if (onLoad)
                                                                                                        onLoad(places);
                                                                                                });
                                                                                            });
                                                                                        } 
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                             NSError *customError = [RestObject customError:error withServerResponse:response andJson:JSON];
                                                                                            if (onError)
                                                                                                onError(customError);
                                                                                        }];
    operation.queuePriority = priority; 
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

}

+ (void)loadReviewsWithPlaceId:(NSNumber *)placeId
             onLoad:(void (^)(NSSet *reviews))onLoad
            onError:(void (^)(NSError *error))onError {
    
//    RestClient *restClient = [RestClient sharedClient];
//    NSString *path = [RESOURCE stringByAppendingFormat:@"/%@/reviews.json", placeId];
//    
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//    NSString *signature = [RestClient signatureWithMethod:@"GET" andParams:params andToken:[RestUser currentUserToken]];
//    [params setValue:signature forKey:@"auth"];
//    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" path:path parameters:[RestClient defaultParametersWithParams:params]];
//    
//    
//    ALog(@"lOAD REVIEWS %@", request);
//    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
//                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
//                                                                                            DLog(@"REVIEWS JSON %@", JSON);
//                                                                                            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                                                                                                NSMutableSet *checkins = [[NSMutableSet alloc] init];
//                                                                                                for (id checkinItem in JSON) {
//                                                                                                    RestCheckin *checkin = [RestCheckin objectFromJSONObject:checkinItem mapping:[RestCheckin mapping]];
//                                                                                                    [checkins addObject:checkin];
//                                                                                                }
//                                                                                                dispatch_async( dispatch_get_main_queue(), ^{
//                                                                                                    if (onLoad)
//                                                                                                        onLoad(checkins);
//                                                                                                });
//                                                                                            });
//                                                                                        }
//                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
//                                                                                             NSError *customError = [RestObject customError:error withServerResponse:response andJson:JSON];
//                                                                                            if (onError)
//                                                                                                onError(customError);
//                                                                                        }];
//    [[UIApplication sharedApplication] showNetworkActivityIndicator];
//    [operation start];

}

+ (void)create:(NSMutableDictionary *)parameters
        onLoad:(void (^)(RestPlace *restPlace))onLoad
       onError:(void (^)(NSError *error))onError {
    RailsRestClient *restClient = [RailsRestClient sharedClient];
    
    NSMutableURLRequest *request = [restClient signedRequestWithMethod:@"POST"
                                                            path:[RESOURCE stringByAppendingString:@".json"]
                                                      parameters:[RestClient defaultParametersWithParams:parameters]];
    
    
    DLog(@"CREATE REQUEST: %@", request);
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            DLog(@"JSON: %@", JSON);
                                                                                            RestPlace *restPlace = [RestPlace objectFromJSONObject:JSON mapping:[RestPlace mapping]];
                                                                                            DLog(@"rest object %@", restPlace);
                                                                                            if (onLoad)
                                                                                                onLoad(restPlace);
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            DLog(@"error %@", JSON);
                                                                                            NSError *customError = [RestObject customError:error withServerResponse:response andJson:JSON];
                                                                                            if (onError)
                                                                                                onError(customError);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

    
}

- (NSString *) description {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:self.externalId], @"externalId",  self.title, @"title", self.desc, @"desc", self.address, @"address",  self.createdAt, @"createdAt", nil];
    return [dict description];
}
@end
