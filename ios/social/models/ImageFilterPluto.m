//
//  ImageFilterPluto.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/7/12.
//
//

#import "ImageFilterPluto.h"
#import "GPUImagePicture.h"
#import "GPUImageLookupFilter.h"
@implementation ImageFilterPluto
- (id)init;
{
    if (!(self = [super init]))
    {
		return nil;
    }
    
    UIImage *image = [UIImage imageNamed:@"6-sepia.png"];
    NSAssert(image, @"To use GPUImageAmatorkaFilter you need to add lookup_amatorka.png from GPUImage/framework/Resources to your application bundle.");
    
    lookupImageSource = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
    
    [lookupImageSource addTarget:lookupFilter atTextureLocation:1];
    [lookupImageSource processImage];
    
    self.initialFilters = [NSArray arrayWithObjects:lookupFilter, nil];
    self.terminalFilter = lookupFilter;
    
    return self;
}


@end
