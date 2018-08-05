//
//  SAColorLinePrinterTileDrawingStrategy.m
//  spiritedarray
//
//  Created by Dave Horlick on 9/4/13.
//  Copyleft 2013 River Porpoise Software
//

#import "SAColorLinePrinterTileDrawingStrategy.h"

@implementation SAColorLinePrinterTileDrawingStrategy
-(void) drawX: (uint)x Y: (uint)y Color: (SAColorType) color Context:(CGContextRef)context Height:(uint)height
{
    CGContextSelectFont(context, [fontFamily cStringUsingEncoding:NSASCIIStringEncoding], 26.0, kCGEncodingMacRoman); // TODO revisit
    
    unsigned char whiteness = (color.Red + color.Green + color.Blue) / 3;
    unsigned char blackness = (255U-whiteness);
    
    CGContextSetRGBFillColor (context, color.Red/255.0f,
                              color.Green/255.0f,
                              color.Blue/255.0f,
                              1.0f);
    
    CGContextShowTextAtPoint(context, 0, 0, [[palette objectAtIndex:(uint)blackness] cStringUsingEncoding:NSASCIIStringEncoding], 1);
}
@end
