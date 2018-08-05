//
//  SALightEmittingDiodeTileDrawingStrategy.m
//  spiritedarray
//
//  Created by Dave Horlick on 3/18/13.
//  Copyleft 2013 River Porpoise Software
//

#import "SALightEmittingDiodeTileDrawingStrategy.h"

@implementation SALightEmittingDiodeTileDrawingStrategy

-(id) init
{
    if (self = [super init])
	{
        centerGradientIntensityDelta = 0.10f;
        edgeGradientIntensityDelta = -0.22f;
    }
    
    return self;
}

-(void) setMetapixelWidthInPixels:(uint)designatedMetapixelWidthInPixels
{
    [super setMetapixelWidthInPixels: designatedMetapixelWidthInPixels];
    
    if (designatedMetapixelWidthInPixels>2)
        metapixelWidthInPixelsMinusAnyTrim = designatedMetapixelWidthInPixels - 2;
    else
        metapixelWidthInPixelsMinusAnyTrim = designatedMetapixelWidthInPixels;
}

-(void) setMetapixelHeightInPixels:(uint)designatedMetapixelHeightInPixels
{
    [super setMetapixelHeightInPixels:designatedMetapixelHeightInPixels];
    
    if (designatedMetapixelHeightInPixels>2)
        metapixelHeightInPixelsMinusAnyTrim = designatedMetapixelHeightInPixels - 2;
    else
        metapixelHeightInPixelsMinusAnyTrim = designatedMetapixelHeightInPixels;
}

-(void) drawX: (uint)x Y: (uint)y Color: (SAColorType) color Context:(CGContextRef)context Height:(uint)height
{
    CGRect metapixelRect = CGRectMake(x*metapixelWidthInPixels,
                                      (height-y-1)*metapixelHeightInPixels,
                                      metapixelWidthInPixels,
                                      metapixelHeightInPixels);
    
    CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 1.0f);
    
    CGContextFillRect(context, metapixelRect);
    
    CGRect diodeRect = CGRectMake(x*metapixelWidthInPixels,
                                  (height-y-1)*metapixelHeightInPixels,
                                  metapixelWidthInPixelsMinusAnyTrim,
                                  metapixelHeightInPixelsMinusAnyTrim);
    
    float red = color.Red/255.0f;
    float green = color.Green/255.0f;
    float blue = color.Blue/255.0f;
    
    float bottomRed = [SALightEmittingDiodeTileDrawingStrategy tweakFloatColor: red By: edgeGradientIntensityDelta];
    float bottomGreen = [SALightEmittingDiodeTileDrawingStrategy tweakFloatColor:green By: edgeGradientIntensityDelta];
    float bottomBlue = [SALightEmittingDiodeTileDrawingStrategy tweakFloatColor: blue By: edgeGradientIntensityDelta];
    
    float topRed = [SALightEmittingDiodeTileDrawingStrategy tweakFloatColor: red By: centerGradientIntensityDelta];
    float topGreen = [SALightEmittingDiodeTileDrawingStrategy tweakFloatColor:green By: centerGradientIntensityDelta];
    float topBlue = [SALightEmittingDiodeTileDrawingStrategy tweakFloatColor: blue By: centerGradientIntensityDelta];
    
    CGFloat colors [] = {
        topRed, topGreen, topBlue, 1.0,
        bottomRed, bottomGreen, bottomBlue, 1.0
    };
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
	CGColorSpaceRelease(baseSpace);
	baseSpace = NULL;
    
    CGContextSaveGState(context);
    CGContextAddEllipseInRect(context, diodeRect);
    CGContextClip(context);
    
    CGPoint center = CGPointMake(CGRectGetMidX(diodeRect), CGRectGetMidY(diodeRect));
    
    float radius = (float)metapixelHeightInPixelsMinusAnyTrim/2.0f;
            // TODO should we consider metapixelWidthInPixelsMinusAnyTrim here, too?
    CGContextDrawRadialGradient(context, gradient, CGPointMake(diodeRect.origin.x + diodeRect.size.width*0.35f, diodeRect.origin.y+ diodeRect.size.height*0.35f), 0, center, radius, 0);
	CGGradientRelease(gradient);
	gradient = NULL;
    
    CGContextRestoreGState(context);
    
    CGContextAddEllipseInRect(context, diodeRect);
    CGContextDrawPath(context, kCGPathStroke);
}

+(float) tweakFloatColor:(float)color By:(float)amount
{
    float sum = color + amount;
    
    if (sum<0.0f)
        return 0.0f;
    if (sum>1.0f)
        return 1.0f;
    
    return sum;
}

-(SAColorType) backgroundColor
{
    return [SpiritedArray black];
}

@end
