//
//  ImageMetapixelPalette.h
//  spiritedarray
//
//  Created by Dave Horlick on 4/11/13.
//  Copyleft 2013 River Porpoise Software
//

#import <Foundation/Foundation.h>
#import "SATileDrawingStrategy.h"

/**
 Used for managing a palette of tiles rendered for different colors based on
 the supplied Tile Drawing strategy. Outputs CGImageRef's.
 
 The content of these tiles is not animated.
 */
@interface ImageMetapixelPalette : NSObject
{
    SATileDrawingStrategy* strategy;
    NSMutableDictionary* palette;
}

-(id)initWith: (SATileDrawingStrategy*) designatedTileDrawingStrategy;
-(CGImageRef) metapixelForColor: (SAColorType) color;
-(SATileDrawingStrategy*) strategy;
-(NSUInteger)cachedMetapixelCount;

@end
