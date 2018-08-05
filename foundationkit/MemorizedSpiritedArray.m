//
//  MemorizedSpiritedArray.m
//  spiritedarray
//
//  Created by Dave Horlick on 11/4/12.
//  Copyleft 2012 River Porpoise Software
//

#import "MemorizedSpiritedArray.h"
#import "SpiritedArrayIterator.h"

@implementation MemorizedSpiritedArray

- (id) init
{
    @throw [NSException exceptionWithName: @"UnsupportedOperation" reason:@"Please use one of the initWith methods, instead."
                          userInfo: nil];
    return nil;
}

- (id) initWith:(uint)designatedFrames Width:(uint) designatedWidth Height:(uint) designatedHeight
{
    if (self = [super init])
    {
        frames = designatedFrames;
        width = designatedWidth;
        height = designatedHeight;
        
        uint initFrame, initY;
        
        pixels = (SAColorType ***)malloc(frames * sizeof(SAColorType **));
        if (pixels==NULL) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Couldn't allocate memory for array dimension #1" userInfo:nil];
        }
        
        delayInCentisAfterFrames = [NSMutableArray arrayWithCapacity:designatedFrames];
        NSNumber* zero = [NSNumber numberWithUnsignedInt:0U];
        
        for (initFrame = 0; initFrame < frames; initFrame++)
        {
            pixels[initFrame] = (SAColorType **)malloc(height * sizeof(SAColorType *));
            if (pixels[initFrame]==NULL) {
                [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Couldn't allocate memory for array dimension #2" userInfo:nil];
            }
            
            for (initY = 0; initY < height; initY++)
            {
                pixels[initFrame][initY] = (SAColorType *)malloc(width * sizeof(SAColorType));
                if (pixels[initFrame][initY]==NULL) {
                    [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Couldn't allocate memory for array dimension #3" userInfo:nil];
                }

            }
            
            [delayInCentisAfterFrames addObject:zero];
        }
    }
    
    return self;
}

-(id) initWithSpiritedArrayIterator: (SpiritedArrayIterator*) spiritedArrayIterator
{
    id result = [self initWith: [spiritedArrayIterator frames] Width:[spiritedArrayIterator width] Height:[spiritedArrayIterator height]];
    
    int frame = 0;
    int x = 0;
    int y = 0;
    
    while ([spiritedArrayIterator arrayHasAnotherFrame])
    {
        x = 0;
        y = 0;
        
        [spiritedArrayIterator nextFrame];
        
        while ([spiritedArrayIterator imageHasAnotherRow])
        {
            x = 0;
            
            [spiritedArrayIterator nextRow];
            
            while ([spiritedArrayIterator rowHasAnotherPixel])
            {
                [self writePixelColorAtFrame:frame X:x Y:y Color:[spiritedArrayIterator nextPixel]];
                x++;
            }
            
            y++;
        }
        
        [delayInCentisAfterFrames replaceObjectAtIndex:frame withObject:[NSNumber numberWithUnsignedInt:[spiritedArrayIterator delayInCentisAfterFrame:frame]]];
        frame++;
    }
    
    [spiritedArrayIterator close];
    
    return result;
}

- (id) initWithSpiritedArray: (SpiritedArray*) spiritedArray
{
    // TODO transcribe inter-frame delays, somehow
    
    SpiritedArrayIterator* spiritedArrayIterator = [[SpiritedArrayIterator alloc] initWithSpiritedArray:spiritedArray];
    id result = [self initWithSpiritedArrayIterator:spiritedArrayIterator];
    
    return result;
}

- (SAColorType) pixelColorAtFrame:(uint)frame X:(uint)x Y:(uint)y
{
    return pixels[frame][y][x];
}

- (void) writePixelColorAtFrame:(uint)frame X:(uint)x Y:(uint)y Color:(SAColorType)color
{
    pixels[frame][y][x] = color;
}

- (uint) memoryFootprint
{
    return (3 * sizeof(uint)) // i.e. width, height, and frames
            + (sizeof(unsigned char) * [self pixels]);
}

- (void) dealloc
{
    uint initFrame, initY;
    
    for (initFrame = 0; initFrame < frames; initFrame++)
    {
        for (initY = 0; initY < height; initY++)
        {
            free(pixels[initFrame][initY]);
        }
        
        free(pixels[initFrame]);
    }
    
    free(pixels);
}

- (uint) delayInCentisAfterFrame: (uint)frame
{
    NSNumber* delay = [delayInCentisAfterFrames objectAtIndex:frame];
    return [delay unsignedIntValue];
}

- (void) setDelayInCentisTo: (uint)delayInCentis AfterFrame:(uint)frame
{
    while ([delayInCentisAfterFrames count] <= frame)
        [delayInCentisAfterFrames addObject:[NSNumber numberWithUnsignedInt:0U]];
        
    [delayInCentisAfterFrames replaceObjectAtIndex:frame withObject:[NSNumber numberWithUnsignedInt:delayInCentis]];
}

- (void )fillWithColor:(SAColorType)color
{
    for (uint frame=0U; frame<[self frames]; frame++)
    {
        for (uint y=0U; y<[self height]; y++)
        {
            for (uint x=0U; x<[self width]; x++)
            {
                [self writePixelColorAtFrame:frame X:x Y:y Color:color];
            }
        }
    }
}

@end
