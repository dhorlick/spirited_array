#import <Foundation/Foundation.h>
#import "StreamedGifDecoder.h"

#undef _GBA_OPTMEM

@implementation StreamedGifDecoder

-(id) initWithFileNameToRead: (NSString*)designatedFilePath
{
	if (self = [super init])
	{
		// NSLog (@"opening file…");
        respoolHandler = nil;
        frames = 0U;
		filePath = designatedFilePath;
		
		[self openIfNecessary];
		
		width = gifFile->SWidth;
		height = gifFile->SHeight;
        
        if (gifFile->SColorMap!=NULL)
            backgroundColorIndex = gifFile->SBackGroundColor;
        else
            backgroundColorIndex = -1;
        
        mustMaintainTwoDimensionalState = NO;
        twoDimensionalState = nil; // If the GIF includes transparency, we need to keep track of the screen in order to determine the colors of composited pixels
						
		BOOL finishedReading = false;
        delayInCentisAfterFrames = [[NSMutableArray alloc] init];
		
        int initTimeFramesCounter = 0;
        
		do
		{
			finishedReading = [self nextChunk: &initTimeFramesCounter];
			// NSLog(@"frames so far = %i", frames);
		}
		while (!finishedReading);
        
        frames = initTimeFramesCounter;
        // frames = 1; // TODO remove this
		
		// NSLog(@"gifFile->ImageCount = %i", gifFile->ImageCount);
        // NSLog(@"mustMaintainTwoDimensionalState? %@", mustMaintainTwoDimensionalState?@"yes":@"no");
        
        // NSLog(@"SColorResolution: %i", gifFile->SColorResolution);
        
        if (frames==0 && gifFile->ImageCount==1)
        {
            // degenerate, static image case.
            frames = 1;
        }
        
        // NSLog(@"frames after initialization = %u", frames);
		
        if (gifFile->Image.Interlace==0)
            interlaced = NO;
        else
            interlaced = YES;
        
		[self close];
        [self reset];
        
		// NSLog (@"returning self…");
	}
	
	return self;
}

- (SAColorType) pixelColorAtFrame:(uint)requestedFrameIndex X:(uint)requestedX Y:(uint)requestedY
{
    while (frameIndex < requestedFrameIndex || !readingImageData)
	{
        [self openIfNecessary];
        
        BOOL terminated = [self nextChunk: &frameIndex];
		if (terminated)
		{
			@throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:[NSString stringWithFormat:@"hit end of file without hitting requested pixel (%u, %u) of frame %u", requestedX, requestedY, requestedFrameIndex]
                                         userInfo:nil];
		}
	}
    
    if (((GifWord)requestedX < gifFile->Image.Left)
        || ((GifWord)requestedY < gifFile->Image.Top)
        || ((GifWord)requestedX >= gifFile->Image.Left + gifFile->Image.Width)
        || ((GifWord)requestedY >= gifFile->Image.Top + gifFile->Image.Height))
    {
        return [twoDimensionalState pixelColorAtFrame:0U X:requestedX Y:requestedY];
    }
    
    unsigned char colorIndex = [self colorTableIndexAtFrame:requestedFrameIndex X:requestedX Y:requestedY];
    
    if (disposalMethod==1 && colorIndex==transparentColorIndex)
    {
        return [twoDimensionalState pixelColorAtFrame:0U X:requestedX Y:requestedY];
    }
    
    SAColorType result = [self pixelColorForColorTableIndex:colorIndex];
    
    if (mustMaintainTwoDimensionalState)
    {
        [twoDimensionalState writePixelColorAtFrame:0U X:requestedX Y:requestedY Color:result];
    }
    
    return result;
}

