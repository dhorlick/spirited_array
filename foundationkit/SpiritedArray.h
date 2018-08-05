#import <Foundation/Foundation.h>
#import "SAHyperPlane.h"

@class MemorizedSpiritedArray;

typedef unsigned char SAByteType;

typedef struct SAColorType {
    SAByteType Red, Green, Blue;
} SAColorType;

BOOL SAEqualColorTypes(SAColorType aColorType, SAColorType bColorType);

NSString* SADescribeColorType(SAColorType colorType);

SAColorType filterPixel(SAColorType originalPixel, SAColorType filter);

@interface SpiritedArray : SAHyperPlane
{
    
}

- (id) initWithFileNameToRead: (NSString*) fileName;
- (SAColorType) pixelColorAtFrame:(uint)frame X:(uint)x Y:(uint)y;
- (void) writePixelColorAtFrame:(uint)frame X:(uint)x Y:(uint)y Color:(SAColorType)color;
- (void) close;
- (BOOL) streamed;
- (MemorizedSpiritedArray *) fitCopyToWidth:(uint)width Height:(uint)height;
- (uint) delayInCentisAfterFrame: (uint)frame;
- (uint) averageDelayInCentisBetweenFrames;

+ (SAColorType) white;
+ (SAColorType) black;

@end

