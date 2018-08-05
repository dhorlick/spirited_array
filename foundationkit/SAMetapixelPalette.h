//
//  SAMetapixelPalette.h
//  spiritedarray
//
//  Created by Dave Horlick on 3/3/13.
//  Copyleft 2013 River Porpoise Software
//

#import <Foundation/Foundation.h>
#import "MemorizedSpiritedArray.h"

/**
 A memorized spirited array whose bitmap can be used as a tile for rendering other
 spirtied arrays.
 
 The palette dictionary contains color-filtered copies of the original tile content. They are outputed as Memorized Spirited Arrays.
 
 This is used to accomplish "meta" tiled drawing, as well as for user-specified animation tiles.
 */
@interface SAMetapixelPalette : NSObject
{
    MemorizedSpiritedArray* content;
    NSMutableDictionary* palette;
}

-(id)initWith: (MemorizedSpiritedArray*) designatedMemorizedSpiritedArray;
-(MemorizedSpiritedArray*) metapixelForColor: (SAColorType) color;
-(MemorizedSpiritedArray*) filterContent: (SAColorType) color;
-(MemorizedSpiritedArray*) content;

+(uint) indexFor: (SAColorType) color;
+(SAColorType) colorFor: (uint) index;

@end
