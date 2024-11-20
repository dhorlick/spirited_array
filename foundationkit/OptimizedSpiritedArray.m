//
//  OptimizedSpiritedArray.m
//  spiritedarray
//
//  Created by Dave Horlick on 11/12/12.
//  Copyleft 2012 River Porpoise Software
//

#import "OptimizedSpiritedArray.h"
#import "MemorizedSpiritedArray.h"

@implementation OptimizedSpiritedArray

- (id) initWith: (SpiritedArray*) designatedSpiritedArray
{
    self = [super init];
    if (self)
    {
        if ([designatedSpiritedArray streamed] && [designatedSpiritedArray width] * [designatedSpiritedArray height] < 500000)
        {
            // NSLog(@"Memorizing…");
            spiritedArray = [[MemorizedSpiritedArray alloc] initWithSpiritedArray:designatedSpiritedArray];
            // NSLog(@"Memorized.");
        }
        else
        {
            // NSLog(@"Proxying…");
            spiritedArray = designatedSpiritedArray;
        }
        
        width = [spiritedArray width];
        height = [spiritedArray height];
        frames = [spiritedArray frames];
    }
    
    return self;
}

- (SAColorType) pixelColorAtFrame:(uint)frame X:(uint)x Y:(uint)y
{
	return [spiritedArray pixelColorAtFrame:frame X:x Y:y];
}

- (void) close
{
    [spiritedArray close];
}

-(uint) delayInCentisAfterFrame:(uint)frame
{
    return [spiritedArray delayInCentisAfterFrame:frame];
}

@end
