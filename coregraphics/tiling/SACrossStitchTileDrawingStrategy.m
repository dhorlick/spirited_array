//
//  SACrossStitchTileDrawingStrategy.m
//  spiritedarray
//
//  Created by Dave Horlick on 12/20/13.
//  Copyleft 2013 River Porpoise Software
//

#import "SACrossStitchTileDrawingStrategy.h"

@implementation SACrossStitchTileDrawingStrategy

-(void) drawX: (uint)x Y: (uint)y Color: (SAColorType) color Context:(CGContextRef)context Height:(uint)height
{
    CGRect rect = CGRectMake(0, 0.3*metapixelHeightInPixels, metapixelWidthInPixels, 0.4*metapixelHeightInPixels);
    float shortestSide;
    if (rect.size.width < rect.size.height)
        shortestSide = rect.size.width;
    else
        shortestSide = rect.size.height;
    
    CGPathRef roundedRectPath = [self newPathForRoundedRect:rect radius:shortestSide/2.1];
    
	[SATileDrawingStrategy setFillColorTo:color OnContext:context];
    
    float translateX = x*metapixelWidthInPixels;
    float translateY = (height-y-1)*metapixelHeightInPixels;
    // float rotateAngleInRadians = 3.1415926 / 4.0;
    
    CGContextTranslateCTM(context, translateX, translateY);
	// CGContextRotateCTM(context, rotateAngleInRadians);
    
    [SATileDrawingStrategy setFillColorTo:color OnContext:context];
   
    CGContextAddPath(context, roundedRectPath);
	CGContextFillPath(context);
    
    // CGContextRotateCTM(context, -rotateAngleInRadians);
    CGContextTranslateCTM(context, -translateX, -translateY);
    
	CGPathRelease(roundedRectPath);

}

/**
 * Thanks, http://www.cocoanetics.com/2010/02/drawing-rounded-rectangles/
 *
 * Note that if radius is larger than either of the input rectangle dimensions, the resulting shape will
 * not be renderable.
 */
- (CGPathRef) newPathForRoundedRect:(CGRect)rect radius:(CGFloat)radius
{
	CGMutablePathRef retPath = CGPathCreateMutable();
    
	CGRect innerRect = CGRectInset(rect, radius, radius);
    
	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;
    
	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;
    
	CGPathMoveToPoint(retPath, NULL, innerRect.origin.x, outside_top);
    
	CGPathAddLineToPoint(retPath, NULL, inside_right, outside_top);
	CGPathAddArcToPoint(retPath, NULL, outside_right, outside_top, outside_right, inside_top, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_right, inside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radius);
    
	CGPathAddLineToPoint(retPath, NULL, innerRect.origin.x, outside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_left, inside_top);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);
    
	CGPathCloseSubpath(retPath);
    
	return retPath;
}

@end
