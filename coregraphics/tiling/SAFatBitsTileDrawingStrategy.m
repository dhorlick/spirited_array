//
//  SAFatBitsTileDrawingStrategy.m
//  spiritedarray
//
//  Created by Dave Horlick on 3/18/13.
//  Copyleft 2013 River Porpoise Software
//

#import "SAFatBitsTileDrawingStrategy.h"
#import "SpiritedArray.h"

@implementation SAFatBitsTileDrawingStrategy

static const SAColorType bluish = {237, 242, 255};

-(void) setMetapixelWidthInPixels:(uint)designatedMetapixelWidthInPixels
{
    [super setMetapixelWidthInPixels: designatedMetapixelWidthInPixels];
    
    if (designatedMetapixelWidthInPixels>1)
        metapixelWidthInPixelsMinusAnyTrim = designatedMetapixelWidthInPixels - 1;
    else
        metapixelWidthInPixelsMinusAnyTrim = 1;
}

-(void) setMetapixelHeightInPixels:(uint)designatedMetapixelHeightInPixels
{
    [super setMetapixelHeightInPixels:designatedMetapixelHeightInPixels];
    
    if (designatedMetapixelHeightInPixels>1)
        metapixelHeightInPixelsMinusAnyTrim = designatedMetapixelHeightInPixels - 1;
    else
        metapixelHeightInPixelsMinusAnyTrim = 1;
}

-(void) drawX: (uint)x Y: (uint)y Color: (SAColorType) color Context:(CGContextRef)context Height:(uint)height
{
    [SATileDrawingStrategy setFillColorTo:bluish OnContext:context];
    CGRect backgroundRect = CGRectMake(x*metapixelWidthInPixels,
                                       (height-y-1)*metapixelHeightInPixels,
                                       metapixelWidthInPixels,
                                       metapixelHeightInPixels);
    CGContextFillRect(context, backgroundRect);
    
    
    if (color.Red > 127U || color.Blue > 127U || color.Green > 127)
        CGContextSetRGBFillColor(context, 0.93f, 0.95f, 1.0f, 1.0f);
    else
        CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 1.0f);
    
    CGRect rect = CGRectMake(x*metapixelWidthInPixels,
                             (height-y-1)*metapixelHeightInPixels,
                             metapixelWidthInPixelsMinusAnyTrim,
                             metapixelHeightInPixelsMinusAnyTrim);
    
    CGContextFillRect(context, rect);
}

-(SAColorType) backgroundColor
{
    return bluish;
}

@end
