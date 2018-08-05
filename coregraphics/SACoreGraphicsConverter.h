//
//  SACoreGraphicsConverter.h
//  spiritedarray
//
//  Created by Dave Horlick on 3/5/13.
//  Copyleft 2013 River Porpoise Software
//

#import <Foundation/Foundation.h>
#import "MemorizedSpiritedArray.h"
#import "SpiritedArray.h"

@interface SACoreGraphicsConverter : NSObject

/**
 * You need to call CGImageRelease on returned images when done with them.
 */
+(CGImageRef) convertToCoreGraphicsImage: (SpiritedArray*)spiritedArray Frame: (uint) frame;

// +(void) transcribe: (CGImageRef)cgImage ToSpiritedArray:(SpiritedArray*)spiritedArray;

// +(MemorizedSpiritedArray*) convertToMemorizedSpiritedArray:(CGImageRef)cgImage;

@end
