@interface RestUser : NSObject

// Identifiers
@property NSInteger externalId;
@property (atomic, strong) NSString *token;
@property (atomic, strong) NSString *vkontakteToken;
@property (atomic, strong) NSString *vkUserId;

// Attributes
@property (atomic, strong) NSString *firstName;
@property (atomic, strong) NSString *lastName;
@property (atomic, strong) NSString *email;
@property (atomic, strong) UIImage *profilePhoto;
@property (atomic, strong) NSString *remoteProfilePhotoUrl;

// Associations
@property (atomic, strong) NSArray *checkins;



- (BOOL)isCurrentUser;
- (BOOL)hasLocation;

- (void)save:(void (^)(RestUser *person))onLoad
   onError:(void (^)(NSString *error))onError;

- (void)reload:(void (^)(RestUser *person))onLoad
     onError:(void (^)(NSString *error))onError;

+ (void)loginUserWithEmail:(NSString *)email
                  password:(NSString *)password
                    onLoad:(void (^)(id object))onLoad
                   onError:(void (^)(NSString *error))onError;

+ (void)create:(NSMutableDictionary *)parameters
        onLoad:(void (^)(id object))onLoad
       onError:(void (^)(NSString *error))onError;

+ (void)loadByIdentifier:(NSNumber *)identifer
                  onLoad:(void (^)(id object))onLoad
                 onError:(void (^)(NSString *error))onError;

+ (void)setCurrentUser:(RestUser *)user;
+ (void)deleteCurrentUser;
+ (RestUser *)currentUser;
+ (NSNumber *)currentUserId;
+ (NSDictionary *)mapping;
@end
