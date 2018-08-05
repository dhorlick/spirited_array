//
//  UnUpSampler.m
//  spiritedarray
//
//  Created by Dave Horlick on 10/27/12.
//  Copyleft 2012 River Porpoise Software
//

#import "UnUpSampler.h"
#import "SpiritedArray.h"

@implementation UnUpSampler

- (id) initWith: (SpiritedArray*) spiritedArray TargetWidth:(uint)designatedTargetWidth TargetHeight:(uint)designatedTargetHeight TileWidth:(uint)requestedTileWidth TileHeight:(uint)requestedTileHeight
{
    self = [super init];
    if (self)
    {
        NSLog(@"input [spiritedArray frames] = %u", [spiritedArray frames]);
        
        samplingType = UNDETERMINED;
        
        bool definitelyNotUnuped = NO;
        
        double spirtedArrayAspectRatio = (double)[spiritedArray height] / (double)[spiritedArray width];
        double targetAspectRatio = (double)designatedTargetHeight / (double)designatedTargetWidth;
        
        if (spirtedArrayAspectRatio>targetAspectRatio)
        {
            targetWidth = designatedTargetHeight / spirtedArrayAspectRatio;
            targetHeight = designatedTargetHeight;
        }
        else
        {
            targetWidth = designatedTargetWidth;
            targetHeight = spirtedArrayAspectRatio * designatedTargetWidth;
        }
        
        /* dumbedDownMemorizedSpiritedArray = [[MemorizedSpiritedArray alloc] initWith:[spiritedArrayIterator frames] Width: targetWidth/requestedTileWidth Height: targetHeight/requestedTileHeight]; */
                // we'll try to avoid doing any new anti-aliasing
        
        SAColorType previousPixel;
        uint candidateHorizontalRunLength = 0;
        uint currentHorizontalRunLength = 0;
        
        // TODO consider frames?
        
        for (uint y=0; y<[spiritedArray height] && samplingType==UNDETERMINED && !definitelyNotUnuped; y++)
        {
            currentHorizontalRunLength = 0;
            
            for (uint x=0; x<[spiritedArray width] && samplingType==UNDETERMINED && !definitelyNotUnuped; x++)
            {
                SAColorType pixel = [spiritedArray pixelColorAtFrame:0 X:x Y:y];
                                        
                if (x>0)
                {
                    if (SAEqualColorTypes(pixel, previousPixel))
                    {
                        if (currentHorizontalRunLength==0)
                            currentHorizontalRunLength = 2;
                        else
                            currentHorizontalRunLength++;
                    }
                    else
                    {
                        if (currentHorizontalRunLength > 1)
                        {
                            // if (candidateHorizontalRunLength%currentHorizontalRunLength==0)
                            if (candidateHorizontalRunLength==0 || currentHorizontalRunLength < candidateHorizontalRunLength) // TODO adjust this metric
                            {
                                // No reason as yet to suppose source image was not up-sampled
                                
                                if (candidateHorizontalRunLength==0 || currentHorizontalRunLength<candidateHorizontalRunLength)
                                {
                                    candidateHorizontalRunLength = currentHorizontalRunLength;
                                }
                            }
                            /* else
                            {
                                // source image was not up-sampled; pixel colors runs are not whole-number multiples of one another in size
                                NSLog(@"source image was not up-sampled; pixel colors runs are not whole-number multiples of one another in size. candidateHorizontalRunLength = %u, currentHorizontalRunLength = %u", candidateHorizontalRunLength, currentHorizontalRunLength);
                                
                                samplingType = DUMBED_DOWN;
                            } */
                        }
                        else
                        {
                            NSLog(@"currentHorizontalRunLength <= 1 at (%u,%u); Definitely not un-uped. candidateHorizontalRunLength was %u", x, y, candidateHorizontalRunLength);
                            NSLog(@"previous pixel=%@, pixel=%@", SADescribeColorType(previousPixel), SADescribeColorType(pixel));
                            definitelyNotUnuped = YES;
                        }
                        
                        currentHorizontalRunLength = 0;
                    }
                }
                
                previousPixel = pixel; // TODO This copies by value, right?
            }
            
            // NSLog(@"candidateHorizontalRunLength at horizontal line end = %u at y=%u", candidateHorizontalRunLength, y);
        }        
        
        uint currentVerticalRunLength = 0;
        uint candidateVerticalRunLength = 0;
        
        for (uint x=0; x<[spiritedArray width] && samplingType==UNDETERMINED && !definitelyNotUnuped; x++)
        {
            currentVerticalRunLength = 0;
            
            for (uint y=0; y<[spiritedArray height] && samplingType==UNDETERMINED && !definitelyNotUnuped; y++)
            {
                SAColorType pixel = [spiritedArray pixelColorAtFrame:0 X:x Y:y];
                
                if (y>0)
                {
                    if (SAEqualColorTypes(pixel, previousPixel))
                    {
                        if (currentVerticalRunLength==0)
                            currentVerticalRunLength = 2;
                        else
                            currentVerticalRunLength++;
                    }
                    else
                    {
                        if (currentVerticalRunLength > 1)
                        {
                            if (candidateVerticalRunLength==0 ||
                                currentVerticalRunLength < candidateVerticalRunLength)
                            {
                                // No reason as yet to suppose source image was not up-sampled
                                
                                if (candidateVerticalRunLength==0 || currentVerticalRunLength<candidateVerticalRunLength)
                                {
                                    candidateVerticalRunLength = currentVerticalRunLength;
                                }
                            }
                            /* else
                            {
                                // source image was not up-sampled
                                
                                NSLog(@"candidateVerticalRunLength==0 || currentVerticalRunLength mod candidateVerticalRunLength==0; Dumbed down.");
                                samplingType = DUMBED_DOWN;
                            } */
                        }
                        else
                        {
                            NSLog(@"current vertical run length <=1; Definitely not un-uped.");
                            definitelyNotUnuped = YES;
                        }
                        
                        currentVerticalRunLength = 0;
                    }
                }
                
                previousPixel = pixel;
            }
        }
        
        uint candidateWidth;
        if (candidateHorizontalRunLength!=0)
            candidateWidth = [spiritedArray width]/candidateHorizontalRunLength;
        uint candidateHeight;
        if (candidateVerticalRunLength!=0)
            candidateHeight = [spiritedArray height]/candidateVerticalRunLength;
        
        if (samplingType==UNDETERMINED && !definitelyNotUnuped)
        {
            if (candidateVerticalRunLength > 2 && candidateHorizontalRunLength > 2)
            {
                CGFloat pixelAspectRatio = (CGFloat)candidateVerticalRunLength / (CGFloat)candidateHorizontalRunLength;
                if (pixelAspectRatio > 0.8f && pixelAspectRatio < 1.25f)
                {
                    // make sure scaled-up candidate width & height would accomodate tile footprint
                    
                    if (candidateWidth*requestedTileWidth <= designatedTargetWidth && candidateHeight*requestedTileHeight <= designatedTargetHeight)
                    {
                        samplingType = UN_UP;
                    }
                }
                else
                {
                    NSLog(@"pixel aspect ratio outside parameter for un-up sampling, %f", pixelAspectRatio);
                }
            }
            else
            {
                NSLog(@"candidate run lengths incompatible with un-up sampling: %u/%u", candidateVerticalRunLength, candidateHorizontalRunLength);
            }
        }
        
        if (samplingType==UNDETERMINED)
        {
            if ([spiritedArray width]*requestedTileWidth <= targetWidth
                && [spiritedArray height]*requestedTileHeight <= targetHeight)
            {
                NSLog(@"No up-sampling detected, and no down-sampling is necessary.");
                samplingType = NONE;
            }
            else
            {
                NSLog(@"Dumbed-down");
                samplingType = DUMBED_DOWN;
            }
        }
        
        uint y2 = 0;
        uint x2 = 0;
        CGFloat scaleX, scaleY;
        
        switch (samplingType)
        {
            case UN_UP:
                NSLog(@"It's Un-up");
                content = [[MemorizedSpiritedArray alloc] initWith:[spiritedArray frames] Width:candidateWidth Height:candidateHeight];
                
                for (uint frame=0U; frame <[spiritedArray frames]; frame++)
                {
                    y2 = 0U;
                    
                    for (uint y=0U; y<[spiritedArray height] && y2<candidateHeight; y+=candidateVerticalRunLength)
                    {
                        x2 = 0U;
                        
                        for (uint x=0U; x<[spiritedArray width] && x2<candidateWidth; x+=candidateHorizontalRunLength)
                        {
                            SAColorType pixel = [spiritedArray pixelColorAtFrame:frame X:x Y:y];
                            [content writePixelColorAtFrame: frame X:x2 Y:y2 Color:pixel];
                            x2++;
                        }
                        
                        y2++;
                    }
                    
                    [((MemorizedSpiritedArray*)content) setDelayInCentisTo:[spiritedArray delayInCentisAfterFrame:frame] AfterFrame:frame];
                }
                
                break;
            
            case DUMBED_DOWN:
                NSLog(@"It's Dumbed-down.");
                content = [[MemorizedSpiritedArray alloc] initWith:[spiritedArray frames] Width:targetWidth/requestedTileWidth Height:targetHeight/requestedTileHeight];
                
                scaleX = (CGFloat)[content width] / (CGFloat)[spiritedArray width]; // should be < 1
                scaleY = (CGFloat)[content height] / (CGFloat)[spiritedArray height]; // should be < 1
                
                SAColorType unavailable; // TODO Make "white" a constant somewhere, preferrably wherever SAColorType is itself defined.
                
                unavailable.Red = 200; // TODO make this 255
                unavailable.Blue = 200; // TODO make this 255
                unavailable.Green = 255;
                
                NSLog(@"scaleX = %f, scaleY = %f",scaleX, scaleY);
                SAColorType pixel;
                
                for (uint frame=0U; frame <[spiritedArray frames]; frame++)
                {
                    for (uint y=0; y<[content height]; y++)
                    {
                        uint cumulativeRed, cumulativeGreen, cumulativeBlue;
                        uint pixels = 0;
                        
                        for (uint x=0; x<[content width]; x++)
                        {
                            cumulativeRed = 0U;
                            cumulativeGreen = 0U;
                            cumulativeBlue = 0U;

                            pixels = 0;
                            
                            // NSLog(@"v = [%u+1 -> %i]", previousY2, y2);
                            // NSLog(@"h = [%u+1 -> %i]", previousX2, x2);
                            
                            for (uint v=(CGFloat)(y)/scaleY; v<(CGFloat)(y+1)/scaleY && v<[spiritedArray height]; v++)
                            {
                                for (uint h=(CGFloat)(x)/scaleX; h<(CGFloat)(x+1)/scaleX && h<[spiritedArray width]; h++)
                                {
                                    SAColorType pixel = [spiritedArray pixelColorAtFrame:frame X:h Y:v];
                                    cumulativeRed += pixel.Red;
                                    cumulativeGreen += pixel.Green;
                                    cumulativeBlue += pixel.Blue;
                                    pixels++;                                }
                            }
                            
                            switch (pixels)
                            {
                                case 0:
                                    // TODO should this really happen?
                                    [content writePixelColorAtFrame:frame X:x Y:y Color:unavailable];
                                    break;
                                case 1:
                                    pixel.Red = (CGFloat)cumulativeRed;
                                    pixel.Green = (CGFloat)cumulativeGreen;
                                    pixel.Blue = (CGFloat)cumulativeBlue;
                                    [content writePixelColorAtFrame:frame X:x Y:y Color:pixel];
                                    break;
                                default:
                                    pixel.Red = (CGFloat)cumulativeRed/(CGFloat)pixels;
                                    pixel.Green = (CGFloat)cumulativeGreen/(CGFloat)pixels;
                                    pixel.Blue = (CGFloat)cumulativeBlue/(CGFloat)pixels;
                                    [content writePixelColorAtFrame:frame X:x Y:y Color:pixel];
                                    
                                    break;
                            }
                        }
                    }
                    
                    [((MemorizedSpiritedArray*)content) setDelayInCentisTo:[spiritedArray delayInCentisAfterFrame:frame] AfterFrame:frame];
                }
                
                break;
            
            case NONE:
                content = spiritedArray; // TODO copy?
                break;
                
            case UNDETERMINED:
            default:
                [NSException exceptionWithName:@"IllegalState" reason:@"bug" userInfo:nil];

        }
    }
    
    frames = [content frames];
    width = [content width];
    height = [content height];
    
    NSLog(@"UUS initialization complete. Frames = %u", frames);
    
    return self;
}

- (SAColorType) pixelColorAtFrame:(uint)frame X:(uint)x Y:(uint)y
{
	return [content pixelColorAtFrame:frame X:x Y:y];
}

- (SpiritedArray*) content
{
    return content;
}

- (SamplingType) samplingType
{
    return samplingType;
}

-(uint) delayInCentisAfterFrame:(uint)frame
{
    return [content delayInCentisAfterFrame:frame];
}

@end
