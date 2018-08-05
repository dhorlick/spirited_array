#import <Foundation/Foundation.h>
#import "SpiritedArray.h"
#include "gif_lib.h"
#include "MemorizedSpiritedArray.h"

@interface StreamedGifDecoder : SpiritedArray
{
	NSString* filePath;

	/**
	 * nil if closed
	 * not nil if open
	 */
	GifFileType* gifFile;
	
	BOOL readingImageData;
	
	int lineWithinFrame;
	int frameIndex;
	unsigned char* rasterBits;
    void (^respoolHandler)(void);
    int transparentColorIndex;
    uint disposalMethod;
    int backgroundColorIndex;

    BOOL mustMaintainTwoDimensionalState;
    MemorizedSpiritedArray* twoDimensionalState;
    BOOL interlaced;
    NSMutableArray* delayInCentisAfterFrames;
}

/**
 * @param framesEncountered a pointer to an int with which to maintain a running tally, 
 * or NULL if you don't care
 * @return yes, if explicitly terminated
 */
- (BOOL) nextChunk: (int*) framesEncountered;
- (void (^)(void)) respoolHandler;
- (void) setRespoolHandler:(void (^)(void))designatedHandler NS_AVAILABLE_MAC(10_6);
- (unsigned char) colorTableIndexAtFrame:(uint)requestedFrameIndex X:(uint)requestedX Y:(uint)requestedY;
- (SAColorType) pixelColorForColorTableIndex:(unsigned char) colorIndex;
- (BOOL) interlaced;
- (MemorizedSpiritedArray*) unInterlace;

@end
