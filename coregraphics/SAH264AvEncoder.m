//
//  SAH264AvEncoder.m
//  spiritedarray
//
//  Created by Dave Horlick on 9/18/13.
//  Copyleft 2013 River Porpoise Software
//

#import "SAH264AvEncoder.h"
#import <AVFoundation/AVFoundation.h>
#import "SATileDrawingStrategy.h"
#import "SAMacroblockedBounded.h"
#import "SAConcreteBounded.h"

@implementation SAH264AvEncoder

-(void) encode:(NSString*)spiritedArraySourceFilePath TileDrawingStrategy:tileDrawingStrategy WidthInPixels:(uint)widthInPixels HeightInPixels:(uint)heightInPixels TileWidthInPixels:(uint)tileWidthInPixels TileHeightInPixels:(uint)tileHeightInPixels Url:(NSURL*)url QuicktimeContainer:(BOOL)quicktimeContainer
{
    // borrowed liberally from http://stackoverflow.com/questions/3741323/how-do-i-export-uiimage-array-as-a-movie/3742212#3742212 and http://www.codegod.com/AVAssetWriterInputPixelBufferAdaptor-use-to-append-QID1296437.aspx :
    
    NSRect rect;
    rect.origin.x    = 0;
    rect.origin.y    = 0;
    rect.size.width  = widthInPixels;
    rect.size.height = heightInPixels;
    
    SAConcreteBounded* concreteBounded = [[SAConcreteBounded alloc] initWith: rect];
    
    SAMacroblockedBounded* replacementBounded = [[SAMacroblockedBounded alloc] initWithBounded:concreteBounded AndMacroblockOfWidth:8U AndHeight:8U];
    NSLog(@"replacementBounded = %@", replacementBounded);
    
    SAViewHelper* h264ViewHelper = [[SAViewHelper alloc] initWith:replacementBounded Path:spiritedArraySourceFilePath];
    [h264ViewHelper setTileDrawingStrategy:tileDrawingStrategy];
    h264ViewHelper.desiredTileWidth = tileWidthInPixels;
    h264ViewHelper.desiredTileHeight = tileHeightInPixels;
    
    NSLog(@"newBounded = %@", [h264ViewHelper bounded]);
    NSLog(@"    (width=%f, height=%f)", [h264ViewHelper bounds].size.width, [h264ViewHelper bounds].size.height);
    
    // 1) Wire the writer:
    
    CGSize frameSize = {[h264ViewHelper bounds].size.width, [h264ViewHelper bounds].size.height};
    
    NSError *error = nil;
    
    NSString* outputFileType = nil;
    if (quicktimeContainer)
        outputFileType = AVFileTypeQuickTimeMovie;
    else
        outputFileType = AVFileTypeMPEG4;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL: url fileType:outputFileType error:&error];
    NSParameterAssert(videoWriter);
    if (!quicktimeContainer)
        videoWriter.shouldOptimizeForNetworkUse = YES;
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
								   AVVideoCodecTypeH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:frameSize.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:frameSize.height], AVVideoHeightKey,
                                   nil];
    AVAssetWriterInput* writerInput = [AVAssetWriterInput
                                       assetWriterInputWithMediaType:AVMediaTypeVideo
                                       outputSettings:videoSettings];
    
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    [videoWriter addInput:writerInput];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             [NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
    
    AVAssetWriterInputPixelBufferAdaptor* adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:options];
    
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel    = 4;
    size_t bytesPerRow      = frameSize.width * bytesPerPixel;
    
    __block int time = 0;
    __block uint frame = 0U;
    
    dispatch_queue_t assetWriterQueue = dispatch_queue_create("AssetWriterQueue", DISPATCH_QUEUE_SERIAL); // thanks, http://stackoverflow.com/questions/14121511/avassetwriter-sometimes-fails-with-status-avassetwriterstatusfailed-seems-rando
    
    [writerInput requestMediaDataWhenReadyOnQueue:assetWriterQueue usingBlock:^(void)
        {
            NSLog(@"    again, width=%f, height=%f", [h264ViewHelper bounds].size.width, [h264ViewHelper bounds].size.height);
            
            while ([writerInput isReadyForMoreMediaData])
            {
                // NSLog(@"encoding frame #%d", frame);
                CVPixelBufferRef pxbuffer = NULL;
                CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
                                                      frameSize.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                                      &pxbuffer); // Note that kCVPixelFormatType_32RGBA, which we use elsewhere, is not supported
                NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
                
                CVPixelBufferLockBaseAddress(pxbuffer, 0);
                void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
                NSParameterAssert(pxdata != NULL);
                
                CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width, frameSize.height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaNoneSkipFirst);
                
                [h264ViewHelper drawRect:CGRectMake(0, 0, frameSize.width, frameSize.height) Context:context Frame: frame];
                NSParameterAssert(context);
                CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
                
                CVPixelBufferRef buffer = (CVPixelBufferRef)pxbuffer;
                
                if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(time, 100)])
                {
                    @throw [NSException exceptionWithName:@"Can't appendPixelBuffer" reason:nil userInfo: nil];
                }
                
                time += [[h264ViewHelper content] delayInCentisAfterFrame:frame];
                frame++;
                
                if (frame >= [[h264ViewHelper content] frames])
                {
                    NSLog(@"our work is done here.");
                    [writerInput markAsFinished];
                    [videoWriter endSessionAtSourceTime:CMTimeMake(time,100)];
                    [videoWriter finishWriting];
                }
                
                // CGColorSpaceRelease(colorSpace); // see http://stackoverflow.com/questions/5269815/does-the-result-of-cgimagegetcolorspaceimage-have-to-be-released
                CGContextRelease(context);
            }
        }
    ];
}

@end
