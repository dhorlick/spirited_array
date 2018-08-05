//
//  SpiritedArrayIterator.h
//  spiritedarray
//
//  Created by Dave Horlick on 10/29/12.
//  Copyleft 2012 River Porpoise Software
//

#import <Foundation/Foundation.h>
#import "SpiritedArray.h"

/**
 * Usage pattern: 
 *
 * while ([spiritedArrayIterator arrayHasAnotherFrame])
 * {
 *    [spiritedArrayIterator nextFrame];
 *     
 *    while ([spiritedArrayIterator imageHasAnotherRow])
 *    {
 *       [spiritedArrayIterator nextRow];
 *        
 *       while ([spiritedArrayIterator rowHasAnotherPixel])
 *       {
 *          SAPixelType pixel = [spiritedArrayIterator nextPixel];
 *          // TODO …
 *       }
 *    }
 * }
 */
@interface SpiritedArrayIterator : SAHyperPlane
{
    SpiritedArray* spiritedArray;
    int x;
    int y;
    int frame;
}

-(id)initWithSpiritedArray: (SpiritedArray*) designatedSpiritedArray;
-(BOOL)rowHasAnotherPixel;
-(SAColorType)nextPixel;
-(BOOL)imageHasAnotherRow;
-(void)nextRow;
-(BOOL)arrayHasAnotherFrame;
-(void)nextFrame;
-(uint) delayInCentisAfterFrame: (uint)frame;

- (void) close;
-(void)abandon;

@end
