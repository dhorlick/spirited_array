//
//  SATileDrawingStrategy.h
//  spiritedarray
//
//  Created by Dave Horlick on 3/17/13.
//  Copyleft 2013 River Porpoise Software
//

#import <Foundation/Foundation.h>
#import "SpiritedArray.h"

@interface SATileDrawingStrategy : NSObject
{
    uint metapixelWidthInPixels;
    uint metapixelHeightInPixels;
}

-(uint) metapixelWidthInPixels;
-(uint) metapixelHeightInPixels;

-(void) setMetapixelWidthInPixels: (uint)designatedMetapixelWidthInPixels;
-(void) setMetapixelHeightInPixels: (uint)designatedMetapixelHeightInPixels;

/**
 * x and y are in the coordinate from of the input image, NOT the output image or view.
 */
-(void) drawX:(uint)x Y: (uint)y Color: (SAColorType) color Context:(CGContextRef)context Height:(uint)height;

-(SAColorType) backgroundColor;
+(void) setFillColorTo: (SAColorType) color OnContext: (CGContextRef) context;

@end
