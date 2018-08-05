//
//  MemorizedSpiritedArray.h
//  spiritedarray
//
//  Created by Dave Horlick on 11/4/12.
//  Copyleft 2012 River Porpoise Software
//

#import "SpiritedArray.h"
#import "SpiritedArrayIterator.h"

@interface MemorizedSpiritedArray : SpiritedArray
{
    SAColorType*** pixels;
    NSMutableArray* delayInCentisAfterFrames;
}

- (id) initWith:(uint)designatedFrames Width:(uint) designatedWidth Height:(uint) designatedHeight;
- (id) initWithSpiritedArrayIterator: (SpiritedArrayIterator*) spiritedArrayIterator;
- (id) initWithSpiritedArray: (SpiritedArray*) spiritedArray;
- (void) setDelayInCentisTo: (uint)delayInCentis AfterFrame:(uint)frame;

- (uint) memoryFootprint;
- (void )fillWithColor:(SAColorType)color;

@end
