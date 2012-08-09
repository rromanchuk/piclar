
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
@property (atomic, strong) RestComment *review;

+ (NSDictionary *)mapping;

            
+ (void)createCheckinWithPlace:(NSNumber *)placeId 
                      andPhoto:(UIImage *)photo 
                    andComment:(NSString *)comment
                     andRating:(NSInteger)rating
                        onLoad:(void (^)(RestCheckin *checkin))onLoad
                       onError:(void (^)(NSString *error))onError;

- (RestPhoto *)firstPhoto;

@end
