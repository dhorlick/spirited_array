//
//  SpirtedArrayFactory.m
//  spiritedarray
//
//  Created by Dave Horlick on 8/27/13.
//  Copyleft 2013 River Porpoise Software
//

#import "SpiritedArrayFactory.h"
#import "StreamedGifDecoder.h"

@implementation SpiritedArrayFactory

+(SpiritedArray *) build:(NSString *)imageFileName
{
	// NSLog(@"imageFileName = %@", imageFileName);
	NSString* extension = [SpiritedArrayFactory fileExtension: imageFileName];
	// NSLog(@"extension = %@", extension);
	
	if ([extension caseInsensitiveCompare: @"gif"]==0)
	{
		StreamedGifDecoder* streamedGifDecoder = [[StreamedGifDecoder alloc] initWithFileNameToRead: imageFileName];
        
        if (![streamedGifDecoder interlaced])
            return streamedGifDecoder;
        else
        {
            // NSLog(@"Boom, interlaced!");
            return [streamedGifDecoder unInterlace];
        }
	}
	else
	{
		@throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"Unrecognized file extension %@. For non-GIF file types, please consult AppKitAwareSpiritedArrayFactory, instead.", extension]
                                     userInfo:nil];
	}
}

+ (NSString*) fileExtension: (NSString*) string
{
	for (long i=[string length]-1; i>=0; i--)
	{
		unichar ch = [string characterAtIndex: i];
		
		if (ch=='.')
		{
			return [string substringFromIndex: i+1];
		}
	}
	
	return nil;
}

@end
