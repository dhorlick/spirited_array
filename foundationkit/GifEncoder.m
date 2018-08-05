//
//  GifEncoder.m
//  spiritedarray
//
//  Created by Dave Horlick on 4/21/13.
//  Copyleft 2013 River Porpoise Software
//

#import "GifEncoder.h"
#import "gif_lib.h"
#import "SAMetapixelPalette.h"
#import "SAColorTree.h"
// #import <math.h>

@implementation GifEncoder

-(void) encode: (SpiritedArray*) designatedSpiritedArray FilePath: (NSString*)designatedFilePath
{
    GifFileType* gifFile = EGifOpenFileName([designatedFilePath UTF8String], 1);
    
    NSMutableSet* colors = [NSMutableSet new];
    
    for (uint frame=0U; frame < [designatedSpiritedArray frames]; frame++)
    {
        for (uint y=0U; y < [designatedSpiritedArray height]; y++)
        {
            for (uint x = 0U; x < [designatedSpiritedArray width]; x++)
            {
                SAColorType color = [designatedSpiritedArray pixelColorAtFrame:frame X:x Y:y];
                uint colorIndex = [SAMetapixelPalette indexFor: color];
                NSNumber* colorIndexAsObject = [NSNumber numberWithUnsignedInt: colorIndex];
                [colors addObject: colorIndexAsObject];
            }
        }
    }
    
    unsigned long colorCount = [colors count];
    // NSLog(@"colors = %@", colors);
    
    GifPixelType* rasterBits = nil;
    
    // if (colorCount>256U) // TODO uncomment
    /*
    {
        NSLog(@"Reducing colors from %lu via color tree…", colorCount);
        SAColorTree* tree = [[SAColorTree alloc] initWithSpiritedArray:designatedSpiritedArray Colors:256U];
        NSLog(@"Immediately after initialization, tree has %u colors.", [tree colors]);
        [tree reduceToColors: 256U];
        NSLog(@"reduced color tree to %u colors.", [tree colors]);
        
        GifColorType* gifColorTypeArray = (GifColorType*) malloc(256U*sizeof(GifColorType));
        
        // TODO populate gifColorTypeArray
        
        ColorMapObject* gifColorMap = MakeMapObject(256U, gifColorTypeArray);
        // TODO fill-out the color map with some kind of blank entries for unusued power-of-two cells?
        
        int putScreenDescResult = EGifPutScreenDesc(gifFile, [designatedSpiritedArray width], [designatedSpiritedArray height], 255U, 0, gifColorMap);
        if (putScreenDescResult == GIF_ERROR)
        {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Call to EGifPutScreenDesc returned %i.", putScreenDescResult] userInfo: nil];
        }
        
        NSLog(@"Wrote color table. Now indexing individual pixels…");
        
        rasterBits = (GifPixelType*) malloc ([designatedSpiritedArray width] * sizeof(GifPixelType));
        NSMutableArray *colorArray = [NSMutableArray new];
        
        for (uint f=0U; f<[designatedSpiritedArray frames]; f++)
        {
            NSLog(@"Frame #%u…",f);
            
            int putImageDescResult = EGifPutImageDesc(gifFile, 0, 0, [designatedSpiritedArray width], [designatedSpiritedArray height], 0, 0);
            // EGifPutExtensionFirst(gifFile);
            // EGifPutExtensionNext(gifFile);
            
            if (putImageDescResult == GIF_ERROR)
            {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Call to EGifPutImageDesc returned %i.", putImageDescResult] userInfo: nil];
            }
            
            for (uint y=0U; y<[designatedSpiritedArray height]; y++)
            {
                for (uint x=0U; x<[designatedSpiritedArray width]; x++)
                {
                    SAColorType originalColor = ([designatedSpiritedArray pixelColorAtFrame:f X:x Y:y]);
                    SAColorType reassignedColor = [tree assignColor: originalColor];
                    uint colorIndex = [SAMetapixelPalette indexFor:reassignedColor];
                    NSNumber* colorIndexAsObject = [NSNumber numberWithUnsignedInt: colorIndex];
                    
                    NSUInteger ordinalIndex;
                    
                    if ([colorArray containsObject:colorIndexAsObject])
                        ordinalIndex = [colorArray indexOfObject: colorIndexAsObject];
                    else
                    {
                        ordinalIndex = [colorArray count];
                        [colorArray addObject: colorIndexAsObject];
                    }
                    
                    rasterBits[x] = (uint) ordinalIndex;
                }
                
                EGifPutLine(gifFile, rasterBits, [designatedSpiritedArray width]);
            }
        }
        
        NSLog(@"…exported!");
    }
    else
    { */
        NSLog(@"NOT Reducing colors via color tree, there are only %lu", colorCount);
        
        GifColorType* gifColorTypeArray = (GifColorType*) malloc(colorCount*sizeof(GifColorType));
        
        NSEnumerator *enumerator = [colors objectEnumerator];
        NSNumber* element = nil;
        uint i=0U;
        
        while (element = [enumerator nextObject])
        {
            GifColorType color = [GifEncoder gifColorFor: [element unsignedIntValue]];
            gifColorTypeArray[i] = color;
            i++;
        }
        
        NSArray *colorArray = [colors allObjects];
        
        // double powerOfTwoColorCount = round(pow(ceil(log2((double)colorCount)), 2.0));
        unsigned long powerOfTwoColorCount = [GifEncoder lowestPowerOfTwoThatIsNotLessThan: colorCount];
        NSLog(@"powerOfTwoColorCount = %lu", powerOfTwoColorCount);
        
        ColorMapObject* gifColorMap = MakeMapObject((uint)powerOfTwoColorCount, gifColorTypeArray);
            // TODO fill-out the color map with some kind of blank entries for unusued power-of-two cells?
        
        int putScreenDescResult = EGifPutScreenDesc(gifFile, [designatedSpiritedArray width], [designatedSpiritedArray height], 255U, 0, gifColorMap);
        if (putScreenDescResult == GIF_ERROR)
        {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Call to EGifPutScreenDesc returned %i.", putScreenDescResult] userInfo: nil];
        }
        
        NSLog(@"Wrote color table. Now indexing individual pixels…");
        
        rasterBits = (GifPixelType*) malloc ([designatedSpiritedArray width] * sizeof(GifPixelType));
        
        for (uint f=0U; f<[designatedSpiritedArray frames]; f++)
        {
            NSLog(@"Frame #%u…",f);
            
            int putImageDescResult = EGifPutImageDesc(gifFile, 0, 0, [designatedSpiritedArray width], [designatedSpiritedArray height], 0, 0);
            // EGifPutExtensionFirst(gifFile);
            // EGifPutExtensionNext(gifFile);
            
            if (putImageDescResult == GIF_ERROR)
            {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Call to EGifPutImageDesc returned %i.", putImageDescResult] userInfo: nil];
            }
            
            for (uint y=0U; y<[designatedSpiritedArray height]; y++)
            {
                for (uint x=0U; x<[designatedSpiritedArray width]; x++)
                {
                    SAColorType color = ([designatedSpiritedArray pixelColorAtFrame:f X:x Y:y]);
                    uint colorIndex = [SAMetapixelPalette indexFor:color];
                    NSNumber* colorIndexAsObject = [NSNumber numberWithUnsignedInt: colorIndex];
                    NSUInteger ordinalIndex = [colorArray indexOfObject: colorIndexAsObject];
                    
                    rasterBits[x] = (uint) ordinalIndex;
                }
                
                EGifPutLine(gifFile, rasterBits, [designatedSpiritedArray width]);
            }
        }
        
        NSLog(@"OK, done");
    // }
    
    // TODO FreeMapObject(gifColorMap); ?
    EGifCloseFile(gifFile);
    
    free(rasterBits);
}

+(GifColorType) saColorTypeToGifColorType: (SAColorType) pixelColor
{
    GifColorType result;
    result.Red = pixelColor.Red;
    result.Green = pixelColor.Green;
    result.Blue = pixelColor.Blue;
    return result;
}

+(GifColorType) gifColorFor: (uint) index
{
    uint red = index / 65536U;
    uint leftover = index % 65536U;
    uint green = leftover / 256U;
    uint blue = leftover % 256U;
    GifColorType result = {red, green, blue};
    return result;
}

+(unsigned long) lowestPowerOfTwoThatIsNotLessThan: (unsigned long) value
{
    unsigned long result = 1;
    
    for (uint i=0; i<256; i++)
    {
        result = result * 2;
        
        if (value <= result)
            return result;
    }
    
    // This algorithm probably isn't going to get me a CS doctorate, but it works and it isn't that inefficient.
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Couldn't find result for: %lu", value] userInfo: nil];
}

@end