- (SAColorType) pixelColorForColorTableIndex:(unsigned char) colorIndex
{
    if (transparentColorIndex>=0 && transparentColorIndex == colorIndex)
    {
        switch (disposalMethod)
        {
            case 1:
                // Really not appropriate to be calling the method, but we'll do our best to answer.
                break;
            default:
                if (backgroundColorIndex!=-1 && backgroundColorIndex!=colorIndex)
                    return [self pixelColorForColorTableIndex:backgroundColorIndex];

                // TODO else something helpful, but not sure what
                    
                break;
        }
    }
    
    ColorMapObject* colorMap;
    if (gifFile->Image.ColorMap!=NULL)
        colorMap = gifFile->Image.ColorMap;
    else if (gifFile->SColorMap!=NULL)
        colorMap = gifFile->SColorMap;
    else
    {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"No local color map defined for this image or global color map defined for this GIF file."
                                     userInfo:nil];
    }
    
    // if (colorIndex>pow(2,colorMap->ColorCount))
    if (colorIndex>colorMap->ColorCount)
    {
        /*
         @throw [NSException exceptionWithName:NSInternalInconsistencyException
         reason:[NSString stringWithFormat:@"Bad color index at (%u, %u) in frame %u. Color index is %u and color count is %u.",
         x, y, frameIndex, colorIndex, colorMap->ColorCount]
         userInfo:nil];
         */
        
        // NSLog(@">>> Nonsense colorIndex %u", colorIndex);
        
        SAColorType reply = { .Red = 0, .Green = 100, .Blue = 0 };
        return reply;
    }
    else
    {
        SAColorType reply = { .Red = colorMap->Colors[colorIndex].Red,
            .Green = colorMap->Colors[colorIndex].Green,
            .Blue = colorMap->Colors[colorIndex].Blue }; // TODO cache colors?
        return reply;
    }    
}

- (unsigned char) colorTableIndexAtFrame:(uint)requestedFrameIndex X:(uint)requestedX Y:(uint)requestedY
{
	// NSLog(@"REQUEST for (%u, %u) of frame %u", requestedX, requestedY, requestedFrameIndex);
    
    if (gifFile!=nil && requestedY>=gifFile->SHeight && requestedX>=gifFile->SWidth && frameIndex==frames)
	{
		// NSLog (@"Deallocating line, etc.");
		[self close];
	}
    
    if (requestedX==0 && lineWithinFrame>0 && lineWithinFrame % 50==0)
    {
        // NSLog(@"lineWithinFrame = %i", lineWithinFrame);
    }
    
    if ((frameIndex > requestedFrameIndex || (frameIndex==requestedFrameIndex && lineWithinFrame > requestedY)) && gifFile!=nil)
	{
		// need to respool GIF
		// NSLog (@"respooling GIF for REQUEST of (%u, %u) of frame %u when frameIndex = %u and lineWithinFrame = %u", requestedX, requestedY, requestedFrameIndex, frameIndex, lineWithinFrame);
		
		int errorCode;
		DGifCloseFile(gifFile, &errorCode);
		gifFile = nil;
		// NSLog (@"respooled");
        
        [self reset];
        
        if (respoolHandler != nil)
        {
            respoolHandler();
        }
	}
	
	[self openIfNecessary];
	
	// while (frameIndex > frame || y > lineWithinFrame || !readingImageData)
    while (frameIndex < requestedFrameIndex || !readingImageData || (lineWithinFrame < (requestedY-gifFile->Image.Top)))
	{	
		// NSLog(@"Still need frame %u and y %u", requestedY, requestedFrameIndex);
        
        BOOL terminated = [self nextChunk: &frameIndex];
		if (terminated)
		{
			@throw [NSException exceptionWithName:NSInternalInconsistencyException
					reason:[NSString stringWithFormat:@"hit end of file without hitting requested pixel (%u, %u) of frame %u", requestedX, requestedY, requestedFrameIndex]
					userInfo:nil];
		}
	}
    
    return rasterBits[requestedX-gifFile->Image.Left];
}

