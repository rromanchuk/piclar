#import "RestObject.h"
@interface RestUser : RestObject

// Identifiers
@property (atomic, strong) NSString *token;
@property (atomic, strong) NSString *vkontakteToken;
@property (atomic, strong) NSString *vkUserId;

// Attributes
@property (atomic, strong) NSString *firstName;
@property (atomic, strong) NSString *lastName;
@property (atomic, strong) NSString *fullName;
@property (atomic, strong) NSString *email;
@property (atomic, strong) UIImage *profilePhoto;
@property (atomic, strong) NSString *remoteProfilePhotoUrl;
@property (atomic, strong) NSString *location;

// Associations
@property (atomic, strong) NSArray *checkins;
@property (atomic, strong) NSSet *followers;
@property (atomic, strong) NSSet *following;




- (BOOL)isCurrentUser;


+ (void)reload:(void (^)(RestUser *person))onLoad
     onError:(void (^)(NSString *error))onError;

+ (void)loginUserWithEmail:(NSString *)email
                  password:(NSString *)password
                    onLoad:(void (^)(id object))onLoad
                   onError:(void (^)(NSString *error))onError;

+ (void)create:(NSMutableDictionary *)parameters
        onLoad:(void (^)(RestUser *restUser))onLoad
       onError:(void (^)(NSString *error))onError;

+ (void)loadByIdentifier:(NSNumber *)identifer
                  onLoad:(void (^)(RestUser *restUser))onLoad
                 onError:(void (^)(NSString *error))onError;

+ (void)loadFollowers:(void (^)(NSSet *users))onLoad
                 onError:(void (^)(NSString *error))onError;

+ (void)loadFollowing:(void (^)(NSSet *users))onLoad
              onError:(void (^)(NSString *error))onError;

+ (void)setCurrentUser:(RestUser *)user;
+ (void)deleteCurrentUser;
+ (RestUser *)currentUser;
+ (NSNumber *)currentUserId;
+ (NSDictionary *)mapping;
+ (NSString *)currentUserToken;

@end
