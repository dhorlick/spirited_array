//
//  SAViewHelper.m
//  spiritedarray
//
//  Created by Dave Horlick on 3/10/13.
//  Copyleft 2013 River Porpoise Software
//

#import "SAViewHelper.h"
#import "SpiritedArray.h"
#import "OptimizedSpiritedArray.h"
#import "UnUpSampler.h"
#import "SAMetapixelPalette.h"
#import "SACoreGraphicsConverter.h"
#import "SAFatBitsTileDrawingStrategy.h"
#import "SALightEmittingDiodeTileDrawingStrategy.h"
#import "AppKitAwareSpiritedArrayFactory.h"
#import "CoreGraphicsRGBADataBackedSpiritedArray.h"
#import <math.h>

@implementation SAViewHelper

-(id)init
{
    [NSException raise:@"Unsupported Operation Exception"
                format:@"Call initWith:designatedBounded, instead at %d", (int)__LINE__];
    
    return self;
}

-(id)initWith:(NSObject*)designatedBounded Path:(NSString*) designatedSpiritedArraySourceFilePath
{
    self = [super init];
    if (self)
    {
        if(![designatedBounded respondsToSelector:@selector(bounds)])
        {
            [NSException raise:@"MyDelegate Exception"
                        format:@"Parameter lacks a bounds selector at %d", (int)__LINE__];
        }
        
        _bounded = designatedBounded;
        self.resizeTileWidthAndHeightTogether = YES;
        
        [self setSpiritedArraySourceFilePath: designatedSpiritedArraySourceFilePath];
        self.desiredTileWidth = 20U;
        self.desiredTileHeight = 20U;
        [self obtainSpiritedArray];
        [self regenerateStatusText];
    }
    
    return self;
}

-(void)drawRect:(NSRect)dirtyRect Context:(CGContextRef)context Frame: (uint)frame
{
    // TODO do something with dirtyRect?
    
    SpiritedArray* spiritedArray = [self obtainSpiritedArray];
    
    if (spiritedArray == nil || [spiritedArray frames]==0)
    {
        // NSLog(@"NOT drawing GIF");
    }
    else
    {
        // NSLog(@"drawing GIF %u x %u frame #%u…", [spiritedArray width], [spiritedArray height], frame);
        
        if (tileDrawingStrategy!=nil)
        {
            SAColorType backgroundColor = [tileDrawingStrategy backgroundColor];
			CGContextSetRGBFillColor(context,
                                     backgroundColor.Red/255.0f,
                                     backgroundColor.Green/255.0f,
                                     backgroundColor.Blue/255.0f,
                                     1.0f);
			CGContextFillRect(context, [self bounds]);
        }
        else
        {
            if (scaledMetapixelPalette == nil
                || [[scaledMetapixelPalette content] width]!=self.desiredTileWidth
                || [[scaledMetapixelPalette content] height]!=self.desiredTileHeight)
            {
                // Resize the tile content
                
                NSLog(@"Resizing tile content cache…");
                scaledMetapixelPalette = [[SAMetapixelPalette alloc] initWith:[tileContent fitCopyToWidth:self.desiredTileWidth Height:desiredTileHeight]];
            }
        }
        
        if ([self bounds].size.width==0)
            [NSException raise:@"IllegalArgument" format:@"Bounds width is zero."];
        if ([self bounds].size.height==0)
            [NSException raise:@"IllegalArgument" format:@"Bounds height is zero."];
        
        float shiftX = ceilf(([self bounds].size.width - [spiritedArray width]*self.desiredTileWidth) / 2.0);
        float shiftY = ceilf(([self bounds].size.height - [spiritedArray height]*self.desiredTileHeight) / 2.0);
        // NSLog(@"shiftX=%f, shiftY=%f", shiftX, shiftY);
        CGContextTranslateCTM(context, shiftX, shiftY);
        
        for (int y=0; y<[spiritedArray height]; y++)
        {
            for (int x=0; x<[spiritedArray width]; x++)
            {
                SAColorType pixelColor = [spiritedArray pixelColorAtFrame:frame X:x Y:y];
                
                // if (tileContent==nil) // TODO or, if the Tile content won't fit                
                if (tileDrawingStrategy!=nil)
                {
                    // TODO refrain from caching CGImages for non-GIF images with enormous color palettes?
                    // [tileDrawingStrategy drawX:x Y:y Color:pixelColor Context:context Height:[spiritedArray height]];
                    
                    if (imageMetapixelPalette==nil
                        || [tileDrawingStrategy metapixelWidthInPixels]!=self.desiredTileWidth
                        || [tileDrawingStrategy metapixelHeightInPixels]!=self.desiredTileHeight)
                    {
                        [tileDrawingStrategy setMetapixelWidthInPixels:self.desiredTileWidth];
                        [tileDrawingStrategy setMetapixelHeightInPixels:self.desiredTileHeight];
                        imageMetapixelPalette = [[ImageMetapixelPalette alloc] initWith:tileDrawingStrategy];
                    }
                    
                    CGImageRef cgImageRef = [imageMetapixelPalette metapixelForColor:pixelColor];
                    CGContextDrawImage(context, CGRectMake(x*self.desiredTileWidth, ([spiritedArray height]-y)*self.desiredTileHeight, self.desiredTileWidth, self.desiredTileHeight), cgImageRef);
                }
                else
                {
                    MemorizedSpiritedArray* memoized = [scaledMetapixelPalette metapixelForColor: pixelColor];
                    
                    CGImageRef imageRef = [SACoreGraphicsConverter convertToCoreGraphicsImage: memoized Frame:frame]; // TODO manage these in a separate container
                    
                    CGRect rect = CGRectMake(x*desiredTileWidth,
                                             ([spiritedArray height]-y)*self.desiredTileHeight,
                                             [memoized width],
                                             [memoized height]);
                    
                    CGContextDrawImage(context, rect, imageRef);
                    CGImageRelease(imageRef);
                }
            }
        }
        
        CGContextTranslateCTM(context, -shiftX, -shiftY);
    }
}

