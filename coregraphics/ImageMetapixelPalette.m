//
//  ImageMetapixelPalette.m
//  spiritedarray
//
//  Created by Dave Horlick on 4/11/13.
//  Copyleft 2013 River Porpoise Software
//

#import "ImageMetapixelPalette.h"
#import "SAMetapixelPalette.h"

@implementation ImageMetapixelPalette

-(id)initWith: (SATileDrawingStrategy*) designatedTileDrawingStrategy
{
    self = [super init];
    if (self)
    {
        strategy = designatedTileDrawingStrategy;
        palette = [NSMutableDictionary new];
    }
    
    return self;
}

-(CGImageRef) metapixelForColor: (SAColorType) color
{
    uint colorIndex = [SAMetapixelPalette indexFor: color];
    NSNumber* key = [NSNumber numberWithUnsignedInt: colorIndex];
    NSValue* intermediateResult = [palette objectForKey:key];
    
    if (intermediateResult == nil)
    {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        size_t bitsPerComponent = 8;
        size_t bytesPerPixel    = 4;
        size_t bytesPerRow      = ([strategy metapixelWidthInPixels] * bitsPerComponent * bytesPerPixel + 7) / 8; // TODO why isn't this just 4 * width? To leave some kind of margin?
        CGContextRef context = CGBitmapContextCreate(NULL, [strategy metapixelWidthInPixels], [strategy metapixelHeightInPixels], bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        
        [strategy drawX:0U Y:0U Color:color Context:context Height:1U]; // TODO wrong
        CGImageRef imageRef = CGBitmapContextCreateImage(context);
        
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(context);
        
        intermediateResult = [NSValue valueWithBytes:&imageRef objCType:@encode(CGImageRef)];
        [palette setObject:intermediateResult forKey:key];
    }
    
    CGImageRef retrievedCGImageRef;
    [intermediateResult getValue:&retrievedCGImageRef];
    return retrievedCGImageRef;
}

-(SATileDrawingStrategy*) strategy
{
    return strategy;
}

-(NSUInteger) cachedMetapixelCount
{
    return [palette count];
}

@end
