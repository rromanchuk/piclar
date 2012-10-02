
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

+ (NSString *)getPlaceTypeWithTypeId:(int)typeId {
    NSString *type;
    switch (typeId) {
        case 0:
            type = NSLocalizedString(@"MYSTERY", nil);
            break;
        case 1:
            type = NSLocalizedString(@"HOTEL", nil);
            break;
        case 2:
            type = NSLocalizedString(@"RESTAURANT", nil);
            break;
        case 3:
            type = NSLocalizedString(@"ATTRACTION", nil);
            break;
        case 4:
            type = NSLocalizedString(@"ENTERTAINMENT", nil);
            break;
        default:
            type = NSLocalizedString(@"HOTEL", nil);
            break;
    }
    
    return type;
}


+ (BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

+ (void)print_free_memory:(NSString *)tag
{
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
        NSLog(@"Failed to fetch vm statistics");
    
    /* Stats in bytes */
    natural_t mem_used = (vm_stat.active_count +
                          vm_stat.inactive_count +
                          vm_stat.wire_count) * pagesize;
    natural_t mem_free = vm_stat.free_count * pagesize;
    natural_t mem_total = mem_used + mem_free;
       
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
    
    NSString *used = [formatter stringFromNumber:[NSNumber numberWithInteger:mem_used]];
    NSString *free = [formatter stringFromNumber:[NSNumber numberWithInteger:mem_free]];
    NSString *total = [formatter stringFromNumber:[NSNumber numberWithInteger:mem_total]];
    DLog(@"%@: used: %@ free: %@ total: %@", tag, used, free, total);
    
}


@end