-(NSString*) spiritedArraySourceFilePath
{
    return spiritedArraySourceFilePath;
}

-(void) setSpiritedArraySourceFilePath: (NSString*) designatedSpiritedArraySourceFilePath
{
    spiritedArraySourceFilePath = designatedSpiritedArraySourceFilePath;
}

-(SpiritedArray*)obtainSpiritedArray
{
    if (content==nil)
    {
        if (spiritedArraySourceFilePath!=nil)
        {
            // NSLog(@"generating spirited array…");
            SpiritedArray* spiritedArrayFromFile = [AppKitAwareSpiritedArrayFactory build:spiritedArraySourceFilePath]; // TODO Obtain the factory from a factory factory (sigh)
            OptimizedSpiritedArray* optimizedSpiritedArray = [[OptimizedSpiritedArray alloc] initWith:spiritedArrayFromFile];
                // TODO stop doing this… wasteful
            UnUpSampler* unUpSampler = [[UnUpSampler alloc] initWith: optimizedSpiritedArray TargetWidth:[self bounds].size.width TargetHeight:[self bounds].size.height TileWidth:desiredTileWidth TileHeight:desiredTileHeight];
            // TODO parameterize the tile bounds
            // TODO make sure view starts at the origin
            content = unUpSampler;
            
            tileContent = unUpSampler; // TODO get this from a separate input, instead
            [self regenerateStatusText];
            // [optimizedSpiritedArray close]; // TODO really safe?
        }
        else
        {
            return nil;
        }
    }
    
    return content;
}

-(uint)desiredTileWidth
{
    return desiredTileWidth;
}

