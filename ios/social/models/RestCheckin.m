#import "RestCheckin.h"
#import "RestClient.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"

static NSString *CHEKIN_RESOURCE = @"api/v1/checkin";
static NSString *PERSON_RESOURCE = @"api/v1/person";

@implementation RestCheckin
@synthesize externalId;
@synthesize favorites;
@synthesize createdAt; 
@synthesize comment;
@synthesize place;
@synthesize user; 
@synthesize photos;

+ (NSDictionary *)mapping {
//    [JTUserTest mappingWithKey:@"users"
//                       mapping:[NSDictionary dictionaryWithObjectsAndKeys:
//                                @"name", @"p_name",
//                                nil]], @"p_users",
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"externalId", @"id",
            @"comment", @"comment",
            [NSDate mappingWithKey:@"createdAt"
                  dateFormatString:@"yyyy-MM-dd HH:mm:ssZ"], @"create_date",
            [RestUser mappingWithKey:@"user"
                                        mapping:[RestUser mapping]], @"person",
            [RestPlace mappingWithKey:@"place" 
                              mapping:[RestPlace mapping]], @"place",
            @"favorites", @"count_likes",
            nil];
}

+ (void)loadIndex:(void (^)(id object))onLoad 
                  onError:(void (^)(NSString *error))onError
                 withPage:(int)page {
    
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [PERSON_RESOURCE stringByAppendingString:@"/logged/feed.json"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"GET" andParams:params andToken:[RestUser currentUserToken]]; 
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" path:path parameters:[RestClient defaultParametersWithParams:params]];
    NSLog(@"CHECKIN INDEX REQUEST %@", request);
    TFLog(@"CHECKIN INDEX REQUEST: %@", request);
    
    

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSLog(@"JSON %@", JSON);
                                                                                            NSMutableArray *checkins = [[NSMutableArray alloc] init];
                                                                                            if ([JSON count] > 0) {
                                                                                                for (id checkinDict in JSON) {
                                                                                                    id data = [checkinDict objectForKey:@"data"];
                                                                                                    id checkinDictionary = [data objectForKey:@"checkin"];
                                                                                                    
                                                                                                    NSLog(@"checkin dictionary is %@", checkinDictionary);
                                                                                                    RestCheckin *checkin = [RestCheckin objectFromJSONObject:checkinDictionary mapping:[RestCheckin mapping]];
                                                                                                    [checkins addObject:checkin];
                                                                                                    NSLog(@"restCheckin object is %@", checkin);
                                                                                                }
                                                                                                
                                                                                                NSLog(@"restCheckin %@", checkins);
                                                                                                if (onLoad)
                                                                                                    onLoad(checkins);
                                                                                            }
                                                                                            
                                                                                        } 
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSString *description = [[response allHeaderFields] objectForKey:@"X-Error"];
                                                                                            NSLog(@"%@", JSON);
                                                                                            NSLog(@"%@", error);
                                                                                            if (onError)
                                                                                                onError(description);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];
    
    
}

+ (void)createCheckinWithPlace:(NSNumber *)placeId 
                      andPhoto:(UIImage *)photo 
                    andComment:(NSString *)comment
                        onLoad:(void (^)(RestCheckin *checkin))onLoad
                       onError:(void (^)(NSString *error))onError;
{
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [CHEKIN_RESOURCE stringByAppendingString:@".json"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:comment, @"comment", placeId, @"place_id", nil];
    NSString *signature = [RestClient signatureWithMethod:@"POST" andParams:params andToken:[RestUser currentUserToken]]; 
    [params setValue:signature forKey:@"auth"];
    NSData *imageData = UIImagePNGRepresentation(photo);
    
    NSMutableURLRequest *request = [restClient multipartFormRequestWithMethod:@"POST" 
                                                                         path:path 
                                                                   parameters:[RestClient defaultParametersWithParams:params] 
                                                    constructingBodyWithBlock:^(id <AFMultipartFormData>formData) 
                                    {                                     

                                        [formData appendPartWithFileData:imageData 
                                                                    name:@"photo" 
                                                                fileName:@"my_photo.png" 
                                                                mimeType:@"image/png"]; 
                                    }]; 
    NSLog(@"CHECKIN CREATE REQUEST %@", request);
    TFLog(@"CHECKIN CREATE REQUEST: %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            
                                                                                            
                                                                                            NSLog(@"JSON: %@", JSON);
                                                                                            id data = [JSON objectForKey:@"data"];
                                                                                            id checkinDictionary = [data objectForKey:@"checkin"];
                                                                                            RestCheckin *checkin = [RestCheckin objectFromJSONObject:checkinDictionary mapping:[self mapping]];
                                                                                            if (onLoad)
                                                                                                onLoad(checkin);
                                                                                        } 
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSString *description = [[response allHeaderFields] objectForKey:@"X-Error"];
                                                                                            NSLog(@"%@", JSON);
                                                                                            NSLog(@"%@", error);
                                                                                            if (onError)
                                                                                                onError(description);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

                                    
}

- (NSString *) description {
    return [NSString stringWithFormat:@"[RestCheckin] EXTERNAL_ID: %d\nCREATED AT: %@\n COMMENT: %@\nUSER: %@\nPLACE: %@",
            self.externalId, self.createdAt, self.comment, self.user, self.place];
}

@end
