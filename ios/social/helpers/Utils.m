
#import "Utils.h"
#import <CommonCrypto/CommonDigest.h>

@implementation Utils

+ (void)alertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:title
                                 message:message
                                delegate:nil
                       cancelButtonTitle:@"OK"
                       otherButtonTitles:nil] show];
}

+ (NSString *)MD5:(NSString *)str
{
    const char *ptr = [str UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", md5Buffer[i]];
    
    return output;
}

+ (NSDate *)parseDate:(NSString *)date
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    f.dateFormat = @"dd-MM-yyyy'T'HH:mm:ss'Z'";
    return [f dateFromString:date];
}

+ (CGFloat)sizeForDevice:(CGFloat)size {
    // Take Retina display into account
    CGFloat scale = [[UIScreen mainScreen] scale];
    size *= scale;
    return size;
}

+ (UIImage *)getPlaceTypeImageWithTypeId:(int)typeId {
    UIImage *image;
    switch (typeId) {
        case 0:
            image = [UIImage imageNamed:@"type-mystery.png"];
            break;
        case 1:
            image = [UIImage imageNamed:@"type-hotel.png"];
            break;
        case 2:
            image = [UIImage imageNamed:@"type-food.png" ];
            break;
        case 3:
            image = [UIImage imageNamed:@"type-attraction.png" ];
            break;
        case 4:
            image = [UIImage imageNamed:@"type-entertainment.png" ];
            break;
        default:
            image = [UIImage imageNamed:@"type-mystery.png"];
            break;
    }
    
    return image;
}

@end
