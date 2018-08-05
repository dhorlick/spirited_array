//
//  CoreGraphicsRGBADataBackedSpirtedArray.m
//  spiritedarray
//
//  Created by Dave Horlick on 9/15/13.
//  Copyleft 2013 River Porpoise Software
//

#import "CoreGraphicsRGBADataBackedSpiritedArray.h"

@implementation CoreGraphicsRGBADataBackedSpiritedArray
-(id) initWithImage:(CGImageRef)designatedCgImageRef
{
    if (self = [super init])
    {
        CFDataRef dataRef = CGDataProviderCopyData(CGImageGetDataProvider(designatedCgImageRef));
        pixelData = CFDataGetBytePtr(dataRef);
        frames = 1U;
        width = (uint)CGImageGetWidth(designatedCgImageRef);
        height = (uint)CGImageGetHeight(designatedCgImageRef);
    }
    
    return self;
}

-(id) initWithImageData:(unsigned char*) designatedPixelData Width:(uint)designatedWidth Height:(uint)designatedHeight
{
    if (self = [super init])
    {
        pixelData = designatedPixelData;
        frames = 1U;
        width = designatedWidth;
        height = designatedHeight;
    }
    
    return self;
}

- (SAColorType) pixelColorAtFrame:(uint)frame X:(uint)x Y:(uint)y
{
    if (frame!=0)
    {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"Frame index must be zero, it's %u", frame]
                                     userInfo:nil];
    }
    
    uint i = 4*(x + (y*width));
    UInt8 red = pixelData[i++];
    UInt8 green = pixelData[i++];
    UInt8 blue = pixelData[i++];
    // i++; // (alpha)
    SAColorType pixel = {red, green, blue};
    
    return pixel;
}

- (uint) delayInCentisAfterFrame: (uint)frame
{
    return 10L;
    // TODO rework the animation not to flip at all if there's only one frame
}

- (void) dealloc
{
    // if (pixelData)
    //     free((void*)pixelData);
    
    // TODO uncomment-out above?
}

@end
