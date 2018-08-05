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

-(void) encode: (SpiritedArray*) designatedSpiritedArray FilePath: (NSString*)designatedFilePath;
// +(uint) countColorsInSpiritedArray: (SpiritedArray*) spiritedArray;
+(unsigned long) lowestPowerOfTwoThatIsNotLessThan: (unsigned long) value;

@end