-(void) setDesiredTileWidth:(uint)designatedDesiredTileWidth
{
    if (designatedDesiredTileWidth!=desiredTileWidth)
    {
        desiredTileWidth = designatedDesiredTileWidth;
        tileContent = nil;
        content = nil;
    }
    
    if (self.resizeTileWidthAndHeightTogether && designatedDesiredTileWidth!=desiredTileHeight)
    {
        self.desiredTileHeight = designatedDesiredTileWidth;
        tileContent = nil;
        content = nil;
    }
}

-(uint)desiredTileHeight
{
    return desiredTileHeight;
}

-(void) setDesiredTileHeight:(uint)designatedDesiredTileHeight
{
    if (designatedDesiredTileHeight!=desiredTileHeight)
    {
        desiredTileHeight = designatedDesiredTileHeight;
        tileContent = nil;
        content = nil;
    }
    
    if (self.resizeTileWidthAndHeightTogether && designatedDesiredTileHeight!=desiredTileWidth)
    {
        self.desiredTileWidth = designatedDesiredTileHeight;
        tileContent = nil;
        content = nil;
    }
}

-(void) clearCachedSpiritedArray
{
    if (content!=nil)
    {
        content = nil;
    }
}

-(NSRect) frame
{
	if (_bounded==nil)
	{
		[NSException raise:@"SAViewHelper Unitialized"
					format:@"_bounded property has not been configured at %d", (int)__LINE__];
	}
	
	return [_bounded frame];
}

-(NSRect) bounds
{
    if (_bounded==nil)
    {
        [NSException raise:@"SAViewHelper Unitialized"
                    format:@"_bounded property has not been configured at %d", (int)__LINE__];
    }
    
    return [_bounded bounds];
}

-(MemorizedSpiritedArray*) freeze
{
    NSRect bounds = [self bounds];
    MemorizedSpiritedArray* result = [[MemorizedSpiritedArray alloc] initWith:[content frames] Width:bounds.size.width Height:bounds.size.height];
        // TODO tighten-up framing here.
        // TODO also, not super-efficient to store entire thing in memory. Maybe do this (or optionally do this) via a SpiritedArrayIterator?
    
    if (tileDrawingStrategy!=nil)
        [result fillWithColor: [tileDrawingStrategy backgroundColor]];
    else
        [result fillWithColor: [SpiritedArray black]];

    SpiritedArray* spiritedArray = [self obtainSpiritedArray];
    
    for (uint f=0; f<[content frames]; f++)
    {
        // TODO center
        
        // TODO introduce SATileBlittingStrategies? Or would that perform badly for command line users providing their own tiles?
        
        for (int y=0; y<[spiritedArray height]; y++)
        {
            for (int x=0; x<[spiritedArray width]; x++)
            {
                SAColorType pixelColor = [spiritedArray pixelColorAtFrame:f X:x Y:y];
                
                if (tileDrawingStrategy!=nil)
                // if (tileContent==nil) // TODO or, if the Tile content won't fit
                {
                    if (imageMetapixelPalette==nil
                        || [tileDrawingStrategy metapixelWidthInPixels]!=desiredTileWidth
                        || [tileDrawingStrategy metapixelHeightInPixels]!=desiredTileHeight)
                    {
                        [tileDrawingStrategy setMetapixelWidthInPixels:desiredTileWidth];
                        [tileDrawingStrategy setMetapixelHeightInPixels:desiredTileHeight];
                        imageMetapixelPalette = [[ImageMetapixelPalette alloc] initWith:tileDrawingStrategy];
                    }
                    
                    CGImageRef cgImageRef = [imageMetapixelPalette metapixelForColor:pixelColor];
                    
                    // transcribe cgImageRef to memorized spirited array
                    CoreGraphicsRGBADataBackedSpiritedArray* metapixel = [[CoreGraphicsRGBADataBackedSpiritedArray alloc] initWithImage:cgImageRef];
                    
                    uint yy0 = y*desiredTileHeight;
                    uint xx0 = x*desiredTileWidth;
                    
                    for (int yy=yy0; yy<yy0+desiredTileHeight; yy++)
                    {
                        for (int xx=xx0; xx<xx0+desiredTileWidth; xx++)
                        {
                            [result writePixelColorAtFrame:f X:xx Y:yy Color:[metapixel pixelColorAtFrame:0 X:xx-xx0 Y:yy-yy0]];
                        }
                    }
                }
                else
                {
                    if (scaledMetapixelPalette == nil || [[scaledMetapixelPalette content] width]!=desiredTileWidth
                        || [[scaledMetapixelPalette content] height]!=desiredTileHeight)
                    {
                        // Resize the tile content
                        
                        // NSLog(@"Resizing tile content cache…");
                        scaledMetapixelPalette = [[SAMetapixelPalette alloc] initWith:[tileContent fitCopyToWidth:desiredTileWidth Height:desiredTileHeight]];
                    }
                    
                    MemorizedSpiritedArray* memoized = [scaledMetapixelPalette metapixelForColor: pixelColor];
                    
                    for (uint yyy=0; yyy < [memoized height]; yyy++)
                    {
                        for (uint xxx = 0; xxx < [memoized width]; xxx++)
                        {
                            SAColorType subPixelColor = [memoized pixelColorAtFrame:0 X:xxx Y:yyy];
                            
                            [result writePixelColorAtFrame:f X:(x*desiredTileWidth) + xxx Y:(y*desiredTileHeight) + yyy Color:subPixelColor];
                        }
                    }
                }
            }
        }
    }
    
    return result;
}