- (BOOL) nextChunk: (int*) framesEncountered
{
	// NSLog (@"Fast-forwarding. frameIndex = %i and lineWithinFrame = %i and readingImageData %d", frameIndex, lineWithinFrame, readingImageData);
	
	// NSLog(@"type = %i", (type));
	
    /* if (gifFile->Image.ColorMap!=NULL)
        NSLog(@"Hey! have local color table."); */
    
	if (readingImageData)
	{
		// iterate thru entire fricking pixel content
			// TODO is this really necessary?
		
		if (lineWithinFrame<gifFile->Image.Height-1)
		{
			// NSLog(@"y = %i", y);
			// NSLog(@"---> Gettin' a line…");
			
			if (DGifGetLine(gifFile, rasterBits, gifFile->Image.Width) == GIF_ERROR)
			{
				@throw [NSException exceptionWithName:NSInternalInconsistencyException
                                               reason:[NSString stringWithFormat:@"Could not load line of pixels at y=%i, framesEncountered=%d", lineWithinFrame, *framesEncountered]
						userInfo:nil];
			}
			
			lineWithinFrame++;
		}
		else
		{						
			// NSLog(@"lineWithinFrame %u matches or exceeds gifFile->SHeight %u", lineWithinFrame, gifFile->SHeight);
            lineWithinFrame = -1;
			readingImageData = false;
            disposalMethod = 0;
		}
	}
	else
	{
		GifRecordType type;
		GifByteType* extensionData;
		int extensionType;
        
        // NSLog(@"gifFile->ImageCount = %i", gifFile->ImageCount);
		
		if (DGifGetRecordType(gifFile, &type)==GIF_ERROR)
		{
			@throw [NSException exceptionWithName:NSInternalInconsistencyException
					reason:[NSString stringWithFormat:@"DGifGetRecordType returned a GIF_ERROR"]
					userInfo:nil];
		}
		
		switch (type)
		{
			case IMAGE_DESC_RECORD_TYPE:
				// NSLog(@"hit IMAGE_DESC_RECORD_TYPE");
				if (DGifGetImageDesc(gifFile)==GIF_ERROR) // TODO necessary?
                {
                    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                           reason:@"DGifGetImageDesc returned GIF_ERROR." userInfo:nil];
                }
                
                /* if (gifFile->Image.ColorMap!=NULL)
                    NSLog(@"*** Found local color table!");
                else
                    NSLog(@"*** Did NOT find local color table!"); */
				
                readingImageData = true;
                lineWithinFrame = -1;
                
                if ((*framesEncountered)==-1)
                {
                    (*framesEncountered) = 0;
                    // NSLog(@"Hey, there! Incremented framesEncountered from -1 to 0");
                }
                
                // read in first line of pixel data
                BOOL result = [self nextChunk: framesEncountered];
                
                /* if (framesEncountered!=NULL)
                    NSLog(@"Jerp! framesEncountered = %u", *framesEncountered); */
				
                return result;
			
			case EXTENSION_RECORD_TYPE:
                if (DGifGetExtension(gifFile, &extensionType, &extensionData) != GIF_ERROR) // TODO make sure this can't indicate something other than a frame (like a textual comment, etc.)
                {
                    // NSLog (@"extensionType = %X and bytesCount = %u", extensionType, bytesCount);

                    
                    if (extensionType == GRAPHICS_EXT_FUNC_CODE)
                    {
                        // NSLog(@"******************");
                        
                        unsigned char packedField = extensionData[1];
                        // NSLog(@"packedField = %X", packedField);
                        
                        //           *  *  *
                        //  1  2  3  4  5  6  7  8
                        //128 64 32 16  8  4  2  1
                        
                        // NSLog(@"disposal method in binary = %u %u %u", ((packedField & 16) == 16)?1:0, ((packedField & 8) == 8)?1:0, ((packedField & 4) == 4)?1:0);
                        
                        disposalMethod = (((packedField & 16) == 16)?4:0)
                                + (((packedField & 8) == 8)?2:0) 
                                + (((packedField & 4) == 4)?1:0);
                        // NSLog(@"disposal method = %u", disposalMethod);
                        
                        switch (disposalMethod)
                        {
                            case 0: /* No disposal specified. The decoder is
                                     not required to take any action. */
                                break;
                            case 1: /* Do not dispose. The graphic is to be left
                                     in place. */
                                mustMaintainTwoDimensionalState = YES;
                                break;
                            case 2: /* Restore to background color. The area used by the
                                     graphic must be restored to the background color. */
                                break;
                            case 3: /* Restore to previous. The decoder is required to
                                     restore the area overwritten by the graphic with
                                     what was there prior to rendering the graphic. 
                                     
                                     Rare. */
                                break;
                            default:
                                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"invalid disposal method %u", disposalMethod]
                                     userInfo:nil];

                        }
                        
                        // unsigned int userInput = packedField & 2;
                        // NSLog(@"userInput = %u", userInput);
                        
                        // bitN = packedField & 2^N;
                        
                        unsigned int transparency = packedField & 1; // TODO use BOOL, instead?
                        // NSLog(@"transparency = %u", transparency);
                        
                        /* if (transparency==1)
                            NSLog(@"transparent");
                        else
                            NSLog(@"opaque"); */
                        
                        unsigned int delayTimeInCentis = extensionData[2] + (256*extensionData[3]);
                        
                        // NSLog(@"delayTimeInCentis = %u", delayTimeInCentis);
                        // NSLog(@"delayInCentisAfterFrames = %@", delayInCentisAfterFrames);
                        
                        if (transparency)
                            transparentColorIndex = extensionData[4];
                        else
                            transparentColorIndex = -1;
                        
                        // NSLog(@"transparentColorIndex = %i", transparentColorIndex);
                        
                        if (framesEncountered != NULL)
                        {
                            (*framesEncountered)++; // This is either frames or the frameIndex, depending on whether we've intialized yet
                            
                            // NSLog(@"Incrementing framesEncountered! %i", *framesEncountered);
                            
                            if (frames==0U || [delayInCentisAfterFrames count] < frames)
                                [delayInCentisAfterFrames addObject:[NSNumber numberWithUnsignedInt: delayTimeInCentis]];
                            else
                            {
                                // NSLog(@"[delayInCentisAfterFrames count] = %lu and frames = %u", [delayInCentisAfterFrames count], frames);
                                [delayInCentisAfterFrames replaceObjectAtIndex:*framesEncountered withObject:[NSNumber numberWithUnsignedInt: delayTimeInCentis]];
                            }
                        }
                        
                        lineWithinFrame = 0;
                    }
                }
                else
                {
                    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                            reason:[NSString stringWithFormat:@"gifunlib reported an extension block but would not disclose it."]
                            userInfo:nil];
                }
                
                while (extensionData != NULL) 
                {
                    if (DGifGetExtensionNext(gifFile, &extensionData) == GIF_ERROR)
                    {
                        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                reason:[NSString stringWithFormat:@"gifunlib reported an extension block but would not describe it further."]
                                userInfo:nil];
                    }
                    
                    if (extensionData!=NULL)							
                    {
                        int i=0;
                        while (((void *)extensionData[i])!=NULL)
                        {
                            // NSLog(@"extensionData = %X", extensionData[i]);
                            i++;
                        }
                        
                        // NSLog(@"******************");
                        
                    }
                    /* else
                     	NSLog(@"*** burp ***"); */
                } // TODO necessary?
                
                break;
            case SCREEN_DESC_RECORD_TYPE:
                // No need to read; read "automatically called once a file is opened, and therefore usually need not be called explicitly."
                break;
            case TERMINATE_RECORD_TYPE:
                // NSLog(@"*** Terminated! ***");
                return TRUE;
            case UNDEFINED_RECORD_TYPE:
                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                    reason:[NSString stringWithFormat:@"gifunlib returned an error condition"]
                    userInfo:nil];
		}
	}
	
	return FALSE;
}

