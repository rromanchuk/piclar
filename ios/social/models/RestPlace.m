

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
@synthesize lat;
@synthesize lon;
@synthesize typeId;

+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"title", @"title",
            @"type", @"type_text",
            @"typeId", @"type",
            @"desc", @"description",
            @"address", @"address",
            @"externalId", @"id",
            @"rating", @"rate",
            @"lat", @"position.lat",
            @"lon", @"position.lng",
            //[RestCheckin mappingWithKey:@"checkins" mapping:[RestCheckin mapping]], @"checkins",
            [RestPhoto mappingWithKey:@"photos" mapping:[RestPhoto mapping]], @"photos",
            [NSDate mappingWithKey:@"createdAt"
                  dateFormatString:@"yyyy-MM-dd'T'hh:mm:ssZ"], @"create_date",
            [NSDate mappingWithKey:@"updatedAt"
                  dateFormatString:@"yyyy-MM-dd'T'hh:mm:ssZ"], @"modified_date",
            nil];
}

+ (void)loadByIdentifier:(NSNumber *)identifier
                  onLoad:(void (^)(RestPlace *restPlace))onLoad
                 onError:(void (^)(NSString *error))onError {
    
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [RESOURCE stringByAppendingString:[NSString stringWithFormat:@"/%@.json", identifier]];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"GET" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" path:path parameters:[RestClient defaultParametersWithParams:params]];
    
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
                                                                                             NSString *publicMessage = [RestObject processError:error for:@"LOAD_PLACE_BY_IDENTIFIER" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError)
                                                                                                onError(publicMessage);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

}

+ (void)searchByLat:(float)lat
             andLon:(float)lon
             onLoad:(void (^)(NSSet *places))onLoad
            onError:(void (^)(NSString *error))onError {
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [RESOURCE stringByAppendingString:@"/search.json"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f", lat], @"lat", [NSString stringWithFormat:@"%f", lon], @"lng", nil];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" path:path parameters:[RestClient defaultParametersWithParams:params]];
    
    DLog(@"SEARCH PLACES REQUEST %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            DLog(@"SEARCH PLACES JSON %@", JSON);
                                                                                            NSMutableSet *places = [[NSMutableSet alloc] init];
                                                                                            for (id placeData in JSON) {
                                                                                                RestPlace *restPlace = [RestPlace objectFromJSONObject:placeData mapping:[RestPlace mapping]];
                                                                                                [places addObject:restPlace];
                                                                                            }

                                                                                            if (onLoad)
                                                                                                onLoad(places);
                                                                                        } 
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                             NSString *publicMessage = [RestObject processError:error for:@"SEARCH_PLACE" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError)
                                                                                                onError(publicMessage);
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
    
    
    DLog(@"lOAD REVIEWS %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            DLog(@"REVIEWS JSON %@", JSON);
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
                                                                                             NSString *publicMessage = [RestObject processError:error for:@"LOAD_REVIEWS_FOR_PLACE" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError)
                                                                                                onError(publicMessage);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

}

+ (void)create:(NSMutableDictionary *)parameters
        onLoad:(void (^)(RestPlace *restPlace))onLoad
       onError:(void (^)(NSString *error))onError {
    RestClient *restClient = [RestClient sharedClient];
    
    NSString *signature = [RestClient signatureWithMethod:@"POST" andParams:parameters andToken:[RestUser currentUserToken]];
    [parameters setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"POST"
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
                                                                                            NSString *publicMessage = [RestObject processError:error for:@"CREATE_PLACE" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError)
                                                                                                onError(publicMessage);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

    
}

- (NSString *) description {
    return [NSString stringWithFormat:@"EXTERNAL_ID: %d\nTITLE: %@\nDESCRIPTION: %@\nADDRESS:\nCREATED AT: %@\n MODIFIED AT: %@\n",
            self.externalId, self.title, self.desc, self.address, self.createdAt];
}
@end
