//
//  SAFrameWheelViewHelper.h
//  spiritedarray
//
//  Created by Dave Horlick on 4/15/13.
//  Copyleft 2013 River Porpoise Software
//

#import <Foundation/Foundation.h>
#import "SpiritedArray.h"

@interface SAFrameWheelViewHelper : NSObject
{
    SpiritedArray* spiritedArray;
    uint gapBetweenFramesInPixels;
}

-(uint) ringOuterWidthInPixels;
-(uint) ringInnerWidthInPixels;
-(uint) ringThickness;
-(double) startAngleInRadiansFor:(uint)frame;
-(double) endAngleInRadiansFor:(uint)frame;

/**
 * @return a zero-ordered frame index, or -1 if no frame was clicked in.
 */
-(uint) frameAtX:(uint)x Y:(uint) y;

-(void)drawRect:(NSRect)dirtyRect Context:(CGContextRef)context;

@end
