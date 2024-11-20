//
//  SALinePrinterTileDrawingStrategy.m
//  spiritedarray
//
//  Created by Dave Horlick on 8/18/13.
//  Copyleft 2013 River Porpoise Software
//

#import "SALinePrinterTileDrawingStrategy.h"

@implementation SALinePrinterTileDrawingStrategy

-(id) initWithFontFamily:(NSString*)designatedFontFamily
{
    if (designatedFontFamily==nil)
    {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
               reason:[NSString stringWithFormat:@"No font family provided."] userInfo:nil];
    }
    
    if (self = [super init])
    {
        fontFamily = designatedFontFamily;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        char letter[] = " ";
        letter[1] = 0; // terminator
        
        NSMutableDictionary* charIndexArrayKeyedOnCount = [NSMutableDictionary new];
        NSMutableArray* counts = [NSMutableArray new];
        
        for (uint i=32U; i<127U; i++)
        {
            letter[0] = i;
            CGContextRef context = CGBitmapContextCreate(NULL, 14, 14, 8, 14, colorSpace, kCGImageAlphaNone);
            CGContextSelectFont(context, [fontFamily cStringUsingEncoding:NSASCIIStringEncoding], 14.0, kCGEncodingMacRoman); // TODO revisit
            
            CGContextSetGrayFillColor(context, 1.0f, 1.0f); // black
            CGContextSetGrayStrokeColor(context, 1.0f, 1.0f); // black
            CGContextShowTextAtPoint(context, 0, 0, letter, 1);
            
            unsigned char* data = CGBitmapContextGetData(context);
            double darkPixelCount = 0.0;
            
            // NSLog(@"%s --------", letter);
            
            if (data != NULL)
            {
                for (uint i=0U; i<14*14; i++)
                {
                    if (data[i]!=0U)
                    {
                        // NSLog(@"data[%u] = %u", i, data[i]);
                        darkPixelCount += ((double)data[i]/255.0);
                    }
                }
            }
            else
            {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                               reason:[NSString stringWithFormat:@"Insufficient memory to obtain bitmap data."] userInfo:nil];

            }
            
            // When finished, release the context
            CGContextRelease(context); 
            // Free image data memory for the context
            
            CGContextRelease(context);
            NSNumber* darkPixelCountAsObject = [NSNumber numberWithDouble:darkPixelCount];
            NSMutableArray* charIndexArray = [charIndexArrayKeyedOnCount objectForKey:darkPixelCountAsObject];
            if (charIndexArray==nil)
            {
                charIndexArray = [NSMutableArray new];
                [charIndexArrayKeyedOnCount setObject:charIndexArray forKey:darkPixelCountAsObject];
                [counts addObject:darkPixelCountAsObject];
            }
            
            [charIndexArray addObject:[NSString stringWithCString:letter encoding:NSASCIIStringEncoding]];
        }
        
        NSArray *sortedCounts = [counts sortedArrayUsingSelector: @selector(compare:)];
        
        palette = [NSMutableArray new];
        
        NSString* string = nil;
        
        for (uint i=0U; i<[sortedCounts count]; i++)
        {
            NSNumber* darkPixelCountAsObject = [sortedCounts objectAtIndex:i];
            NSMutableArray* charIndexArray = [charIndexArrayKeyedOnCount objectForKey:darkPixelCountAsObject];
            
            string = [charIndexArray objectAtIndex:0U]; // TODO pick character with biggest footprint?
            
            while ([palette count] <= [darkPixelCountAsObject unsignedCharValue])
            {
                [palette addObject:string];
            }
        }
        
        while ([palette count]<256U)
        {
            [palette addObject:string];
        }
        
        // NSLog(@"--> %@", palette);
        
        CGColorSpaceRelease(colorSpace);
    }
    
    return self;
}

-(void) drawX: (uint)x Y: (uint)y Color: (SAColorType) color Context:(CGContextRef)context Height:(uint)height
{
    CGContextSelectFont(context, [fontFamily cStringUsingEncoding:NSASCIIStringEncoding], 26.0, kCGEncodingMacRoman); // TODO revisit
    
    unsigned char whiteness = (color.Red + color.Green + color.Blue) / 3;
    unsigned char blackness = (255U-whiteness);
    
    // TODO scale brightness
    
    CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 1.0f);
    
    CGContextShowTextAtPoint(context, 0, 0, [[palette objectAtIndex:(uint)blackness] cStringUsingEncoding:NSASCIIStringEncoding], 1);
}

-(NSString*) fontFamily
{
    return fontFamily;
}

@end
