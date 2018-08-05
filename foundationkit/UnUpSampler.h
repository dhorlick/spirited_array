//
//  UnUpSampler.h
//  spiritedarray
//
//  Reverses up-sampling or downsamples a spirited array iterator.
//
//  Created by Dave Horlick on 10/27/12.
//  Copyleft 2012 River Porpoise Software
//

#import "SpiritedArrayIterator.h"
#import "MemorizedSpiritedArray.h"

typedef enum {
    UNDETERMINED,
    UN_UP,
    DUMBED_DOWN,
    NONE
} SamplingType;

@interface UnUpSampler : SpiritedArray
{
    SpiritedArray* content;
    
    /**
     The sampling type performed by <em>this</em> sampler.
     */
    SamplingType samplingType;
    uint targetWidth;
    uint targetHeight;
}

- (id) initWith: (SpiritedArray*) spiritedArray TargetWidth:(uint)designatedTargetWidth TargetHeight:(uint)designatedTargetHeight TileWidth:(uint)requestedTileWidth TileHeight:(uint)requestedTileHeight;

- (SpiritedArray*) content;

- (SamplingType) samplingType;

@end
