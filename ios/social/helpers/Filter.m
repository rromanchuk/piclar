
#import "Filter.h"

@implementation Filter

@synthesize name, filter; 

-(id) initWithNameAndFilter:(NSString *)theName filter:(CIFilter *)theFilter
{
    self = [super init]; 
    
    self.name = theName; 
    self.filter = theFilter; 
    
    return self; 
}

@end