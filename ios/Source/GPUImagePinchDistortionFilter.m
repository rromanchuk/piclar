#import "GPUImagePinchDistortionFilter.h"

NSString *const kGPUImagePinchDistortionFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform highp vec2 center;
 uniform highp float radius;
 uniform highp float scale;
 
 void main()
 {
     highp vec2 textureCoordinateToUse = textureCoordinate;
     highp float dist = distance(center, textureCoordinate);
     textureCoordinateToUse -= center;
     if (dist < radius)
     {
         highp float percent = 1.0 + ((0.5 - dist) / 0.5) * scale;
         
         textureCoordinateToUse = textureCoordinateToUse * percent;
     }
     textureCoordinateToUse += center;
    
     gl_FragColor = texture2D(inputImageTexture, textureCoordinateToUse );
     
 }
);

@implementation GPUImagePinchDistortionFilter

@synthesize center = _center;
@synthesize radius = _radius;
@synthesize scale = _scale;

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImagePinchDistortionFragmentShaderString]))
    {
		return nil;
    }
    
    radiusUniform = [filterProgram uniformIndex:@"radius"];
    scaleUniform = [filterProgram uniformIndex:@"scale"];
    centerUniform = [filterProgram uniformIndex:@"center"];

    self.radius = 1.0;
    self.scale = 0.5;
    self.center = CGPointMake(0.5, 0.5);

    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex;
{
    [super setInputRotation:newInputRotation atIndex:textureIndex];
    [self setCenter:self.center];
}

- (void)setRadius:(CGFloat)newValue;
{
    _radius = newValue;
    
    [self setFloat:_radius forUniform:radiusUniform program:filterProgram];
}

- (void)setScale:(CGFloat)newValue;
{
    _scale = newValue;

    [self setFloat:_scale forUniform:scaleUniform program:filterProgram];
}

- (void)setCenter:(CGPoint)newValue;
{
    _center = newValue;
    
    CGPoint rotatedPoint = [self rotatedPoint:_center forRotation:inputRotation];
    [self setPoint:rotatedPoint forUniform:centerUniform program:filterProgram];
}

@end
