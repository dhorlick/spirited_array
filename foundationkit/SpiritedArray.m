#import <Foundation/Foundation.h>
#import "SpiritedArray.h"
#import "StreamedGifDecoder.h"
#import "MemorizedSpiritedArray.h"

@implementation SpiritedArray

static const SAColorType WHITE = {255, 255, 255};
static const SAColorType BLACK = {0, 0, 0};

-(id) initWithFileNameToRead: (NSString*)fileName
{
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
			reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
			userInfo:nil];
}

- (SAColorType) pixelColorAtFrame:(uint)frame X:(uint)x Y:(uint)y
{
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
			reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
			userInfo:nil];
}

- (void) writePixelColorAtFrame:(uint)frame X:(uint)x Y:(uint)y Color:(SAColorType)color
{
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
			reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
			userInfo:nil];
}

- (uint) delayInCentisAfterFrame: (uint)frame
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
           reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
         userInfo:nil];
}

-(uint) averageDelayInCentisBetweenFrames
{
    if (frames==0U)
        return 0U;
    
    unsigned long total = 0UL;
    for (uint frame=0U; frame<frames; frame++)
    {
        // NSLog(@"delay --> %u", [self delayInCentisAfterFrame:frame]);
        total += [self delayInCentisAfterFrame:frame];
    }
    
    return (uint)(total / frames);
}

- (void) close
{
}

- (NSString *)description
{
	return [NSString stringWithFormat: @"[SpiritedArray width=%u height=%u frames=%u]", [self width], [self height], [self frames]];
}

- (BOOL) streamed
{
    return NO;
}

- (MemorizedSpiritedArray *) fitCopyToWidth:(uint)designatedWidth Height:(uint)designatedHeight
{
    MemorizedSpiritedArray* result = [[MemorizedSpiritedArray alloc] initWith:[self frames] Width:designatedWidth Height:designatedHeight ];

    float yFraction = (float) [self height] / (float) designatedHeight;
    float xFraction = (float) [self width] / (float) designatedWidth;

    for (uint frame=0; frame < [self frames]; frame++)
    {
        for (uint scaledY=0; scaledY < designatedHeight; scaledY++)
        {
            for (uint scaledX = 0; scaledX < designatedWidth; scaledX++)
            {
                uint red = 0U;
                uint green = 0U;
                uint blue = 0U;
                uint pixelCount = 0U;
                
                uint endY = (float)(scaledY+1U) * yFraction;
                
                for (uint y=(float)scaledY * yFraction; y < endY; y++)
                {
                    uint endX = (float)(scaledX+1U) * xFraction;
                    
                    for (uint x=(float)scaledX * xFraction; x < endX; x++)
                    {
                        SAColorType color = [self pixelColorAtFrame:frame X:x Y:y];
                        red += color.Red;
                        blue += color.Blue;
                        green += color.Green;
                        pixelCount++;
                    }
                }
                
                SAColorType scaledColor;
                
                if (pixelCount>0)
                {
                    scaledColor.Red=red/pixelCount;
                    scaledColor.Blue=blue/pixelCount;
                    scaledColor.Green=green/pixelCount;
                }
                else
                {
                    scaledColor.Red = 0;
                    scaledColor.Green = 255;
                    scaledColor.Blue = 0;
                    
                    // TODO investigate
                }
                
                [result writePixelColorAtFrame:frame X:scaledX Y:scaledY Color:scaledColor];
            }
        }
    }
    
    return result;
}

+(SAColorType) white
{
    return WHITE;
}

+(SAColorType) black
{
    return BLACK;
}

@end

/* int main(int argc, const char *argv[])
{
	if (argc<=1)
	{
		NSLog (@"usage: spiritedarray file.[gif|mpng|apng]");
		return -1;
	}
	else
	{
		printf("arg1 = %s\n", argv[1]);
		printf("arg0 = %s\n", argv[0]);
		NSString* imageFileName = [[NSString alloc] initWithUTF8String: argv[1]];
	
		SpiritedArray * spiritedArray = [SpiritedArray build: imageFileName];
		NSLog (@"Retrieving pixel color…");
		int pixelColor = [spiritedArray pixelColorAtFrame:0 X: 0 Y:0];
		NSLog (@"pixelColor = %i", pixelColor);
		return pixelColor;
	}
} */

BOOL SAEqualColorTypes(SAColorType aColorType, SAColorType bColorType)
{
    return (aColorType.Red==bColorType.Red
            && aColorType.Green==bColorType.Green
            && aColorType.Blue==bColorType.Blue);
}

NSString* SADescribeColorType(SAColorType colorType)
{
    return [NSString localizedStringWithFormat:@"SAColorType {Red = %u, Green = %u, Blue = %u}",
            colorType.Red, colorType.Green, colorType.Blue];
}

SAColorType filterPixel(SAColorType originalPixel, SAColorType filter)
{
    SAColorType reply = {
        .Red = originalPixel.Red > filter.Red ? filter.Red : originalPixel.Red,
        .Green = originalPixel.Green > filter.Green ? filter.Green : originalPixel.Green,
        .Blue = originalPixel.Blue > filter.Blue ? filter.Blue : originalPixel.Blue };
    
    return reply;
}


