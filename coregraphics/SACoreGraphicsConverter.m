//
//  SACoreGraphicsConverter.m
//  spiritedarray
//
//  Created by Dave Horlick on 3/5/13.
//  Copyleft 2013 River Porpoise Software
//

#import "SACoreGraphicsConverter.h"
#import "SAMetapixelPalette.h"
#import "CoreGraphicsImageDataBackedSpiritedArray.h"
#import <Quartz/Quartz.h>

@implementation SACoreGraphicsConverter

+(CGImageRef) convertToCoreGraphicsImage: (SpiritedArray*)spiritedArray Frame: (uint) frame
{
    uint arrLength = [spiritedArray width] * [spiritedArray height] * 3;
    UInt8 pixelData[arrLength];
    
    // fill the raw pixel buffer with arbitrary gray color for test

    uint i=0;
    
    for (int y=0; y<[spiritedArray height]; y++)
    {
        for (int x=0; x<[spiritedArray width]; x++)
        {
            SAColorType color = [spiritedArray pixelColorAtFrame:frame X:x Y:y];
            // pixelData[i++] = [SAMetapixelPalette indexFor:color];
            pixelData[i++] = color.Red;
            pixelData[i++] = color.Green;
            pixelData[i++] = color.Blue;
        }
    }
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CFDataRef rgbData = CFDataCreate(NULL, pixelData, arrLength);
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(rgbData);
    
    CGImageRef rgbImageRef = CGImageCreate([spiritedArray width], [spiritedArray height], 8, 24, [spiritedArray width] * 3, colorspace, kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    
    CFRelease(rgbData);
    
    CGDataProviderRelease(provider);
    
    CGColorSpaceRelease(colorspace);
    
    return rgbImageRef;
}

/*
+(CoreGraphicsImageDataBackedSpiritedArray*) convertToMemorizedSpiritedArray:(CGImageRef)cgImage
{
    return [[CoreGraphicsImageDataBackedSpiritedArray alloc] initWithImage: cgImage];
}
*/

@end