- (void) openIfNecessary
{
	if (gifFile == nil)
	{
		// NSLog (@"opening/re-opening GIF…");
		
		int errorCode;
		gifFile = DGifOpenFileName([filePath UTF8String], &errorCode);
		if (gifFile == (GifFileType *)NULL)
		{
			@throw [NSException exceptionWithName:NSInternalInconsistencyException
					reason:[NSString stringWithFormat: @"Couldn't open file %@: error code %i", filePath, errorCode]
					userInfo:nil];
		}
		
		frameIndex = -1;
		lineWithinFrame = 0; // TODO or is it -1 ?
		readingImageData = false;
		
		// NSLog (@"mallocing…");
		
		rasterBits = (unsigned char *) malloc (gifFile->SWidth * sizeof(GifPixelType));
		
		// NSLog (@"malloced");
		
		if (rasterBits == NULL)
		{
			@throw [NSException exceptionWithName:NSInternalInconsistencyException
					reason:@"Couldn't allocate memory to load GIF image."
					userInfo:nil];
		}
        
        if (gifFile->SColorMap!=NULL)
        {
            // NSLog(@"There is a global color table.");
            
        }
        else
        {
            // NSLog(@"There is NO global color table.");
        }
        
		// NSLog (@"GIF opened/re-opened.");
	}
}

