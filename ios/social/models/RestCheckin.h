
#import "RestObject.h"
#import "RestUser.h"
#import "RestPlace.h"
#import "RestPhoto.h"
#import "RestComment.h"
@interface RestCheckin : RestObject
@property NSInteger userRating;
@property (atomic, strong) NSString *comment; 
@property (atomic, strong) NSDate *createdAt; 
@property (atomic, strong) RestUser *user;
@property (atomic, strong) RestPlace *place;
@property (atomic, strong) NSSet *photos;
@property (atomic, strong) NSString *review;

+ (NSDictionary *)mapping;

            
+ (void)createCheckinWithPlace:(NSNumber *)placeId 
                      andPhoto:(UIImage *)photo 
                    andComment:(NSString *)comment
                     andRating:(NSNumber *)rating
                        onLoad:(void (^)(id feedItem))onLoad
                       onError:(void (^)(NSString *error))onError;

- (RestPhoto *)firstPhoto;

@end
