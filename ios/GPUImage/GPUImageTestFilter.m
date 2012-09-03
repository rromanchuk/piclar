//
//  GPUImageTestFilter.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/3/12.
//
//
#import "GPUImagePicture.h"
#import "GPUImageLookupFilter.h"

#import "GPUImageTestFilter.h"

@implementation GPUImageTestFilter

- (id)init;
{
    if (!(self = [super init]))
    {
		return nil;
    }
    
    UIImage *image = [UIImage imageNamed:@"sexy-time-fun-filter.png"];
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
