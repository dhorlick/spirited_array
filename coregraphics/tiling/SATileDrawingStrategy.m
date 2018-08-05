//
//  SATileDrawingStrategy.m
//  spiritedarray
//
//  Created by Dave Horlick on 3/17/13.
//  Copyleft 2013 River Porpoise Software
//

#import "SATileDrawingStrategy.h"

@implementation SATileDrawingStrategy

-(void) setMetapixelWidthInPixels:(uint)designatedMetapixelWidthInPixels
{
    metapixelWidthInPixels = designatedMetapixelWidthInPixels;
}

-(void) setMetapixelHeightInPixels:(uint)designatedMetapixelHeightInPixels
{
    metapixelHeightInPixels = designatedMetapixelHeightInPixels;
}

-(void) drawX: (uint)x Y: (uint)y Color: (SAColorType) color Context:(CGContextRef)context Height:(uint)height
{
    [SATileDrawingStrategy setFillColorTo:color OnContext:context];
    
    CGRect rect = CGRectMake(x*metapixelWidthInPixels,
                             (height-y-1)*metapixelHeightInPixels,
                             metapixelWidthInPixels,
                             metapixelHeightInPixels);
    
    CGContextFillRect(context, rect);
}

-(uint) metapixelWidthInPixels
{
    return metapixelWidthInPixels;
}

-(uint) metapixelHeightInPixels
{
    return metapixelHeightInPixels;
}

-(SAColorType) backgroundColor
{
    return [SpiritedArray white];
}

+(void) setFillColorTo: (SAColorType) color OnContext: (CGContextRef) context
{
    CGContextSetRGBFillColor (context, color.Red/255.0f,
                              color.Green/255.0f,
                              color.Blue/255.0f,
                              1.0f);
}

@end
