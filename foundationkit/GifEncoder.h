//
//  GifEncoder.h
//  spiritedarray
//
//  Created by Dave Horlick on 4/21/13.
//  Copyleft 2013 River Porpoise Software
//

#import <Foundation/Foundation.h>
#import "SpiritedArray.h"

@interface GifEncoder : NSObject
{
}

/**
 * Attempts to encode and output the animation to a new GIF file.
 *
 * Returns the number of colors in the output palette. If it is greater than 256, conclude that the encoding failed.
 */
-(unsigned long) encode: (SpiritedArray*) designatedSpiritedArray FilePath: (NSString*)designatedFilePath;
// +(uint) countColorsInSpiritedArray: (SpiritedArray*) spiritedArray;
+(unsigned long) lowestPowerOfTwoThatIsNotLessThan: (unsigned long) value;

@end
