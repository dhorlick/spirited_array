//
//  SAGraphPaperTileDrawingStrategy.m
//  spiritedarray
//
//  Created by Dave Horlick on 9/15/13.
//  Copyleft 2013 River Porpoise Software
//

#import "SAGraphPaperTileDrawingStrategy.h"
#import "SpiritedArray.h"

@implementation SAGraphPaperTileDrawingStrategy

static const SAColorType graphPaperBlue = {100, 100, 255};

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
    [SATileDrawingStrategy setFillColorTo:graphPaperBlue OnContext:context];
    CGRect backgroundRect = CGRectMake(x*metapixelWidthInPixels,
                                       (height-y-1)*metapixelHeightInPixels,
                                       metapixelWidthInPixels,
                                       metapixelHeightInPixels);
    CGContextFillRect(context, backgroundRect);
    
    [SATileDrawingStrategy setFillColorTo:color OnContext:context];
    
    CGRect rect = CGRectMake(x*metapixelWidthInPixels,
                             (height-y-1)*metapixelHeightInPixels,
                             metapixelWidthInPixelsMinusAnyTrim,
                             metapixelHeightInPixelsMinusAnyTrim);
    
    CGContextFillRect(context, rect);
}

-(SAColorType) backgroundColor
{
    return [SpiritedArray white];
}

@end