- (void) close
{
	if (gifFile != nil) // TODO handle differently if open for writing
	{
		// NSLog (@"Closing GIF…");
		
		int errorCode;
		int result = DGifCloseFile(gifFile, &errorCode);
		if (result == D_GIF_ERR_CLOSE_FAILED)
		{
			@throw [NSException exceptionWithName:NSInternalInconsistencyException
										   reason:[NSString stringWithFormat:@"Could not close GIF file, error code: %i", errorCode]
							userInfo:nil];
		}
		
		readingImageData = false;
		lineWithinFrame = 0; // TODO or is it -1 ?
		frameIndex = -1;
		gifFile = nil;
		free(rasterBits);
        twoDimensionalState = nil;
	}
}

-(void) reset
{
    lineWithinFrame = 0; // TODO or is it -1 ?
    frameIndex = -1;
    transparentColorIndex = -1;
    disposalMethod = 0;
    
    if (mustMaintainTwoDimensionalState)
    {
        twoDimensionalState = [[MemorizedSpiritedArray alloc] initWith:1U Width:width Height:height];
    }
}

- (BOOL) streamed
{
    return YES;
}

- (void (^)(void)) respoolHandler
{
    return respoolHandler;
}

- (void) setRespoolHandler:(void (^)(void))designatedHandler NS_AVAILABLE_MAC(10_6)
{
    respoolHandler = designatedHandler;
}

-(BOOL) interlaced
{
    return interlaced;
}

- (MemorizedSpiritedArray*) unInterlace
{
    MemorizedSpiritedArray* result = [[MemorizedSpiritedArray alloc] initWith:frames Width:width Height:height];
    
    for (uint f=0U; f<frames; f++)
    {
        uint pass = 0U;
        uint rowTicker = 0U;
        
        for (uint y0=0U; y0<height; y0++)
        {
            int y1 = -1;
            
            switch (pass)
            {
                case 0U:
                    y1 = 8U * rowTicker;
                    
                    if (y1<height)
                    {
                        rowTicker++;
                        break;
                    }
                    else
                    {
                        pass++;
                        rowTicker = 0U;
                    }
                    
                    // NSLog(@"Passing thru from pass 0 to pass 1");
                    
                case 1U:
                    y1 = 4U + (8U * rowTicker);
                    
                    if (y1<height)
                    {
                        rowTicker++;
                        break;
                    }
                    else
                    {
                        pass++;
                        rowTicker = 0U;
                    }
                    
                    // NSLog(@"Passing thru from pass 1 to pass 2");
                    
                case 2U:
                    y1 = 2U + (4U * rowTicker);
                    
                    if (y1<height)
                    {
                        rowTicker++;
                        break;
                    }
                    else
                    {
                        pass++;
                        rowTicker = 0U;
                    }
                    
                    // NSLog(@"Passing thru from pass 2 to pass 3");
                    
                case 3U:
                    y1 = 1U + (2U * rowTicker);
                    
                    if (y1<height)
                    {
                        rowTicker++;
                        break;
                    }
                    else
                    {
                        pass++;
                        rowTicker = 0U;
                    }
                    
                    // NSLog(@"Passing thru from pass 3 to pass 4");
                    
                default:
                    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                           reason:[NSString stringWithFormat:@"Invalid pass #%u at y0=%u --> y1=%u", pass, y0, y1]
                         userInfo:nil];
                    
                    return result;
            }
            
            for (uint x=0U; x<width; x++)
            {
                [result writePixelColorAtFrame:f X:x Y:y1 Color:[self pixelColorAtFrame:f X:x Y:y0]];
            }
        }
    }
    
    return result;
}

- (uint) delayInCentisAfterFrame: (uint)frame
{
    NSNumber* delay = [delayInCentisAfterFrames objectAtIndex:frame];
    return [delay unsignedIntValue];
}

@end
