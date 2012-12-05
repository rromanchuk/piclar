
/*
 kCFURLErrorUnknown   = -998,
 kCFURLErrorCancelled = -999,
 kCFURLErrorBadURL    = -1000,
 kCFURLErrorTimedOut  = -1001,
 kCFURLErrorUnsupportedURL = -1002,
 kCFURLErrorCannotFindHost = -1003,
 kCFURLErrorCannotConnectToHost    = -1004,
 kCFURLErrorNetworkConnectionLost  = -1005,
 kCFURLErrorDNSLookupFailed        = -1006,
 kCFURLErrorHTTPTooManyRedirects   = -1007,
 kCFURLErrorResourceUnavailable    = -1008,
 kCFURLErrorNotConnectedToInternet = -1009,
 kCFURLErrorRedirectToNonExistentLocation = -1010,
 kCFURLErrorBadServerResponse             = -1011,
 kCFURLErrorUserCancelledAuthentication   = -1012,
 kCFURLErrorUserAuthenticationRequired    = -1013,
 kCFURLErrorZeroByteResource        = -1014,
 kCFURLErrorCannotDecodeRawData     = -1015,
 kCFURLErrorCannotDecodeContentData = -1016,
 kCFURLErrorCannotParseResponse     = -1017,
 kCFURLErrorInternationalRoamingOff = -1018,
 kCFURLErrorCallIsActive               = -1019,
 kCFURLErrorDataNotAllowed             = -1020,
 kCFURLErrorRequestBodyStreamExhausted = -1021,
 kCFURLErrorFileDoesNotExist           = -1100,
 kCFURLErrorFileIsDirectory            = -1101,
 kCFURLErrorNoPermissionsToReadFile    = -1102,
 kCFURLErrorDataLengthExceedsMaximum   = -1103,
 
 */


typedef enum  {
    kObjectNotFound = 404,
    kUserNotAuthorized = 403,
    kInternalServerError = 500
} OstronautNetworkError;


#import "RestObject.h"

@implementation RestObject
@synthesize externalId;

+ (NSString *)processError:(NSError *)error for:(NSString *)name withMessageFromServer:(NSString *)message {
    NSString *publicMessage;
    if (error.code == -1004) {
        publicMessage = error.localizedDescription;
    } else {
        publicMessage = message;
    }
    [Flurry logError:name message:publicMessage error:error];
    return publicMessage;
}

+ (NSError *)customError:(NSError *)error withServerResponse:(NSHTTPURLResponse *)response andJson:(id)JSON {
    NSString *localizedDescription;
    switch (response.statusCode) {
        case kUserNotAuthorized:
            localizedDescription = NSLocalizedString(@"NOT_AUTHORIZED", @"signature incorrect");
            break;
        case kObjectNotFound:
            localizedDescription = NSLocalizedString(@"NOT_FOUND", @"resource not found");
            break;
        case kInternalServerError:
            localizedDescription = NSLocalizedString(@"FATAL_ERROR", @"interal exception");
            break;
        default:
            localizedDescription = [JSON objectForKey:@"message"];
            break;
    }
    NSMutableDictionary *details = [NSMutableDictionary dictionary];
    [details setValue:localizedDescription forKey:NSLocalizedDescriptionKey];
    // populate the error object with the details
    NSError *customError = [NSError errorWithDomain:@"Ostronaut" code:response.statusCode userInfo:details];
    [Flurry logError:@"REST_ERROR" message:[JSON objectForKey:@"message"] error:customError];
    return customError;
}
@end
