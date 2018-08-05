//
//  SAMetapixelPalette.m
//  spiritedarray
//
//  Created by Dave Horlick on 3/3/13.
//  Copyleft 2013 River Porpoise Software
//

#import "SpiritedArray.h"
#import "SAMetapixelPalette.h"

@implementation SAMetapixelPalette

-(id)initWith: (MemorizedSpiritedArray*) designatedMemorizedSpiritedArray
{
    if (self = [super init])
    {
        content = designatedMemorizedSpiritedArray;
        palette = [NSMutableDictionary new];
    }
    
    return self;
}

-(MemorizedSpiritedArray*) metapixelForColor: (SAColorType) color
{
    uint colorIndex = [SAMetapixelPalette indexFor: color];
    NSNumber* key = [NSNumber numberWithUnsignedInt: colorIndex];
    MemorizedSpiritedArray* result = [palette objectForKey:key];
    
    if (result == nil)
    {
        result = [self filterContent:color];
        [palette setObject:result forKey:key];
    }

    return result;
}

-(MemorizedSpiritedArray*) filterContent: (SAColorType) color
{
    MemorizedSpiritedArray* filtered = [[MemorizedSpiritedArray alloc] initWith:[content frames] Width:[content width] Height:[content height]]; // TODO transcribe frames accurately
    
    for (uint frame=0; frame < [content frames]; frame++)
    {
        for (uint y=0; y < [content height]; y++)
        {
            for (uint x = 0; x < [content width]; x++)
            {
                SAColorType subPixelColor = filterPixel([content pixelColorAtFrame:frame X:x Y:y], color);
                [filtered writePixelColorAtFrame:frame X:x Y:y Color:subPixelColor];
            }
        }
    }
    
    return filtered;
}

-(MemorizedSpiritedArray*) content
{
    return content;
}

+(uint) indexFor: (SAColorType) color
{
    uint result = (65536*color.Red)
            + (256*color.Green)
            + color.Blue;
    
    return result;
}

+(SAColorType) colorFor: (uint) index
{
    uint red = index / 65536U;
    uint leftover = index % 65536U;
    uint green = leftover / 256U;
    uint blue = leftover % 256U;
    SAColorType result = {red, green, blue};
    return result;
}

@end
