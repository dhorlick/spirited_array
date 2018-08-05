//
//  StreamedH264Decoder.m
//  spiritedarray
//
//  Created by Dave Horlick on 2/5/14.
//  Copyleft 2014 River Porpoise Software. All rights reserved.
//

#import "StreamedH264Decoder.h"
#import <AVFoundation/AVFoundation.h>

@implementation StreamedH264Decoder

-(id) initWithFileNameToRead: (NSString*)fileName
{
	if (self = [super init])
	{
        ready = NO;
        NSURL* url = [NSURL fileURLWithPath: fileName];
        // NSError *error = nil;

        NSString* outputFileType = nil;
        BOOL quicktimeContainer = YES; // TODO look at file extension or whatever
        if (quicktimeContainer)
            outputFileType = AVFileTypeQuickTimeMovie;
        else
            outputFileType = AVFileTypeMPEG4;
        
        AVAsset* asset = [AVAsset assetWithURL:url];
        
        /*
        AVAssetReader* videoReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
        
        if (videoReader == nil)
        {
            // TODO throw something
        }
        */
        
        memorized = nil;
        
        NSLog(@"Async Time");
        
        [asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler:
         ^{
             // dispatch_async(dispatch_get_main_queue(),
             dispatch_sync(dispatch_get_main_queue(),
                ^{
                    AVAssetTrack * videoTrack = nil;
                    NSArray * tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
                    if ([tracks count] == 1)
                    {
                        videoTrack = [tracks objectAtIndex:0];
                        
                        NSError * error = nil;
                        
                        // _movieReader is a member variable
                        AVAssetReader* videoReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
                        if (error)
                        {
                            NSLog(error.localizedDescription);
                            // TODO throw something
                        }
                        
                        NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
                        NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
                        NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
                        
                        [videoReader addOutput:[AVAssetReaderTrackOutput 
                                                 assetReaderTrackOutputWithTrack:videoTrack 
                                                 outputSettings:videoSettings]];
                        [videoReader startReading];
                        
                        if (videoReader.status == AVAssetReaderStatusReading)
                        {
                            AVAssetReaderTrackOutput * output = [videoReader.outputs objectAtIndex:0];
                            
                            CMSampleBufferRef sampleBuffer = [output copyNextSampleBuffer];
                            if (sampleBuffer)
                            {
                                // frames = (uint) (sampleBuffer->duration).value;

                                // TODO throw exception if [asset duration].value > MAX_UINT
                                // frames = (uint)[asset duration].value;
                                    // TODO this isn't quite right; we want the *frames* count, not the duration
								self->frames = 1U;
                                
                                CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
                                
                                // Lock the image buffer
                                CVPixelBufferLockBaseAddress(imageBuffer,0);
                                
                                // Get information of the image
                                uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
                                size_t ulWidth = CVPixelBufferGetWidth(imageBuffer);
                                // TODO throw exception if ulWidth > MAX_UINT
								self->width = (uint) ulWidth;
                                size_t ulHeight = CVPixelBufferGetHeight(imageBuffer);
                                // TODO throw exception if ulHeight > MAX_UINT
								self->height = (uint) ulHeight;
                                
								if (self->memorized==nil)
                                {
									self->memorized = [[MemorizedSpiritedArray alloc] initWith:1U Width:self->width Height:self->height];
                                }
                                
                                //  Here's where you can process the buffer!
                                //  (your code goes here)
                                
                                uint i = 0U;
                                uint blackPixels = 0U;
                                
								for (uint y=0U; y<self->height; y++)
                                {
									for (uint x=0U; x<self->width; x++)
                                    {
                                        SAColorType color;
                                        uint ii = i * 3;
                                        color.Red = baseAddress[ii];
                                        color.Green = baseAddress[ii+1];
                                        color.Blue = baseAddress[ii+2];
										[self->memorized writePixelColorAtFrame: 0U X:x Y:y Color:color];
                                        i++;
                                        
                                        if (color.Red<20 && color.Green<20 && color.Blue<20)
                                            blackPixels++;
                                    }
                                }
                                
                                NSLog(@"blackPixels = %u", blackPixels);
                                
                                // Unlock the image buffer
                                CVPixelBufferUnlockBaseAddress(imageBuffer,0);
                                CFRelease(sampleBuffer);
                            }
                        }

                        NSLog([NSString stringWithFormat:@"OK, ready now."]);
						NSLog(@"frames = %u", self->frames);
						self->ready = YES;
                        [self _fireAndClearLoadListeners];
                    }
                });
         }];
        
        // thanks, http://www.7twenty7.com/blog/2010/11/video-processing-with-av-foundation
    }
    
    NSLog(@"Returning self…");
    
    return self;
}

- (void) _fireAndClearLoadListeners
{
    NSLog(@"Hello! ][");
}

- (uint) frames
{
    NSLog(@"Returning super frames %u", [super frames]);
    return [super frames];
}

- (SAColorType) pixelColorAtFrame:(uint)frame X:(uint)x Y:(uint)y
{
    NSLog(@"SHD frames = %u", frames);
    return [memorized pixelColorAtFrame:frame X:x Y:y];
}

- (void) writePixelColorAtFrame:(uint)frame X:(uint)x Y:(uint)y Color:(SAColorType)color
{
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (uint) delayInCentisAfterFrame: (uint)frame
{
    return 10;
}

- (BOOL) streamed
{
    return YES;
}

-(void) close
{
    if (memorized!=nil)
    {
        [memorized close];
    }
}

- (BOOL) ready
{
    return ready;
}

@end
