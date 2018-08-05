//
//  CoreGraphicsBackedSpiritedArray.h
//  spiritedarray
//
//  Created by Dave Horlick on 8/18/13.
//  Copyleft 2013 River Porpoise Software
//

#import "SpiritedArray.h"

/**
 * For handling TIFF's
 */
@interface CoreGraphicsImageDataBackedSpiritedArray : SpiritedArray
{
    const UInt8 *pixelData;
}

-(id) initWithImage:(CGImageRef)cgImage;
-(id) initWithImageData:(unsigned char*) designatedPixelData Width:(uint)designatedWidth Height:(uint)designatedHeight;

@end
