//
//  AppKitAwareSpirtedArrayFactory.m
//  spiritedarray
//
//  Created by Dave Horlick on 8/27/13.
//  Copyleft 2013 River Porpoise Software
//

#import "AppKitAwareSpiritedArrayFactory.h"
#import "CoreGraphicsImageDataBackedSpiritedArray.h"

@implementation AppKitAwareSpiritedArrayFactory

+(SpiritedArray *) build:(NSString *)imageFileName
{
	NSLog(@"imageFileName = %@", imageFileName);
	NSString* extension = [SpiritedArrayFactory fileExtension: imageFileName];
	NSLog(@"extension = %@", extension);
    // CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	if ([extension caseInsensitiveCompare: @"png"]==0)
	{
        /** ?
         UIImage *image = [UIImage imageNamed:@"image.png"];
         CGImageRef imageRef = [image CGImage];
         */
        
        NSImage* nsImage = [[NSImage alloc] initWithContentsOfFile:imageFileName];
        if (nsImage == nil)
        {
            @throw [NSException exceptionWithName:@"Can't open image file" reason:[NSString stringWithFormat:@"Attempt to open %@ returned nil.", imageFileName] userInfo: nil];
        }
        
        // CGContextRef context = CGBitmapContextCreate(NULL, 14, 14, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
        // [nsImage CGImageForProposedRect:nil context:context hints:nil];
        
        NSData *imageData = [nsImage TIFFRepresentation];
        
        return [[CoreGraphicsImageDataBackedSpiritedArray alloc] initWithImageData:(UInt8*)[imageData bytes] Width: [nsImage size].width Height:[nsImage size].height];
        
        // CFDataRef cfImageData = CFBridgingRetain(imageData);
        // CGImageSourceRef source = CGImageSourceCreateWithData(cfImageData, NULL);
        // CGImageRef maskRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
        
        // CGContextRelease(context);
        // CFRelease(cfImageData);
        // CFRelease(source);
        
        // TODO release imageData, somehow?
	}
	else
	{
		return [[AppKitAwareSpiritedArrayFactory superclass] build:imageFileName];
	}
}


@end