-(SpiritedArray*) content
{
    return content;
}

-(SpiritedArray*) tileContent
{
    return tileContent;
}

-(uint) frames
{
    return [content frames];
}

-(SATileDrawingStrategy*) tileDrawingStrategy
{
    return tileDrawingStrategy;
}

-(void) setTileDrawingStrategy:(SATileDrawingStrategy *)designatedTileDrawingStrategy
{
    tileDrawingStrategy = designatedTileDrawingStrategy;
}

-(void) regenerateStatusText
{
    NSString* stagedText = [NSString stringWithFormat:@"view=%u×%u, tile=%u×%u",
                       (uint)[self bounds].size.width, (uint)[self bounds].size.height,
                       desiredTileWidth, desiredTileHeight];
    
    if ([content frames]>1) // TODO try to ensure this isn't forcing unnecessary memorization
    {
        float rateInFpsTimes10000 = 100.0f/(float)[content averageDelayInCentisBetweenFrames];
        uint integerRateInFps = (uint)round(rateInFpsTimes10000);
        uint firstFourFractionalDigitsOfRateInFps = integerRateInFps % 10000U;
        
        bool uniformFrameRate = YES;
        for (uint i=1; uniformFrameRate && i<[content frames]; i++)
        {
            if ([content delayInCentisAfterFrame:i]!=[content delayInCentisAfterFrame:i-1])
                uniformFrameRate = NO;
        }
        
        stagedText = [stagedText stringByAppendingString: [NSString stringWithFormat:@", rate%@%u.%u f/s", uniformFrameRate?@"=":@"≈", integerRateInFps, firstFourFractionalDigitsOfRateInFps]];
        
        if ([content isKindOfClass:[UnUpSampler class]])
        {
            NSString* samplingTypeString = nil;
            
            UnUpSampler* unUpSampler = (UnUpSampler*) content;
            switch ([unUpSampler samplingType])
            {
                case UNDETERMINED:
                    samplingTypeString = @"?";
                    break;
                case UN_UP:
                    samplingTypeString = @"un-up";
                    break;
                case DUMBED_DOWN:
                    samplingTypeString = @"down";
                    break;
                case NONE:
                    samplingTypeString = @"none";
                    break;
                default:
                    @throw [NSException exceptionWithName:@"Unsupported option" reason:[NSString stringWithFormat:@"Unsupported sampling type: %i", [unUpSampler samplingType]] userInfo: nil];
            }
            
            stagedText = [stagedText stringByAppendingString:[NSString stringWithFormat:@", sampling=%@", samplingTypeString]];
        }
    }
    
    self.statusText = stagedText;
}

@end
