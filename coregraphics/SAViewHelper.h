//
//  SAViewHelper.h
//  spiritedarray
//
//  Created by Dave Horlick on 3/10/13.
//  Copyleft 2013 River Porpoise Software
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "SpiritedArray.h"
#import "MemorizedSpiritedArray.h"
#import "SAMetapixelPalette.h"
#import "SATileDrawingStrategy.h"
#import "ImageMetapixelPalette.h"

@interface SAViewHelper : NSObject<CALayerDelegate, NSAnimationDelegate>
{
    NSString* spiritedArraySourceFilePath;
    SpiritedArray* content;
    SpiritedArray* tileContent;
    SAMetapixelPalette* scaledMetapixelPalette;
    SATileDrawingStrategy* tileDrawingStrategy;
    ImageMetapixelPalette* imageMetapixelPalette;
    uint desiredTileWidth;
    uint desiredTileHeight;
}

@property id bounded;
@property uint desiredTileWidth;
@property uint desiredTileHeight;
@property BOOL resizeTileWidthAndHeightTogether;
@property NSString* statusText;

-(id)initWith:(NSObject*)designatedBounded Path:(NSString*) designatedSpiritedArraySourceFilePath;

-(NSString*) spiritedArraySourceFilePath;
-(void) setSpiritedArraySourceFilePath: (NSString*)setSpiritedArraySourceFilePath;

-(void) clearCachedSpiritedArray;
-(void)drawRect:(NSRect)dirtyRect Context:(CGContextRef)context Frame: (uint)frame;
-(MemorizedSpiritedArray*) freeze;

-(SpiritedArray*) content;
-(SpiritedArray*) tileContent;
-(void) setTileDrawingStrategy: (SATileDrawingStrategy*) designatedTileDrawingStrategy;
-(SATileDrawingStrategy*) tileDrawingStrategy;

-(uint) frames;
-(NSRect) bounds;
-(uint) desiredTileWidth;
-(uint) desiredTileHeight;
-(void) regenerateStatusText;

@end
