//
//  CoreGraphicsRGBADataBackedSpirtedArray.h
//  spiritedarray
//
//  Created by Dave Horlick on 9/15/13.
//  Copyleft 2013 River Porpoise Software
//

#import "SpiritedArray.h"

@interface CoreGraphicsRGBADataBackedSpiritedArray : SpiritedArray
{
    const UInt8 *pixelData;
}

-(id) initWithImage:(CGImageRef)cgImage;
-(id) initWithImageData:(unsigned char*) designatedPixelData Width:(uint)designatedWidth Height:(uint)designatedHeight;

@end
